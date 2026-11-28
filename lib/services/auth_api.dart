import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:asn1lib/asn1lib.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../biometric_sign_in.dart';
import 'auth_http_client.dart';

typedef _RawKeyPairData = ({
  String publicKey,
  String keyId,
  BigInt modulus,
  BigInt privateExponent,
  BigInt? p,
  BigInt? q,
});

_RawKeyPairData _generateSessionKeyPairInIsolate() {
  final random = Random.secure();
  final secureRandom = FortunaRandom()
    ..seed(KeyParameter(Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    )));
  final generator = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
      secureRandom,
    ));
  final pair = generator.generateKeyPair();
  final publicKey = pair.publicKey;
  final privateKey = pair.privateKey;
  final keyIdBytes = List<int>.generate(12, (_) => random.nextInt(256));
  final keyId = base64Url.encode(keyIdBytes).replaceAll('=', '');

  List<int> derLength(int length) {
    if (length < 0x80) return <int>[length];
    final bytes = <int>[];
    var remaining = length;
    while (remaining > 0) {
      bytes.insert(0, remaining & 0xff);
      remaining >>= 8;
    }
    return <int>[0x80 | bytes.length, ...bytes];
  }

  List<int> derValue(int tag, List<int> value) => <int>[
    tag,
    ...derLength(value.length),
    ...value,
  ];

  List<int> unsignedBigIntBytes(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    final bytes = <int>[
      for (var offset = 0; offset < hex.length; offset += 2)
        int.parse(hex.substring(offset, offset + 2), radix: 16),
    ];
    if (bytes.isEmpty) return <int>[0];
    if ((bytes.first & 0x80) != 0) bytes.insert(0, 0);
    return bytes;
  }

  final rsaPublicKey = derValue(0x30, <int>[
    ...derValue(0x02, unsignedBigIntBytes(publicKey.modulus!)),
    ...derValue(0x02, unsignedBigIntBytes(publicKey.exponent!)),
  ]);
  final rsaEncryptionAlgorithm = derValue(0x30, <int>[
    ...derValue(0x06, <int>[
      0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01,
    ]),
    ...derValue(0x05, const <int>[]),
  ]);
  final subjectPublicKeyInfo = derValue(0x30, <int>[
    ...rsaEncryptionAlgorithm,
    ...derValue(0x03, <int>[0, ...rsaPublicKey]),
  ]);

  return (
    publicKey: base64Encode(subjectPublicKeyInfo),
    keyId: keyId,
    modulus: privateKey.modulus!,
    privateExponent: privateKey.privateExponent!,
    p: privateKey.p,
    q: privateKey.q,
  );
}

/// API access for the client authentication endpoints.
/// Override API_BASE_URL with --dart-define for a different environment.
class AuthApi {
  AuthApi._();

  static final AuthApi instance = AuthApi._();
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _productionBaseUrl = 'https://client.hi5trader.com';
  static const _apiPrefix = String.fromEnvironment(
    'API_PREFIX',
    defaultValue: '/client/api/',
  );

  bool get isUsingLocalhost => false;

  void setUseLocalhost(bool useLocal) {
    // No-op: Localhost API is removed; app routes exclusively to client.hi5trader.com
  }

  Uri get baseUri => _baseUri;
  String get activeHost => _baseUri.host;

  final http.Client _client = createAuthHttpClient();
  http.Client? _testClient;
  http.Client get _httpClient => _testClient ?? _client;
  final Map<String, String> _cookies = <String, String>{};
  String? _accessToken;
  static const _accessTokenStorageKey = 'vtindex_client_access_token';
  String? _pushToken;
  static const _pushTokenStorageKey = 'vtindex_client_push_token';
  Future<void>? _restoreFuture;
  Future<Map<String, dynamic>>? _logoutFuture;
  bool _isLoggingOut = false;
  int _sessionGeneration = 0;
  final StreamController<int> _unauthorizedSessionController =
      StreamController<int>.broadcast();
  final Map<String, dynamic> _responseEncryptionPrivateKeys = <String, dynamic>{};
  ({String publicKey, String keyId, RSAPrivateKey privateKey})? _cachedSessionKeyPair;
  Future<({String publicKey, String keyId, RSAPrivateKey privateKey})>? _generatingSessionKeyPair;
  int _sessionKeyUseCount = 0;
  DateTime? _sessionKeyCreatedAt;

  /// Emits the HTTP status code (401 or 403) when an authenticated API call
  /// triggers an automatic session logout.
  Stream<int> get onUnauthorizedSession => _unauthorizedSessionController.stream;

  @visibleForTesting
  void setHttpClientForTesting(http.Client? client) {
    _testClient = client;
  }

  @visibleForTesting
  void setSessionForTesting({
    String? accessToken,
    Map<String, String>? cookies,
  }) {
    _sessionGeneration++;
    _accessToken = accessToken;
    _cookies.clear();
    if (cookies != null) {
      _cookies.addAll(cookies);
    }
    _restoreFuture = Future<void>.value();
  }

  @visibleForTesting
  Future<void> resetForTesting() async {
    _sessionGeneration++;
    _testClient = null;
    _isLoggingOut = false;
    _logoutFuture = null;
    _restoreFuture = null;
    _cachedSessionKeyPair = null;
    _generatingSessionKeyPair = null;
    _responseEncryptionPrivateKeys.clear();
    _cookies.clear();
    _accessToken = null;
    _pushToken = null;
  }

  static String _normalizeEndpointPath(String path) {
    final withoutQuery = path.split('?').first.trim();
    return withoutQuery.startsWith('/') ? withoutQuery.substring(1) : withoutQuery;
  }

  static bool _isUnauthorizedExemptPath(String path) {
    final normalized = _normalizeEndpointPath(path);
    return const <String>{
      'logout/',
      'login/',
      'login/encryption-challenge/',
      'verify-otp/',
      'resend-login-otp/',
      'login-otp-status/',
      'signup/',
      'send-signup-otp/',
      'verify-signup-otp/',
      'send-reset-otp/',
      'reset-password/confirm/',
      'security/captcha/config/',
      'pub/rsa_key/',
      'profile/security/verify-password/',
    }.contains(normalized);
  }

  Future<void> _handleUnauthorizedResponse(int? statusCode, String path) async {
    if (statusCode != 401 && statusCode != 403) return;
    if (_isLoggingOut || _isUnauthorizedExemptPath(path)) return;
    if (!_unauthorizedSessionController.isClosed) {
      _unauthorizedSessionController.add(statusCode!);
    }
    try {
      await logout();
    } catch (_) {
      // Local credentials are cleared by logout()'s finally block even when
      // the server logout call fails or returns an error status.
    }
  }

  bool get hasToken =>
      (_accessToken != null && _accessToken!.isNotEmpty) ||
      _cookies.containsKey('client_access_token') ||
      _cookies.containsKey('access_token') ||
      _cookies.containsKey('jwt_token');

  Future<void> restoreSession() {
    return _restoreFuture ??= _restoreStoredSession();
  }

  Future<void> _restoreStoredSession() async {
    // Warm up the session encryption key in the background isolate early so
    // network requests never freeze the main thread.
    unawaited(_getOrCreateResponseEncryptionKeyPair());
    try {
      final preferences = await SharedPreferences.getInstance();
      _accessToken ??= preferences.getString(_accessTokenStorageKey);
      _pushToken ??= preferences.getString(_pushTokenStorageKey);
    } catch (_) {
      // A missing local session is handled by the API's 401 response.
    }
  }

  Future<void> _persistAccessToken() async {
    final token = _accessToken;
    if (token == null || token.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenStorageKey, token);
  }

  static Uri _normalizeBaseUrl(String raw) {
    final configured = Uri.parse(raw);
    var path = configured.path;
    if (path.endsWith('/client') || path.endsWith('/client/')) {
      path = '${path.replaceFirst(RegExp(r'/$'), '')}/api/';
    } else if (!path.endsWith('/api') && !path.endsWith('/api/')) {
      final prefix = _apiPrefix.startsWith('/') ? _apiPrefix : '/$_apiPrefix';
      path = '${path == '/' ? '' : path}$prefix';
    }
    return configured.replace(path: path.endsWith('/') ? path : '$path/');
  }

  Uri get _productionBaseUri => _normalizeBaseUrl(_productionBaseUrl);

  Uri get _baseUri {
    if (_configuredBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(_configuredBaseUrl);
    }
    return _productionBaseUri;
  }

  Map<String, String> get _headers => _headersForUri(_baseUri);

  Map<String, String> _headersForUri(
    Uri uri, {
    bool includeSessionHeaders = true,
  }) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (includeSessionHeaders) {
      if (_cookies.isNotEmpty) {
        headers['Cookie'] = _cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; ');
      }
      if (_accessToken != null) headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Uri _uri(String path, {Uri? base}) {
    final cleanPath = path.startsWith('/api/')
        ? path.substring(5)
        : (path.startsWith('/') ? path.substring(1) : path);
    return (base ?? _baseUri).resolve(cleanPath);
  }

  Uri _rootApiUri(String path, {Uri? base}) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return (base ?? _baseUri).replace(path: '/api/').resolve(cleanPath);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool encryptProfileBody = false,
    bool useRootApi = false,
    bool includeSessionHeaders = true,
  }) async {
    final requestGeneration = _sessionGeneration;
    await restoreSession();
    final headers = _headersForUri(
      _baseUri,
      includeSessionHeaders: includeSessionHeaders,
    );
    final responseKeyPair = await _getOrCreateResponseEncryptionKeyPair();
    headers['X-Response-Encryption-Key'] = responseKeyPair.publicKey;

    Map<String, dynamic>? wireBody = body;
    if (body != null && encryptProfileBody) {
      // The server issues a short-lived, one-use key for every encrypted write.
      final requestKey = await requestProfileEncryptionKey();
      final keyId = _findString(requestKey, const ['key_id']);
      final pem = _findString(requestKey, const ['public_key']);
      if (keyId == null || pem == null) {
        _cleanupResponseKeyPair(responseKeyPair.keyId);
        throw const AuthApiException(
          'The server did not provide a profile encryption key.',
        );
      }

      const aadText = 'vtindex:profile-request:v1';
      final aad = Uint8List.fromList(utf8.encode(aadText));
      final aesKey = _randomBytes(32);
      final nonce = _randomBytes(12);
      final cipher = GCMBlockCipher(AESEngine())
        ..init(true, AEADParameters(KeyParameter(aesKey), 128, nonce, aad));
      final ciphertext = cipher.process(
        Uint8List.fromList(utf8.encode(jsonEncode(body))),
      );
      final wrappedKey = _rsaOaepSha256Encrypt(
        aesKey,
        pem,
        encodingParams: aad,
      );

      headers['X-Request-Encryption-Key-Id'] = keyId;
      headers['Content-Type'] = 'application/vnd.vtindex.encrypted+json';
      wireBody = <String, dynamic>{
        'encrypted': true,
        'version': 1,
        'algorithm': 'RSA-OAEP-256+A256GCM',
        'wrapped_key': base64Encode(wrappedKey),
        'nonce': base64Encode(nonce),
        'ciphertext': base64Encode(ciphertext),
      };
    } else if (body != null) {
      headers['Content-Type'] = 'application/json';
    }

    http.Response response;
    try {
      final request = http.Request(
        method,
        useRootApi ? _rootApiUri(path) : _uri(path),
      )..headers.addAll(headers);
      if (wireBody != null) request.body = jsonEncode(wireBody);
      final streamed = await _httpClient
          .send(request)
          .timeout(const Duration(seconds: 25));
      response = await http.Response.fromStream(streamed);
    } catch (error) {
      _cleanupResponseKeyPair(responseKeyPair.keyId);
      rethrow;
    }
    return _decodeAndValidateResponse(
      response,
      path,
      responseKeyPair.keyId,
      requestGeneration: requestGeneration,
      allowCookieTokenOverwrite: !includeSessionHeaders,
    );
  }

  Future<({String publicKey, String keyId})> _getOrCreateResponseEncryptionKeyPair() async {
    final now = DateTime.now();
    final cached = _cachedSessionKeyPair;
    if (cached != null) {
      final isExpired = _sessionKeyCreatedAt != null &&
          now.difference(_sessionKeyCreatedAt!).inMinutes > 30;
      if (_sessionKeyUseCount < 100 && !isExpired) {
        _sessionKeyUseCount++;
        return (publicKey: cached.publicKey, keyId: cached.keyId);
      }
      // Retain the retired key in the history ring buffer so any in-flight
      // responses can still be decrypted cleanly.
      _responseEncryptionPrivateKeys[cached.keyId] = (
        key: cached.privateKey,
        retiredAt: now,
      );
      _purgeExpiredPrivateKeys();
      _cachedSessionKeyPair = null;
    }
    final inProgress = _generatingSessionKeyPair;
    if (inProgress != null) {
      final pair = await inProgress;
      return (publicKey: pair.publicKey, keyId: pair.keyId);
    }

    final future = Isolate.run(_generateSessionKeyPairInIsolate);
    _generatingSessionKeyPair = future.then((data) {
      final pair = (
        publicKey: data.publicKey,
        keyId: data.keyId,
        privateKey: RSAPrivateKey(data.modulus, data.privateExponent, data.p, data.q),
      );
      _cachedSessionKeyPair = pair;
      _sessionKeyCreatedAt = DateTime.now();
      _sessionKeyUseCount = 1;
      return pair;
    });

    try {
      final pair = await _generatingSessionKeyPair!;
      return (publicKey: pair.publicKey, keyId: pair.keyId);
    } finally {
      _generatingSessionKeyPair = null;
    }
  }

  void _purgeExpiredPrivateKeys() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
    _responseEncryptionPrivateKeys.removeWhere((_, value) {
      if (value is ({RSAPrivateKey key, DateTime retiredAt})) {
        return value.retiredAt.isBefore(cutoff);
      }
      return false;
    });
  }

  static Future<dynamic> _decodeJsonBody(String body) async {
    if (body.isEmpty) return <String, dynamic>{};
    if (body.length > 50000) {
      return await Isolate.run(() => jsonDecode(body));
    }
    return jsonDecode(body);
  }

  void _cleanupResponseKeyPair(String keyId) {
    if (_cachedSessionKeyPair?.keyId != keyId) {
      final retired = _responseEncryptionPrivateKeys[keyId];
      if (retired is ({RSAPrivateKey key, DateTime retiredAt})) {
        if (DateTime.now().difference(retired.retiredAt).inMinutes > 5) {
          _responseEncryptionPrivateKeys.remove(keyId);
        }
      }
    }
  }

  dynamic _decryptResponseEnvelope(Map<String, dynamic> envelope, String keyId) {
    RSAPrivateKey? privateKey;
    if (_cachedSessionKeyPair?.keyId == keyId) {
      privateKey = _cachedSessionKeyPair!.privateKey;
    } else {
      final retired = _responseEncryptionPrivateKeys[keyId];
      if (retired is ({RSAPrivateKey key, DateTime retiredAt})) {
        privateKey = retired.key;
      }
    }
    if (privateKey is! RSAPrivateKey) {
      throw const AuthApiException('The encrypted server response could not be opened.');
    }
    final wrappedKey = base64Decode(envelope['wrapped_key'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final ciphertext = base64Decode(envelope['ciphertext'] as String);
    final rsa = OAEPEncoding.withSHA256(RSAEngine(), Uint8List.fromList(utf8.encode('vtindex:user-info:v1')))
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    final aesKey = rsa.process(wrappedKey);
    final gcm = GCMBlockCipher(AESEngine())
      ..init(false, AEADParameters(
        KeyParameter(aesKey),
        128,
        nonce,
        Uint8List.fromList(utf8.encode('vtindex:user-info:v1')),
      ));
    final plaintext = gcm.process(ciphertext);
    return jsonDecode(utf8.decode(plaintext));
  }

  Future<Map<String, dynamic>> _decodeAndValidateResponse(
    http.Response response,
    String path,
    String keyId, {
    required int requestGeneration,
    String invalidResponseMessage = 'The server returned an invalid response.',
    bool allowCookieTokenOverwrite = false,
  }) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _handleUnauthorizedResponse(response.statusCode, path);
    }
    dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : await _decodeJsonBody(response.body);
    } on FormatException {
      _cleanupResponseKeyPair(keyId);
      throw AuthApiException(
        invalidResponseMessage,
        statusCode: response.statusCode,
      );
    }
    dynamic responsePayload = decoded;
    if (decoded is Map && decoded['encrypted'] == true) {
      responsePayload = _decryptResponseEnvelope(
        decoded.cast<String, dynamic>(),
        keyId,
      );
    } else {
      _cleanupResponseKeyPair(keyId);
    }
    final data = responsePayload is Map<String, dynamic>
        ? responsePayload
        : <String, dynamic>{'data': responsePayload};
    await _validateResponseData(response, data, path);
    _captureSession(
      response,
      payload: data,
      requestGeneration: requestGeneration,
      allowCookieTokenOverwrite: allowCookieTokenOverwrite,
    );
    return data;
  }

  Future<void> _validateResponseData(
    http.Response response,
    Map<String, dynamic> data,
    String path,
  ) async {
    final apiCode = data['code'];
    final hasApiError = apiCode is num && (apiCode < 200 || apiCode >= 300);
    if (response.statusCode != 401 &&
        response.statusCode != 403 &&
        (apiCode == 401 || apiCode == 403)) {
      await _handleUnauthorizedResponse((apiCode as num).toInt(), path);
    }
    final errorVal = data['error'] ?? data['errors'];
    final hasErrorMessage = errorVal != null &&
        errorVal != false &&
        (errorVal is! String || errorVal.isNotEmpty) &&
        (errorVal is! List || errorVal.isNotEmpty) &&
        (errorVal is! Map || errorVal.isNotEmpty);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        hasApiError ||
        hasErrorMessage) {
      throw AuthApiException(
        _messageFrom(data),
        statusCode: response.statusCode,
        data: data,
      );
    }
  }

  void _captureSession(
    http.Response response, {
    Map<String, dynamic>? payload,
    required int requestGeneration,
    bool allowCookieTokenOverwrite = false,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) return;
    if (_isLoggingOut || requestGeneration != _sessionGeneration) return;
    final apiCode = payload?['code'];
    if (apiCode == 401 || apiCode == 403) return;

    final rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      for (final cookie in rawCookies.split(RegExp(r',(?=\s*[^;,]+=)'))) {
        final pair = cookie.split(';').first.trim().split('=');
        if (pair.length < 2) continue;
        if (pair[1].isEmpty || cookie.toLowerCase().contains('max-age=0')) {
          _cookies.remove(pair.first);
        } else {
          _cookies[pair.first] = pair.skip(1).join('=');
        }
      }
    }
    final decoded = payload ?? (response.body.isEmpty ? null : _tryDecode(response.body));
    String? capturedToken;
    if (decoded is Map) {
      final nested = decoded['data'];
      final token =
          decoded['access'] ??
          decoded['access_token'] ??
          decoded['token'] ??
          (nested is Map
              ? nested['access'] ?? nested['access_token'] ?? nested['token']
              : null);
      if (token is String && token.isNotEmpty) {
        capturedToken = token;
      }
    }
    if (capturedToken == null &&
        (_accessToken == null ||
            (allowCookieTokenOverwrite && rawCookies != null))) {
      final cookieToken = _cookies['client_access_token'] ??
          _cookies['access_token'] ??
          _cookies['jwt_token'];
      if (cookieToken != null && cookieToken.isNotEmpty) {
        capturedToken = cookieToken;
      }
    }
    if (capturedToken != null) {
      _accessToken = capturedToken;
      _sessionGeneration++;
      unawaited(_persistAccessToken());
    }
  }

  dynamic _tryDecode(String value) {
    try {
      return jsonDecode(value);
    } on FormatException {
      return null;
    }
  }

  String _messageFrom(Map<String, dynamic> data) {
    for (final key in const ['message', 'error', 'errors', 'detail', 'non_field_errors']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is List && value.isNotEmpty) return value.map((e) => e.toString()).join(' ');
      if (value is Map && value.isNotEmpty) {
        final messages = <String>[];
        for (final entry in value.entries) {
          final v = entry.value;
          if (v is List) {
            messages.add('${entry.key}: ${v.join(', ')}');
          } else if (v != null) {
            messages.add('${entry.key}: $v');
          }
        }
        if (messages.isNotEmpty) return messages.join('; ');
      }
    }
    // Handle Django REST Framework field validation errors: { "field_name": ["error_text"] }
    final fieldMessages = <String>[];
    for (final entry in data.entries) {
      if (['status', 'code', 'status_code', 'encrypted', 'success', 'data'].contains(entry.key)) continue;
      final v = entry.value;
      if (v is List && v.isNotEmpty) {
        fieldMessages.add('${entry.key}: ${v.join(', ')}');
      } else if (v is String && v.isNotEmpty) {
        fieldMessages.add('${entry.key}: $v');
      } else if (v is Map && v.isNotEmpty) {
        fieldMessages.add('${entry.key}: ${v.values.join(', ')}');
      }
    }
    if (fieldMessages.isNotEmpty) return fieldMessages.join('; ');

    return 'The request failed. Please try again.';
  }

  Future<Map<String, dynamic>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) {
    final query = Uri(queryParameters: {
      'limit': '$limit',
      'unread_only': unreadOnly ? 'true' : 'false',
    }).query;
    return _request('GET', 'notifications/?$query');
  }

  Future<Map<String, String>?> getNativePositionMonitorConfig(String accountId) async {
    await restoreSession();
    // The Android service runs in a separate process lifecycle and reads the
    // Flutter SharedPreferences JWT directly. Await persistence here: session
    // capture intentionally writes asynchronously, which could otherwise race
    // the foreground-service startup immediately after the user taps Track.
    final token = _accessToken;
    if (token == null || token.isEmpty) return null;
    await _persistAccessToken();

    final id = Uri.encodeComponent(accountId);
    final host = _headers['Host'];
    return <String, String>{
      'url': _uri('open-positions/$id/').toString(),
      if (host != null && host.isNotEmpty) 'host': host,
    };
  }

  /// Build a single background-monitor configuration for every owned trading account.
  /// Demo and live accounts are deliberately kept separate for portfolio P/L grouping.
  Future<Map<String, String>?> getNativePortfolioMonitorConfig() async {
    await restoreSession();
    final token = _accessToken;
    if (token == null || token.isEmpty) return null;
    await _persistAccessToken();

    final response = await getUserTradingAccounts(fresh: true);
    final rows = response['accounts'];
    final accounts = <Map<String, dynamic>>[];
    if (rows is List) {
      for (final raw in rows.whereType<Map>()) {
        final item = raw.cast<String, dynamic>();
        final accountId = (item['account_id'] ?? '').toString().trim();
        if (accountId.isEmpty) continue;
        final accountType = (item['account_type'] ?? '').toString().toLowerCase();
        final isDemo = item['is_demo'] == true || accountType == 'demo';
        accounts.add(<String, dynamic>{
          'accountId': accountId,
          'accountName': (item['account_name'] ?? 'Trading account').toString(),
          'isDemo': isDemo,
          'url': _uri('open-positions/${Uri.encodeComponent(accountId)}/').toString(),
        });
      }
    }
    if (accounts.isEmpty) return null;
    final host = _headers['Host'];
    return <String, String>{
      'accountsJson': jsonEncode(accounts),
      if (host != null && host.isNotEmpty) 'host': host,
    };
  }

  Future<Map<String, dynamic>> registerPushDeviceToken({
    required String token,
    required String platform,
  }) async {
    _pushToken = token;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_pushTokenStorageKey, token);
    } catch (_) {}
    return _request(
      'POST',
      'notifications/push/register/',
      body: <String, dynamic>{'token': token, 'platform': platform},
    );
  }

  Future<String?> _resolveRegisteredPushToken() async {
    if (_pushToken != null && _pushToken!.isNotEmpty) {
      return _pushToken;
    }
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getString(_pushTokenStorageKey);
      if (stored != null && stored.isNotEmpty) {
        _pushToken = stored;
        return stored;
      }
    } catch (_) {}

    try {
      final tokenFuture = FirebaseMessaging.instance.onRegistered
          .where((token) => token.isNotEmpty)
          .first
          .timeout(const Duration(seconds: 2));
      await FirebaseMessaging.instance.register();
      final resolved = await tokenFuture;
      _pushToken = resolved;
      return resolved;
    } catch (_) {}
    return '';
  }

  Future<Map<String, dynamic>> unregisterPushDeviceToken(String token) {
    return _request(
      'POST',
      'notifications/push/unregister/',
      body: <String, dynamic>{'token': token},
    );
  }

  Future<Map<String, dynamic>> markNotificationRead(String notificationId) {
    final id = Uri.encodeComponent(notificationId);
    return _request('POST', 'notifications/$id/mark-read/');
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() =>
      _request('POST', 'notifications/mark-all-read/');

  Future<Map<String, dynamic>> deleteNotification(String notificationId) {
    final id = Uri.encodeComponent(notificationId);
    return _request('DELETE', 'notifications/$id/delete/');
  }

  Future<Map<String, dynamic>> getTradingAccountHistory(
    String accountId, {
    int page = 1,
    int pageSize = 50,
  }) {
    final id = Uri.encodeComponent(accountId);
    return _request(
      'GET',
      'trading-account-history/$id/?page=$page&page_size=$pageSize&include_mt5_deals=true',
    );
  }

  Future<Map<String, dynamic>> getAccountDetails(String accountId) {
    final id = Uri.encodeComponent(accountId);
    return _request('GET', 'account-details/$id/');
  }


  Future<Map<String, dynamic>> _multipartRequest(
    String method,
    String path, {
    required Map<String, String> fields,
    String? fileField,
    String? fileName,
    List<int>? fileBytes,
  }) async {
    final requestGeneration = _sessionGeneration;
    await restoreSession();
    final keyPair = await _getOrCreateResponseEncryptionKeyPair();
    http.Response response;
    try {
      final request = http.MultipartRequest(method, _uri(path))
        ..headers.addAll(_headers)
        ..headers['X-Response-Encryption-Key'] = keyPair.publicKey
        ..fields.addAll(fields);
      if (fileField != null && fileName != null && fileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fileField, fileBytes, filename: fileName,
        ));
      }
      final streamed = await _httpClient.send(request).timeout(const Duration(seconds: 35));
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      _cleanupResponseKeyPair(keyPair.keyId);
      rethrow;
    }
    return _decodeAndValidateResponse(
      response,
      path,
      keyPair.keyId,
      requestGeneration: requestGeneration,
    );
  }

  Future<List<Map<String, dynamic>>> getSupportTickets() async {
    final response = await _request('GET', 'tickets/');
    final grouped = <Map<String, dynamic>>[];
    for (final key in ['open', 'pending', 'closed']) {
      final rows = response[key];
      if (rows is List) {
        for (final row in rows.whereType<Map>()) {
          grouped.add(row.cast<String, dynamic>());
        }
      }
    }
    return grouped;
  }

  Future<Map<String, dynamic>> changeSupportTicketStatus(int ticketId, String status) =>
      _request('POST', 'tickets/$ticketId/change-status/', body: <String, dynamic>{'status': status});

  Future<Map<String, dynamic>> getSupportTicket(int ticketId) =>
      _request('GET', 'tickets/$ticketId/');

  Future<Map<String, dynamic>> createSupportTicket({
    required String subject,
    required String description,
    required String department,
    String? fileName,
    List<int>? fileBytes,
  }) => _multipartRequest(
    'POST', 'tickets/create/',
    fields: <String, String>{
      'subject': '[$department] $subject',
      'description': description,
    },
    fileField: fileBytes == null ? null : 'documents',
    fileName: fileName,
    fileBytes: fileBytes,
  );

  Future<Map<String, dynamic>> replySupportTicket({
    required int ticketId,
    required String message,
    String? fileName,
    List<int>? fileBytes,
  }) => _multipartRequest(
    'POST', 'tickets/$ticketId/send-message/',
    fields: <String, String>{'content': message},
    fileField: fileBytes == null ? null : 'file',
    fileName: fileName,
    fileBytes: fileBytes,
  );

  Future<List<Map<String, dynamic>>> getOpenPositions(String accountId) async {
    final id = Uri.encodeComponent(accountId);
    final response = await _request('GET', 'open-positions/$id/');
    dynamic payload = response;
    for (var depth = 0; depth < 4 && payload is Map; depth++) {
      final map = payload.cast<String, dynamic>();
      final positions = map['positions'] ??
          (map['data'] is Map ? map['data']['positions'] : null);
      if (positions is List) {
        return positions
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(growable: false);
      }
      payload = map['data'] ?? map['result'] ?? map['payload'];
    }
    throw const AuthApiException(
      'The trading server returned an unexpected positions response.',
    );
  }

  Future<List<Map<String, dynamic>>> getTradePatternAnalysis(
    String accountId, {
    int days = 30,
  }) async {
    final id = Uri.encodeComponent(accountId);
    final response = await _request(
      'GET',
      'trade-pattern-analysis/?account_id=$id&days=$days',
    );
    final raw = response['patterns'];
    if (raw is List) {
      return raw.whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList(growable: false);
    }
    return const [];
  }

  Future<Map<String, dynamic>> getPammOpenPositions(
    String accountId, {
    required bool isManager,
  }) =>
      _request(
        'GET',
        '${isManager ? 'open-positions' : 'get-trading-positions'}/${Uri.encodeComponent(accountId)}/',
      );

  Future<List<Map<String, dynamic>>> getClosedPositions(
    String accountId, {
    int daysBack = 30,
    String? fromDate,
    String? toDate,
  }) async {
    final id = Uri.encodeComponent(accountId);
    final query = <String, String>{
      if (fromDate == null || toDate == null) 'days_back': '$daysBack',
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    };
    final queryString = Uri(queryParameters: query).query;
    final response = await _request('GET', 'trading-account/$id/closed-positions/?$queryString');
    dynamic payload = response;
    for (var depth = 0; depth < 4; depth++) {
      if (payload is List) {
        return payload
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(growable: false);
      }
      if (payload is! Map) break;
      final map = payload.cast<String, dynamic>();
      final positions = map['closed_positions'] ??
          map['positions'] ??
          map['history'] ??
          map['trades'] ??
          map['results'] ??
          (map['data'] is Map
              ? (map['data']['closed_positions'] ??
                  map['data']['positions'] ??
                  map['data']['history'] ??
                  map['data']['trades'] ??
                  map['data']['results'])
              : null);
      if (positions is List) {
        return positions
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(growable: false);
      }
      payload = map['data'] ?? map['result'] ?? map['payload'];
    }
    return const [];
  }

  /// Fetch cash-flow totals and persisted MT5 equity snapshots for a report.
  Future<Map<String, dynamic>> getTradingAccountReportData(
    String accountId, {
    required String fromDate,
    required String toDate,
  }) {
    final id = Uri.encodeComponent(accountId);
    final query = Uri(queryParameters: {
      'from_date': fromDate,
      'to_date': toDate,
    }).query;
    return _request(
      'GET',
      'trading-account/$id/report-data/?$query',
    );
  }

  Future<Map<String, dynamic>> closePosition({
    required String accountId,
    required String ticket,
  }) {
    final id = Uri.encodeComponent(accountId);
    return _request(
      'POST',
      'close-position/$id/',
      body: <String, dynamic>{
        'account_id': accountId,
        'ticket': ticket,
        'comment': 'Closed from VTIndex client',
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMobileAccounts({bool refresh = false}) async {
    final response = await _request(
      'GET',
      refresh ? 'mobile/accounts/?fresh=true' : 'mobile/accounts/',
    );
    dynamic payload = response;
    for (var depth = 0; depth < 4 && payload is Map; depth++) {
      final map = payload.cast<String, dynamic>();
      if (map['accounts'] is List) {
        return (map['accounts'] as List)
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList(growable: false);
      }
      payload = map['data'] ?? map['result'] ?? map['payload'];
    }
    throw const AuthApiException(
      'The account service returned an unexpected response.',
    );
  }

  Future<Map<String, dynamic>> getCaptchaConfig() => _request(
    'GET',
    'security/captcha/config/',
    includeSessionHeaders: false,
  );
  Future<Map<String, dynamic>> requestPasswordKey() => _request(
    'POST',
    'pub/rsa_key/',
    body: const {'client': 'pc', 'scene': 'password'},
    includeSessionHeaders: false,
  );

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    bool rememberMe = true,
    Map<String, dynamic>? captcha,
  }) async {
    final challenge = await _request(
      'GET',
      'login/encryption-challenge/',
      includeSessionHeaders: false,
    );
    final publicKey = _findString(challenge, const [
      'public_key',
      'publicKey',
      'key',
    ]);
    final challengeId = _findString(challenge, const [
      'challenge_id',
      'challengeId',
      'id',
      'kid',
    ]);
    if (publicKey == null || challengeId == null) {
      throw AuthApiException(
        'The server did not provide a usable login challenge.',
      );
    }
    final device = await getDeviceInfo();
    final captchaPayload = captcha == null ? null : {'captcha': captcha};
    final credentials = <String, dynamic>{
      'email': identifier,
      'password': password,
      ...device,
      'remember': rememberMe,
      ...?captchaPayload,
    };
    final aesKey = _randomBytes(32);
    final iv = _randomBytes(12);
    final encryptedCredentials = _aesGcmEncrypt(
      Uint8List.fromList(utf8.encode(jsonEncode(credentials))),
      aesKey,
      iv,
    );
    final encryptedKey = _rsaOaepSha256Encrypt(aesKey, publicKey);
    final payload = <String, dynamic>{
      'challenge_id': challengeId,
      'encrypted_credentials': base64Encode(encryptedCredentials),
      'encrypted_key': base64Encode(encryptedKey),
      'iv': base64Encode(iv),
    };
    final result = await _request(
      'POST',
      'login/',
      body: payload,
      includeSessionHeaders: false,
    );
    final nested = result['data'];
    if (nested is Map) result.addAll(nested.cast<String, dynamic>());
    return result;
  }

  Future<bool> tryCookieAutoLogin() async {
    if (!hasToken && _cookies.isEmpty) return false;
    try {
      final result = await _request('POST', 'login/', body: const {});
      if (result['success'] == false || result['authenticated'] == false) {
        return false;
      }
      return await isAuthenticated();
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final preferences = await SharedPreferences.getInstance();
    var deviceId = preferences.getString('vt_device_id');
    if (deviceId == null || deviceId.isEmpty) {
      final bytes = _randomBytes(16);
      bytes[6] = (bytes[6] & 0x0f) | 0x40;
      bytes[8] = (bytes[8] & 0x3f) | 0x80;
      final hex = bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      deviceId =
          '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
      await preferences.setString('vt_device_id', deviceId);
    }
    final deviceType = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => 'mobile',
      _ => 'desktop',
    };
    final deviceName = kIsWeb
        ? 'Browser'
        : switch (defaultTargetPlatform) {
            TargetPlatform.android => 'Android device',
            TargetPlatform.iOS => 'Apple device',
            TargetPlatform.windows => 'Windows app',
            TargetPlatform.macOS => 'Mac app',
            TargetPlatform.linux => 'Linux app',
            _ => 'VTIndex client',
          };
    return {
      'device_id': deviceId,
      'device_type': deviceType,
      'device_name': deviceName,
      'client_type': 'app',
    };
  }

  void _throwIfUnsuccessful(Map<String, dynamic> data) {
    if (data['success'] == false) {
      throw AuthApiException(
        _messageFrom(data),
        statusCode: 200,
        data: data,
      );
    }
  }

  Future<Map<String, dynamic>> sendSignupOtp(String email) async {
    final data = await _request(
      'POST',
      'send-signup-otp/',
      body: {'email': email},
      includeSessionHeaders: false,
    );
    _throwIfUnsuccessful(data);
    return data;
  }

  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    final data = await _request(
      'POST',
      'verify-signup-otp/',
      body: {'email': email, 'otp': otp},
      includeSessionHeaders: false,
    );
    _throwIfUnsuccessful(data);
    return data;
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final result = await _request(
      'POST',
      'verify-otp/',
      body: {'email': email, 'otp': otp, ...await getDeviceInfo()},
    );
    final nested = result['data'];
    if (nested is Map) result.addAll(nested.cast<String, dynamic>());
    return result;
  }

  Future<Map<String, dynamic>> sendResetOtp(String email) async {
    final data = await _request(
      'POST',
      'send-reset-otp/',
      body: {'email': email},
      includeSessionHeaders: false,
    );
    _throwIfUnsuccessful(data);
    return data;
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    Map<String, dynamic> payload,
  ) async {
    final data = await _request(
      'POST',
      'reset-password/confirm/',
      body: payload,
      includeSessionHeaders: false,
    );
    _throwIfUnsuccessful(data);
    return data;
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> payload) async {
    final data = await _request(
      'POST',
      'signup/',
      body: payload,
      includeSessionHeaders: false,
    );
    _throwIfUnsuccessful(data);
    return data;
  }

  Future<Map<String, dynamic>> resendLoginOtp(Map<String, dynamic> payload) =>
      _request(
        'POST',
        'resend-login-otp/',
        body: payload,
        includeSessionHeaders: false,
      );
  Future<Map<String, dynamic>> loginOtpStatus(String email) => _request(
    'GET',
    'login-otp-status/?email=${Uri.encodeQueryComponent(email)}',
    includeSessionHeaders: false,
  );
  Future<Map<String, dynamic>> status() => _request('GET', 'status/');
  Future<bool> isAuthenticated() async {
    try {
      final result = await status();

      // Explicit negative checks
      if (result['valid'] == false ||
          result['status'] == 'unauthenticated' ||
          result['authenticated'] == false ||
          result['is_authenticated'] == false) {
        return false;
      }

      // Explicit positive checks
      if (result['valid'] == true ||
          result['status'] == 'authenticated' ||
          result['authenticated'] == true ||
          result['is_authenticated'] == true) {
        return true;
      }

      // User object presence
      final user = result['user'];
      if (user is Map && user.isNotEmpty) return true;

      final nested = result['data'];
      final maps = <Map<String, dynamic>>[
        result,
        if (nested is Map) nested.cast<String, dynamic>(),
      ];
      for (final map in maps) {
        final valid = map['valid'];
        if (valid is bool) return valid;
        final authenticated = map['authenticated'] ?? map['is_authenticated'];
        if (authenticated is bool) return authenticated;
        if (map['user'] is Map && (map['user'] as Map).isNotEmpty) return true;
      }

      // If we have an active access token in session and status endpoint returned success (200)
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        return true;
      }

      return false;
    } on AuthApiException catch (e) {
      if (e.statusCode == 401 ||
          e.statusCode == 403 ||
          e.message.toLowerCase().contains('unauthenticated') ||
          e.message.toLowerCase().contains('not authenticated') ||
          (e.message.toLowerCase().contains('status check error') &&
              e.message.contains('is_authenticated'))) {
        return false;
      }
      rethrow;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> logout() {
    final ongoing = _logoutFuture;
    if (ongoing != null) return ongoing;
    final future = _performLogout();
    _logoutFuture = future;
    return future.whenComplete(() {
      if (identical(_logoutFuture, future)) {
        _logoutFuture = null;
      }
    });
  }

  Future<Map<String, dynamic>> _performLogout() async {
    _isLoggingOut = true;
    final logoutGeneration = ++_sessionGeneration;
    try {
      try {
        await const MethodChannel('com.vtindex.crm/live_updates').invokeMethod<void>('stopPositionService');
      } catch (_) {}

      // Detach this installation before invalidating the authenticated session.
      try {
        final pushToken = await _resolveRegisteredPushToken();
        if (pushToken != null && pushToken.isNotEmpty && hasToken) {
          await _request(
            'POST',
            'notifications/push/unregister/',
            body: <String, dynamic>{'token': pushToken},
          );
        }
      } catch (_) {
        // Firebase may be unconfigured on local builds; logout must still work.
      }
      return await _request('GET', 'logout/');
    } finally {
      _isLoggingOut = false;
      if (_sessionGeneration == logoutGeneration) {
        _cachedSessionKeyPair = null;
        _cookies.clear();
        _accessToken = null;
        _pushToken = null;
        BiometricSignIn.instance.clearSessionCredentials();
        try {
          final preferences = await SharedPreferences.getInstance();
          await preferences.remove(_accessTokenStorageKey);
          await preferences.remove(_pushTokenStorageKey);
        } catch (_) {}
        _restoreFuture = null;
      }
    }
  }

  Future<Map<String, dynamic>> getTrustedDevices() =>
      _request('GET', 'profile/security/devices/');
  Future<Map<String, dynamic>> trustCurrentDevice({
    required String deviceId,
    String deviceName = 'Mobile device',
    String deviceType = 'mobile',
  }) => _request(
    'POST',
    'profile/security/devices/trust/',
    body: {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
    },
  );

  Future<Map<String, dynamic>> revokeTrustedDevice({int? deviceId}) => _request(
    'DELETE',
    deviceId == null
        ? 'profile/security/devices/revoke/'
        : 'profile/security/devices/$deviceId/revoke/',
    body: const {},
    encryptProfileBody: true,
  );

  Future<Map<String, dynamic>> getCaptchaSettings() =>
      _request('GET', 'profile/security/captcha/');
  Future<Map<String, dynamic>> getTwoFactorSettings() =>
      _request('GET', 'profile/security/two-factor/');

  /// Fetches the signed-in user's transaction history using the same filters
  /// as Client/src/pages/Transactions.jsx.
  Future<Map<String, dynamic>> getUserTransactions({
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 100,
  }) {
    final query = <String, String>{
      if (type != null && type.isNotEmpty) 'type': type,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
      'page': '$page',
      'page_size': '$pageSize',
    };
    final queryString = Uri(queryParameters: query).query;
    return _request(
      'GET',
      'user-transactions/?$queryString',
    );
  }

  Future<Map<String, dynamic>> getPendingTransactions({
    String? type,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 100,
  }) {
    final query = <String, String>{
      if (type != null && type.isNotEmpty) 'type': type,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
      'page': '$page',
      'page_size': '$pageSize',
    };
    final queryString = Uri(queryParameters: query).query;
    return _request(
      'GET',
      'pending-transactions/?$queryString',
    );
  }

  Future<Map<String, dynamic>> getUserTradingAccounts({bool fresh = false}) =>
      _request(
        'GET',
        'user-trading-accounts/${fresh ? '?fresh=true' : ''}',
      );

  Future<Map<String, dynamic>> getTradingPositions(String accountId) =>
      _request(
        'GET',
        'get-trading-positions/${Uri.encodeComponent(accountId)}/',
      );

  Future<Map<String, dynamic>> fetchClosedPositions(
    String accountId, {
    int daysBack = 30,
    String? fromDate,
    String? toDate,
  }) {
    final query = <String, String>{
      'days_back': '$daysBack',
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    };
    final queryString = Uri(queryParameters: query).query;
    return _request(
      'GET',
      'closed-positions/${Uri.encodeComponent(accountId)}/?$queryString',
    );
  }

  Future<Map<String, dynamic>> getPendingOrders(String accountId) =>
      _request(
        'GET',
        'pending-orders/${Uri.encodeComponent(accountId)}/',
      );

  Future<Map<String, dynamic>> closePendingOrder({
    required String accountId,
    dynamic ticket,
    bool cancelAll = false,
  }) {
    final body = <String, dynamic>{
      if (cancelAll) 'cancel_all': true,
      if (cancelAll) 'close_all': true,
    };
    if (ticket != null) body['ticket'] = ticket;
    return _request(
      'POST',
      'close-pending-order/${Uri.encodeComponent(accountId)}/',
      body: body,
    );
  }

  Future<Map<String, dynamic>> cancelPendingOrder({
    required String accountId,
    dynamic ticket,
    bool cancelAll = false,
  }) =>
      closePendingOrder(
        accountId: accountId,
        ticket: ticket,
        cancelAll: cancelAll,
      );

  Future<Map<String, dynamic>> setCaptchaSettings(bool enabled) =>
      _request(
        'PATCH',
        'profile/security/captcha/',
        body: {'require_captcha_at_login': enabled},
        encryptProfileBody: true,
      );

  Future<Map<String, dynamic>> setTwoFactorSettings(bool enabled) => _request(
    'PATCH',
    'profile/security/two-factor/',
    body: {'require_email_otp_at_login': enabled},
    encryptProfileBody: true,
  );
  Future<Map<String, dynamic>> changeClientLoginPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) => _request(
    'POST',
    'profile/security/change-password/',
    body: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    },
    encryptProfileBody: true,
  );

  Future<Map<String, dynamic>> getAccountClosureRequest() =>
      _request('GET', 'profile/security/account-closure/');

  Future<Map<String, dynamic>> submitAccountClosureRequest({
    required String password,
    required String reason,
    String requestType = 'delete',
  }) => _request(
    'POST',
    'profile/security/account-closure/',
    body: {
      'password': password,
      'reason': reason,
      'confirm_closure': true,
      'request_type': requestType,
    },
    encryptProfileBody: true,
  );

  Future<Map<String, dynamic>> requestProfileEncryptionKey() =>
      _request('GET', 'profile/security/request-encryption-key/');
  Future<Map<String, dynamic>> verifyProfilePassword(String password) =>
      _request(
        'POST',
        'profile/security/verify-password/',
        body: {'password': password},
        encryptProfileBody: true,
      );

  /// Trading groups for account creation (type: 'real' or 'demo')
  Future<Map<String, dynamic>> getTradingGroups({String type = 'real'}) =>
      _request('GET', 'trading-groups/?type=$type');

  /// Create real MT5 trading account
  Future<Map<String, dynamic>> createTradingAccount({
    required String accountName,
    required String leverage,
    required dynamic group,
    required String masterPassword,
    required String investorPassword,
    String accountType = 'real',
  }) {
    final cleanLeverage = leverage.contains(':') ? leverage.split(':').last : leverage;
    return _request(
      'POST',
      'create-trading-account/',
      body: {
        'accountName': accountName,
        'leverage': cleanLeverage,
        'group': group,
        'masterPassword': masterPassword,
        'investorPassword': investorPassword,
        'accountType': accountType,
      },
    );
  }

  /// Create virtual demo MT5 account
  Future<Map<String, dynamic>> createDemoAccount({
    required String balance,
    required String leverage,
    String? masterPassword,
    String? investorPassword,
  }) {
    final cleanLeverage = leverage.contains(':') ? leverage.split(':').last : leverage;
    return _request(
      'POST',
      'create-demo-account/',
      body: {
        'balance': balance,
        'leverage': cleanLeverage,
        if (masterPassword != null && masterPassword.isNotEmpty)
          'masterPassword': masterPassword,
        if (investorPassword != null && investorPassword.isNotEmpty)
          'investorPassword': investorPassword,
      },
    );
  }

  /// Update the investor password for an owned MT5 trading account.
  Future<Map<String, dynamic>> updateTradingAccountPassword({
    required String accountId,
    required String newPassword,
  }) => _request(
    'POST',
    'update-password/${Uri.encodeComponent(accountId)}/',
    body: {'new_password': newPassword},
  );

  /// Update leverage for an owned MT5 trading account.
  Future<Map<String, dynamic>> updateTradingAccountLeverage({
    required String accountId,
    required String leverage,
  }) => _request(
    'POST',
    'update-leverage/${Uri.encodeComponent(accountId)}/',
    body: {'leverage': leverage},
  );

  /// Fetch the authenticated manager's MAM profit-share wallet summary.
  Future<Map<String, dynamic>> getMamProfitSummary({
    required String mamAccountId,
  }) =>
      _request(
        'GET',
        'mam/profit/summary/?mam_account_id=${Uri.encodeComponent(mamAccountId)}',
      );

  /// Trigger settlement for a MAM master account owned by the current user.
  Future<Map<String, dynamic>> triggerMamProfitSettlement({
    required String mamAccountId,
  }) =>
      _request(
        'POST',
        'mam/profit/settlements/trigger/',
        body: {'mam_account_id': mamAccountId},
      );

  /// Fetch non-demo accounts (for internal transfer)
  Future<Map<String, dynamic>> getNonDemoAccounts({bool fresh = false}) =>
      _request('GET', 'non-demo-accounts/${fresh ? '?fresh=true' : ''}');

  /// Internal transfer between trading accounts
  Future<Map<String, dynamic>> createInternalTransfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
    String comment = 'Internal Transfer',
  }) =>
      _request(
        'POST',
        'internal-transfer/',
        body: {
          'from_account_id': fromAccount,
          'to_account_id': toAccount,
          'amount': amount,
          'comment': comment,
        },
      );

  /// Create a MAM master account through the authenticated Django API.
  Future<Map<String, dynamic>> createMamAccount({
    required String accountName,
    required String leverage,
    required double profitSharingPercentage,
    required String riskLevel,
    required String payoutFrequency,
  }) =>
      _request(
        'POST',
        'mam-accounts/create/',
        encryptProfileBody: true,
        body: {
          'account_name': accountName.trim(),
          'account_type': 'mam',
          'balance': '0.00',
          'leverage': leverage.contains(':') ? leverage.split(':').last : leverage,
          'profit_sharing_percentage': profitSharingPercentage.toStringAsFixed(2),
          'risk_level': riskLevel.toLowerCase() == 'low' ||
                  riskLevel.toLowerCase() == 'low-risk'
              ? 'low'
              : (riskLevel.toLowerCase() == 'high' ||
                      riskLevel.toLowerCase() == 'aggressive'
                  ? 'high'
                  : 'medium'),
          'payout_frequency': payoutFrequency.toLowerCase().replaceAll(' ', '-'),
        },
      );

  /// Fetch active MAM managers visible to the authenticated user.
  /// Supports server-side search and pagination through Django.
  Future<Map<String, dynamic>> getAvailableMamManagers({
    int page = 1,
    int pageSize = 10,
    String search = '',
  }) {
    final query = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (search.trim().isNotEmpty) 'search': search.trim(),
    };
    return _request(
      'GET',
      'available-mam-managers/?${Uri(queryParameters: query).query}',
    );
  }

  /// Create an investment account linked to an available MAM master.
  /// This endpoint creates the MT5 investor account; it does not accept an
  /// investment amount or source-account allocation.
  Future<Map<String, dynamic>> createMamInvestment({
    required String managerId,
    required String investorPassword,
    String? masterPassword,
  }) =>
      _request(
        'POST',
        'mam/investments/',
        body: {
          'manager_id': managerId,
          'password': investorPassword,
          if (masterPassword != null && masterPassword.isNotEmpty)
            'master_password': masterPassword,
        },
      );

  /// Fetch the authenticated user's MAM investment accounts.
  Future<Map<String, dynamic>> getUserMamInvestments({
    int page = 1,
    int pageSize = 10,
  }) =>
      _request(
        'GET',
        'user-investments/?${Uri(queryParameters: {
          'page': page.toString(),
          'page_size': pageSize.toString(),
        }).query}',
      );

  /// Fetch the authenticated user's MAM master accounts.
  Future<List<Map<String, dynamic>>> getUserMamAccounts() async {
    final dynamic response = await _request('GET', 'user-mam-accounts/');
    dynamic data = response;
    if (data is Map && data['results'] is List) data = data['results'];
    if (data is Map && data['data'] is List) data = data['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }
    throw const AuthApiException('Unexpected MAM accounts response format.');
  }

  /// Enable or disable trading on a MAM master account in MT5.
  Future<Map<String, dynamic>> setMamTradingEnabled({
    required String mamId,
    required bool enabled,
  }) =>
      _request(
        'POST',
        'toggle-mam-status/${Uri.encodeComponent(mamId)}/',
        body: {
          'enable_trading': enabled,
        },
      );

  /// Toggle MT5 copy-trading permission for one investor linked to the user's MAM.
  Future<Map<String, dynamic>> toggleMamInvestorCopy(String accountId) =>
      _request(
        'POST',
        'mam/investors/${Uri.encodeComponent(accountId)}/toggle-copy/',
      );

  /// Pause or resume copy trading for one MAM investment account.
  /// The backend updates the investor permission and applies the change in MT5.
  Future<Map<String, dynamic>> setMamInvestorCopying({
    required String accountId,
    required bool enabled,
  }) =>
      _request(
        'POST',
        enabled ? 'start-copying/' : 'pause-copying/',
        body: {'mam_id': accountId},
      );

  /// Read the persisted MAM copy coefficient and cloning configuration.
  Future<Map<String, dynamic>> getMamCopyCoefficient(String accountId) =>
      _request(
        'GET',
        'account-coefficient/${Uri.encodeComponent(accountId)}/',
      );

  /// Persist the investor's copy scaling and multi-order execution settings.
  Future<Map<String, dynamic>> saveMamCopyCoefficient({
    required String accountId,
    required String mode,
    required double factor,
    required bool dualTradeEnabled,
    required int multiTradeCount,
  }) =>
      _request(
        'POST',
        'save-coefficient/',
        body: {
          'account_id': accountId,
          'mode': mode,
          'factor': factor,
          'dual_trade_enabled': dualTradeEnabled,
          'multi_trade_count': multiTradeCount,
        },
      );

  /// Fetch investor trading accounts linked to a MAM master account.
  Future<List<Map<String, dynamic>>> getMamInvestors(String mamId) async {
    final dynamic response = await _request(
      'GET',
      'mam-investors/${Uri.encodeComponent(mamId)}/',
    );

    dynamic data = response;
    if (data is Map && data['results'] is List) {
      data = data['results'];
    } else if (data is Map && data['data'] is List) {
      data = data['data'];
    } else if (data is Map && data['investors'] is List) {
      data = data['investors'];
    }

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    }

    // The backend returns a message object when there are no linked investors.
    if (data is Map && data['message'] != null) return const [];

    throw const AuthApiException('Unexpected MAM investors response format.');
  }

  /// Live USD to INR exchange rate
  Future<double> getUsdInrRate() async {
    try {
      final res = await _request('GET', 'get-usd-inr-rate/')
          .timeout(const Duration(seconds: 4));
      final rate = res['rate'];
      if (rate is num && rate > 0) return rate.toDouble();
    } catch (_) {
      try {
        final res = await _request('GET', 'usd-inr-rate/')
            .timeout(const Duration(seconds: 4));
        final rate = res['rate'];
        if (rate is num && rate > 0) return rate.toDouble();
      } catch (_) {}
    }
    return 83.5;
  }

  /// Fetch PAMM account lists from the root /api/pamm routes used by the web client.
  Future<Map<String, dynamic>> getPammManaged() =>
      _request('GET', 'pamm/managed/', useRootApi: true);

  Future<Map<String, dynamic>> getPammAvailable() =>
      _request('GET', 'pamm/available/', useRootApi: true);

  Future<Map<String, dynamic>> getPammInvestments() =>
      _request('GET', 'pamm/investments/', useRootApi: true);

  Future<Map<String, dynamic>> getPammInvestors(int pammId) =>
      _request(
        'GET',
        'pamm/$pammId/investors/',
        useRootApi: true,
      );

  Future<Map<String, dynamic>> syncPammEquity(int pammId) =>
      _request(
        'POST',
        'pamm/$pammId/sync-equity/',
        useRootApi: true,
      );

  Future<Map<String, dynamic>> setPammPoolEnabled({
    required int pammId,
    required bool enabled,
  }) =>
      _request(
        'POST',
        'pamm/disable/',
        body: {'pamm_id': pammId, 'enabled': enabled},
        useRootApi: true,
      );

  Future<Map<String, dynamic>> createPammAccount({
    required String name,
    required double profitShare,
    required int leverage,
    required String masterPassword,
    required String investorPassword,
  }) =>
      _request(
        'POST',
        'pamm/create/',
        useRootApi: true,
        body: {
          'name': name.trim(),
          'profit_share': profitShare,
          'leverage': leverage,
          'master_password': masterPassword,
          'invest_password': investorPassword,
        },
      );

  Future<Map<String, dynamic>> investInPamm({
    required int pammId,
    required String investorName,
  }) =>
      _request(
        'POST',
        'pamm/invest/',
        useRootApi: true,
        body: {'pamm_id': pammId, 'investor_name': investorName.trim()},
      );

  Future<Map<String, dynamic>> submitPammDeposit({
    required String pammId,
    required double amountUsd,
    required String method,
    required List<int> proofBytes,
    required String proofFileName,
    required bool isManager,
  }) async {
    if (method != 'manual' && method != 'usdt') {
      throw ArgumentError.value(method, 'method');
    }
    if (amountUsd <= 0 || proofBytes.isEmpty) {
      throw ArgumentError('A positive amount and payment proof are required.');
    }

    final requestGeneration = _sessionGeneration;
    await restoreSession();
    final headers = _headers;
    final responseKeyPair = await _getOrCreateResponseEncryptionKeyPair();
    headers['X-Response-Encryption-Key'] = responseKeyPair.publicKey;

    final path = isManager ? 'pamm/manager-deposit/' : 'pamm/deposit/';
    final request = http.MultipartRequest(
      'POST',
      _rootApiUri(path),
    )..headers.addAll(headers);
    request.fields['pamm_id'] = pammId;
    request.fields['amount'] = amountUsd.toStringAsFixed(2);
    request.fields['method'] = method;
    request.files.add(
      http.MultipartFile.fromBytes(
        'proof',
        proofBytes,
        filename: proofFileName,
      ),
    );

    http.Response response;
    try {
      final streamed = await _httpClient.send(request).timeout(
        const Duration(seconds: 75),
      );
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      _cleanupResponseKeyPair(responseKeyPair.keyId);
      rethrow;
    }
    return _decodeAndValidateResponse(
      response,
      path,
      responseKeyPair.keyId,
      requestGeneration: requestGeneration,
      invalidResponseMessage:
          'The server returned an invalid PAMM deposit response.',
    );
  }

  Future<Map<String, dynamic>> requestPammWithdrawal({
    required int pammId,
    required double amount,
    required String method,
    required bool isManager,
  }) =>
      _request(
        'POST',
        isManager ? 'pamm/manager-withdraw/' : 'pamm/withdraw/',
        useRootApi: true,
        body: {
          'pamm_id': pammId,
          'amount': amount,
          'method': method,
        },
      );

  // ==========================================
  // Introducing Broker (IB) / Partnership APIs
  // ==========================================

  /// Check user's IB status (approved, pending, rejected, etc.)
  Future<Map<String, dynamic>> getIbStatus() =>
      _request('GET', 'ib/status/');

  /// Submit an application for the current user to become an Introducing Broker
  Future<Map<String, dynamic>> submitIbApplication() =>
      _request('POST', 'ib-request/');

  /// Fetch overview metrics, monthly telemetry, and client earnings for IB
  Future<Map<String, dynamic>> getIbStats() =>
      _request('GET', 'ib/stats/');

  /// Fetch registered referral links and profiles
  Future<Map<String, dynamic>> getIbReferralLinks() =>
      _request('GET', 'ib/referral-link/');

  /// Fetch commission transaction ledger
  Future<Map<String, dynamic>> getIbCommissionTransactions() =>
      _request('GET', 'ib/commission-transactions/');

  /// Fetch hierarchical client tree
  Future<Map<String, dynamic>> getIbClientTree({int page = 1, int perPage = 1000}) =>
      _request('GET', 'ib/client-tree/?page=$page&per_page=$perPage');

  /// Submit IB nomination request for a downline client
  Future<Map<String, dynamic>> requestClientIb(dynamic clientId) =>
      _request(
        'POST',
        'ib/request-client-ib/',
        body: {'client_id': clientId},
      );

  /// Request commission payout / transfer to a live MT5 account
  Future<Map<String, dynamic>> requestIbWithdrawal({
    required double amount,
    required String accountId,
    String comment = '',
  }) =>
      _request(
        'POST',
        'ib/request-withdrawal/',
        body: {
          'amount': amount,
          'account_id': accountId,
          'comment': comment,
        },
      );

  /// Fetch IB withdrawal / transfer history transactions
  Future<Map<String, dynamic>> getIbWithdrawalTransactions() =>
      _request('GET', 'ib/transactions/');

  /// Register a direct client under IB
  Future<Map<String, dynamic>> addIbClient({
    required String name,
    required String email,
    required String phone,
    String? dob,
    String? country,
    String? referralCode,
  }) {
    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'dob': ?dob,
      'country': ?country,
      'referral_code': ?referralCode,
    };
    return _request(
      'POST',
      'ib/add-client/',
      body: body,
    );
  }

  /// Withdrawal information for an account
  Future<Map<String, dynamic>> getWithdrawalInfo(String accountId) async {
    try {
      return await _request('GET', 'withdrawal/info/${Uri.encodeComponent(accountId)}/');
    } catch (_) {
      return await _request('GET', 'withdraw-info/${Uri.encodeComponent(accountId)}/');
    }
  }

  /// Request withdrawal from account
  Future<Map<String, dynamic>> requestWithdrawal({
    required String accountId,
    required double amount,
    required String method,
    String description = '',
  }) async {
    final body = {
      'account_id': accountId,
      'mam_id': accountId,
      'amount': amount,
      'method': method,
      'description': description.isNotEmpty ? description : 'Withdrawal via ${method.toUpperCase()}',
    };
    // Use the enhanced withdrawal endpoint only. Do not retry a rejected
    // request against the legacy endpoint: a 403 is a business-rule denial
    // (for example, incomplete KYC), not an endpoint compatibility failure.
    return _request('POST', 'withdrawal/request/', body: body);
  }

  /// Initiate CheesePay deposit
  Future<Map<String, dynamic>> initiateCheesePay({
    required String accountId,
    required double amountUsd,
    required double amountInr,
  }) =>
      _request(
        'POST',
        'cheesepay-initiate/',
        body: {
          'account_id': accountId,
          'mam_id': accountId,
          'amount_usd': amountUsd.toStringAsFixed(2),
          'amount_inr': amountInr.toStringAsFixed(2),
        },
      );

  /// Initiate USDT deposit
  Future<Map<String, dynamic>> initiateUsdtDeposit({
    required String accountId,
    required double amountUsd,
  }) =>
      _request(
        'POST',
        'usdt-deposit/',
        body: {
          'mam_id': accountId,
          'account_id': accountId,
          'amount': amountUsd.toStringAsFixed(2),
        },
      );

  /// Submit manual wire deposit with proof
  Future<Map<String, dynamic>> submitManualDeposit({
    required String accountId,
    required double amountUsd,
    List<int>? proofBytes,
    String? proofFileName,
  }) async {
    final requestGeneration = _sessionGeneration;
    await restoreSession();
    final headers = _headers;
    final responseKeyPair = await _getOrCreateResponseEncryptionKeyPair();
    headers['X-Response-Encryption-Key'] = responseKeyPair.publicKey;

    final request = http.MultipartRequest('POST', _uri('manual-deposit/'));
    request.headers.addAll(headers);
    request.fields['mam_id'] = accountId;
    request.fields['amount'] = amountUsd.toStringAsFixed(2);

    if (proofBytes != null && proofBytes.isNotEmpty) {
      request.files.add(http.MultipartFile.fromBytes(
        'proof',
        proofBytes,
        filename: proofFileName ?? 'proof.jpg',
      ));
    }

    http.Response response;
    try {
      final streamed = await _httpClient
          .send(request)
          .timeout(const Duration(seconds: 75));
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      _cleanupResponseKeyPair(responseKeyPair.keyId);
      rethrow;
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _handleUnauthorizedResponse(response.statusCode, 'manual-deposit/');
    }

    final isSuccessfulStatus =
        response.statusCode >= 200 && response.statusCode < 300;

    dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : await _decodeJsonBody(response.body);
    } on FormatException {
      _cleanupResponseKeyPair(responseKeyPair.keyId);
      if (isSuccessfulStatus) {
        // The server has already accepted the deposit. Its response body is
        // informational only for this endpoint, so do not report a false
        // failure if a proxy or renderer returns a non-JSON success body.
        debugPrint(
          'Manual deposit accepted (HTTP ${response.statusCode}); '
          'response body was not JSON.',
        );
        _captureSession(response, requestGeneration: requestGeneration);
        return <String, dynamic>{
          'message': 'Manual deposit request accepted.',
        };
      }
      throw AuthApiException(
        'Invalid response from server.',
        statusCode: response.statusCode,
      );
    }

    dynamic responsePayload = decoded;
    if (decoded is Map && decoded['encrypted'] == true) {
      try {
        responsePayload = _decryptResponseEnvelope(
          decoded.cast<String, dynamic>(),
          responseKeyPair.keyId,
        );
      } catch (error) {
        if (!isSuccessfulStatus) rethrow;
        // Do not turn a completed 2xx deposit into a failure merely because
        // the encrypted acknowledgement could not be decoded. No response
        // fields are required to complete this manual-deposit flow.
        debugPrint(
          'Manual deposit accepted (HTTP ${response.statusCode}); '
          'encrypted acknowledgement could not be decoded: $error',
        );
        _captureSession(response, requestGeneration: requestGeneration);
        return <String, dynamic>{
          'message': 'Manual deposit request accepted.',
        };
      }
    } else {
      _cleanupResponseKeyPair(responseKeyPair.keyId);
    }

    final data = responsePayload is Map<String, dynamic>
        ? responsePayload
        : <String, dynamic>{'data': responsePayload};

    if (!isSuccessfulStatus) {
      throw AuthApiException(
        _messageFrom(data),
        statusCode: response.statusCode,
        data: data,
      );
    }
    _captureSession(
      response,
      payload: data,
      requestGeneration: requestGeneration,
    );
    return data;
  }

  /// Fetch the authenticated user's profile.
  Future<Map<String, dynamic>> getProfile() => _request('GET', 'profile/');

  /// Save the profile fields supported by Django's EditPersonalInfoView.
  /// Name, email, gender, nationality, occupation and tax residency are not
  /// editable through this endpoint.
  Future<Map<String, dynamic>> updatePersonalInfo({
    String? phoneNumber,
    String? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
  }) {
    final body = <String, dynamic>{
      'phone_number': ?phoneNumber,
      'dob': ?dateOfBirth,
      'address': ?address,
      'city': ?city,
      'state': ?state,
      'country': ?country,
      'zip_code': ?zipCode,
    };
    return _request(
      'POST',
      'profile/edit/',
      body: body,
      encryptProfileBody: true,
    );
  }

  /// Fetch the current user's bank payout details.
  Future<Map<String, dynamic>> getBankDetails() =>
      _request('GET', 'profile/bank-details/');

  /// Submit a bank payout destination. The API returns a pending approval status.
  Future<Map<String, dynamic>> updateBankDetails({
    required String bankName,
    required String accountNumber,
    String? branchName,
    String? ifscCode,
  }) =>
      _request(
        'POST',
        'profile/bank-details/',
        body: {
          'bank_name': bankName,
          'account_number': accountNumber,
          'branch_name': ?branchName,
          'ifsc_code': ?ifscCode,
        },
        encryptProfileBody: true,
      );

  /// Fetch the current user's crypto destination.
  Future<Map<String, dynamic>> getCryptoDetails() =>
      _request('GET', 'profile/crypto-details/');

  /// Submit a crypto wallet destination. Changes require admin approval.
  Future<Map<String, dynamic>> updateCryptoDetails({
    required String walletAddress,
    required String currency,
  }) =>
      _request(
        'POST',
        'profile/crypto-details/',
        body: {'wallet_address': walletAddress, 'currency': currency},
        encryptProfileBody: true,
      );

  /// Upload a profile photo. Django expects multipart field "profile_pic".
  Future<Map<String, dynamic>> uploadProfileImage(String filePath) =>
      _uploadProfileImage(
        filePath: filePath,
        endpoint: 'profile/image/',
        fieldName: 'profile_pic',
      );

  /// Upload a profile banner. Django expects multipart field "banner".
  Future<Map<String, dynamic>> uploadProfileBanner(String filePath) =>
      _uploadProfileImage(
        filePath: filePath,
        endpoint: 'profile/banner/',
        fieldName: 'banner',
      );

  /// Return the signed-in user's identity and residence document statuses.
  Future<Map<String, dynamic>> getProfileDocuments() =>
      _request('GET', 'profile/documents/');

  /// Upload a KYC document using the backend's multipart "document" field.
  Future<Map<String, dynamic>> uploadVerificationDocument({
    required String documentType,
    required String filePath,
  }) {
    if (documentType != 'identity' && documentType != 'residence') {
      throw ArgumentError.value(documentType, 'documentType');
    }
    return _uploadProfileImage(
      filePath: filePath,
      endpoint: 'profile/documents/$documentType/',
      fieldName: 'document',
    );
  }

  /// Verify the CRM password and receive the protected document bytes.
  Future<({Uint8List bytes, String contentType, String fileName})>
      getSecureProfileDocument({
    required String documentType,
    required String password,
  }) async {
    if (documentType != 'identity' && documentType != 'residence') {
      throw ArgumentError.value(documentType, 'documentType');
    }
    await restoreSession();
    final headers = _headers
      ..['Accept'] = '*/*'
      ..['Content-Type'] = 'application/json';
    final request = http.Request(
      'POST',
      _uri('profile/documents/$documentType/view/'),
    )
      ..headers.addAll(headers)
      ..body = jsonEncode({'password': password});
    final streamed = await _httpClient
        .send(request)
        .timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _handleUnauthorizedResponse(
        response.statusCode,
        'profile/documents/$documentType/view/',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      dynamic payload;
      try {
        payload = jsonDecode(response.body);
      } catch (_) {
        payload = null;
      }
      final data = payload is Map
          ? payload.cast<String, dynamic>()
          : <String, dynamic>{};
      throw AuthApiException(
        _messageFrom(data),
        statusCode: response.statusCode,
        data: data,
      );
    }
    final disposition = response.headers['content-disposition'] ?? '';
    final match = RegExp(r'filename="?([^";]+)"?').firstMatch(disposition);
    return (
      bytes: response.bodyBytes,
      contentType: response.headers['content-type'] ?? 'application/octet-stream',
      fileName: match?.group(1) ?? '$documentType-document',
    );
  }

  Future<Map<String, dynamic>> _uploadProfileImage({
    required String filePath,
    required String endpoint,
    required String fieldName,
  }) async {
    final requestGeneration = _sessionGeneration;
    await restoreSession();
    final headers = _headers;
    final responseKeyPair = await _getOrCreateResponseEncryptionKeyPair();
    headers['X-Response-Encryption-Key'] = responseKeyPair.publicKey;

    final request = http.MultipartRequest('POST', _uri(endpoint));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    http.Response response;
    try {
      final streamed = await _httpClient
          .send(request)
          .timeout(const Duration(seconds: 45));
      response = await http.Response.fromStream(streamed);
    } catch (_) {
      _cleanupResponseKeyPair(responseKeyPair.keyId);
      rethrow;
    }
    return _decodeAndValidateResponse(
      response,
      endpoint,
      responseKeyPair.keyId,
      requestGeneration: requestGeneration,
      invalidResponseMessage: 'The server returned an invalid upload response.',
    );
  }

  /// Fetch an authenticated profile photo as raw image bytes.
  Future<Uint8List> getProfileImageBytes() =>
      _getProfileImageBytes(
        'profile/image/?t=${DateTime.now().millisecondsSinceEpoch}',
        label: 'Profile photo',
      );

  /// The banner endpoint supports raw streaming with stream=1. This uses the
  /// same /api/profile/banner/ route exposed by the web client.
  Future<Uint8List> getProfileBannerBytes() =>
      _getProfileImageBytes(
        'profile/banner/?stream=1&t=${DateTime.now().millisecondsSinceEpoch}',
        label: 'Profile banner',
      );

  Future<Uint8List> _getProfileImageBytes(
    String endpoint, {
    required String label,
  }) async {
    await restoreSession();
    // DRF negotiates the request against configured renderers before
    // executing the view. These file endpoints still return FileResponse,
    // but image/* is not a configured DRF renderer and causes HTTP 406.
    // Request JSON for negotiation; the view's FileResponse remains raw bytes.
    final headers = _headers
      ..['Accept'] = 'application/json'
      ..['Cache-Control'] = 'no-cache';
    final request = http.Request('GET', _uri(endpoint))
      ..headers.addAll(headers);

    final streamed = await _httpClient
        .send(request)
        .timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _handleUnauthorizedResponse(response.statusCode, endpoint);
    }
    final contentType = (response.headers['content-type'] ?? '').toLowerCase();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var serverMessage = '';
      try {
        final payload = jsonDecode(response.body);
        if (payload is Map) {
          serverMessage = (payload['detail'] ??
                  payload['error'] ??
                  payload['message'] ??
                  '')
              .toString();
        }
      } catch (_) {
        // The response may be an HTML error page or an empty body.
      }
      debugPrint(
        '$label request failed: HTTP ${response.statusCode}; '
        'content-type=${contentType.isEmpty ? 'unknown' : contentType}; '
        'message=${serverMessage.isEmpty ? 'no server message' : serverMessage}',
      );
      throw AuthApiException(
        serverMessage.isNotEmpty
            ? '$label could not be loaded: $serverMessage'
            : '$label request failed (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw AuthApiException('$label response was empty.');
    }

    if (!contentType.startsWith('image/')) {
      var responseMessage = 'The server did not return image data.';
      try {
        final payload = jsonDecode(response.body);
        if (payload is Map) {
          final message = payload['detail'] ??
              payload['error'] ??
              payload['message'];
          if (message != null) responseMessage = message.toString();
        }
      } catch (_) {
        // Keep the generic content-type diagnostic for non-JSON responses.
      }
      debugPrint(
        '$label returned unexpected content-type: '
        '${contentType.isEmpty ? 'unknown' : contentType}',
      );
      throw AuthApiException('$label could not be displayed: $responseMessage');
    }

    return response.bodyBytes;
  }

  Future<String> encryptPasswordForPasswordFlow(String password) async {
    final response = await requestPasswordKey();
    final kid = _findString(response, const ['kid']);
    final publicKey = _findString(response, const ['public_key', 'publicKey']);
    final nonce = _findString(response, const ['nonce']);
    if (kid == null || publicKey == null || nonce == null) {
      throw const AuthApiException(
        'The server did not provide a password encryption key.',
      );
    }
    final ciphertext = _rsaOaepSha256Encrypt(
      Uint8List.fromList(utf8.encode(password)),
      publicKey,
      encodingParams: Uint8List.fromList(utf8.encode(nonce)),
    );
    final encoded = base64Url.encode(ciphertext).replaceAll('=', '');
    return 'rsa:v1:$kid:$encoded';
  }

  String? _findString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is Map) {
        final nested = _findString(value.cast<String, dynamic>(), keys);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  Uint8List _aesGcmEncrypt(Uint8List plaintext, Uint8List key, Uint8List iv) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(true, AEADParameters(KeyParameter(key), 128, iv, Uint8List(0)));
    return cipher.process(plaintext);
  }

  Uint8List _rsaOaepSha256Encrypt(
    Uint8List plaintext,
    String pem, {
    Uint8List? encodingParams,
  }) {
    final encoded = pem
        .replaceAll(RegExp(r'-----[^-]+-----'), '')
        .replaceAll(RegExp(r'\s'), '');
    final der = base64Decode(encoded);
    final publicInfo = ASN1Parser(der).nextObject() as ASN1Sequence;
    final publicBits = publicInfo.elements[1] as ASN1BitString;
    final rsaSequence =
        ASN1Parser(Uint8List.fromList(publicBits.valueBytes().skip(1).toList()))
                .nextObject()
            as ASN1Sequence;
    final modulus = (rsaSequence.elements[0] as ASN1Integer).valueAsBigInteger;
    final exponent = (rsaSequence.elements[1] as ASN1Integer).valueAsBigInteger;
    final random = Random.secure();
    final secureRandom = FortunaRandom()
      ..seed(
        KeyParameter(
          Uint8List.fromList(
            List<int>.generate(32, (_) => random.nextInt(256)),
          ),
        ),
      );
    final cipher =
        OAEPEncoding.withSHA256(RSAEngine(), encodingParams ?? Uint8List(0))
          ..init(
            true,
            ParametersWithRandom(
              PublicKeyParameter<RSAPublicKey>(RSAPublicKey(modulus, exponent)),
              secureRandom,
            ),
          );
    return cipher.process(plaintext);
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode, this.data});
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  @override
  String toString() => message;
}
