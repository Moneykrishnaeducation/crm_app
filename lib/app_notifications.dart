import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppMessage(String message) {
  final messenger = appScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
}

class AppNotificationItem {
  AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.icon,
    this.isUnread = true,
    this.isGold = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String body;
  final String timestamp;
  final String category;
  final IconData icon;
  bool isUnread;
  final bool isGold;
  final DateTime createdAt;
}

class AppNotificationCenter {
  AppNotificationCenter._() {
    _seedDefaultNotifications();
  }
  static final AppNotificationCenter instance = AppNotificationCenter._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isPluginInitialized = false;
  int _nextNotificationId = 1000;

  final ValueNotifier<List<AppNotificationItem>> notificationsNotifier =
      ValueNotifier<List<AppNotificationItem>>([]);

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  List<AppNotificationItem> get notifications => notificationsNotifier.value;
  int get unreadCount => unreadCountNotifier.value;

  /// Initialize local notification plugin and default notification state
  Future<void> initialize() async {
    _seedDefaultNotifications();

    if (kIsWeb) return;

    try {
      // In headless test environments, platform interface is uninitialized
      try {
        FlutterLocalNotificationsPlatform.instance;
      } catch (_) {
        return;
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          // Handle notification click if needed
        },
      );

      // Create high-importance Android notification channel
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'vt_index_channel',
            'VT Index Notifications',
            description: 'Trading, funding, and security alerts for VT Index CRM',
            importance: Importance.high,
            enableVibration: true,
          ),
        );
        await androidPlugin.requestNotificationsPermission();
      }

      _isPluginInitialized = true;
    } catch (e) {
      debugPrint('AppNotificationCenter: platform notification init warning: $e');
    }
  }

  void _seedDefaultNotifications() {
    if (notificationsNotifier.value.isNotEmpty) return;
    final defaults = [
      AppNotificationItem(
        id: '1',
        title: 'Deposit of \$2,500.00 Credited',
        body: 'Your USDT deposit has been successfully credited to Standard account #3315.',
        timestamp: '10 mins ago',
        category: 'Funds',
        icon: LucideIcons.wallet,
        isUnread: true,
        isGold: false,
      ),
      AppNotificationItem(
        id: '2',
        title: 'TP Executed: XAUUSD +\$180.50',
        body: 'Take profit executed for 0.10 lots XAUUSD at 2,351.80. Net profit: \$180.50.',
        timestamp: '1 hour ago',
        category: 'Trading',
        icon: LucideIcons.trendingUp,
        isUnread: true,
        isGold: true,
      ),
      AppNotificationItem(
        id: '3',
        title: 'Internal Transfer Completed (\$500.00)',
        body: 'Transferred \$500.00 from Main Trading #3315 to ECN #3311 instantly.',
        timestamp: '4 hours ago',
        category: 'Funds',
        icon: LucideIcons.arrowLeftRight,
        isUnread: true,
        isGold: false,
      ),
      AppNotificationItem(
        id: '4',
        title: 'New Authorized Login Detected',
        body: 'Authorized login from Chrome on Windows. Review Security Center if unrecognized.',
        timestamp: 'Yesterday, 18:24',
        category: 'Security',
        icon: LucideIcons.shieldCheck,
        isUnread: false,
        isGold: true,
      ),
      AppNotificationItem(
        id: '5',
        title: 'US CPI Release Market Alert',
        body: 'High volatility anticipated ahead of the Federal Reserve interest rate statement.',
        timestamp: '2 days ago',
        category: 'Trading',
        icon: LucideIcons.newspaper,
        isUnread: false,
        isGold: false,
      ),
    ];
    notificationsNotifier.value = defaults;
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value =
        notificationsNotifier.value.where((n) => n.isUnread).length;
  }

  /// Sends a new notification to BOTH:
  /// 1. The mobile device system notification panel (drawer/status bar)
  /// 2. The in-app notification selection list / center
  Future<void> sendNotification({
    required String title,
    required String body,
    String category = 'Funds',
    IconData icon = LucideIcons.bell,
    bool isGold = false,
    bool sendToMobilePanel = true,
  }) async {
    // 1. Add to in-app notification selection list (at the top index 0)
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final item = AppNotificationItem(
      id: newId,
      title: title,
      body: body,
      timestamp: 'Just now',
      category: category,
      icon: icon,
      isUnread: true,
      isGold: isGold,
    );

    final current = List<AppNotificationItem>.from(notificationsNotifier.value);
    current.insert(0, item);
    notificationsNotifier.value = current;
    _updateUnreadCount();

    // 2. Dispatch to the native mobile notification panel
    if (sendToMobilePanel) {
      await _dispatchSystemNotification(
        id: _nextNotificationId++,
        title: title,
        body: body,
      );
    }
  }

  Future<void> _dispatchSystemNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    try {
      try {
        FlutterLocalNotificationsPlatform.instance;
      } catch (_) {
        return;
      }

      if (!_isPluginInitialized) {
        await initialize();
      }

      const androidDetails = AndroidNotificationDetails(
        'vt_index_channel',
        'VT Index Notifications',
        channelDescription: 'Trading, funding, and security alerts for VT Index CRM',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF1658C9),
        playSound: true,
        enableVibration: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _localNotifications.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
      );
    } catch (e) {
      debugPrint('AppNotificationCenter: mobile notification panel dispatch warning: $e');
    }
  }

  void markAllAsRead() {
    final updated = notificationsNotifier.value.map((n) {
      n.isUnread = false;
      return n;
    }).toList();
    notificationsNotifier.value = updated;
    _updateUnreadCount();
  }

  void markAsRead(String id) {
    var changed = false;
    final updated = notificationsNotifier.value.map((n) {
      if (n.id == id && n.isUnread) {
        n.isUnread = false;
        changed = true;
      }
      return n;
    }).toList();
    if (changed) {
      notificationsNotifier.value = updated;
      _updateUnreadCount();
    }
  }

  void clearAll() {
    notificationsNotifier.value = [];
    _updateUnreadCount();
  }

  void resetToDefault() {
    notificationsNotifier.value = [];
    _seedDefaultNotifications();
  }
}
