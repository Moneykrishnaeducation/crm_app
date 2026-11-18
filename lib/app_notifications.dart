import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Displays standard in-app feedback message via SnackBar
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

  /// Initialize local notification plugin and register Android notification channels
  Future<void> initialize() async {
    _seedDefaultNotifications();

    if (kIsWeb) return;

    try {
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

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // 1. Standard notifications channel (deposits, executions, security alerts)
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'vt_index_channel',
            'VT Index Notifications',
            description: 'Trading, funding, and security alerts for VT Index CRM',
            importance: Importance.high,
            enableVibration: true,
          ),
        );

        // 2. Native OS Live Updates channel (promoted to status bar pill / Moto Live Updates / lockscreen)
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'vt_live_updates_channel',
            'VT Index Live Updates',
            description: 'Real-time ongoing live status updates for open trades and orders',
            importance: Importance.max,
            enableVibration: false,
            enableLights: true,
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

  static const MethodChannel _nativeChannel =
      MethodChannel('com.example.crm_app/live_updates');

  /// Starts a Native OS Live Update notification.
  /// On modern Android (Android 14/15/16/17, Motorola Moto Live Updates, Samsung Now Bar),
  /// ongoing status notifications with chronometer/subText and promoted status
  /// are pinned directly to the status bar pill, lock screen, and notification drawer.
  Future<void> startLiveUpdate({
    required int id,
    required String title,
    required String body,
    String subText = 'LIVE',
    String shortText = 'LIVE',
    String colorHex = '#10B981',
    String iconType = 'trade',
    bool usesChronometer = true,
  }) async {
    if (kIsWeb) return;

    // 1. Try native platform promoted live update channel first (triggers Android 16/17 & Moto Live Updates pill)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _nativeChannel.invokeMethod('startLiveUpdate', {
          'id': id,
          'title': title,
          'body': body,
          'subText': subText,
          'shortText': shortText,
          'colorHex': colorHex,
          'iconType': iconType,
        });
        return;
      } catch (e) {
        debugPrint('AppNotificationCenter: native startLiveUpdate channel failed, falling back to local notifications: $e');
      }
    }

    // 2. Fallback to FlutterLocalNotifications
    try {
      try {
        FlutterLocalNotificationsPlatform.instance;
      } catch (_) {
        return;
      }

      if (!_isPluginInitialized) {
        await initialize();
      }

      final androidDetails = AndroidNotificationDetails(
        'vt_live_updates_channel',
        'VT Index Live Updates',
        channelDescription: 'Real-time ongoing live status updates for open trades and orders',
        importance: Importance.max,
        priority: Priority.max,
        ongoing: true,
        autoCancel: false,
        category: AndroidNotificationCategory.status,
        subText: subText,
        showWhen: true,
        usesChronometer: usesChronometer,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF1658C9),
        playSound: false,
        enableVibration: false,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      final notificationDetails = NotificationDetails(
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
      debugPrint('AppNotificationCenter: startLiveUpdate error: $e');
    }
  }

  /// Dynamically updates an active Native OS Live Update notification (e.g. changing live P&L or status)
  Future<void> updateLiveUpdate({
    required int id,
    required String title,
    required String body,
    String subText = 'LIVE',
    String shortText = 'LIVE',
    String colorHex = '#10B981',
    String iconType = 'trade',
  }) async {
    await startLiveUpdate(
      id: id,
      title: title,
      body: body,
      subText: subText,
      shortText: shortText,
      colorHex: colorHex,
      iconType: iconType,
    );
  }

  /// Cancels / dismisses the Native OS Live Update from the status bar pill and notification tray
  Future<void> stopLiveUpdate(int id) async {
    if (kIsWeb) return;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _nativeChannel.invokeMethod('stopLiveUpdate', {'id': id});
      } catch (_) {}
    }

    try {
      try {
        FlutterLocalNotificationsPlatform.instance;
      } catch (_) {
        return;
      }

      await _localNotifications.cancel(id: id);
    } catch (e) {
      debugPrint('AppNotificationCenter: stopLiveUpdate error: $e');
    }
  }

  String generatePillShortText(String title, String body, String category) {
    final lower = '$title $body'.toLowerCase();
    if (lower.contains('deposit')) {
      final match = RegExp(r'\$([0-9,]+)').firstMatch('$title $body');
      if (match != null) {
        final raw = match.group(1)!.replaceAll(',', '');
        final val = double.tryParse(raw);
        if (val != null && val >= 1000) {
          return 'DEP +${(val / 1000).toStringAsFixed(1)}k';
        }
        return 'DEP +$raw';
      }
      return 'DEP READY';
    }
    if (lower.contains('xau') || lower.contains('gold')) {
      final pnlMatch = RegExp(r'\+?\$?([0-9.]+)').firstMatch(body);
      final pnl = pnlMatch != null ? pnlMatch.group(1) : '58.80';
      return 'XAU ▲ +\$$pnl';
    }
    if (lower.contains('eur')) {
      return 'EUR BUY 0.2';
    }
    if (lower.contains('transfer')) {
      return 'XFER READY';
    }
    if (category == 'Security') {
      return 'SEC ALERT';
    }
    if (title.length <= 12) return title;
    return title.substring(0, 12);
  }

  String generatePillColorHex(String title, String body, bool isGold, String category) {
    final lower = '$title $body'.toLowerCase();
    if (lower.contains('deposit') || lower.contains('profit') || lower.contains('credited') || lower.contains('bought')) {
      return '#10B981'; // Emerald Green
    }
    if (lower.contains('margin') || lower.contains('warning') || lower.contains('loss') || lower.contains('failed')) {
      return '#EF4444'; // Crimson Red
    }
    if (isGold || category == 'Trading') {
      return '#D8A82E'; // Gold
    }
    return '#1658C9'; // VT Blue
  }

  /// Sends a new notification to:
  /// 1. The in-app notification selection list / center
  /// 2. The mobile device system notification panel (drawer/status bar)
  /// 3. Promotes to the Native OS Live Update status bar pill
  Future<void> sendNotification({
    required String title,
    required String body,
    String category = 'Funds',
    IconData icon = LucideIcons.bell,
    bool isGold = false,
    bool sendToMobilePanel = true,
    bool updateLivePill = true,
    String? pillShortText,
    String? colorHex,
  }) async {
    // 1. Add to in-app notification selection list (at index 0)
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
      final color = colorHex ?? generatePillColorHex(title, body, isGold, category);
      await _dispatchSystemNotification(
        id: _nextNotificationId++,
        title: title,
        body: body,
        category: category,
        colorHex: color,
        isGold: isGold,
      );
    }

    // 3. Automatically promote to Native OS Live Update pill
    if (updateLivePill) {
      final short = pillShortText ?? generatePillShortText(title, body, category);
      final color = colorHex ?? generatePillColorHex(title, body, isGold, category);
      await startLiveUpdate(
        id: 7777,
        title: title,
        body: body,
        subText: category.toUpperCase(),
        shortText: short,
        colorHex: color,
        iconType: category == 'Trading' ? 'trade' : 'vt',
      );
    }
  }

  Future<void> _dispatchSystemNotification({
    required int id,
    required String title,
    required String body,
    String category = 'Trading',
    String colorHex = '#1658C9',
    bool isGold = false,
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

      Color parsedColor;
      try {
        final hex = colorHex.replaceAll('#', '');
        parsedColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        parsedColor = const Color(0xFF1658C9);
      }

      final isTrade = category.toLowerCase() == 'trading';
      final smallIcon = isTrade ? 'ic_stat_live' : 'ic_stat_vt';

      // Rich actionable notification buttons by category
      List<AndroidNotificationAction>? actions;
      if (isTrade) {
        actions = const [
          AndroidNotificationAction('view_trade', 'View Trade', showsUserInterface: true),
          AndroidNotificationAction('dismiss', 'Dismiss', cancelNotification: true),
        ];
      } else if (category.toLowerCase() == 'funds') {
        actions = const [
          AndroidNotificationAction('view_wallet', 'View Wallet', showsUserInterface: true),
          AndroidNotificationAction('deposit', 'Deposit', showsUserInterface: true),
        ];
      } else if (category.toLowerCase() == 'security') {
        actions = const [
          AndroidNotificationAction('review_security', 'Review', showsUserInterface: true),
        ];
      } else {
        actions = const [
          AndroidNotificationAction('open_app', 'Open App', showsUserInterface: true),
        ];
      }

      final androidDetails = AndroidNotificationDetails(
        'vt_index_channel',
        'VT Index Notifications',
        channelDescription: 'Trading, funding, and security alerts for VT Index CRM',
        importance: Importance.high,
        priority: Priority.high,
        icon: smallIcon,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: parsedColor,
        subText: category.toUpperCase(),
        groupKey: 'com.example.crm_app.NOTIFICATIONS',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: category.toUpperCase(),
          htmlFormatBigText: true,
          htmlFormatContentTitle: true,
          htmlFormatSummaryText: true,
        ),
        actions: actions,
        playSound: true,
        enableVibration: true,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
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
