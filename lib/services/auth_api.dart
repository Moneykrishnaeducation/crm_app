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

  bool get hasToken =>
      (_accessToken != null && _accessToken!.isNotEmpty) ||
      _cookies.containsKey('client_access_token') ||
      _cookies.containsKey('access_token') ||
      _cookies.containsKey('jwt_token');

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
    if (!kIsWeb) {
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

  Uri _uri(String path) => _baseUri.resolve(path);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requireEncryptedResponse = false,
  }) async {
    final headers = _headers;
    RSAPrivateKey? responsePrivateKey;
    if (requireEncryptedResponse) {
      final responseKey = _createResponseEncryptionKey();
      responsePrivateKey = responseKey.privateKey;
      headers['X-Response-Encryption-Key'] = responseKey.publicKeyBase64;
    }
    if (body != null) headers['Content-Type'] = 'application/json';
    final request = http.Request(method, _uri(path))..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);
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
      throw AuthApiException(
        'The server returned an invalid response.',
        statusCode: response.statusCode,
      );
    }
    var data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        requireEncryptedResponse &&
        data['encrypted'] == true) {
      data = _decryptResponseEnvelope(data, responsePrivateKey!);
    }
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
      if (token is String && token.isNotEmpty) _accessToken = token;
    }
    if (_accessToken == null) {
      final cookieToken = _cookies['client_access_token'] ??
          _cookies['access_token'] ??
          _cookies['jwt_token'];
      if (cookieToken != null && cookieToken.isNotEmpty) {
        _accessToken = cookieToken;
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
      '/api/user-transactions/?$queryString',
      requireEncryptedResponse: true,
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
      '/api/pending-transactions/?$queryString',
      requireEncryptedResponse: true,
    );
  }

  Future<Map<String, dynamic>> getUserTradingAccounts({bool fresh = false}) =>
      _request(
        'GET',
        '/api/user-trading-accounts/${fresh ? '?fresh=true' : ''}',
        requireEncryptedResponse: true,
      );

  Future<Map<String, dynamic>> getOpenPositions(String accountId) =>
      _request(
        'GET',
        '/api/open-positions/${Uri.encodeComponent(accountId)}/',
        requireEncryptedResponse: false,
      );

  Future<Map<String, dynamic>> getTradingPositions(String accountId) =>
      _request(
        'GET',
        '/api/get-trading-positions/${Uri.encodeComponent(accountId)}/',
        requireEncryptedResponse: false,
      );

  Future<Map<String, dynamic>> closePosition({
    required String accountId,
    dynamic ticket,
    double? volume,
    bool closeAll = false,
    String? comment,
  }) {
    final body = <String, dynamic>{
      if (ticket != null) 'ticket': ticket,
      if (volume != null) 'volume': volume,
      if (closeAll) 'close_all': true,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    return _request(
      'POST',
      '/api/close-position/${Uri.encodeComponent(accountId)}/',
      body: body,
      requireEncryptedResponse: false,
    );
  }

  Future<Map<String, dynamic>> getPendingOrders(String accountId) =>
      _request(
        'GET',
        '/api/pending-orders/${Uri.encodeComponent(accountId)}/',
        requireEncryptedResponse: false,
      );

  Future<Map<String, dynamic>> closePendingOrder({
    required String accountId,
    dynamic ticket,
    bool cancelAll = false,
  }) {
    final body = <String, dynamic>{
      if (ticket != null) 'ticket': ticket,
      if (cancelAll) 'cancel_all': true,
      if (cancelAll) 'close_all': true,
    };
    return _request(
      'POST',
      '/api/close-pending-order/${Uri.encodeComponent(accountId)}/',
      body: body,
      requireEncryptedResponse: false,
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

  ({String publicKeyBase64, RSAPrivateKey privateKey})
  _createResponseEncryptionKey() {
    final secureRandom = FortunaRandom()
      ..seed(KeyParameter(_randomBytes(32)));
    final generator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
          secureRandom,
        ),
      );
    final pair = generator.generateKeyPair();
    final publicKey = pair.publicKey;
    final privateKey = pair.privateKey;

    final rsaSequence = ASN1Sequence()
      ..add(ASN1Integer(publicKey.modulus!))
      ..add(ASN1Integer(publicKey.exponent!));
    final algorithmSequence = ASN1Sequence()
      ..add(ASN1ObjectIdentifier.fromComponentString('1.2.840.113549.1.1.1'))
      ..add(ASN1Object.fromBytes(Uint8List.fromList([0x05, 0x00])));
    final subjectPublicKeyInfo = ASN1Sequence()
      ..add(algorithmSequence)
      ..add(ASN1BitString(rsaSequence.encodedBytes));

    return (
      publicKeyBase64: base64Encode(subjectPublicKeyInfo.encodedBytes),
      privateKey: privateKey,
    );
  }

  Map<String, dynamic> _decryptResponseEnvelope(
    Map<String, dynamic> envelope,
    RSAPrivateKey privateKey,
  ) {
    if (envelope['encrypted'] != true ||
        envelope['version'] != 1 ||
        envelope['algorithm'] != 'RSA-OAEP-256+A256GCM') {
      throw const AuthApiException(
        'The server returned an invalid encrypted response.',
      );
    }

    try {
      final aad = Uint8List.fromList(utf8.encode('vtindex:user-info:v1'));
      final wrappedKey = base64Decode(envelope['wrapped_key'] as String);
      final nonce = base64Decode(envelope['nonce'] as String);
      final ciphertext = base64Decode(envelope['ciphertext'] as String);
      final rsa = OAEPEncoding.withSHA256(RSAEngine(), aad)
        ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
      final aesKey = rsa.process(Uint8List.fromList(wrappedKey));
      final aes = GCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(KeyParameter(aesKey), 128, nonce, aad),
        );
      final plaintext = aes.process(Uint8List.fromList(ciphertext));
      final decoded = jsonDecode(utf8.decode(plaintext));
      if (decoded is Map<String, dynamic>) return decoded;
      throw const AuthApiException(
        'The server returned an invalid encrypted response payload.',
      );
    } on AuthApiException {
      rethrow;
    } catch (_) {
      throw const AuthApiException(
        'Could not decrypt the server response. Please retry.',
      );
    }
  }

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
