import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/biometric_sign_in.dart';
import 'package:crm_app/pages/security_center_page.dart';

class _FakeBiometricSignIn extends BiometricSignIn {
  _FakeBiometricSignIn({
    this.enabled = false,
    this.available = false,
    this.authenticated = false,
    this.shouldThrow = false,
  });

  bool enabled;
  bool available;
  bool authenticated;
  bool shouldThrow;
  int authenticationCount = 0;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<bool> isAvailable({TargetPlatform? platform}) async => available;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticationCount += 1;
    if (shouldThrow) {
      throw Exception('Biometric authentication failed');
    }
    return authenticated;
  }

  @override
  Future<void> setEnabled(bool value) async {
    enabled = value;
  }
}

void main() {
  testWidgets(
    'when biometric is enabled and succeeds, showSecurityPasswordModal authenticates directly without showing sheet',
    (tester) async {
      final fakeBio = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: true,
      );

      bool verifiedCallbackCalled = false;
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showSecurityPasswordModal(
                    context,
                    biometricSignIn: fakeBio,
                    onVerified: () {
                      verifiedCallbackCalled = true;
                    },
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(fakeBio.authenticationCount, 1);
      expect(verifiedCallbackCalled, isTrue);
      expect(result, isTrue);
      // Bottom sheet should NOT be shown
      expect(find.text('Security Verification'), findsNothing);
    },
  );

  testWidgets(
    'when biometric is disabled, password bottom sheet opens, and entering password verifies',
    (tester) async {
      final fakeBio = _FakeBiometricSignIn(
        enabled: false,
        available: true,
        authenticated: false,
      );

      bool verifiedCallbackCalled = false;
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showSecurityPasswordModal(
                    context,
                    biometricSignIn: fakeBio,
                    onVerified: () {
                      verifiedCallbackCalled = true;
                    },
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Bottom sheet should be open
      expect(find.text('Security Verification'), findsOneWidget);
      expect(
        find.text('Enter your CRM password to access Security Center.'),
        findsOneWidget,
      );
      expect(find.text('CRM Password'), findsOneWidget);
      expect(
        find.text('Protected by 256-bit encryption. Your password is not stored.'),
        findsOneWidget,
      );

      // Empty submission shows error
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Password cannot be empty'), findsOneWidget);
      expect(verifiedCallbackCalled, isFalse);

      // Enter password and verify
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your current password'),
        'SecurePassword123',
      );
      await tester.pumpAndSettle();
      expect(find.text('Password cannot be empty'), findsNothing);

      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Security Verification'), findsNothing);
      expect(verifiedCallbackCalled, isTrue);
      expect(result, isTrue);
    },
  );

  testWidgets('dismissing or closing bottom sheet returns false or null', (tester) async {
    final fakeBio = _FakeBiometricSignIn(
      enabled: false,
      available: false,
      authenticated: false,
    );

    bool verifiedCallbackCalled = false;
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showSecurityPasswordModal(
                  context,
                  biometricSignIn: fakeBio,
                  onVerified: () {
                    verifiedCallbackCalled = true;
                  },
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    // 1. Open and close with X button
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Security Verification'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();

    expect(find.text('Security Verification'), findsNothing);
    expect(verifiedCallbackCalled, isFalse);
    expect(result, isFalse);

    // 2. Open and dismiss by tapping modal barrier
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Security Verification'), findsOneWidget);

    // Tap outside bottom sheet on barrier
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('Security Verification'), findsNothing);
    expect(verifiedCallbackCalled, isFalse);
    expect(result, isNull);
  });

  testWidgets(
    'when biometric fails, falls back to password bottom sheet with fingerprint shortcut',
    (tester) async {
      final fakeBio = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: false,
      );

      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showSecurityPasswordModal(
                    context,
                    biometricSignIn: fakeBio,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(fakeBio.authenticationCount, 1);
      // Fallback bottom sheet opened
      expect(find.text('Security Verification'), findsOneWidget);
      expect(find.text('Use Fingerprint instead'), findsOneWidget);

      // Now authenticate via fingerprint shortcut button in bottom sheet
      fakeBio.authenticated = true;
      await tester.tap(find.text('Use Fingerprint instead'));
      await tester.pumpAndSettle();

      expect(fakeBio.authenticationCount, 2);
      expect(find.text('Security Verification'), findsNothing);
      expect(result, isTrue);
    },
  );

  testWidgets(
    'when biometric throws exception, falls back to password bottom sheet',
    (tester) async {
      final fakeBio = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        shouldThrow: true,
      );

      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showSecurityPasswordModal(
                    context,
                    biometricSignIn: fakeBio,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(fakeBio.authenticationCount, 1);
      expect(find.text('Security Verification'), findsOneWidget);

      // Verify with password
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your current password'),
        'TestPass',
      );
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    },
  );
}
