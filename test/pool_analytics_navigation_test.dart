import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/widgets/pool_trades_modal.dart';
import 'package:crm_app/pages/trade_pattern_analysis_page.dart';
import 'package:crm_app/pages/pamm_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PoolTradesModal displays live positions and KPI metrics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PoolTradesModal(
            poolLogin: '3503',
            poolName: 'MohanTest',
          ),
        ),
      ),
    );
    // Pump frames without waiting for infinite pulse animation to settle
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Live Open Positions'), findsOneWidget);
    expect(find.text('LIVE FEED'), findsOneWidget);
    expect(find.textContaining('Account 3503'), findsOneWidget);
    expect(find.text('FLOATING P/L'), findsOneWidget);
    expect(find.text('TOTAL VOLUME'), findsOneWidget);
    expect(find.text('OPEN ORDERS'), findsOneWidget);
    expect(find.text('ORDER TYPES'), findsOneWidget);
    expect(find.text('EURUSD'), findsOneWidget);
  });

  testWidgets('TradePatternAnalysisPage renders behavioral patterns, controls and KPIs', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: TradePatternAnalysisPage(
          initialAccountLogin: '3503',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trade Pattern Analysis'), findsWidgets);
    expect(find.text('Trading Analytics'), findsOneWidget);
    expect(find.text('NET PROFIT'), findsOneWidget);
    expect(find.text('OVERALL WIN RATE'), findsOneWidget);
    expect(find.text('Ultra Scalp (< 60s)'), findsOneWidget);
    expect(find.text('Intraday Short (5m - 1h)'), findsOneWidget);
    expect(find.text('Strategy Guide'), findsOneWidget);
  });

  testWidgets('PammPage analytics card actions are wired to pool trades and pattern analysis', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    String? navigatedPage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PammPage(
            onSelectPage: (page) => navigatedPage = page,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // In the managed PAMM pool list, tap the "Details" button of MohanTest
    final detailsBtn = find.widgetWithText(OutlinedButton, 'Details');
    expect(detailsBtn, findsOneWidget);
    await tester.tap(detailsBtn);
    await tester.pumpAndSettle();

    // Verify Analytics and activity card exists
    expect(find.text('Analytics and activity'), findsOneWidget);
    expect(find.text('View pool trades'), findsOneWidget);
    expect(find.text('Trade pattern analysis'), findsOneWidget);

    // Tap "Trade pattern analysis"
    await tester.tap(find.text('Trade pattern analysis'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(navigatedPage, 'Trade Pattern Analysis');

    // Tap "View pool trades"
    await tester.tap(find.text('View pool trades'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Live Open Positions'), findsOneWidget);
    expect(find.textContaining('Account 3503'), findsOneWidget);
  });
}
