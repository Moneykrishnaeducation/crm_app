import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('BrokerAccountsPage loads and displays only standard type accounts', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const standardAccount = BrokerAccount(
      'Standard Trader',
      '3001',
      '1:500',
      r'$10,000.00',
      r'$10,000.00',
      'Live MT5',
      groupName: 'Standard',
    );
    const vipAccount = BrokerAccount(
      'VIP Trader',
      '3002',
      '1:500',
      r'$20,000.00',
      r'$20,000.00',
      'Live MT5',
      groupName: 'VIP',
    );
    const ecnAccount = BrokerAccount(
      'ECN Trader',
      '3003',
      '1:200',
      r'$15,000.00',
      r'$15,000.00',
      'Live MT5',
      groupName: 'ECN',
    );
    const defaultAccount = BrokerAccount(
      'Standard MT5',
      '3004',
      '1:500',
      r'$5,000.00',
      r'$5,000.00',
      'Live MT5',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrokerAccountsPage(
          onSelectPage: (_) {},
          accounts: const [standardAccount, vipAccount, ecnAccount, defaultAccount],
          onAccountCreated: (_) {},
          onAccountSelected: (_) {},
          favoriteLogins: const {},
          onToggleFavorite: (_) {},
        ),
      ),
    ));
    await tester.pump();

    // Standard accounts are displayed
    expect(find.text('Standard Trader'), findsOneWidget);
    expect(find.text('3001'), findsOneWidget);
    expect(find.text('Standard MT5'), findsOneWidget);
    expect(find.text('3004'), findsOneWidget);

    // Non-standard accounts (VIP, ECN) are filtered out
    expect(find.text('VIP Trader'), findsNothing);
    expect(find.text('3002'), findsNothing);
    expect(find.text('ECN Trader'), findsNothing);
    expect(find.text('3003'), findsNothing);

    // Live account badge shows 2 LIVE (the two standard accounts)
    expect(find.text('2 LIVE'), findsOneWidget);
  });

  testWidgets('Open live account sheet on trading account page loads only standard type', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrokerAccountsPage(
          onSelectPage: (_) {},
          accounts: const [],
          onAccountCreated: (_) {},
          onAccountSelected: (_) {},
          favoriteLogins: const {},
          onToggleFavorite: (_) {},
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.text('Open live account'));
    await tester.pump();

    // Trading group only has Standard, VIP and ECN are not loaded
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('VIP - Recommended (Default)'), findsNothing);
    expect(find.text('ECN'), findsNothing);
  });
}
