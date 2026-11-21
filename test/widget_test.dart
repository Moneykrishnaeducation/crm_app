import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('LoginPage renders and navigates to AppShell on login', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify Login page is shown
    expect(find.text('Login'), findsWidgets);

    // Submit valid demo credentials to enter the dashboard.
    await tester.enterText(find.byType(TextFormField).at(0), 'demo@vtindex.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'DemoPass123!');
    final loginBtn = find.widgetWithText(FilledButton, 'Login');
    expect(loginBtn, findsOneWidget);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // Verify Dashboard is displayed
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Total balance'), findsOneWidget);
  });

  testWidgets('AppShell dashboard displays portfolio and can hide balance', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Total balance'), findsOneWidget);
    expect(find.text(r'$12,450.00'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.eye).first);
    await tester.pumpAndSettle();

    expect(find.text('••••••••'), findsOneWidget);
  });

  testWidgets('AppShell bottom navigation navigates between pages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Transactions
    await tester.tap(find.text('Activity').first);
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsWidgets);

    // Navigate to More
    await tester.tap(find.text('More').first);
    await tester.pumpAndSettle();
    expect(find.text('INVESTMENT & PARTNERSHIPS'), findsOneWidget);
    expect(find.text('View profile'), findsOneWidget);
    expect(find.text('Security Center'), findsOneWidget);
  });
}
