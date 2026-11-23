import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Shared HTTP client for the VT-Index Django API.
///
/// Tokens are read from platform secure storage. Authentication endpoints
/// must save tokens only after the backend confirms successful verification.
class ApiClient {
  ApiClient({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'vtindex_mobile_access_token';

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalizedPath')
        .replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({bool authenticated = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool authenticated = true,
  }) async {
    final response = await _client
        .get(_uri(path, query), headers: await _headers(authenticated: authenticated))
        .timeout(ApiConfig.receiveTimeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic> body = const {},
    bool authenticated = true,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = await _headers(authenticated: authenticated);
    if (extraHeaders != null) headers.addAll(extraHeaders);
    final response = await _client
        .post(
          _uri(path),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.receiveTimeout);
    return _decode(response);
  }

  Future<void> saveAccessToken(String token) async {
    if (token.trim().isEmpty) {
      throw const ApiException('The server returned an empty access token.');
    }
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<void> clearAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'The server returned an unreadable response (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? (decoded['error'] ?? decoded['detail'] ?? decoded['message'])
          : null;
      throw ApiException(
        message?.toString() ?? 'Request failed (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException('Unexpected response format from the server.');
  }

  void close() => _client.close();
}
