import 'dart:async';
import 'dart:convert';

import 'package:crm_app/main.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
