import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/app_notifications.dart';

void main() {
  setUp(() {
    AppNotificationCenter.instance.resetToDefault();
  });

  tearDown(() {
    AppNotificationCenter.instance.resetToDefault();
  });

  group('Adaptive Live Update Polling', () {
    test('account with 0 open positions uses longPollInterval (60s)', () {
      final center = AppNotificationCenter.instance;

      expect(AppNotificationCenter.fastPollInterval, const Duration(seconds: 15));
      expect(AppNotificationCenter.longPollInterval, const Duration(seconds: 60));

      // Account with 0 positions (or unknown) defaults to 60s long poll
      final interval = center.getPollIntervalForAccount('acc_idle_1');
      expect(interval, const Duration(seconds: 60));
      expect(center.getOpenPositionCountForAccount('acc_idle_1'), 0);
    });

    test('account with active open positions (>0) adapts to fastPollInterval (15s)', () {
      final center = AppNotificationCenter.instance;

      // When account has 1 or more open positions, polling switches to 15s
      center.setAccountPositionCountForTesting('acc_active_1', 3);

      expect(center.getOpenPositionCountForAccount('acc_active_1'), 3);
      expect(
        center.getPollIntervalForAccount('acc_active_1'),
        const Duration(seconds: 15),
      );
    });

    test('multi-account setup: account with trades polls at 15s while idle account long-polls at 60s', () {
      final center = AppNotificationCenter.instance;

      // Account A has 2 active open positions
      center.setAccountPositionCountForTesting('acc_A', 2);
      // Account B has 0 open positions (no trade)
      center.setAccountPositionCountForTesting('acc_B', 0);

      // Account A is polled at 15s fast interval
      expect(center.getPollIntervalForAccount('acc_A'), const Duration(seconds: 15));
      expect(center.getOpenPositionCountForAccount('acc_A'), 2);

      // Account B is polled at 60s long interval
      expect(center.getPollIntervalForAccount('acc_B'), const Duration(seconds: 60));
      expect(center.getOpenPositionCountForAccount('acc_B'), 0);
    });

    test('dynamic adaptation: transitions between 15s and 60s when trades open or close', () {
      final center = AppNotificationCenter.instance;

      // Start with Account B idle (0 trades -> 60s)
      center.setAccountPositionCountForTesting('acc_B', 0);
      expect(center.getPollIntervalForAccount('acc_B'), const Duration(seconds: 60));

      // User opens a new trade on Account B (1 trade -> switches to 15s)
      center.setAccountPositionCountForTesting('acc_B', 1);
      expect(center.getPollIntervalForAccount('acc_B'), const Duration(seconds: 15));

      // User closes all trades on Account B (0 trades -> switches back to 60s)
      center.setAccountPositionCountForTesting('acc_B', 0);
      expect(center.getPollIntervalForAccount('acc_B'), const Duration(seconds: 60));
    });

    test('resetToDefault resets adaptive polling state', () {
      final center = AppNotificationCenter.instance;
      center.setAccountPositionCountForTesting('acc_test', 5);
      expect(center.getOpenPositionCountForAccount('acc_test'), 5);
      expect(center.getPollIntervalForAccount('acc_test'), const Duration(seconds: 15));

      center.resetToDefault();

      // After reset, account count is cleared and reverts to 60s long poll default
      expect(center.getOpenPositionCountForAccount('acc_test'), 0);
      expect(center.getPollIntervalForAccount('acc_test'), const Duration(seconds: 60));
    });
  });
}
