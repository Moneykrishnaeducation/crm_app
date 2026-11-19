import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('settings groups options and keeps their navigation working', (
    tester,
  ) async {
    final selectedPages = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrokerSettingsPage(
            themeMode: ThemeMode.dark,
            onSelectPage: (page) => selectedPages.add(page),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personalize your experience'), findsOneWidget);
    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Sub-version'), findsOneWidget);

    final chevrons = find.byIcon(LucideIcons.chevronRight);
    final themeChevronX = tester.getTopLeft(chevrons.at(0)).dx;
    final privacyChevronX = tester.getTopLeft(chevrons.at(1)).dx;
    expect(themeChevronX, privacyChevronX);

    await tester.tap(find.text('Theme Mode'));
    await tester.pumpAndSettle();
    expect(selectedPages, ['Theme Mode']);

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(selectedPages, ['Theme Mode', 'Privacy Policy']);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
