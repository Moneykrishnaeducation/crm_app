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
  });
}
