import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';

void main() {
  Widget buildTestDashboard() {
    return MaterialApp(
      home: Scaffold(
        body: BrokerDashboardPage(
          balanceVisible: true,
          onToggleBalance: () {},
          onSelectPage: (_) {},
          onOpenReport: () {},
          accounts: const [],
          onRefreshAccounts: () async {},
        ),
      ),
    );
  }

  testWidgets('Markets category All loads all symbols', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestDashboard());
    await tester.pumpAndSettle();

    // Verify All category pill is present and selected by default
    expect(find.text('All'), findsOneWidget);

    // Verify symbols from all categories are loaded
    expect(find.text('EURUSD'), findsWidgets);
    expect(find.text('GBPUSD'), findsOneWidget);
    expect(find.text('XAUUSD'), findsOneWidget);
    expect(find.text('XAGUSD'), findsOneWidget);
    expect(find.text('USOIL'), findsOneWidget);
    expect(find.text('UKOIL'), findsOneWidget);
    expect(find.text('HK50c'), findsOneWidget);
    expect(find.text('USTECHc'), findsOneWidget);
    expect(find.text('EURGBP'), findsOneWidget);
    expect(find.text('EURJPY'), findsOneWidget);
    expect(find.text('BTCUSD'), findsOneWidget);
    expect(find.text('ETHUSD'), findsOneWidget);
  });

  testWidgets('Quick Trade accesses first symbol of selected market category and updates on selection', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildTestDashboard());
    await tester.pumpAndSettle();

    Finder quickTradeCard() => find.widgetWithText(InkWell, 'Quick Trade');

    // 1. Initial All category -> Quick Trade accesses EURUSD
    expect(find.descendant(of: quickTradeCard(), matching: find.text('EURUSD')), findsOneWidget);
    expect(find.descendant(of: quickTradeCard(), matching: find.text('1.10090')), findsOneWidget);

    // 2. Select Metals -> Quick Trade accesses XAUUSD (first of Metals)
    await tester.ensureVisible(find.text('Metals'));
    await tester.tap(find.text('Metals'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: quickTradeCard(), matching: find.text('XAUUSD')), findsOneWidget);
    expect(find.descendant(of: quickTradeCard(), matching: find.text('2,654.12')), findsOneWidget);
    expect(find.descendant(of: quickTradeCard(), matching: find.text('↗ 0.35%')), findsOneWidget);

    // 3. Select Energy -> Quick Trade accesses USOIL (first of Energy)
    await tester.ensureVisible(find.text('Energy'));
    await tester.tap(find.text('Energy'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: quickTradeCard(), matching: find.text('USOIL')), findsOneWidget);
    expect(find.descendant(of: quickTradeCard(), matching: find.text('70.24')), findsOneWidget);

    // 4. Select Index -> Quick Trade accesses HK50c (first of Index)
    await tester.ensureVisible(find.text('Index'));
    await tester.tap(find.text('Index'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: quickTradeCard(), matching: find.text('HK50c')), findsOneWidget);
    expect(find.descendant(of: quickTradeCard(), matching: find.text('23,815.24')), findsOneWidget);

    // 5. Select Cryptos -> Quick Trade accesses BTCUSD (first of Cryptos)
    await tester.ensureVisible(find.text('Cryptos'));
    await tester.tap(find.text('Cryptos'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: quickTradeCard(), matching: find.text('BTCUSD')), findsOneWidget);
    expect(find.descendant(of: quickTradeCard(), matching: find.text('67,420.00')), findsOneWidget);

    // 6. Select FX Minors -> Quick Trade accesses EURGBP (first of FX Minors)
    await tester.ensureVisible(find.text('FX Minors'));
    await tester.tap(find.text('FX Minors'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: quickTradeCard(), matching: find.text('EURGBP')), findsOneWidget);
    expect(find.descendant(of: quickTradeCard(), matching: find.text('0.83420')), findsOneWidget);

    // 7. Tap Quick Trade card -> opens Quick Trade sheet for EURGBP
    await tester.ensureVisible(quickTradeCard());
    await tester.tap(quickTradeCard());
    await tester.pumpAndSettle();
    expect(find.text('VOLUME (LOTS)'), findsOneWidget);
    expect(find.text('SELL'), findsOneWidget);
    expect(find.text('BUY'), findsOneWidget);
    expect(find.text('0.83420'), findsWidgets);
    expect(find.text('0.83435'), findsWidgets);
  });
}
