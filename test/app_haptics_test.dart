import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_app/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.vtindex.crm/haptics');

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('AppHaptics invokes native Android Vibrator channel with tuned pulses', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });

    await AppHaptics.selectionClick();
    await AppHaptics.lightImpact();
    await AppHaptics.mediumImpact();
    await AppHaptics.heavyImpact();

    expect(calls.length, 4);
    expect(calls[0].method, 'vibrate');
    expect(calls[0].arguments, {'durationMs': 14, 'amplitude': 90});
    expect(calls[1].arguments, {'durationMs': 22, 'amplitude': 140});
    expect(calls[2].arguments, {'durationMs': 36, 'amplitude': 200});
    expect(calls[3].arguments, {'durationMs': 55, 'amplitude': 255});
  });

  test('AppHaptics falls back cleanly when native channel is unavailable', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => false);

    await expectLater(AppHaptics.selectionClick(), completes);
    await expectLater(AppHaptics.mediumImpact(), completes);
  });
}
