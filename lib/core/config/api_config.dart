import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// API host selection for local development.
///
/// Override at build time when needed:
/// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
/// Production:
/// flutter build apk --dart-define=API_BASE_URL=https://crm.example.com
class ApiConfig {
  ApiConfig._();

  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_override.trim().isNotEmpty) {
      return _override.trim().replaceFirst(RegExp(r'/+$'), '');
    }

    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    if (Platform.isIOS || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://127.0.0.1:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 25);
}
