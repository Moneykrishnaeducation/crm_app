import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';

void main() {
  final testAccounts = [
    const BrokerAccount(
      'Standard Account',
      '3315',
      '1:500',
      r'$2,500.00',
      r'$2,500.00',
      'Live MT5',
      server: 'VTIndex-MT5',
    ),
    const BrokerAccount(
      'ECN Account',
      '3311',
      '1:500',
      r'$1,000.00',
      r'$1,000.00',
      'Live MT5',
      server: 'VTIndex-MT5',
    ),
  ];

  Widget buildTestWidget({
    ThemeMode themeMode = ThemeMode.light,
    void Function(String, String, double)? onTransferCompleted,
    VoidCallback? onBack,
  }) {
    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1658C9)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1658C9),
          brightness: Brightness.dark,
        ),
      ),
      home: BrokerInternalTransferPage(
        accounts: testAccounts,
        initialSourceLogin: '3315',
        initialDestinationLogin: '3311',
        onTransferCompleted: onTransferCompleted,
        onBack: onBack,
      ),
    );
  }

  testWidgets('renders Internal Transfer page with brand elements and accounts', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Internal Transfer'), findsWidgets);
    expect(find.textContaining('Move funds'), findsOneWidget);
    expect(find.textContaining('INSTANT'), findsWidgets);
    expect(find.text('TRANSFER AMOUNT'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.textContaining('Available: \$2,500.00'), findsWidgets);
  });

  testWidgets('swapping accounts toggles source and destination', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify initial available balance for source #3315 is $2,500.00
    expect(find.textContaining('Available: \$2,500.00'), findsOneWidget);

    // Tap swap icon button
    final swapButton = find.byKey(const ValueKey('swap_accounts_button'));
    await tester.tap(swapButton);
    await tester.pumpAndSettle();

    // Source is now #3311, so available balance is $1,000.00
    expect(find.textContaining('Available: \$1,000.00'), findsOneWidget);
  });

  testWidgets('quick percentage and preset chips populate amount field', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Tap 50% chip
    await tester.tap(find.text('50%'));
    await tester.pumpAndSettle();

    // 50% of 2500 is 1250.00
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, '1250.00');

    // Tap MAX
    await tester.tap(find.text('MAX').first);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, '2500.00');
  });

  testWidgets('validation detects insufficient balance and disables continue', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Enter amount larger than 2500
    await tester.enterText(find.byType(TextField), '3000');
    await tester.pumpAndSettle();

    expect(find.textContaining('Amount exceeds available balance'), findsOneWidget);

    final continueBtn = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'CONTINUE'));
    expect(continueBtn.onPressed, isNull);
  });

  testWidgets('executing valid transfer completes successfully and updates balance', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    bool transferCalled = false;
    double? transferAmount;

    await tester.pumpWidget(buildTestWidget(
      onTransferCompleted: (from, to, amt) {
        transferCalled = true;
        transferAmount = amt;
      },
    ));
    await tester.pumpAndSettle();

    // Enter valid amount
    await tester.enterText(find.byType(TextField), '200');
    await tester.pumpAndSettle();

    final continueBtnFinder = find.widgetWithText(FilledButton, 'CONTINUE');
    final continueBtn = tester.widget<FilledButton>(continueBtnFinder);
    expect(continueBtn.onPressed, isNotNull);

    // Ensure button is visible before tapping
    await tester.ensureVisible(continueBtnFinder);
    await tester.pumpAndSettle();

    // Tap CONTINUE to show confirmation sheet
    await tester.tap(continueBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Confirm Internal Transfer'), findsOneWidget);
    expect(find.text('Confirm & Transfer'), findsOneWidget);

    // Tap Confirm & Transfer
    await tester.tap(find.text('Confirm & Transfer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(transferCalled, isTrue);
    expect(transferAmount, 200.0);
    expect(find.text('Transfer Successful!'), findsOneWidget);

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Should see new remaining balance: 2500 - 200 = 2300
    expect(find.textContaining('\$2,300.00'), findsWidgets);
  });

  testWidgets('renders cleanly in dark mode without errors', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    expect(find.text('Internal Transfer'), findsWidgets);
    expect(find.textContaining('Move funds'), findsOneWidget);
  });
}
