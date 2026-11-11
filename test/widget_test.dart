import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import 'package:crm_app/main.dart';

void main() {
  testWidgets('dashboard displays portfolio and can hide balance', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.text('PORTFOLIO SUMMARY'), findsOneWidget);
    expect(find.text('TOTAL REAL BALANCE'), findsOneWidget);
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.text('\$0'), findsWidgets);

    await tester.tap(find.byTooltip('Hide balance'));
    await tester.pumpAndSettle();

    expect(find.text('••••'), findsOneWidget);
  });

  testWidgets('sidebar pages keep the shared application header', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Transactions').first);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This section is ready to be connected to your account services.',
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Notifications'), findsOneWidget);
  });

  testWidgets('mobile top menu opens the sidebar and navigates', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();

    expect(find.text('Trade Pattern Analysis'), findsOneWidget);
    await tester.ensureVisible(find.text('Transactions').first);
    await tester.tap(find.text('Transactions').first);
    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.byTooltip('Open navigation'), findsOneWidget);
  });

  testWidgets('desktop sidebar toggle collapses and expands navigation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
    expect(find.text('Dashboard'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Collapse sidebar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Expand sidebar'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);

    await tester.tap(find.byTooltip('Expand sidebar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
  });
}
