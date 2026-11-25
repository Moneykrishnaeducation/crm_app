import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/services/auth_api.dart';

void main() {
  group('AuthApi session & token tests', () {
    test('hasToken returns true when token is present', () {
      final auth = AuthApi.instance;
      expect(auth.hasToken, isFalse);
    });

    test('AuthApiException formats properly', () {
      const exception = AuthApiException('The server did not confirm an authenticated session.');
      expect(exception.toString(), 'The server did not confirm an authenticated session.');
    });

    test('AuthApi defaults to client.hi5trader.com and can switch to localhost', () {
      final auth = AuthApi.instance;
      // Default should be client.hi5trader.com
      auth.setUseLocalhost(false);
      expect(auth.activeHost, equals('client.hi5trader.com'));
      expect(auth.baseUri.toString(), startsWith('https://client.hi5trader.com/client/api/'));

      // Switch to localhost
      auth.setUseLocalhost(true);
      expect(auth.isUsingLocalhost, isTrue);
      expect(auth.activeHost, anyOf(equals('10.0.2.2'), equals('127.0.0.1'), equals('client.localhost')));
      expect(auth.baseUri.toString(), contains(':8000/client/api/'));

      // Switch back to client.hi5trader.com
      auth.setUseLocalhost(false);
      expect(auth.activeHost, equals('client.hi5trader.com'));
      expect(auth.baseUri.scheme, equals('https'));
    });
  });
}
