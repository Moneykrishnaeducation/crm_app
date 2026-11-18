import 'package:crm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

void main() {
  setUp(() {
    AppNotificationCenter.instance.resetToDefault();
  });

  group('AppNotificationCenter Service & State Tests', () {
    test('Initializes with default mock notifications and positive unread count', () {
      final center = AppNotificationCenter.instance;
      expect(center.notifications.isNotEmpty, isTrue);
      expect(center.unreadCount, greaterThan(0));
    });

    test('sendNotification adds notification to top of list and updates unread count', () async {
      final center = AppNotificationCenter.instance;
      final initialCount = center.unreadCount;
      final initialTotal = center.notifications.length;

      await center.sendNotification(
        title: 'New Margin Call Warning',
        body: 'Margin level below 120%. Deposit funds immediately.',
        category: 'Trading',
        icon: LucideIcons.alertTriangle,
        isGold: true,
        sendToMobilePanel: false,
      );

      expect(center.notifications.length, initialTotal + 1);
      expect(center.unreadCount, initialCount + 1);
      expect(center.notifications.first.title, 'New Margin Call Warning');
      expect(center.notifications.first.category, 'Trading');
      expect(center.notifications.first.isUnread, isTrue);
      expect(center.notifications.first.isGold, isTrue);
    });

    test('markAsRead marks specific item as read and decrements count', () {
      final center = AppNotificationCenter.instance;
      final unreadItem = center.notifications.firstWhere((n) => n.isUnread);
      final initialCount = center.unreadCount;

      center.markAsRead(unreadItem.id);

      expect(unreadItem.isUnread, isFalse);
      expect(center.unreadCount, initialCount - 1);
    });

    test('markAllAsRead marks every item read and resets unread count to 0', () {
      final center = AppNotificationCenter.instance;
      center.markAllAsRead();

      expect(center.unreadCount, 0);
      expect(center.notifications.every((n) => !n.isUnread), isTrue);
    });

    test('clearAll empties notification list and resets count to 0', () {
      final center = AppNotificationCenter.instance;
      center.clearAll();

      expect(center.notifications, isEmpty);
      expect(center.unreadCount, 0);
    });
  });

  group('NotificationCenterBottomSheet & In-App Selection UI Tests', () {
    testWidgets('Opens notification selection bottom sheet and displays live notifications', (tester) async {
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

      // Tap Notifications icon on header
      final notifBtn = find.byTooltip('Notifications').first;
      await tester.tap(notifBtn);
      await tester.pumpAndSettle();

      // Verify bottom sheet title and default items
      expect(find.text('Notifications'), findsWidgets);
      expect(find.text('Account alerts, executions & updates'), findsOneWidget);
      expect(find.text('Deposit of \$2,500.00 Credited'), findsOneWidget);

      // Tap Send Test Alert button inside header
      final testAlertBtn = find.byTooltip('Send test notification');
      expect(testAlertBtn, findsOneWidget);
      await tester.tap(testAlertBtn);
      await tester.pumpAndSettle();

      // Verify the new notification is immediately visible in the selection list
      expect(find.text('Market Order Executed'), findsOneWidget);
      expect(find.textContaining('Bought 0.20 lots EURUSD'), findsOneWidget);

      // Tap on the item to view & mark as read
      await tester.tap(find.text('Market Order Executed'));
      await tester.pumpAndSettle();
      expect(AppNotificationCenter.instance.notifications.first.isUnread, isFalse);

      // Filter by 'Security'
      await tester.tap(find.text('Security').first);
      await tester.pumpAndSettle();
      expect(find.text('New Authorized Login Detected'), findsOneWidget);
      expect(find.text('Market Order Executed'), findsNothing);

      // Switch back to 'All'
      await tester.tap(find.text('All').first);
      await tester.pumpAndSettle();
      expect(find.text('Market Order Executed'), findsOneWidget);
    });
  });

  group('Native OS Live Updates & Ongoing Notifications Tests', () {
    test('startLiveUpdate, updateLiveUpdate, and stopLiveUpdate execute safely', () async {
      final center = AppNotificationCenter.instance;

      // Start an ongoing native OS live update for an open trade
      await center.startLiveUpdate(
        id: 9999,
        title: 'Open Position: XAUUSD BUY 0.10',
        body: 'Floating P&L: +\$42.50 (Live)',
        subText: 'LIVE',
        usesChronometer: true,
      );

      // Update the active native OS live update with new price/P&L
      await center.updateLiveUpdate(
        id: 9999,
        title: 'Open Position: XAUUSD BUY 0.10',
        body: 'Floating P&L: +\$68.00 (Target TP Approaching)',
        subText: 'LIVE',
      );

      // Stop/dismiss the native OS live update once trade is closed
      await center.stopLiveUpdate(9999);
    });

    testWidgets('showAppMessage displays a floating SnackBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: appScaffoldMessengerKey,
          home: const Scaffold(
            body: Center(child: Text('Home Page')),
          ),
        ),
      );

      showAppMessage('Trade order executed successfully');
      await tester.pump();

      expect(find.text('Trade order executed successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
