import 'package:crm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

void main() {
  setUp(() {
    liveNotificationNotifier.value = null;
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
      expect(find.text('Market Order Executed'), findsWidgets);
      expect(find.textContaining('Bought 0.20 lots EURUSD'), findsWidgets);

      // Tap on the item to view & mark as read
      await tester.tap(find.text('Market Order Executed').last);
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

  group('LiveNotificationHost & Dynamic Live HUD Tests', () {
    testWidgets('Renders top-floating Live Notification HUD on showAppMessage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: appScaffoldMessengerKey,
          builder: (context, child) => LiveNotificationHost(child: child!),
          home: const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      );

      // Trigger live notification
      showAppMessage('Market order EURUSD executed successfully', type: AppNotificationType.success);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Should find the LIVE badge and the notification text within the live pill
      expect(find.text('LIVE'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('live_notification_pill')),
          matching: find.text('Market order EURUSD executed successfully'),
        ),
        findsOneWidget,
      );

      // Tap close button on the live notification HUD
      final closeBtn = find.byIcon(LucideIcons.x);
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('LIVE'), findsNothing);
    });

    testWidgets('showLiveNotification displays title and auto-dismisses after duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          scaffoldMessengerKey: appScaffoldMessengerKey,
          builder: (context, child) => LiveNotificationHost(child: child!),
          home: const Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      );

      showLiveNotification(
        title: 'Deposit Approved',
        message: '\$5,000.00 credited to account #3315',
        type: AppNotificationType.success,
        duration: const Duration(milliseconds: 1000),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Deposit Approved'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('live_notification_pill')),
          matching: find.text(r'$5,000.00 credited to account #3315'),
        ),
        findsOneWidget,
      );
      expect(find.text('LIVE'), findsOneWidget);

      // Advance clock past the duration + fade animation
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      expect(find.text('Deposit Approved'), findsNothing);
    });
  });
}
