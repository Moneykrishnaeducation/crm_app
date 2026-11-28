import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('BrokerAccountsPage loads and displays only standard type accounts', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Account 1: accountType: 'Standard', but groupName is 'real\Tier1_Raw' (different from Standard)
    const standardAccountWithDifferentGroup = BrokerAccount(
      'Standard Trader',
      '3001',
      '1:500',
      r'$10,000.00',
      r'$10,000.00',
      'Live MT5',
      groupName: 'real\\Tier1_Raw',
      accountType: 'Standard',
    );
    // Account 2: groupName is 'Standard', but accountType is 'VIP' (must NOT be listed)
    const vipAccountWithStandardGroup = BrokerAccount(
      'VIP Trader',
      '3002',
      '1:500',
      r'$20,000.00',
      r'$20,000.00',
      'Live MT5',
      groupName: 'Standard',
      accountType: 'VIP',
    );
    // Account 3: groupName is 'Standard', but accountType is 'ECN' (must NOT be listed)
    const ecnAccountWithStandardGroup = BrokerAccount(
      'ECN Trader',
      '3003',
      '1:200',
      r'$15,000.00',
      r'$15,000.00',
      'Live MT5',
      groupName: 'Standard',
      accountType: 'ECN',
    );
    // Account 4: default standard account
    const defaultAccount = BrokerAccount(
      'Global Alpha',
      '3004',
      '1:500',
      r'$5,000.00',
      r'$5,000.00',
      'Live MT5',
      accountType: 'Standard',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrokerAccountsPage(
          onSelectPage: (_) {},
          accounts: const [
            standardAccountWithDifferentGroup,
            vipAccountWithStandardGroup,
            ecnAccountWithStandardGroup,
            defaultAccount,
          ],
          onAccountCreated: (_) {},
          onAccountSelected: (_) {},
          favoriteLogins: const {},
          onToggleFavorite: (_) {},
        ),
      ),
    ));
    await tester.pump();

    // Accounts with account_type : Standard are displayed (regardless of groupName)
    expect(find.text('Standard Trader'), findsOneWidget);
    expect(find.text('3001'), findsOneWidget);
    expect(find.text('Global Alpha'), findsOneWidget);
    expect(find.text('3004'), findsOneWidget);

    // Accounts with account_type : VIP or ECN are NOT listed (even though groupName was 'Standard')
    expect(find.text('VIP Trader'), findsNothing);
    expect(find.text('3002'), findsNothing);
    expect(find.text('ECN Trader'), findsNothing);
    expect(find.text('3003'), findsNothing);

    // Live account badge shows 2 LIVE (the two accounts with account_type: Standard)
    expect(find.text('2 LIVE'), findsOneWidget);

    // Standard account type badge is visible in the account list
    expect(find.text('Standard'), findsWidgets);
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
