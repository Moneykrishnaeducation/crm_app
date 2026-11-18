import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';

void main() {
  group('BrokerFundsPage Full-Page Tests', () {
    Widget buildTestApp({ThemeMode themeMode = ThemeMode.light}) {
      return MyApp(initialThemeMode: themeMode);
    }

    testWidgets('Deposit navigates to dedicated BrokerFundsPage without Dialog popup', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Login to Dashboard
      final loginBtn = find.widgetWithText(FilledButton, 'Login');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Tap Deposit quick action on Dashboard
      final depositAction = find.text('Deposit').first;
      await tester.tap(depositAction);
      await tester.pumpAndSettle();

      // Verify that NO Dialog popup is used
      expect(find.byType(Dialog), findsNothing);

      // Verify BrokerFundsPage is rendered as a full-page view
      expect(find.byType(BrokerFundsPage), findsOneWidget);

      // Verify Hero gradient banner with wallet icon and title
      expect(find.text('Deposit Funds'), findsWidgets);
      expect(find.byIcon(LucideIcons.wallet), findsWidgets);
      expect(find.textContaining('Add funds to your trading account securely'), findsOneWidget);
      expect(find.textContaining('3311', findRichText: true), findsWidgets);

      // Verify Payment method tabs
      expect(find.text('CHEESE PAY'), findsOneWidget);
      expect(find.text('MANUAL'), findsOneWidget);
      expect(find.text('USDT'), findsOneWidget);

      // Verify Currency toggle & live exchange rate
      expect(find.text('Deposit Currency'), findsOneWidget);
      expect(find.text('1 USD = 94.29 INR'), findsOneWidget);

      // Verify Deposit Summary is removed
      expect(find.text('DEPOSIT SUMMARY'), findsNothing);
      expect(find.text('Estimated deposit credit'), findsNothing);

      // Tap preset amount chip
      await tester.tap(find.text('₹ 5,000'));
      await tester.pumpAndSettle();
      expect(find.text('5000'), findsOneWidget);

      // Switch to MANUAL method
      await tester.tap(find.text('MANUAL'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Upload transaction proof'), findsOneWidget);

      // Switch to USDT method
      await tester.tap(find.text('USDT'));
      await tester.pumpAndSettle();
      expect(find.text('DEPOSIT AMOUNT (USDT)'), findsOneWidget);

      // Tap 'Back to Dashboard' inside hero banner
      await tester.tap(find.text('Back to Dashboard'));
      await tester.pumpAndSettle();

      // Verify we are back on Dashboard
      expect(find.byType(BrokerFundsPage), findsNothing);
      expect(find.text('Total Balance'), findsOneWidget);
    });

    testWidgets('Withdraw navigates to dedicated BrokerFundsPage with full forms and returns via header back button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Login to Dashboard
      await tester.tap(find.widgetWithText(FilledButton, 'Login'));
      await tester.pumpAndSettle();

      // Tap Withdraw quick action
      final withdrawAction = find.text('Withdraw').first;
      await tester.tap(withdrawAction);
      await tester.pumpAndSettle();

      // Verify NO Dialog is present
      expect(find.byType(Dialog), findsNothing);

      // Verify BrokerFundsPage is rendered
      expect(find.byType(BrokerFundsPage), findsOneWidget);

      // Verify Withdraw hero banner & arrowUpRight icon
      expect(find.text('Withdraw Funds'), findsWidgets);
      expect(find.byIcon(LucideIcons.arrowUpRight), findsWidgets);
      expect(find.text('WITHDRAWABLE TREASURY'), findsOneWidget);

      // Verify Steps
      expect(find.text('SELECT SOURCE ACCOUNT'), findsOneWidget);
      expect(find.text('CHOOSE PAYOUT METHOD'), findsOneWidget);
      expect(find.text('ENTER WITHDRAWAL AMOUNT'), findsOneWidget);

      // Verify Withdraw Summary is removed
      expect(find.text('Net Payout Amount'), findsNothing);
      expect(find.text('Credited to your destination'), findsNothing);

      // Verify Payout methods
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.text('Crypto Wallet'), findsOneWidget);

      // Switch payout method to Crypto Wallet
      await tester.tap(find.text('Crypto Wallet'));
      await tester.pumpAndSettle();

      // Tap preset amount chip
      await tester.tap(find.text('\$100'));
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
      expect(find.text('\$100'), findsWidgets);

      // Tap AppBar Back button
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify returned to Dashboard
      expect(find.byType(BrokerFundsPage), findsNothing);
      expect(find.text('Total Balance'), findsOneWidget);
    });

    testWidgets('BrokerFundsPage renders cleanly in dark mode without overflow', (tester) async {
      tester.view.physicalSize = const Size(720, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: Scaffold(
            body: BrokerFundsPage(
              withdrawal: false,
              onBack: () {},
              onSelectPage: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deposit Funds'), findsOneWidget);
      expect(find.text('CHEESE PAY'), findsOneWidget);
      final exc = tester.takeException();
      expect(exc, isNull);
    });

    testWidgets('Deposit flow handles method switching, validation, and response bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      String? selectedPage;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(useMaterial3: true),
          home: Scaffold(
            body: BrokerFundsPage(
              withdrawal: false,
              onBack: () {},
              onSelectPage: (p) => selectedPage = p,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test switching to Manual transfer method
      expect(find.text('MANUAL'), findsOneWidget);
      await tester.tap(find.text('MANUAL'));
      await tester.pumpAndSettle();
      expect(find.text('OFFICIAL BENEFICIARY ACCOUNT'), findsOneWidget);
      expect(find.text('VT Index Markets Ltd'), findsOneWidget);
      expect(find.text('Upload transaction proof (JPG, PNG or PDF)'), findsOneWidget);

      // Test switching to USDT method
      expect(find.text('USDT'), findsOneWidget);
      await tester.tap(find.text('USDT'));
      await tester.pumpAndSettle();
      expect(find.text('OFFICIAL TRC20 DEPOSIT ADDRESS'), findsOneWidget);
      expect(find.text('TX8nQ9xR4bH2mP7vW1kL3s9zY6V4m2Pq'), findsOneWidget);

      // Test switching back to Cheese Pay
      await tester.tap(find.text('CHEESE PAY'));
      await tester.pumpAndSettle();

      // Tap preset amount chip
      expect(find.text('₹ 5,000'), findsOneWidget);
      await tester.tap(find.text('₹ 5,000'));
      await tester.pumpAndSettle();

      // Scroll to make PAY NOW button visible if needed
      await tester.ensureVisible(find.text('PAY NOW'));
      await tester.tap(find.text('PAY NOW'));

      // Advance clock through the simulated network call
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Verify response sheet is displayed
      expect(find.text('Deposit Request Initiated'), findsOneWidget);
      expect(find.textContaining('VTX-DEP-'), findsOneWidget);
      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Live MT5 · 3311'), findsWidgets);
      expect(find.text('View in Activity & Orders'), findsOneWidget);
      expect(find.text('Back to Dashboard'), findsWidgets);

      // Tap View in Activity & Orders
      await tester.tap(find.text('View in Activity & Orders'));
      await tester.pumpAndSettle();
      expect(selectedPage, 'activity');
    });
  });
}
