import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef BiometricCredentials = ({String identifier, String password});

class BiometricSignIn {
  BiometricSignIn({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static final BiometricSignIn instance = BiometricSignIn();
  static const enabledPreferenceKey = 'vtindex_biometric_sign_in_enabled';
  static const _identifierStorageKey = 'vtindex_biometric_identifier';
  static const _passwordStorageKey = 'vtindex_biometric_password';
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  String? _sessionIdentifier;
  String? _sessionPassword;

  Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(enabledPreferenceKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(enabledPreferenceKey, enabled);
    if (!enabled) {
      await clearCredentials();
    } else if (_sessionIdentifier != null && _sessionPassword != null) {
      await saveCredentials(
        identifier: _sessionIdentifier!,
        password: _sessionPassword!,
      );
    }
  }

  /// Stores the current authenticated credentials in memory for the active
  /// session and writes them to hardware-backed encrypted storage when
  /// biometric sign-in is enabled.
  Future<void> rememberSessionCredentials({
    required String identifier,
    required String password,
  }) async {
    final normalized = identifier.trim();
    if (normalized.isEmpty || password.isEmpty) return;
    _sessionIdentifier = normalized;
    _sessionPassword = password;
    if (await isEnabled()) {
      await saveCredentials(identifier: normalized, password: password);
    }
  }

  /// Clears only the in-memory session copy on logout while retaining any
  /// encrypted biometric re-login credentials.
  void clearSessionCredentials() {
    _sessionIdentifier = null;
    _sessionPassword = null;
  }

  Future<void> saveCredentials({
    required String identifier,
    required String password,
  }) async {
    final normalized = identifier.trim();
    if (normalized.isEmpty || password.isEmpty) return;
    try {
      await _secureStorage.write(key: _identifierStorageKey, value: normalized);
      await _secureStorage.write(key: _passwordStorageKey, value: password);
    } catch (_) {
      // Secure storage may be unavailable on unsupported test/desktop targets.
    }
  }

  Future<BiometricCredentials?> readCredentials() async {
    try {
      final identifier = await _secureStorage.read(key: _identifierStorageKey);
      final password = await _secureStorage.read(key: _passwordStorageKey);
      if (identifier == null ||
          identifier.isEmpty ||
          password == null ||
          password.isEmpty) {
        return null;
      }
      return (identifier: identifier, password: password);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasStoredCredentials() async {
    return (await readCredentials()) != null;
  }

  Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: _identifierStorageKey);
      await _secureStorage.delete(key: _passwordStorageKey);
    } catch (_) {
      // Ignore deletion errors if secure storage is unavailable.
    }
  }

  Future<bool> isAvailable({TargetPlatform? platform}) async {
    final currentPlatform = platform ?? defaultTargetPlatform;
    if (kIsWeb ||
        (currentPlatform != TargetPlatform.android &&
            currentPlatform != TargetPlatform.iOS)) {
      return false;
    }

    try {
      if (!await _localAuth.isDeviceSupported()) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      return (await _localAuth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String localizedReason}) {
    return _localAuth.authenticate(
      localizedReason: localizedReason,
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
