import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

void main() {
  testWidgets('BrokerMorePage renders redesigned _MoreProfileCard with all elements', (tester) async {
    String? navigatedTo;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: BrokerMorePage(
            onSelectPage: (page) => navigatedTo = page,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check Identity info
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Email unavailable'), findsOneWidget);
    expect(find.text('Client ID unavailable'), findsOneWidget);
    expect(find.text('U'), findsOneWidget); // Dynamic initials fallback

    // Check Badges & Trust indicators
    expect(find.byIcon(LucideIcons.badgeCheck), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.byIcon(LucideIcons.shieldCheck), findsWidgets);
    expect(find.text('Live MT5 Trader'), findsOneWidget);
    expect(find.byIcon(LucideIcons.crown), findsOneWidget);

    // Check Quick Action link
    expect(find.text('View profile'), findsOneWidget);

    // Test Tap interaction triggers navigation callback
    await tester.tap(find.text('—'));
    await tester.pumpAndSettle();
    expect(navigatedTo, 'Profile');
  });

  testWidgets('_MoreProfileCard renders in dark theme without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: BrokerMorePage(
            onSelectPage: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('INR-DEVOP B'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('Live MT5 Trader'), findsOneWidget);
  });

  testWidgets('_MoreProfileCard adapts to ultra-narrow 320px screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: BrokerMorePage(
            onSelectPage: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('INR-DEVOP B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
