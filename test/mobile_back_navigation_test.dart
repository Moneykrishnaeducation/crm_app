import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  PopScope<Object?> getPopScope(WidgetTester tester) {
    return tester.widget<PopScope<Object?>>(find.byKey(const Key('app_shell_pop_scope')));
  }

  Widget buildTestShell() {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.linux),
      home: const AppShell(),
    );
  }

  group('Mobile Back Navigation and PopScope Tests', () {
    testWidgets(
      'navigating Dashboard -> Trading Accounts -> Account Details and pressing back step-by-step returns to Trading Accounts, Dashboard, and allows system pop',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestShell());
        await tester.pumpAndSettle();

        // 1. Initial page is Dashboard, canPop should be true
        expect(find.text('Total balance'), findsOneWidget);
        expect(getPopScope(tester).canPop, isTrue);

        // 2. Navigate to Trading Accounts
        await tester.tap(find.text('Accounts').first);
        await tester.pumpAndSettle();
        expect(find.text('Trading Accounts'), findsWidgets);
        expect(getPopScope(tester).canPop, isFalse);

        // 3. Open Account Details by tapping the live account card (login 3315)
        final accountCard = find.text('3315');
        expect(accountCard, findsOneWidget);
        await tester.tap(accountCard);
        await tester.pumpAndSettle();

        expect(find.text('Overview'), findsOneWidget);
        expect(getPopScope(tester).canPop, isFalse);

        // 4. Simulate mobile system back button from Account Details -> returns to Trading Accounts
        final handledOnDetails = await tester.binding.handlePopRoute();
        expect(handledOnDetails, isTrue);
        await tester.pumpAndSettle();

        expect(find.text('Trading Accounts'), findsWidgets);
        expect(getPopScope(tester).canPop, isFalse);

        // 5. Simulate mobile system back button from Trading Accounts -> returns to Dashboard
        final handledOnAccounts = await tester.binding.handlePopRoute();
        expect(handledOnAccounts, isTrue);
        await tester.pumpAndSettle();

        expect(find.text('Total balance'), findsOneWidget);
        expect(getPopScope(tester).canPop, isTrue);

        // 6. On Dashboard with empty history, canPop is true allowing system pop
        final handledOnDashboard = await tester.binding.handlePopRoute();
        // Since canPop is true, Navigator does not trap the pop and bubbles to system
        expect(handledOnDashboard, isFalse);
        expect(getPopScope(tester).canPop, isTrue);
      },
    );

    testWidgets(
      'navigating More -> Settings -> Theme Mode and pressing back step-by-step returns cleanly',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestShell());
        await tester.pumpAndSettle();

        // 1. Navigate to More tab
        await tester.tap(find.text('More').first);
        await tester.pumpAndSettle();
        expect(find.text('INVESTMENT & PARTNERSHIPS'), findsOneWidget);

        // 2. Tap Settings in More menu
        await tester.tap(find.text('Settings').first);
        await tester.pumpAndSettle();
        expect(find.text('Personalize your experience'), findsOneWidget);

        // 3. Tap Theme Mode in Settings
        await tester.tap(find.text('Theme Mode').first);
        await tester.pumpAndSettle();
        expect(find.text('Theme Settings'), findsOneWidget);
        expect(find.text('Auto'), findsOneWidget);

        // 4. Press back once -> returns to Settings
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Personalize your experience'), findsOneWidget);
        expect(find.text('Theme Settings'), findsNothing);

        // 5. Press back second time -> returns to More
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('INVESTMENT & PARTNERSHIPS'), findsOneWidget);

        // 6. Press back third time -> returns to Dashboard
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Total balance'), findsOneWidget);

        // 7. On Dashboard, canPop is true
        expect(getPopScope(tester).canPop, isTrue);
      },
    );

    testWidgets(
      'bottom sheet quick actions dismiss cleanly on mobile back without altering page',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestShell());
        await tester.pumpAndSettle();

        // Open quick actions bottom sheet
        await tester.tap(find.byIcon(LucideIcons.plus).last);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);

        // Mobile back dismisses bottom sheet
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsNothing);
        expect(find.text('Total balance'), findsOneWidget);
        expect(getPopScope(tester).canPop, isTrue);
      },
    );

    testWidgets(
      'bottom sheet account creation modals dismiss cleanly on back',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestShell());
        await tester.pumpAndSettle();

        // Open quick actions then Create Demo Account
        await tester.tap(find.byIcon(LucideIcons.plus).last);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create demo account'));
        await tester.pumpAndSettle();

        // The demo account modal sheet is displayed
        expect(find.text('CREATE DEMO ACCOUNT'), findsOneWidget);

        // Mobile back should dismiss modal sheet
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('CREATE DEMO ACCOUNT'), findsNothing);
        expect(find.text('Total balance'), findsOneWidget);
        expect(getPopScope(tester).canPop, isTrue);
      },
    );

    testWidgets(
      'header back button triggers exact same back navigation behavior as system back',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestShell());
        await tester.pumpAndSettle();

        // Tap Deposit quick action on Dashboard
        await tester.ensureVisible(find.text('Deposit').first);
        await tester.tap(find.text('Deposit').first);
        await tester.pumpAndSettle();

        // Verify Deposit page is visible and header back button exists
        expect(find.byTooltip('Back'), findsOneWidget);

        // Tap the header back button
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        // Verify back on Dashboard
        expect(find.text('Total balance'), findsOneWidget);
        expect(getPopScope(tester).canPop, isTrue);
      },
    );
  });
}
