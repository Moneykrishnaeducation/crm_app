import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';

void main() {
  Widget buildTestableWidget({
    List<BrokerAccount>? accounts,
    String? selectedAccountLogin,
    ValueChanged<String>? onAccountChanged,
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
      home: Scaffold(
        body: BrokerTransactionsPage(
          accounts: accounts,
          selectedAccountLogin: selectedAccountLogin,
          onAccountChanged: onAccountChanged,
        ),
      ),
    );
  }

  group('BrokerTransactionsPage Activity & Orders Workspace Tests', () {
    testWidgets('renders account selector bar, hero card, 4 tabs, and open positions', (tester) async {
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
      expect(find.text('Open 2'), findsOneWidget);
      expect(find.text('Pending 1'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Funds'), findsOneWidget);

      // Verify Open Positions populated
      expect(find.text('EURUSD'), findsOneWidget);
      expect(find.text('XAUUSD'), findsOneWidget);
      expect(find.text('BUY'), findsWidgets);
      expect(find.text('SELL'), findsWidgets);
      expect(find.text('0.50 Lots'), findsOneWidget);
      expect(find.text('0.20 Lots'), findsOneWidget);
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

    testWidgets('tapping Trade Report opens modal and displays trading performance', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap Trade Report
      await tester.tap(find.text('Trade Report'));
      await tester.pumpAndSettle();

      expect(find.text('Trade Performance Report'), findsOneWidget);
      expect(find.textContaining('Account: 52132132'), findsOneWidget);
      expect(find.text('Total Net Profit'), findsOneWidget);
      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('Total Trades'), findsOneWidget);
      expect(find.text('Total Volume'), findsOneWidget);
      expect(find.text('Close Report'), findsOneWidget);

      // Dismiss Trade Report
      await tester.tap(find.text('Close Report'));
      await tester.pumpAndSettle();

      expect(find.text('Trade Performance Report'), findsNothing);
    });

    testWidgets('switching to empty account 3315 triggers No Data vector illustration and zero balance', (tester) async {
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

      // Verify Tabs show 0 counts
      expect(find.text('Open 0'), findsOneWidget);
      expect(find.text('Pending 0'), findsOneWidget);

      // Verify Authentic "No Data" with custom painter
      expect(find.text('No Data'), findsOneWidget);
    });

    testWidgets('tab switching across Pending, Closed, and Funds displays appropriate data', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // 1. Switch to Pending Tab
      await tester.tap(find.text('Pending 1'));
      await tester.pumpAndSettle();

      expect(find.text('GBPUSD'), findsOneWidget);
      expect(find.text('BUY LIMIT'), findsOneWidget);
      expect(find.text('0.10 Lots'), findsOneWidget);
      expect(find.text('Order Price'), findsOneWidget);
      expect(find.text('1.294'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // 2. Switch to Closed Tab
      await tester.tap(find.text('Closed'));
      await tester.pumpAndSettle();

      expect(find.text('BTCUSD'), findsOneWidget);
      expect(find.text('HK50c'), findsOneWidget);
      expect(find.text('+\$112.50'), findsOneWidget);
      expect(find.text('-\$60.00'), findsOneWidget);
      expect(find.text('Open Price'), findsWidgets);
      expect(find.text('Close Price'), findsWidgets);

      // 3. Switch to Funds Tab
      await tester.tap(find.text('Funds'));
      await tester.pumpAndSettle();

      // Filter chips in Funds tab
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Deposits'), findsOneWidget);
      expect(find.text('Withdrawals'), findsOneWidget);

      // Fund transactions
      expect(find.text('Deposit'), findsWidgets);
      expect(find.text('Withdrawal'), findsOneWidget);
      expect(find.text('+\$5000.00'), findsOneWidget);
      expect(find.text('-\$1200.00'), findsOneWidget);
      expect(find.text('+\$2500.00'), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);

      // Filter to Withdrawals only
      await tester.tap(find.text('Withdrawals'));
      await tester.pumpAndSettle();

      expect(find.text('-\$1200.00'), findsOneWidget);
      expect(find.text('+\$5000.00'), findsNothing);
    });

    testWidgets('close position dialog confirms closing and moves trade to closed tab', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Open 2'), findsOneWidget);

      // Tap Close on first position (EURUSD)
      await tester.tap(find.text('Close').first);
      await tester.pumpAndSettle();

      expect(find.text('Close Position'), findsOneWidget);
      expect(find.textContaining('Are you sure you want to close EURUSD'), findsOneWidget);
      expect(find.text('Confirm Close'), findsOneWidget);

      // Confirm close
      await tester.tap(find.text('Confirm Close'));
      await tester.pumpAndSettle();

      // Tab count decrements to Open 1
      expect(find.text('Open 1'), findsOneWidget);

      // SnackBar displayed
      expect(find.text('Position EURUSD closed successfully'), findsOneWidget);

      // Verify EURUSD now in Closed tab
      await tester.tap(find.text('Closed'));
      await tester.pumpAndSettle();

      expect(find.text('EURUSD'), findsOneWidget);
      expect(find.text('Just now'), findsOneWidget);
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
      expect(find.text('Open 2'), findsOneWidget);
    });
  });
}
