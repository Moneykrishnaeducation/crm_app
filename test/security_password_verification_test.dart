import 'dart:async';

import 'package:crm_app/biometric_sign_in.dart';
import 'package:crm_app/pages/security_center_page.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class _DisabledBiometricSignIn extends BiometricSignIn {
  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<bool> isAvailable({TargetPlatform? platform}) async => false;
}

void main() {
  testWidgets(
    'Security Center modal only opens when CRM password matches',
    (tester) async {
      bool? modalResult;
      var openedSecurityCenter = false;
      String? capturedPassword;

      Future<Map<String, dynamic>> mockVerify(String password) async {
        capturedPassword = password;
        if (password == 'CorrectCrm@123') {
          return {'verified': true};
        }
        throw AuthApiException('Invalid CRM password', statusCode: 400);
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  modalResult = await showSecurityPasswordModal(
                    context,
                    biometricSignIn: _DisabledBiometricSignIn(),
                    verifyPassword: mockVerify,
                    onVerified: () => openedSecurityCenter = true,
                  );
                },
                child: const Text('Security Center'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Security Center'));
      await tester.pumpAndSettle();

      expect(find.text('Verify your identity'), findsOneWidget);
      expect(find.text('CRM PASSWORD'), findsOneWidget);

      // 1. Empty password is blocked
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump();
      expect(find.text('Enter your CRM password to continue.'), findsOneWidget);
      expect(openedSecurityCenter, isFalse);

      // 2. Wrong CRM password shows error and does NOT open Security Center
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your current password'),
        'WrongPass123',
      );
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      expect(capturedPassword, 'WrongPass123');
      expect(find.text('Invalid CRM password'), findsOneWidget);
      expect(find.text('Verify your identity'), findsOneWidget);
      expect(openedSecurityCenter, isFalse);

      // 3. Matching CRM password unlocks and triggers onVerified
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your current password'),
        'CorrectCrm@123',
      );
      await tester.tap(find.text('Verify & Continue'));
      await tester.pumpAndSettle();

      expect(capturedPassword, 'CorrectCrm@123');
      expect(find.text('Verify your identity'), findsNothing);
      expect(openedSecurityCenter, isTrue);
      expect(modalResult, isTrue);
    },
  );

  testWidgets(
    'Security Center modal rejects {verified: false} payload and toggles obscure text',
    (tester) async {
      var openedSecurityCenter = false;
      final completer = Completer<Map<String, dynamic>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showSecurityPasswordModal(
                  context,
                  biometricSignIn: _DisabledBiometricSignIn(),
                  verifyPassword: (_) => completer.future,
                  onVerified: () => openedSecurityCenter = true,
                ),
                child: const Text('Security Center'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Security Center'));
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.eye), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pump();
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Enter your current password'),
        'AnyPass',
      );
      await tester.tap(find.text('Verify & Continue'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete({'verified': false, 'message': 'Password mismatch'});
      await tester.pumpAndSettle();

      expect(find.text('Password mismatch'), findsOneWidget);
      expect(openedSecurityCenter, isFalse);

      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();
      expect(find.text('Verify your identity'), findsNothing);
    },
  );
}
