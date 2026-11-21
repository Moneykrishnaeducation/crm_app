import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp() {
    return const MaterialApp(
      home: AppShell(),
    );
  }

  testWidgets('primary tab resets scroll to top when navigated away and returned', (tester) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // 1. Navigate to More tab
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.byType(BrokerMorePage), findsOneWidget);

    // Scroll down on More tab
    final moreScrollable = find.descendant(
      of: find.byType(BrokerMorePage),
      matching: find.byType(Scrollable),
    ).first;

    await tester.drag(moreScrollable, const Offset(0, -350));
    await tester.pumpAndSettle();

    final scrollPosBefore = tester.state<ScrollableState>(moreScrollable).position.pixels;
    expect(scrollPosBefore, greaterThan(50));

    // 2. Switch to Dashboard tab
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(BrokerDashboardPage), findsOneWidget);

    // 3. Switch back to More tab
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    // Verify More tab reset to top (offset 0)
    final scrollPosAfter = tester.state<ScrollableState>(moreScrollable).position.pixels;
    expect(scrollPosAfter, equals(0.0));
  });

  testWidgets('secondary page resets scroll to top when revisited', (tester) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    // 1. Navigate to Deposit page
    await tester.ensureVisible(find.text('Deposit').first);
    await tester.tap(find.text('Deposit').first);
    await tester.pumpAndSettle();
    expect(find.byType(BrokerFundsPage), findsOneWidget);

    // Scroll down on Deposit page
    final depositScrollable = find.descendant(
      of: find.byType(BrokerFundsPage),
      matching: find.byType(Scrollable),
    ).first;

    await tester.drag(depositScrollable, const Offset(0, -350));
    await tester.pumpAndSettle();

    final depositPosBefore = tester.state<ScrollableState>(depositScrollable).position.pixels;
    expect(depositPosBefore, greaterThan(50));

    // 2. Go back to Home using back button in header
    final backBtn = find.byTooltip('Back');
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // 3. Re-enter Deposit page
    await tester.ensureVisible(find.text('Deposit').first);
    await tester.tap(find.text('Deposit').first);
    await tester.pumpAndSettle();
    expect(find.byType(BrokerFundsPage), findsOneWidget);

    // Verify Deposit page loaded from the top (offset 0)
    final newDepositScrollable = find.descendant(
      of: find.byType(BrokerFundsPage),
      matching: find.byType(Scrollable),
    ).first;

    final depositPosAfter = tester.state<ScrollableState>(newDepositScrollable).position.pixels;
    expect(depositPosAfter, equals(0.0));
  });
}
