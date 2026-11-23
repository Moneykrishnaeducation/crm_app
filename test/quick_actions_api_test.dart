import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/services/auth_api.dart';

void main() {
  group('AuthApi Quick Actions Integration Tests', () {
    test('AuthApi exposes all required Quick Action API methods', () {
      final api = AuthApi.instance;
      expect(api.getTradingGroups, isA<Function>());
      expect(api.createTradingAccount, isA<Function>());
      expect(api.createDemoAccount, isA<Function>());
      expect(api.getNonDemoAccounts, isA<Function>());
      expect(api.createInternalTransfer, isA<Function>());
      expect(api.getUsdInrRate, isA<Function>());
      expect(api.getWithdrawalInfo, isA<Function>());
      expect(api.requestWithdrawal, isA<Function>());
      expect(api.initiateCheesePay, isA<Function>());
      expect(api.initiateUsdtDeposit, isA<Function>());
      expect(api.submitManualDeposit, isA<Function>());
      expect(api.getBankDetails, isA<Function>());
      expect(api.getCryptoDetails, isA<Function>());
    });

    test('getUsdInrRate returns fallback rate when server is unreachable in test environment', () async {
      final rate = await AuthApi.instance.getUsdInrRate();
      expect(rate, isA<double>());
      expect(rate, equals(83.5));
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('AuthApiException correctly captures endpoint errors', () {
      const ex = AuthApiException('Transfer failed', statusCode: 400, data: {'error': 'Insufficient funds'});
      expect(ex.message, 'Transfer failed');
      expect(ex.statusCode, 400);
      expect(ex.data?['error'], 'Insufficient funds');
      expect(ex.toString(), 'Transfer failed');
    });
  });
}
