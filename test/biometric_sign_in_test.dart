import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crm_app/biometric_sign_in.dart';
import 'package:crm_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('biometric preference defaults off and can be persisted', () async {
    final biometricSignIn = BiometricSignIn.instance;
    expect(await biometricSignIn.isEnabled(), isFalse);

    await biometricSignIn.setEnabled(true);

    expect(await biometricSignIn.isEnabled(), isTrue);
  });

  test('biometrics are unavailable outside Android and iOS', () async {
    expect(
      await BiometricSignIn.instance.isAvailable(
        platform: TargetPlatform.linux,
      ),
      isFalse,
    );
  });

  testWidgets('enabled biometrics authenticate automatically on login', (
    tester,
  ) async {
    final biometricSignIn = _FakeBiometricSignIn(
      enabled: true,
      available: true,
      authenticated: true,
    );
    var loginCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          onLogin: () => loginCalled = true,
          biometricSignIn: biometricSignIn,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(biometricSignIn.authenticationCount, 1);
    expect(loginCalled, isTrue);
  });

  testWidgets('login does not show biometric sign-in unless it is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.linux),
        home: LoginPage(onLogin: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Use fingerprint / Face ID'), findsNothing);
    expect(find.textContaining('Biometric sign-in unavailable'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'unavailable biometric sign-in keeps password fallback available',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        BiometricSignIn.enabledPreferenceKey: true,
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.linux),
          home: LoginPage(onLogin: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Biometric sign-in unavailable'),
        findsOneWidget,
      );
      expect(find.text('Phone number, email or username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
    },
  );
}

class _FakeBiometricSignIn extends BiometricSignIn {
  _FakeBiometricSignIn({
    required this.enabled,
    required this.available,
    required this.authenticated,
  });

  bool enabled;
  final bool available;
  final bool authenticated;
  int authenticationCount = 0;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<bool> isAvailable({TargetPlatform? platform}) async => available;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticationCount += 1;
    return authenticated;
  }

  @override
  Future<void> setEnabled(bool value) async {
    enabled = value;
  }
}
