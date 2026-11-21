import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/pages/partnership_page.dart';

void main() {
  Widget buildTestableWidget({
    Brightness brightness = Brightness.light,
    Widget child = const BrokerPartnershipPage(),
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF0B1424)
            : const Color(0xFFF5F7FB),
        cardColor: brightness == Brightness.dark
            ? const Color(0xFF17243A)
            : Colors.white,
        dividerColor: brightness == Brightness.dark
            ? const Color(0xFF2A3A53)
            : const Color(0xFFE2E8F1),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0875F5),
          brightness: brightness,
        ),
      ),
      home: Scaffold(body: child),
    );
  }

  group('BrokerPartnershipPage UI and Theme Tests', () {
    testWidgets('renders hero card, stats, tools panel, and quick shortcuts in Light Mode', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(brightness: Brightness.light));
      await tester.pumpAndSettle();

      // Hero Card elements
      expect(find.text('PARTNERSHIP PROGRAM'), findsOneWidget);
      expect(find.text('Total IB Earnings'), findsOneWidget);
      expect(find.text(r'$4,820.00 USD'), findsOneWidget);
      expect(find.text('Network Clients'), findsOneWidget);
      expect(find.text('2,458 Clients'), findsOneWidget);
      expect(find.text('Executed Volume'), findsOneWidget);
      expect(find.text('142.80 Lots'), findsOneWidget);

      // Stats row
      expect(find.text('Network clients'), findsOneWidget);
      expect(find.text('2,458'), findsOneWidget);
      expect(find.text('IB earnings'), findsOneWidget);
      expect(find.text(r'$4,820.00'), findsOneWidget);

      // Partner code tools
      expect(find.text('Your partner code'), findsOneWidget);
      expect(find.text('SELECT PARTNER PROFILE'), findsOneWidget);
      expect(find.text('Show referral QR'), findsWidgets);

      // Quick shortcuts
      expect(find.text('Quick shortcuts'), findsOneWidget);
      expect(find.text('Client list'), findsOneWidget);
      expect(find.text('Commission ledger'), findsOneWidget);
      expect(find.text('Referral & QR studio'), findsOneWidget);
      expect(find.text('Commission withdrawal'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Mode without layout exceptions', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(brightness: Brightness.dark));
      await tester.pumpAndSettle();

      expect(find.text('PARTNERSHIP PROGRAM'), findsOneWidget);
      expect(find.text(r'$4,820.00 USD'), findsOneWidget);
      expect(find.text('Quick shortcuts'), findsOneWidget);

      await tester.pumpWidget(
        buildTestableWidget(
          brightness: Brightness.dark,
          child: const BrokerClientTreePage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your client network'), findsOneWidget);
    });

    testWidgets('tapping Show referral QR opens bottom sheet with referral QR and links', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap on Show referral QR button
      final qrButton = find.widgetWithText(FilledButton, 'Show referral QR').first;
      await tester.tap(qrButton);
      await tester.pumpAndSettle();

      // Bottom sheet is displayed
      expect(find.text('Referral QR Code'), findsOneWidget);
      expect(find.text('Copy link'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Close bottom sheet
      final closeButton = find.byTooltip('Close');
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text('Referral QR Code'), findsNothing);
    });

    testWidgets('BrokerReferralStudioPage renders metrics, route selector, and QR card', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(
        child: const BrokerReferralStudioPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Referral & QR Studio'), findsOneWidget);
      expect(find.text('NETWORK CLIENTS'), findsOneWidget);
      expect(find.text('TOTAL COMMISSION'), findsOneWidget);
      expect(find.text('TRADED VOLUME'), findsOneWidget);
      expect(find.text('ACTIVE REFERRAL LINKS'), findsOneWidget);
      expect(find.text('Commission Profiles'), findsOneWidget);
      expect(find.text('Share your partner QR'), findsOneWidget);
    });

    testWidgets('BrokerCommissionWithdrawalPage renders vault card, breakdown, and presets', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(
        child: const BrokerCommissionWithdrawalPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Commission Withdrawal'), findsOneWidget);
      expect(find.text('VT-INDEX VAULT'), findsOneWidget);
      expect(find.text(r'$4820.00'), findsOneWidget);
      expect(find.text('SETTLEMENT BREAKDOWN'), findsOneWidget);
      expect(find.text('COMMISSION PAYOUT DESK'), findsOneWidget);
      expect(find.text('Transfer to Trading Account'), findsOneWidget);

      // Tap preset 50%
      final preset50 = find.text('50%');
      expect(preset50, findsOneWidget);
      await tester.tap(preset50);
      await tester.pumpAndSettle();

      expect(find.text('2410.00'), findsOneWidget);
    });

    testWidgets('BrokerClientTreePage renders network stats, search bar, and member cards', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(
        child: const BrokerClientTreePage(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Client network'), findsOneWidget);
      expect(find.text('Your client network'), findsOneWidget);
      expect(find.text('TOTAL NETWORK'), findsOneWidget);
      expect(find.text('DIRECT (L1)'), findsOneWidget);
      expect(find.text('INR-DEVOP B'), findsOneWidget);
      expect(find.text('SHRAVAN KUMAR MADDKUNTA'), findsOneWidget);
    });

    testWidgets('BrokerCommissionLedgerPage renders ledger table and metrics', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(
        child: const BrokerCommissionLedgerPage(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Commission Ledger'), findsWidgets);
      expect(find.text('TOTAL EARNINGS'), findsOneWidget);
      expect(find.text('VOLUME TRADED'), findsOneWidget);
      expect(find.text('LEDGER RECORDS'), findsOneWidget);
      expect(find.text('CLIENT PROFILE'), findsOneWidget);
      expect(find.text('DEAL TICKET'), findsOneWidget);
      expect(find.text('TEST CRN'), findsWidgets);
      expect(find.text('Lakshminarayanan A'), findsWidgets);
    });

    testWidgets('renders all partnership pages on mobile phone screen (390x844) without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Mobile BrokerPartnershipPage
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      expect(find.text('PARTNERSHIP PROGRAM'), findsOneWidget);

      // Mobile BrokerReferralStudioPage
      await tester.pumpWidget(buildTestableWidget(child: const BrokerReferralStudioPage()));
      await tester.pumpAndSettle();
      expect(find.text('Referral & QR Studio'), findsOneWidget);

      // Mobile BrokerCommissionWithdrawalPage
      await tester.pumpWidget(buildTestableWidget(child: const BrokerCommissionWithdrawalPage()));
      await tester.pumpAndSettle();
      expect(find.text('Commission Withdrawal'), findsOneWidget);

      // Mobile BrokerClientTreePage
      await tester.pumpWidget(buildTestableWidget(child: const BrokerClientTreePage()));
      await tester.pumpAndSettle();
      expect(find.text('Client network'), findsOneWidget);

      // Mobile BrokerCommissionLedgerPage
      await tester.pumpWidget(buildTestableWidget(child: const BrokerCommissionLedgerPage()));
      await tester.pumpAndSettle();
      expect(find.text('Commission Ledger'), findsWidgets);
    });
  });
}
