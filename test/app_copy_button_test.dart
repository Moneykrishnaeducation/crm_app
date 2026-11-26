import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:crm_app/app_notifications.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const hapticsChannel = MethodChannel('com.vtindex.crm/haptics');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hapticsChannel, (call) async => true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(hapticsChannel, null);
  });

  Widget buildTestable(Widget child) {
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('AppCopyButton copies to clipboard and transforms icon to checkmark', (tester) async {
    String? clipboardData;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboardData = (call.arguments as Map)['text'] as String?;
        return null;
      }
      return null;
    });

    await tester.pumpWidget(
      buildTestable(
        const AppCopyButton(
          value: '12345678',
          label: 'Account number',
        ),
      ),
    );

    // Initial state: shows copy icon
    expect(find.byIcon(LucideIcons.copy), findsOneWidget);
    expect(find.byIcon(LucideIcons.check), findsNothing);

    // Tap copy button
    await tester.tap(find.byType(AppCopyButton));
    await tester.pump(); // Start transition

    expect(clipboardData, '12345678');
    await tester.pump(const Duration(milliseconds: 250));

    // Shows animated checkmark
    expect(find.byIcon(LucideIcons.check), findsOneWidget);
    expect(find.byIcon(LucideIcons.copy), findsNothing);

    // After 1500ms duration, reverts back to copy icon
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byIcon(LucideIcons.copy), findsOneWidget);
    expect(find.byIcon(LucideIcons.check), findsNothing);
  });

  testWidgets('AppCopyButton.outlined updates button label to Copied! and reverts', (tester) async {
    await tester.pumpWidget(
      buildTestable(
        const AppCopyButton.outlined(
          value: 'https://vtindex.com/ref/99',
          label: 'Referral link',
          buttonLabel: 'Copy Link',
        ),
      ),
    );

    // Initial label
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.text('Copied!'), findsNothing);

    // Tap button
    await tester.tap(find.byType(AppCopyButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Copied!'), findsOneWidget);
    expect(find.text('Copy Link'), findsNothing);

    // After 1500ms, reverts
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.text('Copied!'), findsNothing);
  });
}
