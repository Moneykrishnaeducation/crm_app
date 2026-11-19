import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricSignIn {
  BiometricSignIn({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  static final BiometricSignIn instance = BiometricSignIn();
  static const enabledPreferenceKey = 'vtindex_biometric_sign_in_enabled';
  final LocalAuthentication _localAuth;

  Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(enabledPreferenceKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(enabledPreferenceKey, enabled);
  }

  Future<bool> isAvailable({TargetPlatform? platform}) async {
    final currentPlatform = platform ?? defaultTargetPlatform;
    if (kIsWeb ||
        (currentPlatform != TargetPlatform.android &&
            currentPlatform != TargetPlatform.iOS)) {
      return false;
    }

    if (!await _localAuth.isDeviceSupported()) return false;
    return (await _localAuth.getAvailableBiometrics()).isNotEmpty;
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
