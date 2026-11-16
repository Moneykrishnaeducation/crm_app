import 'package:crm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

void main() {
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
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('\$125,800.00'), findsOneWidget);
    expect(find.byIcon(LucideIcons.eye), findsOneWidget);
    expect(find.textContaining('Position Total P&L:'), findsOneWidget);

    // Toggle balance eye
    await tester.tap(find.byIcon(LucideIcons.eye));
    await tester.pumpAndSettle();
    expect(find.text('••••••••'), findsOneWidget);
    expect(find.textContaining('****** USD'), findsOneWidget);
    expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);

    // Toggle back
    await tester.tap(find.byIcon(LucideIcons.eyeOff));
    await tester.pumpAndSettle();
    expect(find.text('\$125,800.00'), findsOneWidget);

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
    await tester.tap(find.text('Metals'));
    await tester.pumpAndSettle();
    expect(find.text('XAUUSD'), findsOneWidget);
    expect(find.text('XAGUSD'), findsOneWidget);

    // 3. Customer support modal bottom sheet
    await tester.tap(find.byTooltip('Customer Support'));
    await tester.pumpAndSettle();
    expect(find.text('Customer Support'), findsOneWidget);
    expect(find.text('Live Chat Support'), findsOneWidget);
    expect(find.text('Email Support'), findsOneWidget);
    // Dismiss support bottom sheet
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();

    // 4. Detail page verification with onBack != null
    // Navigate to 'More' tab
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    // In More tab, tap 'Profile'
    await tester.tap(find.text('Profile').first);
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
}
