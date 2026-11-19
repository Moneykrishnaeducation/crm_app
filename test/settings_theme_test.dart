import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('BrokerThemeModePage renders options and triggers callbacks', (tester) async {
    ThemeMode? selectedMode;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrokerThemeModePage(
            themeMode: ThemeMode.system,
            onThemeModeChanged: (mode) => selectedMode = mode,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Theme Settings'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Light Mode'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);

    await tester.tap(find.text('Dark Mode'));
    await tester.pumpAndSettle();
    expect(selectedMode, ThemeMode.dark);

    await tester.tap(find.text('Light Mode'));
    await tester.pumpAndSettle();
    expect(selectedMode, ThemeMode.light);
  });
}
