import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AuthApi.instance.resetForTesting();
    AuthApi.instance.setUseLocalhost(true);
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
    AuthApi.instance.setUseLocalhost(true);
  });

  group('AuthApi session & token tests', () {
    test('hasToken returns true when token or session cookie is present', () async {
      final auth = AuthApi.instance;
      expect(auth.hasToken, isFalse);

      auth.setSessionForTesting(accessToken: 'jwt-token-123');
      expect(auth.hasToken, isTrue);

      await auth.resetForTesting();
      expect(auth.hasToken, isFalse);

      auth.setSessionForTesting(
        cookies: <String, String>{'client_access_token': 'cookie-jwt-456'},
      );
      expect(auth.hasToken, isTrue);
    });

    test('AuthApiException formats properly', () {
      const exception = AuthApiException(
        'The server did not confirm an authenticated session.',
      );
      expect(
        exception.toString(),
        'The server did not confirm an authenticated session.',
      );
    });

    test('AuthApi defaults to localhost and can switch to client.hi5trader.com', () {
      final auth = AuthApi.instance;
      expect(auth.isUsingLocalhost, isTrue);
      expect(
        auth.activeHost,
        anyOf(equals('10.0.2.2'), equals('127.0.0.1'), equals('client.localhost')),
      );
      expect(auth.activeHost, isNot(contains(':')));
      expect(auth.baseUri.port, equals(8000));
      expect(auth.baseUri.toString(), contains(':8000/client/api/'));

      auth.setUseLocalhost(false);
      expect(auth.isUsingLocalhost, isFalse);
      expect(auth.activeHost, equals('client.hi5trader.com'));
      expect(
        auth.baseUri.toString(),
        startsWith('https://client.hi5trader.com/client/api/'),
      );
      expect(auth.baseUri.scheme, equals('https'));

      auth.setUseLocalhost(true);
      expect(auth.isUsingLocalhost, isTrue);
      expect(
        auth.activeHost,
        anyOf(equals('10.0.2.2'), equals('127.0.0.1'), equals('client.localhost')),
      );
    });
  });
}
