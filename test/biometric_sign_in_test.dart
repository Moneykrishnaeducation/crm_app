import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:crm_app/biometric_sign_in.dart';
import 'package:crm_app/main.dart';
import 'package:crm_app/services/auth_api.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AuthApi.instance.resetForTesting();
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
  });

  test('biometric preference defaults off and can be persisted', () async {
    final biometricSignIn = BiometricSignIn();
    expect(await biometricSignIn.isEnabled(), isFalse);

    await biometricSignIn.setEnabled(true);

    expect(await biometricSignIn.isEnabled(), isTrue);
  });

  test(
    'encrypted biometric credentials survive logout and clear when disabled',
    () async {
      final biometricSignIn = BiometricSignIn();

      // Sign in while biometrics are disabled -> cached only for the active session.
      await biometricSignIn.rememberSessionCredentials(
        identifier: 'trader@vtindex.com',
        password: 'SecretPass!1',
      );
      expect(await biometricSignIn.hasStoredCredentials(), isFalse);

      // Enabling biometrics persists the session credentials to encrypted storage.
      await biometricSignIn.setEnabled(true);
      final saved = await biometricSignIn.readCredentials();
      expect(saved, isNotNull);
      expect(saved!.identifier, 'trader@vtindex.com');
      expect(saved.password, 'SecretPass!1');

      // Logout clears active session cache, keeping encrypted biometric re-login data.
      biometricSignIn.clearSessionCredentials();
      expect(await biometricSignIn.hasStoredCredentials(), isTrue);

      // Disabling biometrics removes the encrypted credentials.
      await biometricSignIn.setEnabled(false);
      expect(await biometricSignIn.hasStoredCredentials(), isFalse);
      expect(await biometricSignIn.readCredentials(), isNull);
    },
  );

  test('biometrics are unavailable outside Android and iOS', () async {
    expect(
      await BiometricSignIn.instance.isAvailable(
        platform: TargetPlatform.linux,
      ),
      isFalse,
    );
  });

  testWidgets(
    'enabled biometrics re-login automatically after logout using stored credentials',
    (tester) async {
      final biometricSignIn = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: true,
        storedCredentials: (
          identifier: 'trader@vtindex.com',
          password: 'SecretPass!1',
        ),
      );
      String? capturedIdentifier;
      String? capturedPassword;
      var loginCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            onLogin: () => loginCalled = true,
            biometricSignIn: biometricSignIn,
            credentialLogin: ({
              required identifier,
              required password,
              required rememberMe,
            }) async {
              capturedIdentifier = identifier;
              capturedPassword = password;
              return {'authenticated': true, 'access_token': 'demo-jwt'};
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(biometricSignIn.authenticationCount, 1);
      expect(capturedIdentifier, 'trader@vtindex.com');
      expect(capturedPassword, 'SecretPass!1');
      expect(loginCalled, isTrue);
    },
  );

  testWidgets(
    'biometric re-login clears stale credentials if server rejects password with 401',
    (tester) async {
      final biometricSignIn = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: true,
        storedCredentials: (
          identifier: 'trader@vtindex.com',
          password: 'OldPassword',
        ),
      );
      var loginCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            onLogin: () => loginCalled = true,
            biometricSignIn: biometricSignIn,
            credentialLogin: ({
              required identifier,
              required password,
              required rememberMe,
            }) async {
              throw const AuthApiException(
                'Invalid credentials',
                statusCode: 401,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(biometricSignIn.authenticationCount, 1);
      expect(loginCalled, isFalse);
      expect(await biometricSignIn.hasStoredCredentials(), isFalse);
    },
  );

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
    expect(find.byIcon(Icons.fingerprint), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'unavailable biometric sign-in keeps password fallback available and hides fingerprint button',
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
      expect(find.byIcon(Icons.fingerprint), findsNothing);
      expect(find.text('Username or Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
    },
  );

  testWidgets(
    'shows fingerprint button when enabled without prompting until credentials exist',
    (tester) async {
      final biometricSignIn = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            onLogin: () {},
            biometricSignIn: biometricSignIn,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
      expect(biometricSignIn.authenticationCount, 0);
    },
  );

  testWidgets(
    'readCredentials is not called when biometric authenticate returns false',
    (tester) async {
      final biometricSignIn = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: false,
        storedCredentials: (
          identifier: 'trader@vtindex.com',
          password: 'SecretPass!1',
        ),
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
      expect(biometricSignIn.readCredentialsCount, 0);
      expect(loginCalled, isFalse);
    },
  );

  testWidgets(
    'biometric re-login clears stale credentials if server rejects password with 403',
    (tester) async {
      final biometricSignIn = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: true,
        storedCredentials: (
          identifier: 'trader@vtindex.com',
          password: 'OldPassword',
        ),
      );
      var loginCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            onLogin: () => loginCalled = true,
            biometricSignIn: biometricSignIn,
            credentialLogin: ({
              required identifier,
              required password,
              required rememberMe,
            }) async {
              throw const AuthApiException(
                'Account access forbidden',
                statusCode: 403,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(biometricSignIn.authenticationCount, 1);
      expect(biometricSignIn.readCredentialsCount, 1);
      expect(loginCalled, isFalse);
      expect(await biometricSignIn.hasStoredCredentials(), isFalse);
    },
  );

  testWidgets(
    'stale AuthApi token without stored biometric credentials does not trigger biometric prompt',
    (tester) async {
      AuthApi.instance.setSessionForTesting(accessToken: 'stale-jwt');
      AuthApi.instance.setHttpClientForTesting(
        MockClient((request) async {
          if (request.url.path.endsWith('/login/')) {
            return http.Response(jsonEncode({'authenticated': false}), 401);
          }
          return http.Response('{}', 200);
        }),
      );
      final biometricSignIn = _FakeBiometricSignIn(
        enabled: true,
        available: true,
        authenticated: true,
        storedCredentials: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            onLogin: () {},
            biometricSignIn: biometricSignIn,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(biometricSignIn.authenticationCount, 0);
      expect(biometricSignIn.readCredentialsCount, 0);
    },
  );
}

class _FakeBiometricSignIn extends BiometricSignIn {
  _FakeBiometricSignIn({
    required this.enabled,
    required this.available,
    required this.authenticated,
    this.storedCredentials,
  });

  bool enabled;
  final bool available;
  final bool authenticated;
  BiometricCredentials? storedCredentials;
  int authenticationCount = 0;
  int readCredentialsCount = 0;

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
    if (!value) storedCredentials = null;
  }

  @override
  Future<void> saveCredentials({
    required String identifier,
    required String password,
  }) async {
    storedCredentials = (identifier: identifier, password: password);
  }

  @override
  Future<BiometricCredentials?> readCredentials() async {
    readCredentialsCount += 1;
    return storedCredentials;
  }

  @override
  Future<bool> hasStoredCredentials() async => storedCredentials != null;

  @override
  Future<void> clearCredentials() async {
    storedCredentials = null;
  }
}
