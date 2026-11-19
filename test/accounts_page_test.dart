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
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Account'));
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
}
