import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestShell() {
    return MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      home: const AppShell(),
    );
  }

  group('Floating bottom navigation keyboard avoidance tests', () {
    testWidgets('BrokerBottomNavigation hides when keyboard is open and reappears when closed', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      // 1. Initial state: keyboard is closed, floating nav bar is present
      expect(find.byType(BrokerBottomNavigation), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);

      // 2. Simulate soft keyboard popping up (viewInsets bottom = 300)
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await tester.pumpAndSettle();

      // Verify BrokerBottomNavigation is hidden when keyboard is open
      expect(find.byType(BrokerBottomNavigation), findsNothing);

      // 3. Simulate soft keyboard closing (viewInsets bottom = 0)
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();

      // Verify BrokerBottomNavigation reappears
      expect(find.byType(BrokerBottomNavigation), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('BrokerBottomNavigation hides on secondary form pages when keyboard is active', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      // Navigate to Deposit page
      await tester.ensureVisible(find.text('Deposit').first);
      await tester.tap(find.text('Deposit').first);
      await tester.pumpAndSettle();

      // On Deposit page before keyboard opens: nav bar is present
      expect(find.byType(BrokerBottomNavigation), findsOneWidget);

      // Focus any TextField / simulate keyboard appearing
      tester.view.viewInsets = const FakeViewPadding(bottom: 700);
      await tester.pumpAndSettle();

      // Floating bottom bar MUST NOT be floating above the keyboard
      expect(find.byType(BrokerBottomNavigation), findsNothing);

      // Keyboard dismissed
      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();

      // Floating bottom bar is restored
      expect(find.byType(BrokerBottomNavigation), findsOneWidget);
    });
  });
}
