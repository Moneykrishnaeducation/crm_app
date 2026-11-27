import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crm_app/main.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:pointycastle/export.dart' hide State;
import 'package:shared_preferences/shared_preferences.dart';

String _generateTestRsaPublicKeyPem() {
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

MockClient _createMockAuthClient(String challengePublicKeyPem) {
  return MockClient((request) async {
    final path = request.url.path;
    if (path.endsWith('/security/captcha/config/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{'require_captcha': false, 'enabled': false}),
        200,
      );
    }
    if (path.endsWith('/login/encryption-challenge/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{
          'challenge_id': 'challenge-1',
          'public_key': challengePublicKeyPem,
        }),
        200,
      );
    }
    if (path.endsWith('/login/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{
          'success': true,
          'authenticated': true,
          'access_token': 'mock-jwt-token',
        }),
        200,
      );
    }
    if (path.endsWith('/status/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{'authenticated': true, 'valid': true}),
        200,
      );
    }
    if (path.endsWith('/mobile/accounts/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{
          'accounts': <Map<String, dynamic>>[
            <String, dynamic>{
              'account_id': '1001',
              'account_name': 'Live Pro',
              'account_type': 'live',
              'currency': 'USD',
              'balance': 1250.50,
              'equity': 1300.75,
              'profit': 50.25,
              'margin': 100.0,
              'free_margin': 1200.75,
              'leverage': 100,
            },
          ],
        }),
        200,
      );
    }
    if (path.contains('/open-positions/')) {
      return http.Response(jsonEncode(<String, dynamic>{'positions': const []}), 200);
    }
    if (path.contains('/trading-account-history/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{
          'transactions': <String, dynamic>{'results': const []},
        }),
        200,
      );
    }
    if (path.endsWith('/notifications/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{'notifications': const [], 'unread_count': 0}),
        200,
      );
    }
    if (path.endsWith('/profile/')) {
      return http.Response(
        jsonEncode(<String, dynamic>{
          'user': <String, dynamic>{
            'name': 'Demo Trader',
            'email': 'demo@vtindex.com',
            'client_id': 'CL-1001',
          },
        }),
        200,
      );
    }
    if (path.endsWith('/user-transactions/') || path.endsWith('/pending-transactions/')) {
      return http.Response(jsonEncode(<String, dynamic>{'transactions': const []}), 200);
    }
    if (path.endsWith('/user-trading-accounts/')) {
      return http.Response(jsonEncode(<String, dynamic>{'accounts': const []}), 200);
    }
    return http.Response('{}', 200);
  });
}

class _TestLoginHost extends StatefulWidget {
  const _TestLoginHost();

  @override
  State<_TestLoginHost> createState() => _TestLoginHostState();
}

class _TestLoginHostState extends State<_TestLoginHost> {
  bool _authenticated = false;

  @override
  Widget build(BuildContext context) {
    if (_authenticated) {
      return const AppShell();
    }
    return LoginPage(onLogin: () => setState(() => _authenticated = true));
  }
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 80,
}) async {
  for (var i = 0; i < maxAttempts; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      // Allow one extra frame for post-frame callbacks / animations to settle.
      await tester.pump(const Duration(milliseconds: 300));
      return;
    }
  }
}

void main() {
  late final String testRsaPublicKeyPem;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    testRsaPublicKeyPem = _generateTestRsaPublicKeyPem();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    AppNotificationCenter.instance.resetToDefault();
    await AuthApi.instance.resetForTesting();
    AuthApi.instance.setHttpClientForTesting(
      _createMockAuthClient(testRsaPublicKeyPem),
    );
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
  });

  testWidgets('LoginPage renders and navigates to AppShell on login', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: _TestLoginHost()));
    await _pumpUntilFound(tester, find.widgetWithText(FilledButton, 'Login'));

    expect(find.text('Login'), findsWidgets);

    await tester.enterText(find.byType(TextFormField).at(0), 'demo@vtindex.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'DemoPass123!');
    final loginBtn = find.widgetWithText(FilledButton, 'Login');
    expect(loginBtn, findsOneWidget);
    await tester.tap(loginBtn);
    await _pumpUntilFound(tester, find.text(r'$1250.50'));

    expect(AuthApi.instance.hasToken, isTrue);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('TOTAL TRADING PORTFOLIO'), findsOneWidget);
    expect(find.text(r'$1250.50'), findsOneWidget);
  });

  testWidgets('AppShell dashboard displays portfolio and can hide balance', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AuthApi.instance.setSessionForTesting(accessToken: 'mock-jwt-token');

    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(),
      ),
    );
    await _pumpUntilFound(tester, find.text(r'$1250.50'));

    expect(find.text('TOTAL TRADING PORTFOLIO'), findsOneWidget);
    expect(find.text(r'$1250.50'), findsOneWidget);
    expect(find.text('1 trading accounts · combined balance'), findsOneWidget);

    final eyeButton = find.descendant(
      of: find.byType(BrokerDashboardPage),
      matching: find.byIcon(LucideIcons.eye),
    );
    await tester.tap(eyeButton);
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('••••••••'), findsOneWidget);
    expect(find.text(r'$1250.50'), findsNothing);
  });

  testWidgets('AppShell bottom navigation navigates between pages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AuthApi.instance.setSessionForTesting(accessToken: 'mock-jwt-token');

    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(),
      ),
    );
    await _pumpUntilFound(tester, find.text(r'$1250.50'));

    await tester.tap(find.text('Activity').first);
    await _pumpUntilFound(tester, find.text('Transactions'));
    expect(find.text('Transactions'), findsWidgets);

    await tester.tap(find.text('More').first);
    await _pumpUntilFound(tester, find.text('Demo Trader'));
    expect(find.text('INVESTMENT & PARTNERSHIPS'), findsOneWidget);
    expect(find.text('View profile'), findsOneWidget);
    expect(find.text('Security Center'), findsOneWidget);
    expect(find.text('Demo Trader'), findsOneWidget);
  });
}
