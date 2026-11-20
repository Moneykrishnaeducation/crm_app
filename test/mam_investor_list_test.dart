import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/pages/mam_page.dart';

void main() {
  testWidgets('investor tab lists accounts before opening account details', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MamPage(initialTab: 1)));
    await tester.pumpAndSettle();

    expect(find.text('Investor Accounts'), findsOneWidget);
    expect(find.text('testtest1 - Investment'), findsOneWidget);
    expect(find.text('testtest2 - Pro Copier'), findsOneWidget);
    expect(find.text('Account 3511'), findsNothing);

    await tester.tap(find.text('Account Details').first);
    await tester.pumpAndSettle();

    expect(find.text('MAM Account'), findsOneWidget);
    expect(find.byTooltip('Back to investor accounts'), findsOneWidget);
    expect(find.text('Investment Overview'), findsNothing);
    expect(find.text('Manage investment account 3511.'), findsNothing);

    await tester.tap(find.byTooltip('Back to investor accounts'));
    await tester.pumpAndSettle();

    expect(find.text('Investor Accounts'), findsOneWidget);
    expect(find.text('MAM Account'), findsNothing);
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
                  onDeploy: (method, factor, orderCloning, cloneCount) {
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
