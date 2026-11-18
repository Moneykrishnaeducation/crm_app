import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

enum AppNotificationType {
  info,
  success,
  warning,
  error,
}

class LiveNotificationData {
  LiveNotificationData({
    required this.message,
    this.title,
    this.type = AppNotificationType.info,
    this.icon,
    this.duration = const Duration(milliseconds: 3200),
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? title;
  final AppNotificationType type;
  final IconData? icon;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
}

final ValueNotifier<LiveNotificationData?> liveNotificationNotifier =
    ValueNotifier<LiveNotificationData?>(null);

/// Displays a top-floating, interactive Live Notification (Dynamic Island style)
/// and triggers a floating SnackBar fallback for accessibility & tests.
void showAppMessage(
  String message, {
  AppNotificationType type = AppNotificationType.info,
  String? title,
  IconData? icon,
  Duration duration = const Duration(milliseconds: 3200),
  bool sendToMobilePanel = false,
  String category = 'General',
}) {
  // 1. Trigger the animated top Live Notification overlay
  liveNotificationNotifier.value = LiveNotificationData(
    message: message,
    title: title,
    type: type,
    icon: icon,
    duration: duration,
  );

  // 2. Dispatch to the native mobile notification panel if requested
  if (sendToMobilePanel) {
    AppNotificationCenter.instance.sendNotification(
      title: title ?? 'VT Index Alert',
      body: message,
      category: category,
      icon: icon ?? LucideIcons.bell,
      isGold: type == AppNotificationType.success || type == AppNotificationType.warning,
      sendToMobilePanel: true,
      showLiveOverlay: false, // Already shown above
    );
  }

  // 3. Fallback / mirror in ScaffoldMessenger for accessibility & existing tests
  final messenger = appScaffoldMessengerKey.currentState;
  if (messenger != null) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: duration,
        ),
      );
  }
}

/// Convenience alias to show a Live Notification with explicit title and category
void showLiveNotification({
  required String message,
  String? title,
  AppNotificationType type = AppNotificationType.info,
  IconData? icon,
  Duration duration = const Duration(milliseconds: 3200),
  bool sendToMobilePanel = true,
  String category = 'Funds',
}) {
  showAppMessage(
    message,
    type: type,
    title: title,
    icon: icon,
    duration: duration,
    sendToMobilePanel: sendToMobilePanel,
    category: category,
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

  /// Sends a new notification to:
  /// 1. The in-app notification selection list / center
  /// 2. The mobile device system notification panel (drawer/status bar)
  /// 3. The animated on-screen Live Notification Dynamic Island overlay
  Future<void> sendNotification({
    required String title,
    required String body,
    String category = 'Funds',
    IconData icon = LucideIcons.bell,
    bool isGold = false,
    bool sendToMobilePanel = true,
    bool showLiveOverlay = true,
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
      await _dispatchSystemNotification(
        id: _nextNotificationId++,
        title: title,
        body: body,
      );
    }

    // 3. Show live floating notification pill if requested
    if (showLiveOverlay) {
      liveNotificationNotifier.value = LiveNotificationData(
        title: title,
        message: body,
        type: isGold ? AppNotificationType.warning : AppNotificationType.info,
        icon: icon,
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
    liveNotificationNotifier.value = null;
    notificationsNotifier.value = [];
    _seedDefaultNotifications();
  }
}

/// Host widget that renders the animated top-floating Live Notification pill (Dynamic Island style)
class LiveNotificationHost extends StatefulWidget {
  const LiveNotificationHost({super.key, required this.child});
  final Widget child;

  @override
  State<LiveNotificationHost> createState() => _LiveNotificationHostState();
}

class _LiveNotificationHostState extends State<LiveNotificationHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  LiveNotificationData? _currentData;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 260),
    );

    _slideAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.easeInCubic,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _scaleAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    liveNotificationNotifier.addListener(_onNotificationTriggered);
    // If a notification was already set before this widget mounted:
    if (liveNotificationNotifier.value != null) {
      _onNotificationTriggered();
    }
  }

  void _onNotificationTriggered() {
    final data = liveNotificationNotifier.value;
    if (data == null) {
      _hide();
      return;
    }

    _dismissTimer?.cancel();
    setState(() {
      _currentData = data;
    });

    _animCtrl.forward(from: 0.0);
    _dismissTimer = Timer(data.duration, () {
      _hide();
    });
  }

  void _hide() {
    _dismissTimer?.cancel();
    _animCtrl.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentData = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    liveNotificationNotifier.removeListener(_onNotificationTriggered);
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        if (_currentData != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.6),
                          end: Offset.zero,
                        ).animate(_slideAnim),
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: _buildLivePill(_currentData!),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLivePill(LiveNotificationData data) {
    final typeConfig = _getTypeConfig(data.type, data.icon);

    return Dismissible(
      key: ValueKey(data.message.hashCode ^ DateTime.now().millisecondsSinceEpoch),
      direction: DismissDirection.up,
      onDismissed: (_) => _hide(),
      child: Material(
        key: const Key('live_notification_pill'),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0C192E), // VT Index dark navy Dynamic Island
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: typeConfig.color.withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: typeConfig.color.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: typeConfig.color.withValues(alpha: 0.16),
                  border: Border.all(
                    color: typeConfig.color.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  typeConfig.icon,
                  color: typeConfig.color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.title != null && data.title!.isNotEmpty) ...[
                      Text(
                        data.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 1),
                    ],
                    Text(
                      data.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: typeConfig.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: typeConfig.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: typeConfig.color,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _hide,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    LucideIcons.x,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({Color color, IconData icon}) _getTypeConfig(
      AppNotificationType type, IconData? customIcon) {
    return switch (type) {
      AppNotificationType.success => (
          color: const Color(0xFF10B981),
          icon: customIcon ?? LucideIcons.checkCircle2,
        ),
      AppNotificationType.warning => (
          color: const Color(0xFFF59E0B),
          icon: customIcon ?? LucideIcons.alertTriangle,
        ),
      AppNotificationType.error => (
          color: const Color(0xFFEF4444),
          icon: customIcon ?? LucideIcons.alertCircle,
        ),
      AppNotificationType.info => (
          color: const Color(0xFF3B82F6),
          icon: customIcon ?? LucideIcons.bellRing,
        ),
    };
  }
}
