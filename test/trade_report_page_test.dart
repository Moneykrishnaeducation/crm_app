import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';

void main() {
  Widget buildTestableWidget({
    List<BrokerAccount>? accounts,
    String? selectedAccountLogin,
    ValueChanged<String>? onAccountChanged,
    VoidCallback? onBack,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF5F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1658C9),
          brightness: brightness,
        ),
      ),
      home: TradeReportPage(
        accounts: accounts,
        selectedAccountLogin: selectedAccountLogin,
        onAccountChanged: onAccountChanged,
        onBack: onBack,
      ),
    );
  }

  group('TradeReportPage Comprehensive Fidelity & Interaction Tests', () {
    testWidgets('renders all visual components matching design reference', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // 1. AppBar / Header
      expect(find.text('Trade Report'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);

      // 2. Date Range Filter Row
      expect(find.text('Trade Time'), findsOneWidget);
      expect(find.text('2026 / 11 / 01 - 2026 / 11 / 17'), findsOneWidget);
      expect(find.byIcon(LucideIcons.calendar), findsOneWidget);

      // 3. Hero Account Summary Card
      expect(find.text('MT5'), findsOneWidget);
      expect(find.textContaining('52132132'), findsOneWidget);
      expect(find.text('Account Balance (USD)'), findsOneWidget);
      expect(find.text('Account Equity (USD)'), findsOneWidget);
      expect(find.text('Total Credit (USD)'), findsOneWidget);

      // 4. Closed Order Statistics
      expect(find.text('Closed Order Statistics'), findsOneWidget);
      expect(find.text('Trade Volume (Million USD)'), findsOneWidget);
      expect(find.text('0.0000'), findsOneWidget);
      expect(find.text('Commissions'), findsOneWidget);
      expect(find.text('Trade Lots'), findsOneWidget);
      expect(find.text('Trade Count'), findsOneWidget);
      expect(find.text('Interest (USD)'), findsOneWidget);

      // 5. Order P&L & Total P&L Card
      expect(find.text('Order P&L (USD)'), findsOneWidget);
      expect(find.text('Position P&L'), findsOneWidget);
      expect(find.text('Closed P&L'), findsOneWidget);
      expect(find.text('Total P&L (USD)'), findsOneWidget);
      expect(find.text('Position Total P&L'), findsOneWidget);
      expect(find.text('Closed Total P&L'), findsOneWidget);

      // 6. Deposit / Withdraw 2x2 Grid Cards
      expect(find.text('Net Deposit (USD)'), findsOneWidget);
      expect(find.text('Deposit/Withdraw Count'), findsOneWidget);
      expect(find.text('Total Deposit (USD)'), findsOneWidget);
      expect(find.text('Total Withdraw (USD)'), findsOneWidget);

      // 7. Equity Curve Section
      expect(find.text('Equity Curve'), findsOneWidget);

      // 8. P&L Analysis Section
      expect(find.text('P&L Analysis'), findsOneWidget);
      expect(find.text('All Symbols'), findsOneWidget);
      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Hour'), findsOneWidget);
    });

    testWidgets('triggers pull-to-refresh without error', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Fling down to trigger refresh indicator
      await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 350), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.text('Trade Report'), findsOneWidget);
    });

    testWidgets('toggles eye icon to obscure and reveal Net Deposit', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Initially eye is visible, value is 0.00
      expect(find.byIcon(LucideIcons.eye), findsOneWidget);
      expect(find.text('••••••'), findsNothing);

      // Tap eye icon to hide Net Deposit
      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
      expect(find.text('••••••'), findsOneWidget);

      // Tap again to restore
      await tester.tap(find.byIcon(LucideIcons.eyeOff));
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.eye), findsOneWidget);
      expect(find.text('••••••'), findsNothing);
    });

    testWidgets('toggles timeframe between Day and Hour', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Hour'), findsOneWidget);

      // Tap Hour
      await tester.tap(find.text('Hour'));
      await tester.pumpAndSettle();

      // Tap Day back
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
    });

    testWidgets('scrubbing on Equity Curve reveals interactive tooltip', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final equityGesture = find.byKey(const Key('equity_curve_gesture'));
      expect(equityGesture, findsOneWidget);

      // Tap down to reveal tooltip
      final gesture = await tester.startGesture(tester.getCenter(equityGesture));
      await tester.pump();

      expect(find.textContaining(r'$0.00 USD'), findsWidgets);

      // Move gesture across chart
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(find.textContaining(r'$0.00 USD'), findsWidgets);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('scrubbing on P&L Analysis reveals interactive tooltip', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final pnlGesture = find.byKey(const Key('pnl_chart_gesture'));
      expect(pnlGesture, findsOneWidget);

      // Start gesture on chart
      final gesture = await tester.startGesture(tester.getCenter(pnlGesture));
      await tester.pump();

      expect(find.textContaining(r'$0.00 USD'), findsWidgets);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('selects symbol from dropdown filter', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('All Symbols'), findsOneWidget);

      // Tap dropdown button
      await tester.tap(find.text('All Symbols'));
      await tester.pumpAndSettle();

      // Verify menu items
      expect(find.text('EURUSD'), findsOneWidget);
      expect(find.text('GBPUSD'), findsOneWidget);
      expect(find.text('XAUUSD'), findsOneWidget);
      expect(find.text('BTCUSD'), findsOneWidget);
      expect(find.text('USDJPY'), findsOneWidget);

      // Select XAUUSD
      await tester.tap(find.text('XAUUSD'));
      await tester.pumpAndSettle();

      expect(find.text('XAUUSD'), findsOneWidget);
    });

    testWidgets('account switcher modal opens and selects account', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? selectedLogin;
      await tester.pumpWidget(buildTestableWidget(
        onAccountChanged: (login) => selectedLogin = login,
      ));
      await tester.pumpAndSettle();

      // Tap account selector pill in Hero card
      await tester.tap(find.textContaining('52132132'));
      await tester.pumpAndSettle();

      expect(find.text('Switch Trading Account'), findsOneWidget);
      expect(find.textContaining('3315'), findsOneWidget);

      // Select Demo account 3315
      await tester.tap(find.textContaining('3315'));
      await tester.pumpAndSettle();

      expect(selectedLogin, equals('3315'));
      expect(find.textContaining('3315'), findsOneWidget);
      expect(find.text('10000.00'), findsNWidgets(2)); // Balance & Equity for 3315
    });

    testWidgets('date range filter picker modal opens and applies preset', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Trade Time row
      await tester.tap(find.text('Trade Time'));
      await tester.pumpAndSettle();

      expect(find.text('Select Date Range'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Last 7 Days'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last 30 Days'), findsOneWidget);
      expect(find.text('Custom Range...'), findsOneWidget);

      // Tap Today
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('Select Date Range'), findsNothing);
    });

    testWidgets('back button triggers onBack callback when provided', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var backTapped = false;
      await tester.pumpWidget(buildTestableWidget(
        onBack: () => backTapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.chevronLeft));
      await tester.pumpAndSettle();

      expect(backTapped, isTrue);
    });

    testWidgets('renders cleanly in dark mode without any errors', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(brightness: Brightness.dark));
      await tester.pumpAndSettle();

      expect(find.text('Trade Report'), findsOneWidget);
      expect(find.text('Closed Order Statistics'), findsOneWidget);
      expect(find.text('Equity Curve'), findsOneWidget);
      expect(find.text('P&L Analysis'), findsOneWidget);
    });
  });
}
