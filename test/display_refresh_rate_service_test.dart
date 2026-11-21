import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app/main.dart';
import 'package:crm_app/services/display_refresh_rate_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> methodCalls = [];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    methodCalls.clear();
    DisplayRefreshRateService.isAndroidOverride = true;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      DisplayRefreshRateService.channel,
      (MethodCall call) async {
        methodCalls.add(call);
        switch (call.method) {
          case 'setHighRefreshRate':
            return true;
          case 'getActiveMode':
            return {
              'id': 2,
              'width': 1080,
              'height': 2400,
              'refreshRate': 120.0,
            };
          case 'getAvailableModes':
            return [
              {
                'id': 1,
                'width': 1080,
                'height': 2400,
                'refreshRate': 60.0,
              },
              {
                'id': 2,
                'width': 1080,
                'height': 2400,
                'refreshRate': 120.0,
              },
            ];
          case 'setPreferredMode':
            return true;
          case 'setDeviceDefault':
            return true;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    DisplayRefreshRateService.isAndroidOverride = null;
  });

  group('DisplayRefreshRateService tests', () {
    test('adaptToHighestRefreshRate invokes native setHighRefreshRate', () async {
      final result = await DisplayRefreshRateService.adaptToHighestRefreshRate();
      expect(result, isTrue);
      expect(methodCalls.map((c) => c.method), contains('setHighRefreshRate'));
    });

    test('getActiveMode parses current display mode info accurately', () async {
      final mode = await DisplayRefreshRateService.getActiveMode();
      expect(mode, isNotNull);
      expect(mode!.id, 2);
      expect(mode.width, 1080);
      expect(mode.height, 2400);
      expect(mode.refreshRate, 120.0);
      expect(mode.refreshRateInt, 120);
      expect(mode.toString(), '1080x2400 @ 120Hz');
    });

    test('getAvailableModes returns list of supported modes', () async {
      final modes = await DisplayRefreshRateService.getAvailableModes();
      expect(modes.length, 2);
      expect(modes[0].refreshRateInt, 60);
      expect(modes[1].refreshRateInt, 120);
    });

    test('setPreferredMode calls native method with modeId', () async {
      final ok = await DisplayRefreshRateService.setPreferredMode(2);
      expect(ok, isTrue);
      expect(
        methodCalls.any((c) => c.method == 'setPreferredMode' && c.arguments['modeId'] == 2),
        isTrue,
      );
    });

    test('resetToDefault calls native setDeviceDefault', () async {
      final ok = await DisplayRefreshRateService.resetToDefault();
      expect(ok, isTrue);
      expect(methodCalls.map((c) => c.method), contains('setDeviceDefault'));
    });
  });

  group('Settings Page UI tests', () {
    testWidgets('Settings page does not display refresh rate section in settings', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: BrokerSettingsPage(),
        ),
      ));
      await tester.pumpAndSettle();

      // Verify Smooth Display and refresh rate section are not present
      expect(find.text('Smooth Display'), findsNothing);
      expect(find.text('120 Hz'), findsNothing);
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });
  });
}
