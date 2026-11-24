import 'package:crm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

void main() {
  setUp(() {
    AppNotificationCenter.instance.resetToDefault();
  });

  group('AppNotificationCenter', () {
    test('starts empty instead of displaying fabricated sample notifications', () {
      final center = AppNotificationCenter.instance;
      expect(center.notifications, isEmpty);
      expect(center.unreadCount, 0);
    });

    test('sendNotification adds a local notification and updates unread count', () async {
      final center = AppNotificationCenter.instance;
      await center.sendNotification(
        title: 'Local notification test',
        body: 'This verifies local notification rendering only.',
        category: 'Trading',
        icon: LucideIcons.trendingUp,
        isGold: true,
        sendToMobilePanel: false,
        updateLivePill: false,
      );

      expect(center.notifications, hasLength(1));
      expect(center.unreadCount, 1);
      expect(center.notifications.first.title, 'Local notification test');
      expect(center.notifications.first.isUnread, isTrue);
    });

    test('resetToDefault clears local notification state', () async {
      final center = AppNotificationCenter.instance;
      await center.sendNotification(
        title: 'Temporary notification',
        body: 'Temporary',
        sendToMobilePanel: false,
        updateLivePill: false,
      );
      center.resetToDefault();

      expect(center.notifications, isEmpty);
      expect(center.unreadCount, 0);
    });
  });

  group('NotificationCenterBottomSheet', () {
    testWidgets('opens with backend empty state and refresh control', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: appScaffoldMessengerKey,
          home: const AppShell(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Notifications').first);
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsWidgets);
      expect(find.text('Account alerts, executions & updates'), findsOneWidget);
      expect(find.byTooltip('Refresh notifications'), findsOneWidget);
      expect(find.text("You're all caught up!"), findsOneWidget);
    });
  });

  group('Native OS Live Updates', () {
    test('startLiveUpdate, updateLiveUpdate, and stopLiveUpdate execute safely', () async {
      final center = AppNotificationCenter.instance;
      await center.startLiveUpdate(
        id: 9999,
        title: 'Open Position: XAUUSD BUY 0.10',
        body: 'Floating P&L: +\$42.50 (Live)',
        subText: 'LIVE',
        usesChronometer: true,
      );
      await center.updateLiveUpdate(
        id: 9999,
        title: 'Open Position: XAUUSD BUY 0.10',
        body: 'Floating P&L: +\$68.00 (Target TP Approaching)',
        subText: 'LIVE',
      );
      await center.stopLiveUpdate(9999);
    });

    testWidgets('showAppMessage displays a floating SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: appScaffoldMessengerKey,
          home: const Scaffold(body: Center(child: Text('Home Page'))),
        ),
      );

      showAppMessage('Trade order executed successfully');
      await tester.pump();

      expect(find.text('Trade order executed successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
