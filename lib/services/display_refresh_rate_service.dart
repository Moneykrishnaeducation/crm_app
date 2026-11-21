import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DisplayModeInfo {
  final int id;
  final int width;
  final int height;
  final double refreshRate;

  const DisplayModeInfo({
    required this.id,
    required this.width,
    required this.height,
    required this.refreshRate,
  });

  factory DisplayModeInfo.fromMap(Map<dynamic, dynamic> map) {
    return DisplayModeInfo(
      id: (map['id'] as num?)?.toInt() ?? 0,
      width: (map['width'] as num?)?.toInt() ?? 0,
      height: (map['height'] as num?)?.toInt() ?? 0,
      refreshRate: (map['refreshRate'] as num?)?.toDouble() ?? 60.0,
    );
  }

  int get refreshRateInt => refreshRate.round();

  @override
  String toString() => '${width}x$height @ ${refreshRateInt}Hz';
}

class DisplayRefreshRateService {
  static const MethodChannel _channel = MethodChannel('com.example.crm_app/display_mode');

  @visibleForTesting
  static MethodChannel get channel => _channel;

  @visibleForTesting
  static bool? isAndroidOverride;

  static bool get _isAndroid =>
      isAndroidOverride ?? (!kIsWeb && (Platform.isAndroid || defaultTargetPlatform == TargetPlatform.android));

  /// Automatically adapts the screen to the highest refresh rate mode
  /// supported by current device settings (e.g., 90Hz, 120Hz, 144Hz).
  static Future<bool> adaptToHighestRefreshRate() async {
    if (kIsWeb) return false;
    // On non-Android platforms (e.g. iOS), ProMotion 120Hz is driven by Info.plist CADisableMinimumFrameDurationOnPhone
    if (!_isAndroid) return true;

    try {
      final success = await _channel.invokeMethod<bool>('setHighRefreshRate');
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('DisplayRefreshRateService error: $e');
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Returns the active display mode info.
  static Future<DisplayModeInfo?> getActiveMode() async {
    if (!_isAndroid) return null;

    try {
      final result = await _channel.invokeMapMethod<dynamic, dynamic>('getActiveMode');
      if (result != null) {
        return DisplayModeInfo.fromMap(result);
      }
    } catch (_) {}
    return null;
  }

  /// Returns all display modes supported by the screen hardware.
  static Future<List<DisplayModeInfo>> getAvailableModes() async {
    if (!_isAndroid) return const [];

    try {
      final list = await _channel.invokeListMethod<dynamic>('getAvailableModes');
      if (list != null) {
        return list
            .whereType<Map<dynamic, dynamic>>()
            .map((m) => DisplayModeInfo.fromMap(m))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  /// Sets a specific display mode by its id.
  static Future<bool> setPreferredMode(int modeId) async {
    if (!_isAndroid) return false;

    try {
      final ok = await _channel.invokeMethod<bool>('setPreferredMode', {'modeId': modeId});
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Resets display mode to system default.
  static Future<bool> resetToDefault() async {
    if (!_isAndroid) return false;

    try {
      final ok = await _channel.invokeMethod<bool>('setDeviceDefault');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}
