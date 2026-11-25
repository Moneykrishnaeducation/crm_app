import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';

void main() {
  const sampleAccounts = [
    BrokerAccount(
      'V Tamizharasan',
      '52132132',
      '1:500',
      '\$12,300.00',
      '\$12,450.00',
      'Live MT5',
    ),
    BrokerAccount(
      'XRSIM-USD-1',
      '3315',
      '1:500',
      '\$0.00',
      '\$0.00',
      'Live MT5',
    ),
  ];

  final sampleFunds = {
    '52132132': [
      const ActivityFundTransaction(
        id: 'tx-104',
        isDeposit: true,
        method: 'Internal Transfer',
        amount: 850.00,
        date: '2026-11-17 11:20',
        status: 'Completed',
        sourceLogin: '3315',
        destinationLogin: '52132132',
        tradingAccount: '52132132',
        isTransfer: true,
      ),
      const ActivityFundTransaction(
        id: 'tx-101',
        isDeposit: true,
        method: 'Bank Transfer',
        amount: 5000.00,
        date: '2026-11-16 14:20',
        status: 'Completed',
        tradingAccount: '52132132',
      ),
      const ActivityFundTransaction(
        id: 'tx-102',
        isDeposit: false,
        method: 'USDT TRC20',
        amount: 1200.00,
        date: '2026-11-15 11:35',
        status: 'Completed',
        tradingAccount: '52132132',
      ),
      const ActivityFundTransaction(
        id: 'tx-105',
        isDeposit: true,
        method: 'Crypto Deposit',
        amount: 300.00,
        date: '2026-11-18 09:00',
        status: 'Pending',
        tradingAccount: '52132132',
      ),
    ],
    '3315': [
      const ActivityFundTransaction(
        id: 'tx-301',
        isDeposit: false,
        method: 'Internal Transfer',
        amount: 850.00,
        date: '2026-11-17 11:20',
        status: 'Completed',
        sourceLogin: '3315',
        destinationLogin: '52132132',
        tradingAccount: '3315',
        isTransfer: true,
      ),
    ],
  };

  Widget buildTestableWidget({
    List<BrokerAccount>? accounts = sampleAccounts,
    String? selectedAccountLogin,
    ValueChanged<String>? onAccountChanged,
    Map<String, List<ActivityFundTransaction>>? externalFundTransactions,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
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
      home: Scaffold(
        body: BrokerTransactionsPage(
          accounts: accounts,
          selectedAccountLogin: selectedAccountLogin,
          onAccountChanged: onAccountChanged,
          externalFundTransactions: externalFundTransactions,
        ),
      ),
    );
  }

  group('BrokerTransactionsPage Activity & Orders Workspace Tests', () {
    testWidgets('renders account selector bar, hero card, 4 tabs, and No Data without fallback', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify Account Selector Bar top header icons are NOT present
      expect(find.byIcon(LucideIcons.bell), findsNothing);
      expect(find.byIcon(LucideIcons.headset), findsNothing);
      expect(find.text('99+'), findsNothing);

      // Verify Account Selector Chip inside Hero Equity & Balance Card
      expect(find.text('V Tamizharasan'), findsOneWidget);
      expect(find.text('Live | 52132132'), findsOneWidget);

      // Verify Hero Equity & Balance Card
      expect(find.text('Equity'), findsOneWidget);
      expect(find.text('Trade Report'), findsOneWidget);
      expect(find.text('Position Total P&L'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.textContaining('USD'), findsWidgets);

      // Verify 4 Tabs
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Funds'), findsOneWidget);

      // Verify Authentic "No Data" with custom painter
      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('toggles eye icon to obscure equity and balance', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Initially eye is open
      expect(find.byIcon(LucideIcons.eye), findsOneWidget);
      expect(find.text('•••••••• USD'), findsNothing);

      // Tap eye toggle
      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pumpAndSettle();

      // Obscured state
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
      expect(find.text('•••••••• USD'), findsOneWidget);
      expect(find.text('••••••'), findsNWidgets(2)); // P&L and Balance

      // Tap eye again to unmask
      await tester.tap(find.byIcon(LucideIcons.eyeOff));
      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.eye), findsOneWidget);
      expect(find.text('•••••••• USD'), findsNothing);
    });

    testWidgets('tapping Trade Report navigates to TradeReportPage and can pop back', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Trade Report
      await tester.tap(find.text('Trade Report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(TradeReportPage), findsOneWidget);
      expect(find.text('Trade Time'), findsOneWidget);
      expect(find.text('Closed Order Statistics'), findsOneWidget);
      expect(find.text('Order P&L (USD)'), findsOneWidget);
      expect(find.text('Total P&L (USD)'), findsOneWidget);
      expect(find.text('Equity Curve'), findsOneWidget);
      expect(find.text('P&L Analysis'), findsOneWidget);

      // Pop back via Chevron Left
      await tester.tap(find.byIcon(LucideIcons.chevronLeft));
      await tester.pumpAndSettle();

      expect(find.byType(TradeReportPage), findsNothing);
      expect(find.text('Live | 52132132'), findsOneWidget);
    });

    testWidgets('switching account updates selected account and zero balance for 3315', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? changedLogin;
      await tester.pumpWidget(
        buildTestableWidget(
          onAccountChanged: (login) => changedLogin = login,
        ),
      );
      await tester.pumpAndSettle();

      // Tap account selector
      await tester.tap(find.text('V Tamizharasan'));
      await tester.pumpAndSettle();

      expect(find.text('Select Trading Account'), findsOneWidget);
      expect(find.text('XRSIM-USD-1'), findsOneWidget);

      // Tap account 3315
      await tester.tap(find.text('XRSIM-USD-1'));
      await tester.pumpAndSettle();

      expect(changedLogin, equals('3315'));
      expect(find.text('Live | 3315'), findsOneWidget);
      expect(find.text('0.00 USD'), findsOneWidget);
      expect(find.text('0.00'), findsNWidgets(2)); // P&L and Balance
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('Funds tab replaces All with Pending and displays selected trading account details only', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          externalFundTransactions: sampleFunds,
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Funds Tab
      await tester.tap(find.text('Funds'));
      await tester.pumpAndSettle();

      // Verify 'All' filter chip is REMOVED and replaced with 'Pending'
      expect(find.text('All'), findsNothing);
      expect(find.widgetWithText(AnimatedContainer, 'Pending'), findsNWidgets(2));
      expect(find.widgetWithText(AnimatedContainer, 'Deposits'), findsOneWidget);
      expect(find.widgetWithText(AnimatedContainer, 'Withdrawals'), findsOneWidget);
      expect(find.widgetWithText(AnimatedContainer, 'Transfers'), findsOneWidget);

      // Under 'Pending' filter (active by default), only pending transactions for selected account (52132132) show
      expect(find.textContaining('Crypto Deposit'), findsOneWidget);
      expect(find.text('+\$300.00'), findsOneWidget);
      expect(find.textContaining('Bank Transfer'), findsNothing);

      // Filter to Deposits
      await tester.tap(find.widgetWithText(AnimatedContainer, 'Deposits'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bank Transfer'), findsOneWidget);
      expect(find.text('+\$5000.00'), findsOneWidget);
      expect(find.textContaining('USDT TRC20'), findsNothing);

      // Filter to Withdrawals
      await tester.tap(find.widgetWithText(AnimatedContainer, 'Withdrawals'));
      await tester.pumpAndSettle();

      expect(find.textContaining('USDT TRC20'), findsOneWidget);
      expect(find.text('-\$1200.00'), findsOneWidget);
      expect(find.textContaining('Bank Transfer'), findsNothing);

      // Filter to Transfers
      await tester.tap(find.widgetWithText(AnimatedContainer, 'Transfers'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer In'), findsOneWidget);
      expect(find.text('INTERNAL'), findsOneWidget);
      expect(find.text('+\$850.00'), findsOneWidget);
      expect(find.textContaining('From #3315'), findsOneWidget);
    });

    testWidgets('Funds tab only shows selected account transactions when switched', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          externalFundTransactions: sampleFunds,
        ),
      );
      await tester.pumpAndSettle();

      // Switch account to 3315
      await tester.tap(find.text('V Tamizharasan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('XRSIM-USD-1'));
      await tester.pumpAndSettle();

      // Switch to Funds Tab
      await tester.tap(find.text('Funds'));
      await tester.pumpAndSettle();

      // For account 3315, pending has no transactions -> shows No Data
      expect(find.text('No Data'), findsOneWidget);

      // Filter to Transfers for account 3315
      await tester.tap(find.text('Transfers'));
      await tester.pumpAndSettle();

      // Only 3315's Transfer Out shows, 52132132's Bank Transfer does not show
      expect(find.text('Transfer Out'), findsOneWidget);
      expect(find.text('-\$850.00'), findsOneWidget);
      expect(find.text('+\$5000.00'), findsNothing);
    });

    testWidgets('renders cleanly in dark mode without any errors', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(brightness: Brightness.dark));
      await tester.pumpAndSettle();

      expect(find.text('V Tamizharasan'), findsOneWidget);
      expect(find.text('Equity'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('No Data'), findsOneWidget);
    });
  });
}
