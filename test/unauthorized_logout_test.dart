import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:crm_app/main.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _generateTestChallengePem() {
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
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 1024, 64),
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
  final rsaAlgorithm = derValue(0x30, <int>[
    ...derValue(0x06, <int>[0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01]),
    ...derValue(0x05, const <int>[]),
  ]);
  final spki = derValue(0x30, <int>[
    ...rsaAlgorithm,
    ...derValue(0x03, <int>[0, ...rsaPublicKey]),
  ]);
  return '-----BEGIN PUBLIC KEY-----\n${base64Encode(spki)}\n-----END PUBLIC KEY-----';
}

Map<String, dynamic> _encryptResponseEnvelope(
  Map<String, dynamic> payload,
  String responsePublicKeyBase64,
) {
  final der = base64Decode(responsePublicKeyBase64);
  final spki = ASN1Parser(der).nextObject() as ASN1Sequence;
  final bits = spki.elements[1] as ASN1BitString;
  final rsaSeq =
      ASN1Parser(Uint8List.fromList(bits.valueBytes().skip(1).toList()))
              .nextObject()
          as ASN1Sequence;
  final modulus = (rsaSeq.elements[0] as ASN1Integer).valueAsBigInteger;
  final exponent = (rsaSeq.elements[1] as ASN1Integer).valueAsBigInteger;

  final random = Random.secure();
  Uint8List randBytes(int length) =>
      Uint8List.fromList(List<int>.generate(length, (_) => random.nextInt(256)));
  final aesKey = randBytes(32);
  final nonce = randBytes(12);
  final aad = Uint8List.fromList(utf8.encode('vtindex:user-info:v1'));

  final gcm = GCMBlockCipher(AESEngine())
    ..init(true, AEADParameters(KeyParameter(aesKey), 128, nonce, aad));
  final ciphertext = gcm.process(
    Uint8List.fromList(utf8.encode(jsonEncode(payload))),
  );

  final secureRandom = FortunaRandom()..seed(KeyParameter(randBytes(32)));
  final rsa = OAEPEncoding.withSHA256(RSAEngine(), aad)
    ..init(
      true,
      ParametersWithRandom(
        PublicKeyParameter<RSAPublicKey>(RSAPublicKey(modulus, exponent)),
        secureRandom,
      ),
    );
  final wrappedKey = rsa.process(aesKey);

  return <String, dynamic>{
    'encrypted': true,
    'wrapped_key': base64Encode(wrappedKey),
    'nonce': base64Encode(nonce),
    'ciphertext': base64Encode(ciphertext),
  };
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'vtindex_client_access_token': 'stored-jwt-token',
    });
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AuthApi.instance.resetForTesting();
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
  });

  test('HTTP 401 triggers logout API call, clears session, and emits event', () async {
    final requestedPaths = <String>[];
    final events = <int>[];
    final sub = AuthApi.instance.onUnauthorizedSession.listen(events.add);
    addTearDown(sub.cancel);

    AuthApi.instance.setSessionForTesting(
      accessToken: 'active-token',
      cookies: <String, String>{'client_access_token': 'active-token'},
    );
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        requestedPaths.add(request.url.path);
        if (request.url.path.endsWith('/profile/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{'detail': 'Authentication credentials were not provided.'}),
            401,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/logout/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{'success': true}),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      AuthApi.instance.getProfile(),
      throwsA(isA<AuthApiException>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    expect(requestedPaths, contains('/client/api/profile/'));
    expect(requestedPaths.where((p) => p.endsWith('/logout/')).length, 1);
    expect(events, <int>[401]);
    expect(AuthApi.instance.hasToken, isFalse);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('vtindex_client_access_token'), isNull);
  });

  test('HTTP 403 triggers logout API call, clears session, and emits event', () async {
    final requestedPaths = <String>[];
    final events = <int>[];
    final sub = AuthApi.instance.onUnauthorizedSession.listen(events.add);
    addTearDown(sub.cancel);

    AuthApi.instance.setSessionForTesting(accessToken: 'active-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        requestedPaths.add(request.url.path);
        if (request.url.path.endsWith('/mobile/accounts/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{'detail': 'Forbidden'}),
            403,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }
        if (request.url.path.endsWith('/logout/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{'success': true}),
            200,
          );
        }
        return http.Response('{}', 200);
      }),
    );

    await expectLater(
      AuthApi.instance.getMobileAccounts(),
      throwsA(isA<AuthApiException>().having((e) => e.statusCode, 'statusCode', 403)),
    );

    expect(requestedPaths.where((p) => p.endsWith('/logout/')).length, 1);
    expect(events, <int>[403]);
    expect(AuthApi.instance.hasToken, isFalse);
  });

  test('non-JSON 401 response and 401 from logout endpoint do not loop', () async {
    var logoutCalls = 0;
    final events = <int>[];
    final sub = AuthApi.instance.onUnauthorizedSession.listen(events.add);
    addTearDown(sub.cancel);

    AuthApi.instance.setSessionForTesting(accessToken: 'active-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/logout/')) {
          logoutCalls++;
          return http.Response('{"detail": "Already logged out"}', 401);
        }
        return http.Response('<html>401 Unauthorized</html>', 401);
      }),
    );

    await expectLater(
      AuthApi.instance.getProfile(),
      throwsA(isA<AuthApiException>().having((e) => e.statusCode, 'statusCode', 401)),
    );

    expect(logoutCalls, 1);
    expect(events, <int>[401]);
    expect(AuthApi.instance.hasToken, isFalse);
  });

  test('concurrent 401/403 responses deduplicate logout API call', () async {
    var logoutCalls = 0;
    final logoutCompleter = Completer<void>();

    AuthApi.instance.setSessionForTesting(accessToken: 'active-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/logout/')) {
          logoutCalls++;
          await logoutCompleter.future;
          return http.Response('{"success": true}', 200);
        }
        return http.Response('{"detail": "Unauthorized"}', 401);
      }),
    );

    final f1 = expectLater(
      AuthApi.instance.getProfile(),
      throwsA(isA<AuthApiException>()),
    );
    final f2 = expectLater(
      AuthApi.instance.getNotifications(),
      throwsA(isA<AuthApiException>()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    logoutCompleter.complete();
    await Future.wait(<Future<void>>[f1, f2]);

    expect(logoutCalls, 1);
    expect(AuthApi.instance.hasToken, isFalse);
  });

  test('401 on login endpoint does not trigger logout or session expired event', () async {
    var logoutCalls = 0;
    final events = <int>[];
    final sub = AuthApi.instance.onUnauthorizedSession.listen(events.add);
    addTearDown(sub.cancel);

    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/logout/')) {
          logoutCalls++;
          return http.Response('{"success": true}', 200);
        }
        return http.Response('{"detail": "Invalid credentials"}', 401);
      }),
    );

    await expectLater(
      AuthApi.instance.tryCookieAutoLogin(),
      completion(isFalse),
    );
    // tryCookieAutoLogin short-circuits without token/cookies; verify explicit login path exemption via getCaptchaConfig-like request or _request('POST', 'login/')
    AuthApi.instance.setSessionForTesting(
      accessToken: null,
      cookies: <String, String>{'sessionid': 'anon'},
    );
    expect(await AuthApi.instance.tryCookieAutoLogin(), isFalse);
    expect(logoutCalls, 0);
    expect(events, isEmpty);
  });

  test('401 on raw byte/document endpoints triggers automatic logout', () async {
    var logoutCalls = 0;

    AuthApi.instance.setSessionForTesting(accessToken: 'active-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/logout/')) {
          logoutCalls++;
          return http.Response('{"success": true}', 200);
        }
        return http.Response('{"detail": "Forbidden"}', 403);
      }),
    );

    await expectLater(
      AuthApi.instance.getProfileImageBytes(),
      throwsA(isA<AuthApiException>().having((e) => e.statusCode, 'statusCode', 403)),
    );

    expect(logoutCalls, 1);
    expect(AuthApi.instance.hasToken, isFalse);
  });

  testWidgets('AppShell automatically triggers logout API and leaves AppShell on 401', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var logoutCalls = 0;
    AuthApi.instance.setSessionForTesting(accessToken: 'active-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/logout/')) {
          logoutCalls++;
          return http.Response('{"success": true}', 200);
        }
        if (request.url.path.endsWith('/mobile/accounts/')) {
          return http.Response('{"detail": "Token expired"}', 401);
        }
        return http.Response('{"notifications": [], "unread_count": 0}', 200);
      }),
    );

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    for (var i = 0; i < 60 && find.byType(AppShell).evaluate().isNotEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(logoutCalls, 1);
    expect(AuthApi.instance.hasToken, isFalse);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('AppShell automatically triggers logout API and leaves AppShell on 403', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var logoutCalls = 0;
    AuthApi.instance.setSessionForTesting(accessToken: 'active-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/logout/')) {
          logoutCalls++;
          return http.Response('{"success": true}', 200);
        }
        if (request.url.path.endsWith('/notifications/')) {
          return http.Response('{"detail": "Forbidden"}', 403);
        }
        return http.Response('{"accounts": []}', 200);
      }),
    );

    await tester.pumpWidget(const MaterialApp(home: AppShell()));
    for (var i = 0; i < 60 && find.byType(AppShell).evaluate().isNotEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(logoutCalls, 1);
    expect(AuthApi.instance.hasToken, isFalse);
    expect(find.byType(AppShell), findsNothing);
  });

  test('encrypted login and verifyOtp responses decrypt, flatten data, and persist token', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final challengePem = _generateTestChallengePem();

    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        final responseKey = request.headers['X-Response-Encryption-Key'] ?? '';
        if (request.url.path.endsWith('/login/encryption-challenge/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'challenge_id': 'chal-enc',
              'public_key': challengePem,
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/login/')) {
          final encrypted = _encryptResponseEnvelope(
            <String, dynamic>{
              'success': true,
              'authenticated': true,
              'data': <String, dynamic>{
                'access_token': 'encrypted-login-jwt',
                'user': <String, dynamic>{'email': 'trader@vtindex.com'},
              },
            },
            responseKey,
          );
          return http.Response(jsonEncode(encrypted), 200);
        }
        if (request.url.path.endsWith('/verify-otp/')) {
          final encrypted = _encryptResponseEnvelope(
            <String, dynamic>{
              'success': true,
              'authenticated': true,
              'data': <String, dynamic>{
                'access': 'encrypted-otp-jwt',
                'user': <String, dynamic>{'email': 'trader@vtindex.com'},
              },
            },
            responseKey,
          );
          return http.Response(jsonEncode(encrypted), 200);
        }
        return http.Response('{}', 200);
      }),
    );

    final loginResult = await AuthApi.instance.login(
      identifier: 'trader@vtindex.com',
      password: 'Password123!',
    );
    expect(loginResult['access_token'], 'encrypted-login-jwt');
    expect(AuthApi.instance.hasToken, isTrue);

    await Future<void>.delayed(Duration.zero);
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('vtindex_client_access_token'), 'encrypted-login-jwt');

    final otpResult = await AuthApi.instance.verifyOtp(
      email: 'trader@vtindex.com',
      otp: '123456',
    );
    expect(otpResult['access'], 'encrypted-otp-jwt');
    expect(otpResult['user'], isA<Map<String, dynamic>>());
    expect(AuthApi.instance.hasToken, isTrue);

    await Future<void>.delayed(Duration.zero);
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('vtindex_client_access_token'), 'encrypted-otp-jwt');
  });

  test('in-flight request finishing after logout does not resurrect session', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final inFlightCompleter = Completer<void>();

    AuthApi.instance.setSessionForTesting(
      accessToken: 'initial-token',
      cookies: <String, String>{'client_access_token': 'initial-cookie'},
    );
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/profile/')) {
          await inFlightCompleter.future;
          return http.Response(
            jsonEncode(<String, dynamic>{
              'access_token': 'resurrected-token',
              'user': <String, dynamic>{'id': 1},
            }),
            200,
            headers: <String, String>{
              'set-cookie': 'client_access_token=resurrected-cookie; Path=/',
            },
          );
        }
        if (request.url.path.endsWith('/logout/')) {
          return http.Response('{"success": true}', 200);
        }
        return http.Response('{}', 200);
      }),
    );

    final profileFuture = AuthApi.instance.getProfile();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await AuthApi.instance.logout();
    expect(AuthApi.instance.hasToken, isFalse);

    inFlightCompleter.complete();
    await profileFuture;

    expect(AuthApi.instance.hasToken, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('vtindex_client_access_token'), isNull);
  });

  test('non-2xx responses do not capture tokens', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'access_token': 'should-not-persist',
            'detail': 'Bad request',
          }),
          400,
          headers: <String, String>{
            'set-cookie': 'client_access_token=should-not-persist; Path=/',
          },
        );
      }),
    );

    await expectLater(
      AuthApi.instance.signup(<String, dynamic>{'email': 'a@b.com'}),
      throwsA(isA<AuthApiException>().having((e) => e.statusCode, 'statusCode', 400)),
    );
    expect(AuthApi.instance.hasToken, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('vtindex_client_access_token'), isNull);
  });

  test('pre-auth endpoints omit stale session headers while tryCookieAutoLogin includes them', () async {
    final challengePem = _generateTestChallengePem();
    final sentHeadersByPath = <String, Map<String, String>>{};

    AuthApi.instance.setSessionForTesting(
      accessToken: 'stale-jwt',
      cookies: <String, String>{'client_access_token': 'stale-cookie'},
    );
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        sentHeadersByPath[request.url.path] = Map<String, String>.from(request.headers);
        if (request.url.path.endsWith('/login/encryption-challenge/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{
              'challenge_id': 'chal-1',
              'public_key': challengePem,
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/status/')) {
          return http.Response('{"authenticated": true}', 200);
        }
        return http.Response('{"success": true, "kid": "1", "public_key": "", "nonce": ""}', 200);
      }),
    );

    await AuthApi.instance.getCaptchaConfig();
    await AuthApi.instance.requestPasswordKey();
    await AuthApi.instance.sendSignupOtp('a@b.com');
    await AuthApi.instance.verifySignupOtp(email: 'a@b.com', otp: '111111');
    await AuthApi.instance.sendResetOtp('a@b.com');
    await AuthApi.instance.confirmPasswordReset(<String, dynamic>{'email': 'a@b.com'});
    await AuthApi.instance.signup(<String, dynamic>{'email': 'a@b.com'});
    await AuthApi.instance.loginOtpStatus('a@b.com');
    await AuthApi.instance.resendLoginOtp(<String, dynamic>{'email': 'a@b.com'});
    await AuthApi.instance.login(identifier: 'a@b.com', password: 'Password1!');

    for (final path in const <String>[
      '/client/api/security/captcha/config/',
      '/client/api/pub/rsa_key/',
      '/client/api/send-signup-otp/',
      '/client/api/verify-signup-otp/',
      '/client/api/send-reset-otp/',
      '/client/api/reset-password/confirm/',
      '/client/api/signup/',
      '/client/api/login-otp-status/',
      '/client/api/resend-login-otp/',
      '/client/api/login/encryption-challenge/',
      '/client/api/login/',
    ]) {
      final headers = sentHeadersByPath[path]!;
      expect(headers.containsKey('Authorization'), isFalse, reason: path);
      expect(headers.containsKey('Cookie'), isFalse, reason: path);
    }

    sentHeadersByPath.clear();
    expect(await AuthApi.instance.tryCookieAutoLogin(), isTrue);
    expect(sentHeadersByPath['/client/api/login/']?['Authorization'], 'Bearer stale-jwt');
    expect(
      sentHeadersByPath['/client/api/login/']?['Cookie'],
      contains('client_access_token=stale-cookie'),
    );
  });

  test('success: false on signup/OTP/reset throws AuthApiException while status() returns false', () async {
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/status/')) {
          return http.Response(
            jsonEncode(<String, dynamic>{'success': false, 'authenticated': false}),
            200,
          );
        }
        return http.Response(
          jsonEncode(<String, dynamic>{
            'success': false,
            'message': 'Verification code rejected.',
          }),
          200,
        );
      }),
    );

    for (final call in <Future<Map<String, dynamic>> Function()>[
      () => AuthApi.instance.signup(<String, dynamic>{'email': 'a@b.com'}),
      () => AuthApi.instance.sendSignupOtp('a@b.com'),
      () => AuthApi.instance.verifySignupOtp(email: 'a@b.com', otp: '123456'),
      () => AuthApi.instance.sendResetOtp('a@b.com'),
      () => AuthApi.instance.confirmPasswordReset(<String, dynamic>{
        'email': 'a@b.com',
        'otp': '123456',
        'password': 'NewPassword1!',
      }),
    ]) {
      await expectLater(
        call(),
        throwsA(
          isA<AuthApiException>()
              .having((e) => e.statusCode, 'statusCode', 200)
              .having((e) => e.message, 'message', 'Verification code rejected.')
              .having((e) => e.data?['success'], 'data[success]', false),
        ),
      );
    }

    expect(await AuthApi.instance.isAuthenticated(), isFalse);
  });

  test('submitPammDeposit handles payload code 403 and error fields consistently', () async {
    var logoutCalls = 0;
    final events = <int>[];
    final sub = AuthApi.instance.onUnauthorizedSession.listen(events.add);
    addTearDown(sub.cancel);

    AuthApi.instance.setSessionForTesting(accessToken: 'active-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((request) async {
        if (request.url.path.endsWith('/logout/')) {
          logoutCalls++;
          return http.Response('{"success": true}', 200);
        }
        return http.Response(
          jsonEncode(<String, dynamic>{
            'code': 403,
            'error': 'PAMM deposit denied.',
          }),
          200,
        );
      }),
    );

    await expectLater(
      AuthApi.instance.submitPammDeposit(
        pammId: '12',
        amountUsd: 100,
        method: 'manual',
        proofBytes: const <int>[1, 2, 3],
        proofFileName: 'proof.png',
        isManager: false,
      ),
      throwsA(
        isA<AuthApiException>().having(
          (e) => e.message,
          'message',
          'PAMM deposit denied.',
        ),
      ),
    );

    expect(logoutCalls, 1);
    expect(events, <int>[403]);
    expect(AuthApi.instance.hasToken, isFalse);
  });
}
