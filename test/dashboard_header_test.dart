import 'package:crm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

void main() {
  setUp(() {
    AppNotificationCenter.instance.resetToDefault();
  });

  Widget createTestWidget() {
    return const MaterialApp(
      home: AppShell(),
    );
  }

  testWidgets('Common brand header is applied on primary tabs and detail pages work correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Primary tab (Dashboard): Verify VT Index logo image is present and no text title
    expect(find.byType(Image), findsWidgets);
    expect(find.byTooltip('Search'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsWidgets);
    expect(find.text('99+'), findsOneWidget);
    expect(find.byTooltip('Customer Support'), findsOneWidget);

    // 2. Dashboard components:
    // Hero Balance Card
    expect(find.text('Total balance'), findsOneWidget);
    expect(find.text(r'$12,450.00'), findsOneWidget);
    final dashboardEye = find.descendant(
      of: find.byType(BrokerDashboardPage),
      matching: find.byIcon(LucideIcons.eye),
    );
    expect(dashboardEye, findsOneWidget);
    expect(find.text('Floating P&L'), findsOneWidget);
    expect(find.text(r'+$245.80'), findsOneWidget);

    // Toggle balance eye
    await tester.tap(dashboardEye);
    await tester.pumpAndSettle();
    expect(find.text('••••••••'), findsOneWidget);
    expect(find.text('••••••'), findsOneWidget);
    final dashboardEyeOff = find.descendant(
      of: find.byType(BrokerDashboardPage),
      matching: find.byIcon(LucideIcons.eyeOff),
    );
    expect(dashboardEyeOff, findsOneWidget);

    // Toggle back
    await tester.tap(dashboardEyeOff);
    await tester.pumpAndSettle();
    expect(find.text(r'$12,450.00'), findsOneWidget);
    expect(find.text(r'+$245.80'), findsOneWidget);

    // 4 Quick Actions
    expect(find.text('Deposit'), findsWidgets);
    expect(find.text('Withdraw'), findsWidgets);
    expect(find.text('Transfer'), findsWidgets);
    expect(find.text('Report Center'), findsWidgets);

    // Dual Feature Cards
    expect(find.text('Quick Trade'), findsWidgets);
    expect(find.text('EURUSD'), findsWidgets);
    expect(find.text('Refer & Earn'), findsWidgets);
    expect(find.text('Invite one friend'), findsWidgets);

    // Market Insights Banner
    expect(find.text('Market Insights'), findsWidgets);
    expect(find.textContaining('Stay informed with the latest market news'), findsOneWidget);

    // Markets section with filter pills
    expect(find.text('Markets'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Metals'), findsOneWidget);
    expect(find.text('Energy'), findsOneWidget);
    expect(find.text('Product / Change'), findsOneWidget);
    expect(find.text('Sell'), findsWidgets);
    expect(find.text('Buy'), findsWidgets);

    // Tap on Metals filter pill
    await tester.ensureVisible(find.text('Metals'));
    await tester.tap(find.text('Metals'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(BrokerDashboardPage), matching: find.text('XAUUSD')), findsOneWidget);
    expect(find.text('XAGUSD'), findsOneWidget);

    // 3. Customer support modal bottom sheet
    await tester.tap(find.byTooltip('Customer Support'));
    await tester.pumpAndSettle();
    expect(find.text('Customer Support'), findsOneWidget);
    expect(find.text('Support Tickets'), findsOneWidget);
    expect(find.text('Email Support'), findsOneWidget);
    // Dismiss support bottom sheet
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();

    // 4. Detail page verification with onBack != null
    // Navigate to 'More' tab
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    // In More tab, tap 'View profile'
    await tester.tap(find.text('View profile').first);
    await tester.pumpAndSettle();

    // Detail page: should show Back button and 'Profile' title
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.text('Profile'), findsWidgets);

    // Tap back button
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Now back on 'More' tab, brand header is restored (VT Index logo, Search, Support, 99+)
    expect(find.byTooltip('Customer Support'), findsOneWidget);
  });

  testWidgets('Search and Notifications open animated bottom sheets instead of popups', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Verify tapping Search opens MarketSearchBottomSheet
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    // Verify it is a bottom sheet and NOT an AlertDialog popup
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Search Markets'), findsOneWidget);
    expect(find.text('Search symbols (e.g. EURUSD, XAUUSD, BTC)...'), findsOneWidget);
    expect(find.text('Forex'), findsWidgets);
    expect(find.text('Crypto'), findsWidgets);

    // Dismiss search bottom sheet via close button
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Search Markets'), findsNothing);

    // 2. Verify tapping Notifications opens NotificationCenterBottomSheet
    await tester.tap(find.byTooltip('Notifications').first);
    await tester.pumpAndSettle();

    // Verify it is a bottom sheet and NOT an AlertDialog popup
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Notifications'), findsWidgets);
    expect(find.text('Mark read'), findsOneWidget);
    expect(find.text('Trading'), findsWidgets);
    expect(find.text('Funds'), findsWidgets);
    expect(find.text('Security'), findsWidgets);

    // Tap 'Mark read'
    await tester.tap(find.text('Mark read'));
    await tester.pumpAndSettle();

    // Dismiss notification bottom sheet
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Mark read'), findsNothing);
  });

  testWidgets('Header sheets close when tapping outside', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    Future<void> tapOutsidePopup() async {
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search Markets'), findsOneWidget);
    await tapOutsidePopup();
    expect(find.text('Search Markets'), findsNothing);

    await tester.tap(find.byTooltip('Notifications').first);
    await tester.pumpAndSettle();
    expect(find.text('Mark read'), findsOneWidget);
    await tapOutsidePopup();
    expect(find.text('Mark read'), findsNothing);

    await tester.tap(find.byTooltip('Customer Support'));
    await tester.pumpAndSettle();
    expect(find.text('Support Tickets'), findsOneWidget);
    await tapOutsidePopup();
    expect(find.text('Support Tickets'), findsNothing);

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();
    const logoutMessage =
        'Are you sure you want to log out of your account? You will need to enter your credentials to sign back in.';
    expect(find.text(logoutMessage), findsOneWidget);
    await tapOutsidePopup();
    expect(find.text(logoutMessage), findsNothing);
  });
}
