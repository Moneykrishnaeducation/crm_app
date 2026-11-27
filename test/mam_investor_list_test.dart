import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/pages/mam_page.dart';

void main() {
  testWidgets('master dashboard displays exact AUM currency values', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MamPage(initialTab: 0)));

    expect(find.text('MANAGED AUM'), findsOneWidget);
    expect(find.text('\$1700400.00'), findsOneWidget);
  });

  testWidgets('investor tab lists accounts before opening account details, without duplicate second header', (
    tester,
  ) async {
    final mamKey = GlobalKey<MamPageState>();
    await tester.pumpWidget(MaterialApp(home: MamPage(key: mamKey, initialTab: 1)));
    await tester.pumpAndSettle();

    expect(find.text('Investor Accounts'), findsOneWidget);
    expect(find.text('testtest1 - Investment'), findsOneWidget);
    expect(find.text('testtest2 - Pro Copier'), findsOneWidget);
    expect(find.text('Account 3511'), findsNothing);

    await tester.tap(find.text('Account Details').first);
    await tester.pumpAndSettle();

    // Verify the second duplicate header with 'Back to investor accounts' is removed
    expect(find.byTooltip('Back to investor accounts'), findsNothing);
    expect(mamKey.currentState!.hasActiveSubView, isTrue);
    expect(find.text('TESTTEST1 - INVESTMENT'), findsOneWidget);
    expect(find.text('Investment Overview'), findsNothing);
    expect(find.text('Manage investment account 3511.'), findsNothing);

    // Popping subview (via PopScope or top app bar) transitions back to Investor Accounts
    final handled = await tester.binding.handlePopRoute();
    expect(handled, isTrue);
    await tester.pumpAndSettle();

    expect(mamKey.currentState!.hasActiveSubView, isFalse);
    expect(find.text('Investor Accounts'), findsOneWidget);
  });

  testWidgets('position clone count supports 1x through 5x', (tester) async {
    int? deployedCloneCount;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showEditCopyMultipliersModal(
                  context,
                  initialOrderCloning: true,
                  initialCloneCount: 1,
                  onDeploy: (method, factor, orderCloning, cloneCount) async {
                    deployedCloneCount = cloneCount;
                  },
                );
              },
              child: const Text('Open Configuration'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Configuration'));
    await tester.pumpAndSettle();

    expect(find.text('POSITION CLONE COUNT'), findsOneWidget);
    expect(find.text('1x'), findsOneWidget);
    expect(find.text('2x'), findsOneWidget);
    expect(find.text('3x'), findsOneWidget);
    expect(find.text('4x'), findsOneWidget);
    expect(find.text('5x'), findsOneWidget);

    await tester.tap(find.text('3x'));
    await tester.tap(find.text('DEPLOY CONFIGURATION'));
    await tester.pumpAndSettle();

    expect(deployedCloneCount, 3);
  });
}
