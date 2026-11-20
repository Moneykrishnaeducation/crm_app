import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('created live account sheet stays open and shows credentials', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    BrokerAccount? createdAccount;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrokerAccountsPage(
          onSelectPage: (_) {},
          accounts: const [],
          onAccountCreated: (account) => createdAccount = account,
          onAccountSelected: (_) {},
          favoriteLogins: const {},
          onToggleFavorite: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open live account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Test Trader');
    await tester.tap(find.text('CREATE LIVE ACCOUNT'));
    await tester.pumpAndSettle();

    expect(createdAccount, isNotNull);
    expect(find.text('Account Created'), findsOneWidget);
    expect(find.text('Account number'), findsOneWidget);
    expect(find.text('Master password'), findsOneWidget);
    expect(find.text('Investor password'), findsOneWidget);
    expect(find.text(createdAccount!.login), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Open Live Account'), findsNothing);
  });

  testWidgets('created demo account sheet stays open and shows credentials', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    BrokerAccount? createdAccount;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrokerDemoAccountsPage(
          onAccountCreated: (account) => createdAccount = account,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Demo'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).at(1),
      'Practice Trader',
    );
    await tester.tap(find.text('CREATE DEMO ACCOUNT'));
    await tester.pumpAndSettle();

    expect(createdAccount, isNotNull);
    expect(createdAccount!.type, 'Demo MT5');
    expect(find.text('Demo Account Created'), findsOneWidget);
    expect(find.text('Account number'), findsOneWidget);
    expect(find.text('Master password'), findsOneWidget);
    expect(find.text('Investor password'), findsOneWidget);
    expect(find.byType(SelectableText), findsNWidgets(3));
    expect(find.text('DONE'), findsOneWidget);
    expect(find.text('Create Demo Account'), findsNothing);
  });

  testWidgets('settings button opens change investor password bottom popup and flows through continue, confirm, and done in same sheet', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const testAccount = BrokerAccount('Standard Trader', '3419921', '1:500', '\$2,500.00', '\$2,500.00', 'Live MT5');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: BrokerAccountDetailsPage(
          account: testAccount,
          onBack: () {},
          onSelectPage: (_) {},
          isFavorite: false,
          onToggleFavorite: () {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final settingsBtn = find.text('Settings');
    expect(settingsBtn, findsOneWidget);

    await tester.tap(settingsBtn);
    await tester.pumpAndSettle();

    // Step 1: Input view
    expect(find.text('Change Investor Password'), findsOneWidget);
    expect(find.text('Account #3419921 (Standard Trader)'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);

    await tester.tap(find.text('Generate Strong Password'));
    await tester.pumpAndSettle();

    // Tap CONTINUE -> Step 2: Confirm view
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Password Change'), findsOneWidget);
    expect(find.text('SUMMARY OF CHANGES'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);

    // Test CANCEL button returns to input step
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(find.text('Change Investor Password'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);

    // Move to confirm again
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Password Change'), findsOneWidget);

    // Tap CONFIRM -> Step 3: Success view
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(find.text('Investor Password Preview Ready'), findsOneWidget);
    expect(find.text('This password is shown for preview only and has not been applied to MT5.'), findsOneWidget);
    expect(find.text('New investor password'), findsOneWidget);
    expect(find.text('Access permission'), findsNothing);
    expect(find.text('Read-only (No trading execution)'), findsNothing);
    expect(find.text('DONE'), findsOneWidget);

    // Tap DONE -> closes sheet
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    expect(find.text('Investor Password Changed!'), findsNothing);
    expect(find.text('Trading snapshot'), findsOneWidget);
  });
}
