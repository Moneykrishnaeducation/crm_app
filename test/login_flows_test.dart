import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crm_app/main.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _buildTestRsaPublicKeyPem() {
  final random = Random.secure();
  final secureRandom = FortunaRandom()
    ..seed(
      KeyParameter(
        Uint8List.fromList(List<int>.generate(32, (_) => random.nextInt(256))),
      ),
    );
  final generator = RSAKeyGenerator()
    ..init(
      ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        secureRandom,
      ),
    );
  final publicKey = generator.generateKeyPair().publicKey;

  List<int> derLength(int length) {
    if (length < 0x80) return <int>[length];
    final bytes = <int>[];
    var remaining = length;
    while (remaining > 0) {
      bytes.insert(0, remaining & 0xff);
      remaining >>= 8;
    }
    return <int>[0x80 | bytes.length, ...bytes];
  }

  List<int> derValue(int tag, List<int> value) => <int>[
        tag,
        ...derLength(value.length),
        ...value,
      ];

  List<int> unsignedBigIntBytes(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    final bytes = <int>[
      for (var offset = 0; offset < hex.length; offset += 2)
        int.parse(hex.substring(offset, offset + 2), radix: 16),
    ];
    if (bytes.isEmpty) return <int>[0];
    if ((bytes.first & 0x80) != 0) bytes.insert(0, 0);
    return bytes;
  }

  final rsaPublicKey = derValue(0x30, <int>[
    ...derValue(0x02, unsignedBigIntBytes(publicKey.modulus!)),
    ...derValue(0x02, unsignedBigIntBytes(publicKey.exponent!)),
  ]);
  final rsaEncryptionAlgorithm = derValue(0x30, <int>[
    ...derValue(0x06, <int>[
      0x2a,
      0x86,
      0x48,
      0x86,
      0xf7,
      0x0d,
      0x01,
      0x01,
      0x01,
    ]),
    ...derValue(0x05, const <int>[]),
  ]);
  final spki = derValue(0x30, <int>[
    ...rsaEncryptionAlgorithm,
    ...derValue(0x03, <int>[0, ...rsaPublicKey]),
  ]);

  final b64 = base64Encode(spki);
  return '-----BEGIN PUBLIC KEY-----\n$b64\n-----END PUBLIC KEY-----';
}

Future<void> _flushAsync(WidgetTester tester, {int ticks = 4}) async {
  for (var i = 0; i < ticks; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }
}

void main() {
  late String testPublicKeyPem;

  setUpAll(() {
    testPublicKeyPem = _buildTestRsaPublicKeyPem();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AuthApi.instance.resetForTesting();
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
  });

  Widget buildTestApp(Widget home) {
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      home: home,
    );
  }

  testWidgets(
    'stale hasToken after isAuthenticated() == false does not enter dashboard',
    (tester) async {
      var statusCalls = 0;
      var loginSucceeded = false;

      AuthApi.instance.setHttpClientForTesting(
        MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('/security/captcha/config/')) {
            return http.Response(jsonEncode({'enabled': false}), 200);
          }
          if (path.endsWith('/login/encryption-challenge/')) {
            return http.Response(
              jsonEncode({
                'challenge_id': 'chal-1',
                'public_key': testPublicKeyPem,
              }),
              200,
            );
          }
          if (path.endsWith('/login/')) {
            return http.Response(
              jsonEncode({'access_token': 'stale-or-revoked-jwt'}),
              200,
            );
          }
          if (path.endsWith('/status/')) {
            statusCalls++;
            return http.Response(
              jsonEncode({'detail': 'Session revoked'}),
              401,
            );
          }
          if (path.endsWith('/logout/')) {
            return http.Response(jsonEncode({'success': true}), 200);
          }
          return http.Response('{}', 200);
        }),
      );
      await tester.runAsync(() => AuthApi.instance.getCaptchaConfig());

      await tester.pumpWidget(
        buildTestApp(LoginPage(onLogin: () => loginSucceeded = true)),
      );
      await _flushAsync(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'trader@vtindex.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'StrongPass123!',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await _flushAsync(tester, ticks: 8);
      await tester.pumpAndSettle();

      expect(statusCalls, 1);
      expect(AuthApi.instance.hasToken, isFalse);
      expect(loginSucceeded, isFalse);
      expect(
        find.text('The server did not confirm an authenticated session.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'login OTP dialog validates 4-8 digits, handles nested verifyOtp data, and disposes cleanly',
    (tester) async {
      var verifyOtpCalls = 0;
      var loginSucceeded = false;

      AuthApi.instance.setHttpClientForTesting(
        MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('/security/captcha/config/')) {
            return http.Response(jsonEncode({'enabled': false}), 200);
          }
          if (path.endsWith('/login-otp-status/')) {
            return http.Response(jsonEncode({'sent': true}), 200);
          }
          if (path.endsWith('/verify-otp/')) {
            verifyOtpCalls++;
            return http.Response(
              jsonEncode({
                'data': {
                  'authenticated': true,
                  'access_token': 'verified-jwt',
                },
              }),
              200,
            );
          }
          if (path.endsWith('/status/')) {
            return http.Response(jsonEncode({'authenticated': true}), 200);
          }
          return http.Response('{}', 200);
        }),
      );
      await tester.runAsync(() => AuthApi.instance.getCaptchaConfig());

      await tester.pumpWidget(
        buildTestApp(
          LoginPage(
            onLogin: () => loginSucceeded = true,
            credentialLogin: ({
              required identifier,
              required password,
              required rememberMe,
            }) async => {'otp_required': true},
          ),
        ),
      );
      await _flushAsync(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'trader@vtindex.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'StrongPass123!',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      // Note: _loginBusy is true while the OTP dialog is open, so pump frames instead of pumpAndSettle.
      await _flushAsync(tester, ticks: 6);

      expect(find.text('Verify your login'), findsOneWidget);

      // Empty OTP should show inline validation and keep dialog open.
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pump();
      expect(
        find.text('Please enter the verification code.'),
        findsOneWidget,
      );
      expect(verifyOtpCalls, 0);

      // Short OTP (< 4 digits) should show inline validation and keep dialog open.
      await tester.enterText(find.byType(TextField).last, '12');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await tester.pump();
      expect(
        find.text('Please enter a valid 4–8 digit verification code.'),
        findsOneWidget,
      );
      expect(verifyOtpCalls, 0);

      // Valid 6-digit OTP submits and closes dialog cleanly without disposal errors.
      await tester.enterText(find.byType(TextField).last, '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await _flushAsync(tester, ticks: 8);
      await tester.pumpAndSettle();

      expect(verifyOtpCalls, 1);
      expect(loginSucceeded, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'nested captcha_required in verifyOtp response blocks login with clear message',
    (tester) async {
      var loginSucceeded = false;

      AuthApi.instance.setHttpClientForTesting(
        MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('/security/captcha/config/')) {
            return http.Response(jsonEncode({'enabled': true}), 200);
          }
          if (path.endsWith('/login-otp-status/')) {
            return http.Response(jsonEncode({'sent': true}), 200);
          }
          if (path.endsWith('/verify-otp/')) {
            return http.Response(
              jsonEncode({
                'data': {'captcha_required': true},
              }),
              200,
            );
          }
          return http.Response('{}', 200);
        }),
      );
      await tester.runAsync(() => AuthApi.instance.getCaptchaConfig());

      await tester.pumpWidget(
        buildTestApp(
          LoginPage(
            onLogin: () => loginSucceeded = true,
            credentialLogin: ({
              required identifier,
              required password,
              required rememberMe,
            }) async => {'otp_required': true},
          ),
        ),
      );
      await _flushAsync(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'trader@vtindex.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'StrongPass123!',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await _flushAsync(tester, ticks: 6);

      await tester.enterText(find.byType(TextField).last, '654321');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
      await _flushAsync(tester, ticks: 8);
      await tester.pumpAndSettle();

      expect(loginSucceeded, isFalse);
      expect(
        find.textContaining('CAPTCHA verification is required'),
        findsOneWidget,
      );
    },
  );

  testWidgets('double-submit protection prevents duplicate login requests', (
    tester,
  ) async {
    var calls = 0;
    var loginSucceeded = false;
    final completer = Completer<Map<String, dynamic>>();

    await tester.pumpWidget(
      buildTestApp(
        LoginPage(
          onLogin: () => loginSucceeded = true,
          credentialLogin: ({
            required identifier,
            required password,
            required rememberMe,
          }) {
            calls++;
            return completer.future;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'trader@vtindex.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'StrongPass123!',
    );

    final loginBtn = find.widgetWithText(FilledButton, 'Login');
    await tester.tap(loginBtn);
    await tester.pump();

    expect(find.widgetWithText(FilledButton, 'Connecting…'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Connecting…'));
    await tester.pump();

    expect(calls, 1);

    completer.complete({'authenticated': true, 'access_token': 'jwt-1'});
    await tester.pumpAndSettle();

    expect(loginSucceeded, isTrue);
  });

  testWidgets(
    'Sign-Up keeps separate controllers, validates properly, guards OTP & signup double-submit',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'vtindex_remember_login': true,
        'vtindex_login_identifier': 'remembered@vtindex.com',
      });

      var sendOtpCalls = 0;
      var verifyOtpCalls = 0;
      var signupCalls = 0;
      final verifyOtpCompleter = Completer<void>();
      final signupCompleter = Completer<void>();

      AuthApi.instance.setHttpClientForTesting(
        MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('/security/captcha/config/')) {
            return http.Response(jsonEncode({'enabled': false}), 200);
          }
          if (path.endsWith('/send-signup-otp/')) {
            sendOtpCalls++;
            if (sendOtpCalls == 1) {
              return http.Response(
                jsonEncode({'message': 'Temporary mail failure'}),
                500,
              );
            }
            return http.Response(jsonEncode({'success': true}), 200);
          }
          if (path.endsWith('/verify-signup-otp/')) {
            verifyOtpCalls++;
            await verifyOtpCompleter.future;
            return http.Response(jsonEncode({'verified': true}), 200);
          }
          if (path.endsWith('/pub/rsa_key/')) {
            return http.Response(
              jsonEncode({
                'kid': 'kid-1',
                'public_key': testPublicKeyPem,
                'nonce': 'nonce-1',
              }),
              200,
            );
          }
          if (path.endsWith('/signup/')) {
            signupCalls++;
            await signupCompleter.future;
            return http.Response(jsonEncode({'success': true}), 200);
          }
          return http.Response('{}', 200);
        }),
      );
      await tester.runAsync(() => AuthApi.instance.getCaptchaConfig());

      await tester.pumpWidget(buildTestApp(LoginPage(onLogin: () {})));
      await _flushAsync(tester);

      // Remembered login email is populated in Login mode.
      expect(find.text('remembered@vtindex.com'), findsOneWidget);

      // Switch to Sign-Up: remembered login email must NOT leak into Sign-Up.
      await tester.ensureVisible(find.textContaining('Sign up'));
      await tester.tap(find.textContaining('Sign up'));
      await tester.pumpAndSettle();

      expect(find.text('remembered@vtindex.com'), findsNothing);

      // Empty submit shows empty email error without overwriting with verify error.
      final createAccountBtn = find.widgetWithText(
        FilledButton,
        'Create Account',
      );
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pump();

      expect(find.text('Please enter your full name.'), findsOneWidget);
      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(
        find.text('Please verify your email address to continue.'),
        findsNothing,
      );

      // Invalid email shows regex validation error.
      await tester.enterText(find.byType(TextFormField).at(0), 'Alice Trader');
      await tester.enterText(find.byType(TextFormField).at(1), 'bad@email');
      await tester.enterText(find.byType(TextFormField).at(3), 'Password123!');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await tester.pump();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(find.text('Verify Email Address'), findsNothing);

      // Valid email opens verification modal via Verify button.
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'alice@vtindex.com',
      );
      final verifyBtn = find.widgetWithText(FilledButton, 'Verify');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await _flushAsync(tester, ticks: 6);
      await tester.pumpAndSettle();

      expect(find.text('Verify Email Address'), findsOneWidget);
      expect(sendOtpCalls, 1);

      // Initial send failed -> immediate resend must be available (not stuck at 00:45).
      expect(find.text('Resend OTP Code'), findsOneWidget);
      expect(find.textContaining('Resend code in'), findsNothing);

      await tester.tap(find.text('Resend OTP Code'));
      await _flushAsync(tester, ticks: 6);
      await tester.pump();
      expect(sendOtpCalls, 2);
      expect(find.textContaining('Resend code in 00:'), findsOneWidget);

      // Less than 6 digits must not call verifySignupOtp.
      final otpField = find.byType(TextField).last;
      await tester.enterText(otpField, '1234');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify Email'));
      await tester.pump();
      expect(
        find.text('Please enter the complete 6-digit verification code.'),
        findsOneWidget,
      );
      expect(verifyOtpCalls, 0);

      // Entering 6 digits auto-submits; tapping Verify Email while in flight must not double-submit.
      await tester.enterText(otpField, '123456');
      await _flushAsync(tester, ticks: 3);
      expect(verifyOtpCalls, 1);
      expect(find.widgetWithText(FilledButton, 'Verifying…'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Verifying…'));
      await tester.pump();
      expect(verifyOtpCalls, 1);

      verifyOtpCompleter.complete();
      await _flushAsync(tester, ticks: 6);
      await tester.pumpAndSettle();

      expect(find.text('Verify Email Address'), findsNothing);
      expect(find.text('Verified'), findsOneWidget);

      // Double-submit on Create Account calls signup only once.
      await tester.ensureVisible(createAccountBtn);
      await tester.tap(createAccountBtn);
      await _flushAsync(tester, ticks: 4);
      expect(
        find.widgetWithText(FilledButton, 'Creating Account…'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Creating Account…'));
      await tester.pump();
      expect(signupCalls, 1);

      signupCompleter.complete();
      await _flushAsync(tester, ticks: 6);
      await tester.pumpAndSettle();
      expect(
        find.text('Your account request was submitted successfully.'),
        findsOneWidget,
      );

      // Switch back to Login: Sign-Up email must NOT leak into Login.
      await tester.ensureVisible(find.textContaining('Already have an account?'));
      await tester.tap(find.textContaining('Already have an account?'));
      await tester.pumpAndSettle();
      expect(find.text('alice@vtindex.com'), findsNothing);
      expect(find.text('remembered@vtindex.com'), findsOneWidget);
    },
  );

  testWidgets(
    'Forgot Password flow validates email/6-digit OTP, clears OTP on Change, and guards double-submit',
    (tester) async {
      var sendResetCalls = 0;
      var verifyOtpCalls = 0;
      var confirmResetCalls = 0;
      final sendResetCompleter = Completer<void>();
      final verifyOtpCompleter = Completer<void>();
      final confirmResetCompleter = Completer<void>();

      AuthApi.instance.setHttpClientForTesting(
        MockClient((request) async {
          final path = request.url.path;
          if (path.endsWith('/security/captcha/config/')) {
            return http.Response(jsonEncode({'enabled': false}), 200);
          }
          if (path.endsWith('/send-reset-otp/')) {
            sendResetCalls++;
            if (sendResetCalls == 1) {
              await sendResetCompleter.future;
            }
            return http.Response(jsonEncode({'success': true}), 200);
          }
          if (path.endsWith('/verify-otp/')) {
            verifyOtpCalls++;
            await verifyOtpCompleter.future;
            return http.Response(
              jsonEncode({'reset_token': 'reset-tok-1'}),
              200,
            );
          }
          if (path.endsWith('/pub/rsa_key/')) {
            return http.Response(
              jsonEncode({
                'kid': 'kid-1',
                'public_key': testPublicKeyPem,
                'nonce': 'nonce-1',
              }),
              200,
            );
          }
          if (path.endsWith('/reset-password/confirm/')) {
            confirmResetCalls++;
            await confirmResetCompleter.future;
            return http.Response(jsonEncode({'success': true}), 200);
          }
          return http.Response('{}', 200);
        }),
      );
      await tester.runAsync(() => AuthApi.instance.getCaptchaConfig());

      await tester.pumpWidget(buildTestApp(LoginPage(onLogin: () {})));
      await _flushAsync(tester);

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Email Address'), findsOneWidget);

      // Invalid email rejected by RegExp.
      await tester.enterText(find.byType(TextFormField).last, 'invalid@domain');
      await tester.tap(find.widgetWithText(FilledButton, 'Send OTP'));
      await tester.pump();
      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      expect(sendResetCalls, 0);

      // Valid email + double tap Send OTP -> only 1 API call.
      await tester.enterText(
        find.byType(TextFormField).last,
        'reset@vtindex.com',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Send OTP'));
      await _flushAsync(tester, ticks: 3);
      expect(find.widgetWithText(FilledButton, 'Sending OTP…'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Sending OTP…'));
      await tester.pump();
      expect(sendResetCalls, 1);

      sendResetCompleter.complete();
      await _flushAsync(tester, ticks: 6);
      await tester.pump();

      expect(find.text('Enter Verification Code'), findsOneWidget);

      // Partial OTP (< 6 digits) shows error and does not verify.
      await tester.enterText(find.byType(TextField).last, '1234');
      await tester.tap(find.widgetWithText(FilledButton, 'Verify OTP'));
      await tester.pump();
      expect(
        find.text('Please enter the complete 6-digit verification code.'),
        findsOneWidget,
      );
      expect(verifyOtpCalls, 0);

      // Tapping Change returns to Step 1 and clears OTP controller.
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm Email Address'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Send OTP'));
      await _flushAsync(tester, ticks: 6);
      await tester.pump();
      expect(find.text('Enter Verification Code'), findsOneWidget);
      final otpTextField = tester.widget<TextField>(find.byType(TextField).last);
      expect(otpTextField.controller!.text, isEmpty);

      // 6 digits auto-submits once; tapping Verify OTP while busy does not duplicate.
      await tester.enterText(find.byType(TextField).last, '654321');
      await _flushAsync(tester, ticks: 3);
      expect(verifyOtpCalls, 1);
      expect(find.widgetWithText(FilledButton, 'Verifying…'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Verifying…'));
      await tester.pump();
      expect(verifyOtpCalls, 1);

      verifyOtpCompleter.complete();
      await _flushAsync(tester, ticks: 6);
      await tester.pumpAndSettle();

      expect(find.text('Create New Password'), findsOneWidget);

      // Mismatched passwords show inline error.
      final step3Fields = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(step3Fields.at(0), 'NewPass123!');
      await tester.enterText(step3Fields.at(1), 'Mismatch123!');
      await tester.tap(find.widgetWithText(FilledButton, 'Reset Password'));
      await tester.pump();
      expect(
        find.text('Passwords do not match. Please re-enter.'),
        findsOneWidget,
      );
      expect(confirmResetCalls, 0);

      // Matching passwords + double tap Reset Password -> only 1 API call.
      await tester.enterText(step3Fields.at(1), 'NewPass123!');
      await tester.tap(find.widgetWithText(FilledButton, 'Reset Password'));
      await _flushAsync(tester, ticks: 4);
      expect(find.widgetWithText(FilledButton, 'Resetting…'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Resetting…'));
      await tester.pump();
      expect(confirmResetCalls, 1);

      confirmResetCompleter.complete();
      await _flushAsync(tester, ticks: 6);
      await tester.pumpAndSettle();

      expect(find.text('Password Reset Done!'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Back to Login'));
      await tester.pumpAndSettle();

      // Login fields updated with reset credentials.
      expect(find.text('reset@vtindex.com'), findsOneWidget);
    },
  );
}
