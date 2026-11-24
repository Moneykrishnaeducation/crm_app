import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'app_notifications.dart';
import 'services/auth_api.dart';

/// Firebase configuration is supplied locally through google-services.json.
class PushMessagingService {
  PushMessagingService._();
  static final PushMessagingService instance = PushMessagingService._();

  bool _initialized = false;
  final ValueNotifier<String?> pendingActionUrl = ValueNotifier<String?>(null);
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  Future<void> initializeAndRegister() async {
    if (kIsWeb || !AuthApi.instance.hasToken) return;
    try {
      if (Firebase.apps.isEmpty) {
        // Android's google-services.json supplies the native default app.
        await Firebase.initializeApp();
      }
      if (!_initialized) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        _foregroundSubscription = FirebaseMessaging.onMessage.listen(_showForegroundPush);
        _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_handlePushOpen);
        _tokenSubscription = FirebaseMessaging.instance.onTokenRefresh.listen(
          (token) => unawaited(_registerToken(token)),
        );
        _initialized = true;
      }
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) await _registerToken(token);
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) _handlePushOpen(initialMessage);
    } catch (error) {
      debugPrint('PushMessagingService: Firebase is not ready: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    if (!AuthApi.instance.hasToken) return;
    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    try {
      await AuthApi.instance.registerPushDeviceToken(token: token, platform: platform);
    } catch (error) {
      debugPrint('PushMessagingService: token registration failed: $error');
    }
  }

  Future<void> _showForegroundPush(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    if (title == null || title.isEmpty) return;
    await AppNotificationCenter.instance.sendNotification(
      title: title,
      body: body ?? '',
      category: _category(message.data['notification_type']?.toString()),
      sendToMobilePanel: true,
      updateLivePill: false,
    );
    unawaited(AppNotificationCenter.instance.refreshFromBackend());
  }

  void _handlePushOpen(RemoteMessage message) {
    unawaited(AppNotificationCenter.instance.refreshFromBackend());
    final action = message.data['action_url']?.toString();
    if (action != null && action.isNotEmpty) pendingActionUrl.value = action;
  }

  String _category(String? type) {
    switch ((type ?? '').toUpperCase()) {
      case 'BANK':
      case 'CRYPTO':
        return 'Funds';
      case 'ACCOUNT':
        return 'Trading';
      case 'PROFILE':
      case 'DOCUMENT':
      case 'IB':
        return 'Security';
      default:
        return 'General';
    }
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
  }
}
