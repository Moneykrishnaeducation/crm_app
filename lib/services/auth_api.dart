import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_http_client.dart';

/// API access for the client authentication endpoints.
/// Override API_BASE_URL with --dart-define for a different environment.
class AuthApi {
  AuthApi._();

  static final AuthApi instance = AuthApi._();
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _apiPrefix = String.fromEnvironment(
    'API_PREFIX',
    defaultValue: '/client/api/',
  );

  final http.Client _client = createAuthHttpClient();
  final Map<String, String> _cookies = <String, String>{};
  String? _accessToken;
  static const _accessTokenStorageKey = 'vtindex_client_access_token';
  Future<void>? _restoreFuture;
  final Map<String, dynamic> _responseEncryptionPrivateKeys = <String, dynamic>{};

  bool get hasToken =>
      (_accessToken != null && _accessToken!.isNotEmpty) ||
      _cookies.containsKey('client_access_token') ||
      _cookies.containsKey('access_token') ||
      _cookies.containsKey('jwt_token');

  Future<void> restoreSession() {
    return _restoreFuture ??= _restoreStoredSession();
  }

  Future<void> _restoreStoredSession() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _accessToken ??= preferences.getString(_accessTokenStorageKey);
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

  Uri get _baseUri {
    if (_configuredBaseUrl.isNotEmpty) {
      final configured = Uri.parse(_configuredBaseUrl);
      var path = configured.path;
      if (path.endsWith('/client') || path.endsWith('/client/')) {
        path = '${path.replaceFirst(RegExp(r'/$'), '')}/api/';
      } else if (!path.endsWith('/api') && !path.endsWith('/api/')) {
        final prefix = _apiPrefix.startsWith('/') ? _apiPrefix : '/$_apiPrefix';
        path = '${path == '/' ? '' : path}$prefix';
      }
      return configured.replace(path: path.endsWith('/') ? path : '$path/');
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return Uri.parse('http://10.0.2.2:8000$_apiPrefix');
    }
    if (!kIsWeb) return Uri.parse('http://127.0.0.1:8000$_apiPrefix');
    return Uri.parse('http://client.localhost:8000$_apiPrefix');
  }

  Map<String, String> get _headers {
    final headers = <String, String>{'Accept': 'application/json'};
    if (!kIsWeb && _configuredBaseUrl.isEmpty &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      // Local development host override only. Production uses the configured API host.
      headers['Host'] = 'client.localhost:8000';
    }
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = _cookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');
    }
    if (_accessToken != null) headers['Authorization'] = 'Bearer $_accessToken';
    return headers;
  }

  Uri _uri(String path) {
    final cleanPath = path.startsWith('/api/')
        ? path.substring(5)
        : (path.startsWith('/') ? path.substring(1) : path);
    return _baseUri.resolve(cleanPath);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool encryptProfileBody = false,
  }) async {
    await restoreSession();
    final headers = _headers;
    final responseKeyPair = _createResponseEncryptionKeyPair();
    headers['X-Response-Encryption-Key'] = responseKeyPair.publicKey;

    Map<String, dynamic>? wireBody = body;
    if (body != null && encryptProfileBody) {
      // The server issues a short-lived, one-use key for every encrypted write.
      final requestKey = await requestProfileEncryptionKey();
      final keyId = _findString(requestKey, const ['key_id']);
      final pem = _findString(requestKey, const ['public_key']);
      if (keyId == null || pem == null) {
        _responseEncryptionPrivateKeys.remove(responseKeyPair.keyId);
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

    final request = http.Request(method, _uri(path))..headers.addAll(headers);
    if (wireBody != null) request.body = jsonEncode(wireBody);
    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamed);
    _captureSession(response);
    dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      _responseEncryptionPrivateKeys.remove(responseKeyPair.keyId);
      throw AuthApiException(
        'The server returned an invalid response.',
        statusCode: response.statusCode,
      );
    }
    dynamic responsePayload = decoded;
    if (decoded is Map && decoded['encrypted'] == true) {
      responsePayload = _decryptResponseEnvelope(
        decoded.cast<String, dynamic>(),
        responseKeyPair.keyId,
      );
    } else {
      _responseEncryptionPrivateKeys.remove(responseKeyPair.keyId);
    }
    final data = responsePayload is Map<String, dynamic>
        ? responsePayload
        : <String, dynamic>{'data': responsePayload};
    final apiCode = data['code'];
    final hasApiError = apiCode is num && (apiCode < 200 || apiCode >= 300);
    final hasErrorMessage =
        data['error'] is String && (data['error'] as String).isNotEmpty;
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
    return data;
  }

  ({String publicKey, String keyId}) _createResponseEncryptionKeyPair() {
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
    final keyId = base64Url.encode(_randomBytes(12)).replaceAll('=', '');
    _responseEncryptionPrivateKeys[keyId] = privateKey;

    // Build DER SubjectPublicKeyInfo explicitly. This avoids ASN.1 library
    // bit-string encoding differences and matches cryptography.load_der_public_key.
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
    );
  }

  dynamic _decryptResponseEnvelope(Map<String, dynamic> envelope, String keyId) {
    final privateKey = _responseEncryptionPrivateKeys.remove(keyId);
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

  void _captureSession(http.Response response) {
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
    final decoded = response.body.isEmpty ? null : _tryDecode(response.body);
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
        _accessToken = token;
        unawaited(_persistAccessToken());
      }
    }
    // Some authentication responses are encrypted by the same response-key
    // contract; token persistence must happen after _request decrypts them.
    if (_accessToken == null) {
      final cookieToken = _cookies['client_access_token'] ??
          _cookies['access_token'] ??
          _cookies['jwt_token'];
      if (cookieToken != null && cookieToken.isNotEmpty) {
        _accessToken = cookieToken;
        unawaited(_persistAccessToken());
      }
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
    for (final key in const ['message', 'error', 'detail']) {
      final value = data[key];
      if (value is String && value.isNotEmpty) return value;
      if (value is List && value.isNotEmpty) return value.join(' ');
    }
    return 'The request failed. Please try again.';
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

  Future<List<Map<String, dynamic>>> getClosedPositions(
    String accountId, {
    int daysBack = 30,
    String? fromDate,
    String? toDate,
  }) async {
    final id = Uri.encodeComponent(accountId);
    final query = <String, String>{
      'days_back': '$daysBack',
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    };
    final queryString = Uri(queryParameters: query).query;
    final response = await _request('GET', 'close-position/$id/?$queryString');
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

  Future<Map<String, dynamic>> getCaptchaConfig() =>
      _request('GET', 'security/captcha/config/');
  Future<Map<String, dynamic>> requestPasswordKey() => _request(
    'POST',
    'pub/rsa_key/',
    body: const {'client': 'pc', 'scene': 'password'},
  );

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    bool rememberMe = true,
    Map<String, dynamic>? captcha,
  }) async {
    final challenge = await _request('GET', 'login/encryption-challenge/');
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
    final result = await _request('POST', 'login/', body: payload);
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

  Future<Map<String, dynamic>> sendSignupOtp(String email) =>
      _request('POST', 'send-signup-otp/', body: {'email': email});
  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) => _request(
    'POST',
    'verify-signup-otp/',
    body: {'email': email, 'otp': otp},
  );
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async => _request(
    'POST',
    'verify-otp/',
    body: {'email': email, 'otp': otp, ...await getDeviceInfo()},
  );
  Future<Map<String, dynamic>> sendResetOtp(String email) =>
      _request('POST', 'send-reset-otp/', body: {'email': email});
  Future<Map<String, dynamic>> confirmPasswordReset(
    Map<String, dynamic> payload,
  ) => _request('POST', 'reset-password/confirm/', body: payload);

  Future<Map<String, dynamic>> signup(Map<String, dynamic> payload) =>
      _request('POST', 'signup/', body: payload);
  Future<Map<String, dynamic>> resendLoginOtp(Map<String, dynamic> payload) =>
      _request('POST', 'resend-login-otp/', body: payload);
  Future<Map<String, dynamic>> loginOtpStatus(String email) => _request(
    'GET',
    'login-otp-status/?email=${Uri.encodeQueryComponent(email)}',
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

  Future<Map<String, dynamic>> logout() async {
    try {
      return await _request('POST', 'logout/');
    } finally {
      _cookies.clear();
      _accessToken = null;
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_accessTokenStorageKey);
      } catch (_) {}
      _restoreFuture = null;
    }
  }

  Future<Map<String, dynamic>> getTrustedDevices() =>
      _request('GET', 'profile/security/devices/');
  Future<Map<String, dynamic>> trustCurrentDevice() =>
      _request('POST', 'profile/security/devices/trust/', body: const {});
  Future<Map<String, dynamic>> revokeTrustedDevice({int? deviceId}) => _request(
    'POST',
    deviceId == null
        ? 'profile/security/devices/revoke/'
        : 'profile/security/devices/$deviceId/revoke/',
    body: const {},
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
      _request('POST', 'profile/security/captcha/', body: {'enabled': enabled});
  Future<Map<String, dynamic>> setTwoFactorSettings(bool enabled) => _request(
    'POST',
    'profile/security/two-factor/',
    body: {'enabled': enabled},
  );
  Future<Map<String, dynamic>> requestProfileEncryptionKey() => _request(
    'POST',
    'profile/security/request-encryption-key/',
    body: const {},
  );
  Future<Map<String, dynamic>> verifyProfilePassword(String password) =>
      _request(
        'POST',
        'profile/security/verify-password/',
        body: {'password': password},
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
    await restoreSession();
    final headers = _headers;
    final responseKeyPair = _createResponseEncryptionKeyPair();
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

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 75));
    final response = await http.Response.fromStream(streamed);
    _captureSession(response);

    final isSuccessfulStatus =
        response.statusCode >= 200 && response.statusCode < 300;

    dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      _responseEncryptionPrivateKeys.remove(responseKeyPair.keyId);
      if (isSuccessfulStatus) {
        // The server has already accepted the deposit. Its response body is
        // informational only for this endpoint, so do not report a false
        // failure if a proxy or renderer returns a non-JSON success body.
        debugPrint(
          'Manual deposit accepted (HTTP ${response.statusCode}); '
          'response body was not JSON.',
        );
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
        return <String, dynamic>{
          'message': 'Manual deposit request accepted.',
        };
      }
    } else {
      _responseEncryptionPrivateKeys.remove(responseKeyPair.keyId);
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
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (dateOfBirth != null) 'dob': dateOfBirth,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (zipCode != null) 'zip_code': zipCode,
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
          if (branchName != null) 'branch_name': branchName,
          if (ifscCode != null) 'ifsc_code': ifscCode,
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
    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
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
    await restoreSession();
    final headers = _headers;
    final responseKeyPair = _createResponseEncryptionKeyPair();
    headers['X-Response-Encryption-Key'] = responseKeyPair.publicKey;

    final request = http.MultipartRequest('POST', _uri(endpoint));
    request.headers.addAll(headers);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 45));
    final response = await http.Response.fromStream(streamed);
    _captureSession(response);

    dynamic decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } on FormatException {
      _responseEncryptionPrivateKeys.remove(responseKeyPair.keyId);
      throw AuthApiException(
        'The server returned an invalid upload response.',
        statusCode: response.statusCode,
      );
    }

    dynamic payload = decoded;
    if (decoded is Map && decoded['encrypted'] == true) {
      payload = _decryptResponseEnvelope(
        decoded.cast<String, dynamic>(),
        responseKeyPair.keyId,
      );
    } else {
      _responseEncryptionPrivateKeys.remove(responseKeyPair.keyId);
    }

    final data = payload is Map<String, dynamic>
        ? payload
        : <String, dynamic>{'data': payload};
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        (data['error'] is String && (data['error'] as String).isNotEmpty)) {
      throw AuthApiException(
        _messageFrom(data),
        statusCode: response.statusCode,
        data: data,
      );
    }
    return data;
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

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 25));
    final response = await http.Response.fromStream(streamed);
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
