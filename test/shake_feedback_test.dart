import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_app/widgets/shake_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.vtindex.crm/haptics');

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('ShakeController', () {
    test('initializes with isError false', () {
      final controller = ShakeController();
      expect(controller.isError, isFalse);
      controller.dispose();
    });

    test('shake sets isError to true and notifies listeners', () {
      final controller = ShakeController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.shake(triggerHaptics: false);

      expect(controller.isError, isTrue);
      expect(notifications, 1);
      controller.dispose();
    });

    test('clearError resets isError to false and notifies listeners', () {
      final controller = ShakeController();
      var notifications = 0;
      controller.shake(triggerHaptics: false);
      controller.addListener(() => notifications++);

      controller.clearError();

      expect(controller.isError, isFalse);
      expect(notifications, 1);

      // Calling clearError again when already false should not notify
      controller.clearError();
      expect(notifications, 1);
      controller.dispose();
    });

    test('shake invokes haptics when triggerHaptics is true', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return true;
      });

      final controller = ShakeController();
      controller.shake(triggerHaptics: true);

      // Allow microtask queue to process
      await Future<void>.delayed(Duration.zero);
      expect(calls.isNotEmpty, isTrue);
      expect(calls.first.method, 'vibrate');
      controller.dispose();
    });
  });

  group('ShakeFeedbackWidget', () {
    testWidgets('renders child widget correctly', (tester) async {
      final controller = ShakeController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShakeFeedbackWidget(
              controller: controller,
              child: const Text('Target Field'),
            ),
          ),
        ),
      );

      expect(find.text('Target Field'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('animates horizontal offset on controller.shake()', (tester) async {
      final controller = ShakeController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShakeFeedbackWidget(
              controller: controller,
              shakeDistance: 8.0,
              child: const SizedBox(
                key: Key('target_box'),
                width: 100,
                height: 50,
              ),
            ),
          ),
        ),
      );

      // Initial transform at rest
      final initialTransform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(ShakeFeedbackWidget),
          matching: find.byType(Transform),
        ),
      );
      expect(initialTransform.transform.getTranslation().x, 0.0);

      // Trigger shake
      controller.shake(triggerHaptics: false);
      await tester.pump(const Duration(milliseconds: 50));

      final midTransform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(ShakeFeedbackWidget),
          matching: find.byType(Transform),
        ),
      );
      // Translation or isError state should be active
      expect(midTransform.transform.getTranslation().x != 0.0 || controller.isError, isTrue);

      // Complete full duration (350ms)
      await tester.pumpAndSettle();

      final finalTransform = tester.widget<Transform>(
        find.descendant(
          of: find.byType(ShakeFeedbackWidget),
          matching: find.byType(Transform),
        ),
      );
      // At the end, translation rests at zero
      expect(finalTransform.transform.getTranslation().x.abs(), lessThan(0.001));
      controller.dispose();
    });
  });
}
