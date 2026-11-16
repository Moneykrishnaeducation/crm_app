import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';

Widget _buildNavBarHarness({
  String selectedPage = 'Dashboard',
  required ValueChanged<String> onSelect,
}) {
  return MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: Scaffold(
      bottomNavigationBar: BrokerBottomNavigation(
        selectedPage: selectedPage,
        onSelect: onSelect,
      ),
    ),
  );
}

void main() {
  group('BrokerBottomNavigation Widget Tests', () {
    testWidgets('renders all 4 tabs and center quick actions button', (tester) async {
      await tester.pumpWidget(
        _buildNavBarHarness(
          selectedPage: 'Dashboard',
          onSelect: (_) {},
        ),
      );

      // Verify all 4 tab labels
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);

      // Verify center quick action '+' button
      expect(find.byIcon(LucideIcons.plus), findsOneWidget);

      // Verify tab icons
      expect(find.byIcon(LucideIcons.house), findsOneWidget);
      expect(find.byIcon(LucideIcons.receiptText), findsOneWidget);
      expect(find.byIcon(LucideIcons.layers), findsOneWidget);
      expect(find.byIcon(LucideIcons.grid2x2), findsOneWidget);
    });

    testWidgets('tapping each navigation tab triggers onSelect with expected identifier', (tester) async {
      final List<String> selections = [];

      await tester.pumpWidget(
        _buildNavBarHarness(
          selectedPage: 'Dashboard',
          onSelect: selections.add,
        ),
      );

      // Tap Transactions
      await tester.tap(find.text('Transactions'));
      await tester.pump();
      expect(selections, equals(['Transactions']));

      // Tap Accounts (should pass 'Trading Accounts')
      await tester.tap(find.text('Accounts'));
      await tester.pump();
      expect(selections, equals(['Transactions', 'Trading Accounts']));

      // Tap More
      await tester.tap(find.text('More'));
      await tester.pump();
      expect(selections, equals(['Transactions', 'Trading Accounts', 'More']));

      // Tap Dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pump();
      expect(selections, equals(['Transactions', 'Trading Accounts', 'More', 'Dashboard']));
    });

    testWidgets('tapping + opens quick actions modal sheet and shows all actions', (tester) async {
      String? selectedAction;

      await tester.pumpWidget(
        _buildNavBarHarness(
          selectedPage: 'Dashboard',
          onSelect: (action) => selectedAction = action,
        ),
      );

      // Tap center '+' button
      await tester.tap(find.byIcon(LucideIcons.plus));
      await tester.pumpAndSettle();

      // Verify modal sheet is open with title
      expect(find.text('Quick actions'), findsOneWidget);

      // Verify all quick action rows are displayed
      expect(find.text('Deposit funds'), findsOneWidget);
      expect(find.text('Withdraw funds'), findsOneWidget);
      expect(find.text('Open live account'), findsOneWidget);
      expect(find.text('Internal transfer'), findsOneWidget);
      expect(find.text('Create demo account'), findsOneWidget);

      // Tap 'Deposit funds' action
      await tester.tap(find.text('Deposit funds'));
      await tester.pumpAndSettle();

      // Verify callback was called with 'Deposit' and sheet dismissed
      expect(selectedAction, equals('Deposit'));
      expect(find.text('Quick actions'), findsNothing);
    });

    testWidgets('all quick action items trigger their corresponding callbacks', (tester) async {
      final actions = <String, String>{
        'Deposit funds': 'Deposit',
        'Withdraw funds': 'Withdraw',
        'Open live account': 'Open Account',
        'Internal transfer': 'Internal Transfer',
        'Create demo account': 'Demo Accounts',
      };

      for (final entry in actions.entries) {
        String? triggered;

        await tester.pumpWidget(
          _buildNavBarHarness(
            selectedPage: 'Dashboard',
            onSelect: (val) => triggered = val,
          ),
        );

        // Open sheet
        await tester.tap(find.byIcon(LucideIcons.plus));
        await tester.pumpAndSettle();

        // Tap the action
        await tester.tap(find.text(entry.key));
        await tester.pumpAndSettle();

        expect(triggered, equals(entry.value), reason: 'Expected ${entry.value} for action "${entry.key}"');
        expect(find.text('Quick actions'), findsNothing);
      }
    });

    testWidgets('active tab reflects selectedPage semantics', (tester) async {
      await tester.pumpWidget(
        _buildNavBarHarness(
          selectedPage: 'Trading Accounts',
          onSelect: (_) {},
        ),
      );

      final dashboardSemantics = tester.widget<Semantics>(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Dashboard'),
      );
      expect(dashboardSemantics.properties.selected, isFalse);

      final accountsSemantics = tester.widget<Semantics>(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Accounts'),
      );
      expect(accountsSemantics.properties.selected, isTrue);
    });

    testWidgets('center quick action (+) button scales down on tap down and returns on release', (tester) async {
      await tester.pumpWidget(
        _buildNavBarHarness(
          selectedPage: 'Dashboard',
          onSelect: (_) {},
        ),
      );

      final plusFinder = find.byIcon(LucideIcons.plus);
      expect(plusFinder, findsOneWidget);

      // Initially scale is 1.0
      final scaleFinder = find.ancestor(
        of: plusFinder,
        matching: find.byType(AnimatedScale),
      );
      expect(scaleFinder, findsWidgets);

      final gesture = await tester.startGesture(tester.getCenter(plusFinder));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      final pressedScaleWidget = tester.widget<AnimatedScale>(scaleFinder.first);
      expect(pressedScaleWidget.scale, equals(0.92));

      await gesture.up();
      await tester.pumpAndSettle();

      // Quick action sheet opened, but button scale in bar returned to 1.0
      final releasedScaleWidget = tester.widget<AnimatedScale>(scaleFinder.first);
      expect(releasedScaleWidget.scale, equals(1.0));
    });

    testWidgets('active nav tab displays illuminated indicator pill', (tester) async {
      await tester.pumpWidget(
        _buildNavBarHarness(
          selectedPage: 'Dashboard',
          onSelect: (_) {},
        ),
      );

      // Verify that Dashboard has the illuminated indicator dot/bar (width 14)
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      final indicatorBars = animatedContainers.where(
        (c) => (c.decoration as BoxDecoration?)?.borderRadius == BorderRadius.circular(2),
      );
      expect(indicatorBars, isNotEmpty);

      // At least one indicator bar has width 14 (for selected tab)
      final selectedIndicator = indicatorBars.firstWhere((c) => (c.constraints?.maxWidth ?? 0) >= 14 || c.constraints == BoxConstraints.tightFor(width: 14, height: 2.5));
      expect(selectedIndicator, isNotNull);
    });

    testWidgets('floating capsule dock renders with 32px border radius, max-width 520 and elevated center button', (tester) async {
      await tester.pumpWidget(
        _buildNavBarHarness(
          selectedPage: 'Dashboard',
          onSelect: (_) {},
        ),
      );

      // Verify max width constraint is 520
      final constrainedBoxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final dockConstraint = constrainedBoxes.firstWhere(
        (cb) => cb.constraints.maxWidth == 520,
      );
      expect(dockConstraint, isNotNull);

      // Verify outer capsule container has BorderRadius.circular(32)
      final containers = tester.widgetList<Container>(find.byType(Container));
      final capsule = containers.firstWhere(
        (c) => (c.decoration as BoxDecoration?)?.borderRadius == BorderRadius.circular(32),
      );
      expect(capsule, isNotNull);
      expect(capsule.margin, equals(const EdgeInsets.fromLTRB(16, 0, 16, 12)));

      // Verify center (+) button is 56x56 and elevated with Offset(0, -18)
      final plusFinder = find.byIcon(LucideIcons.plus);
      final centerButtonContainer = tester.widget<Container>(
        find.ancestor(of: plusFinder, matching: find.byType(Container)).first,
      );
      expect(centerButtonContainer.constraints?.maxWidth, equals(56));
      expect(centerButtonContainer.constraints?.maxHeight, equals(56));

      final translationFinder = find.ancestor(of: plusFinder, matching: find.byType(Transform));
      final elevatedTransform = tester.widgetList<Transform>(translationFinder).firstWhere(
        (t) => t.transform.getTranslation().y == -18.0,
      );
      expect(elevatedTransform, isNotNull);

      // Verify active nav tab pill has BorderRadius.circular(20)
      final activeItemPill = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).firstWhere(
        (c) => (c.decoration as BoxDecoration?)?.borderRadius == BorderRadius.circular(20),
      );
      expect(activeItemPill, isNotNull);
    });
  });
}
