import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crm_app/biometric_sign_in.dart';
import 'package:crm_app/pages/security_center_page.dart';
import 'package:crm_app/services/auth_api.dart';

final _requestedPaths = <String>[];

void main() {
  setUp(() async {
    _requestedPaths.clear();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AuthApi.instance.resetForTesting();
    AuthApi.instance.setSessionForTesting(accessToken: 'test-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        _requestedPaths.add(request.url.path);
        final Map<String, dynamic> body;
        if (request.url.path.endsWith('/profile/')) {
          body = {
            'data': {
              'profile': {'email': 'trader@example.com'},
            },
          };
        } else {
          body = {};
        }
        return http.Response(
          jsonEncode(body),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
  });

  testWidgets(
    'loads the signed-in email and allows biometric verification on password change',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final biometric = _FakeBiometricSignIn();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecurityCenterPage(
              onBack: () {},
              onSelectPage: (_) {},
              biometricSignIn: biometric,
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await tester.pump();

      expect(_requestedPaths, contains('/client/api/profile/'));
      expect(find.text('trader@example.com'), findsOneWidget);

      await tester.tap(find.text('Change'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(biometric.authenticationCount, 1);
      expect(find.text('Use biometrics instead'), findsNothing);
      expect(
        find.widgetWithText(TextField, 'Enter your current CRM password'),
        findsNothing,
      );
      expect(find.byType(TextField), findsNWidgets(2));

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      expect(
        find.text('Use at least 8 characters for your new password.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).at(0), 'NewPassword123!');
      await tester.pump(const Duration(milliseconds: 220));
      expect(
        find.text('Use at least 8 characters for your new password.'),
        findsNothing,
      );
      await tester.enterText(find.byType(TextField).at(1), 'NewPassword123!');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Review password change'), findsOneWidget);
    },
  );
}

class _FakeBiometricSignIn extends BiometricSignIn {
  int authenticationCount = 0;

  @override
  Future<bool> isEnabled() async => true;

  @override
  Future<bool> isAvailable({TargetPlatform? platform}) async => true;

  @override
  Future<bool> hasStoredCredentials() async => true;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticationCount++;
    return true;
  }

  @override
  Future<BiometricCredentials?> readCredentials() async =>
      (identifier: 'trader@example.com', password: 'CurrentPassword123!');
}
