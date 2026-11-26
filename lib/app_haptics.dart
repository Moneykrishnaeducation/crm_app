import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Tactile feedback helper that routes Android haptic triggers through the
/// native Vibrator service (via `VIBRATE` permission) with automatic fallback
/// to Flutter's [HapticFeedback] on iOS and headless test environments.
abstract final class AppHaptics {
  static const MethodChannel _channel = MethodChannel('com.vtindex.crm/haptics');

  static Future<void> selectionClick() => _trigger(
    durationMs: 14,
    amplitude: 90,
    fallback: HapticFeedback.selectionClick,
  );

  static Future<void> lightImpact() => _trigger(
    durationMs: 22,
    amplitude: 140,
    fallback: HapticFeedback.lightImpact,
  );

  static Future<void> mediumImpact() => _trigger(
    durationMs: 36,
    amplitude: 200,
    fallback: HapticFeedback.mediumImpact,
  );

  static Future<void> heavyImpact() => _trigger(
    durationMs: 55,
    amplitude: 255,
    fallback: HapticFeedback.heavyImpact,
  );

  static Future<void> _trigger({
    required int durationMs,
    required int amplitude,
    required Future<void> Function() fallback,
  }) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final vibrated = await _channel.invokeMethod<bool>(
          'vibrate',
          <String, dynamic>{
            'durationMs': durationMs,
            'amplitude': amplitude,
          },
        );
        if (vibrated == true) return;
      } on MissingPluginException {
        // Fall back in widget tests or when the native channel is absent.
      } on PlatformException {
        // Fall back to Flutter's built-in haptic channel.
      } catch (_) {}
    }

    try {
      await fallback();
    } catch (_) {}
  }
}
