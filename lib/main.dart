import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_notifications.dart';
import 'push_messaging.dart';
export 'app_haptics.dart';
export 'app_notifications.dart';
import 'biometric_sign_in.dart';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'pages/funds_action_dialog.dart';
export 'pages/funds_action_dialog.dart';
import 'pages/mam_page.dart';
import 'pages/pamm_page.dart';
import 'pages/partnership_page.dart';
import 'pages/privacy_policy_page.dart';
import 'pages/profile_page.dart';
import 'pages/security_center_page.dart';
import 'pages/trade_pattern_analysis_page.dart';
import 'services/display_refresh_rate_service.dart';
import 'services/auth_api.dart';

part 'widgets/app_header.dart';
part 'pages/dashboard_page.dart';
part 'pages/broker_screens.dart';
part 'pages/trade_report_page.dart';
part 'pages/accounts_page.dart';
part 'pages/internal_transfer_page.dart';
part 'pages/demo_accounts_page.dart';
part 'pages/more_page.dart';
part 'pages/download_center_page.dart';
part 'pages/settings_page.dart';
part 'pages/support_legal_pages.dart';
part 'pages/login_page.dart';

const _background = Color(0xFFF5F7FB);
const _sidebar = Color(0xFF10264B);
const _panel = Colors.white;
const _panelLight = Color(0xFFF3F6FB);
const _border = Color(0xFFE2E8F1);
const _muted = Color(0xFF71809A);
const _blue = Color(0xFF174A8B);
const _gold = Color(0xFFD8A82E);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(DisplayRefreshRateService.adaptToHighestRefreshRate());
  await AppNotificationCenter.instance.initialize();
  final preferences = await SharedPreferences.getInstance();
  final stored = preferences.getString('vtindex_theme_mode');
  final initialThemeMode = switch (stored) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  runApp(MyApp(initialThemeMode: initialThemeMode));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialThemeMode});

  final ThemeMode? initialThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  late final ThemeData _lightTheme;
  late final ThemeData _darkTheme;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode ?? ThemeMode.system;
    _lightTheme = _buildTheme(Brightness.light);
    _darkTheme = _buildTheme(Brightness.dark);
    if (widget.initialThemeMode == null) {
      _loadThemeMode();
    }
  }

  Future<void> _loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString('vtindex_theme_mode');
    final mode = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    if (mounted && _themeMode != mode) {
      setState(() => _themeMode = mode);
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    setState(() => _themeMode = mode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('vtindex_theme_mode', switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _blue,
      brightness: brightness,
      primary: _blue,
      secondary: _gold,
      surface: dark ? const Color(0xFF17243A) : Colors.white,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0B1424) : _background,
      cardColor: dark ? const Color(0xFF17243A) : Colors.white,
      dividerColor: dark ? const Color(0xFF2A3A53) : _border,
      fontFamily: GoogleFonts.poppins().fontFamily,
      fontFamilyFallback: const ['sans-serif', 'Roboto'],
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF101D31) : Colors.white,
        foregroundColor: dark ? const Color(0xFFF2F5FA) : _sidebar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFF263750) : _sidebar,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      useMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTIndex',
      scaffoldMessengerKey: appScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _themeMode,
      home: _AppEntry(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppEntry extends StatefulWidget {
  const _AppEntry({this.themeMode = ThemeMode.system, this.onThemeModeChanged});
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _splashFinished = false;
  bool _sessionCheckComplete = false;
  bool _hasRestoredSession = false;
  bool _openingDashboard = false;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreExistingSession());
  }

  Future<void> _restoreExistingSession() async {
    try {
      await AuthApi.instance.restoreSession();
      if (AuthApi.instance.hasToken &&
          await AuthApi.instance.isAuthenticated()) {
        _hasRestoredSession = true;
      }
    } catch (_) {
      // A failed session check falls back to the login screen.
    }
    if (!mounted) return;
    setState(() => _sessionCheckComplete = true);
    if (_splashFinished && _hasRestoredSession) _openDashboard();
  }

  void _openDashboard() {
    if (!mounted || _openingDashboard) return;
    _openingDashboard = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AppShell(
          themeMode: widget.themeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashFinished) {
      return _LogoAnimationSplash(
        onFinished: () {
          if (!mounted) return;
          setState(() => _splashFinished = true);
          if (_sessionCheckComplete && _hasRestoredSession) {
            _openDashboard();
          }
        },
      );
    }
    if (!_sessionCheckComplete || _hasRestoredSession || _openingDashboard) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B1424),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC533)),
        ),
      );
    }
    return LoginPage(onLogin: _openDashboard);
  }
}

class _LogoAnimationSplash extends StatefulWidget {
  const _LogoAnimationSplash({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_LogoAnimationSplash> createState() => _LogoAnimationSplashState();
}

class _LogoAnimationSplashState extends State<_LogoAnimationSplash> {
  late final VideoPlayerController _controller;
  Timer? _fallbackTimer;
  bool _ready = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = VideoPlayerController.asset(
      'assets/splash/Logo_animation.mp4',
    );
    _controller.addListener(_handlePlayback);
    _fallbackTimer = Timer(const Duration(seconds: 7), _finish);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      if (!mounted || _finished) return;
      await _controller.setVolume(0);
      if (!mounted || _finished) return;
      await _controller.play();
      if (mounted && !_finished) setState(() => _ready = true);
    } catch (_) {
      _finish();
    }
  }

  void _handlePlayback() {
    final value = _controller.value;
    if (value.hasError) {
      _finish();
    } else if (value.isInitialized &&
        value.duration > Duration.zero &&
        value.position >= value.duration &&
        !value.isPlaying) {
      _finish();
    }
  }

  void _finish() {
    if (!mounted || _finished) return;
    _finished = true;
    _fallbackTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    widget.onFinished();
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.removeListener(_handlePlayback);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SizedBox.expand(
      child: _ready
          ? FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          : const SizedBox.expand(),
    ),
  );
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  ThemeMode? _currentThemeMode;
  ThemeMode get _effectiveThemeMode => _currentThemeMode ?? widget.themeMode;
  String _selectedPage = 'Dashboard';
  int _activityRefreshToken = 0;
  Timer? _notificationRefreshTimer;
  StreamSubscription<int>? _unauthorizedSubscription;
  bool _isLoggingOut = false;
  final List<String> _navigationHistory = <String>[];
  final GlobalKey<MamPageState> _mamKey = GlobalKey<MamPageState>();
  BrokerAccount? _selectedAccount;
  String _accountDetailsReturnPage = 'Trading Accounts';
  bool _balanceVisible = true;
  final Set<String> _favoriteAccountLogins = <String>{};
  final Map<String, List<ActivityFundTransaction>> _appFundTransactions = {};
  final ScrollController _dashboardScrollController = ScrollController(
    keepScrollOffset: false,
  );
  final ScrollController _transactionsScrollController = ScrollController(
    keepScrollOffset: false,
  );
  final ScrollController _accountsScrollController = ScrollController(
    keepScrollOffset: false,
  );
  final ScrollController _moreScrollController = ScrollController(
    keepScrollOffset: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_handleFocusChange);
    PushMessagingService.instance.pendingActionUrl.addListener(_handlePushAction);
    _unauthorizedSubscription = AuthApi.instance.onUnauthorizedSession.listen(
      _handleUnauthorizedSession,
    );
    _currentThemeMode = widget.themeMode;
    unawaited(PushMessagingService.instance.initializeAndRegister());
    _loadFavoriteAccounts();
    unawaited(_loadTradingAccounts());
    unawaited(AppNotificationCenter.instance.refreshFromBackend());
    unawaited(AppNotificationCenter.instance.resumePositionMonitoring());
    _notificationRefreshTimer = Timer.periodic(
      const Duration(seconds: 90),
      (_) => unawaited(AppNotificationCenter.instance.refreshFromBackend()),
    );
  }

  void _handlePushAction() {
    final action = PushMessagingService.instance.pendingActionUrl.value;
    if (action == null || action.isEmpty || !mounted) return;
    PushMessagingService.instance.pendingActionUrl.value = null;
    final value = action.toLowerCase();
    if (value.contains('security')) {
      _selectPage('Security Center');
    } else if (value.contains('withdraw')) {
      _selectPage('Withdraw');
    } else if (value.contains('deposit')) {
      _selectPage('Deposit');
    } else if (value.contains('transfer')) {
      _selectPage('Internal Transfer');
    } else if (value.contains('transaction') || value.contains('history')) {
      _selectPage('Transactions');
    } else if (value.contains('account') || value.contains('trade') || value.contains('position')) {
      _selectPage('Trading Accounts');
    } else {
      _selectPage('Dashboard');
    }
  }

  Future<void> _loadFavoriteAccounts() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final stored =
          preferences.getStringList('vtindex_favorite_account_logins') ??
          const <String>[];
      if (!mounted) return;
      setState(() {
        _favoriteAccountLogins
          ..clear()
          ..addAll(stored);
      });
    } catch (_) {
      // Favorites are optional; the accounts page remains usable.
    }
  }

  Future<void> _toggleFavoriteAccount(String login) async {
    setState(() {
      if (!_favoriteAccountLogins.add(login)) {
        _favoriteAccountLogins.remove(login);
      }
    });
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        'vtindex_favorite_account_logins',
        _favoriteAccountLogins.toList(),
      );
    } catch (_) {
      if (mounted) showAppMessage('Could not save account favorites on this device.');
    }
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeMode != widget.themeMode) {
      _currentThemeMode = widget.themeMode;
    }
  }

  void _changeThemeMode(ThemeMode mode) {
    if (_effectiveThemeMode != mode) {
      setState(() => _currentThemeMode = mode);
    }
    widget.onThemeModeChanged?.call(mode);
  }

  void _addAccount(BrokerAccount account) {
    if (!mounted) return;
    setState(() => _accounts.insert(0, account));
  }

  int _secondaryPageNavId = 0;
  double _lastScreenWidth = 0;
  double _maxWindowHeight = 0;

  @override
  void dispose() {
    _unauthorizedSubscription?.cancel();
    _notificationRefreshTimer?.cancel();
    unawaited(AppNotificationCenter.instance.stopPositionMonitoring());
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_handleFocusChange);
    PushMessagingService.instance.pendingActionUrl.removeListener(_handlePushAction);
    _dashboardScrollController.dispose();
    _transactionsScrollController.dispose();
    _accountsScrollController.dispose();
    _moreScrollController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _notificationRefreshTimer?.cancel();
      _notificationRefreshTimer = Timer.periodic(
        const Duration(seconds: 90),
        (_) => unawaited(AppNotificationCenter.instance.refreshFromBackend()),
      );
      unawaited(AppNotificationCenter.instance.refreshFromBackend());
      unawaited(AppNotificationCenter.instance.resumePositionMonitoring());
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _notificationRefreshTimer?.cancel();
      _notificationRefreshTimer = null;
      unawaited(AppNotificationCenter.instance.pausePositionMonitoring());
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) {
      setState(() {});
    }
  }

  bool _isWindowShrunkForKeyboard(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (_lastScreenWidth != size.width) {
      _lastScreenWidth = size.width;
      _maxWindowHeight = size.height;
      return false;
    }
    if (size.height > _maxWindowHeight) {
      _maxWindowHeight = size.height;
    }
    return _maxWindowHeight > 0 && (_maxWindowHeight - size.height) > 120;
  }

  bool _isKeyboardOpen(BuildContext context) {
    if (BrokerBottomNavigation.isKeyboardOrInputActive(context)) {
      return true;
    }
    if (_isWindowShrunkForKeyboard(context)) {
      return true;
    }
    return false;
  }

  void _resetScrollFor(String page) {
    void performJump() {
      switch (page) {
        case 'Dashboard':
          if (_dashboardScrollController.hasClients) {
            _dashboardScrollController.jumpTo(0.0);
          }
        case 'Transactions':
          if (_transactionsScrollController.hasClients) {
            _transactionsScrollController.jumpTo(0.0);
          }
        case 'Trading Accounts':
          if (_accountsScrollController.hasClients) {
            _accountsScrollController.jumpTo(0.0);
          }
        case 'More':
          if (_moreScrollController.hasClients) {
            _moreScrollController.jumpTo(0.0);
          }
      }
    }

    performJump();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) performJump();
    });
  }

  final List<BrokerAccount> _accounts = <BrokerAccount>[];
  Future<void>? _accountsLoadFuture;
  bool _accountsLoading = false;
  String? _accountsError;

  double _accountNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
    return 0;
  }

  String _accountMoney(dynamic value, String currency) {
    final prefix = currency.toUpperCase() == 'USD' ? r'$' : '';
    return '$prefix${_accountNumber(value).toStringAsFixed(2)}';
  }

  BrokerAccount _mapApiAccount(Map<String, dynamic> item) {
    final login = (item['account_id'] ?? item['login'] ?? item['account'] ?? '').toString();
    final rawAccountType = (item['account_type'] ?? item['accountType'] ?? item['type'] ?? '').toString().trim();
    final accountType = rawAccountType.isNotEmpty ? rawAccountType : 'Standard';
    final group = (item['group_name'] ?? item['group_alias'] ?? '').toString();
    final isDemo = item['is_demo'] == true ||
        rawAccountType.toLowerCase() == 'demo' ||
        group.toLowerCase().contains('demo');
    final currency = (item['currency'] ?? 'USD').toString();
    final balance = _accountNumber(item['balance']);
    final equity = _accountNumber(item['equity'] ?? item['balance']);
    final profit = item['profit'] ?? item['floating_pnl'] ?? item['floatingPnl'];
    final server = item['server'] ?? item['server_name'] ?? item['serverName'];
    final leverage = (item['leverage'] ?? 100).toString();
    return BrokerAccount(
      (item['account_name'] ?? item['name'] ?? (isDemo ? 'Demo Account' : 'Trading Account')).toString(),
      login,
      leverage.startsWith('1:') ? leverage : '1:$leverage',
      _accountMoney(balance, currency),
      _accountMoney(equity, currency),
      isDemo ? 'Demo MT5' : 'Live MT5',
      server: server?.toString().isNotEmpty == true ? server.toString() : null,
      currency: currency,
      floatingPnl: item['is_active'] == false || item['is_enabled'] == false
          ? null
          : profit == null ? equity - balance : _accountNumber(profit),
      margin: _accountNumber(item['margin'] ?? item['used_margin'] ?? item['usedMargin']),
      freeMargin: _accountNumber(item['free_margin'] ?? item['freeMargin']),
      marginLevel: _accountNumber(item['margin_level'] ?? item['marginLevel']),
      credit: _accountNumber(item['credit']),
      groupName: group,
      accountType: accountType,
      isMt5Connected: item['is_mt5_connected'] == true || item['mt5_connected'] == true,
    );
  }

  Future<void> _loadTradingAccounts({bool refresh = false}) {
    final ongoing = _accountsLoadFuture;
    if (ongoing != null) return ongoing;
    final request = _performLoadTradingAccounts(refresh: refresh);
    _accountsLoadFuture = request;
    return request.whenComplete(() {
      if (identical(_accountsLoadFuture, request)) {
        _accountsLoadFuture = null;
      }
    });
  }

  Future<void> _performLoadTradingAccounts({bool refresh = false}) async {
    setState(() {
      _accountsLoading = true;
      _accountsError = null;
    });
    try {
      await AuthApi.instance.restoreSession();
      if (!AuthApi.instance.hasToken) {
        throw const AuthApiException(
          'Your session has expired. Sign in again to load trading accounts.',
          statusCode: 401,
        );
      }
      final records = await AuthApi.instance.getMobileAccounts(refresh: refresh);
      final mapped = records.map(_mapApiAccount)
          .where((account) => account.login.isNotEmpty)
          .toList(growable: false);
      final liveAccounts = mapped
          .where((account) => account.type == 'Live MT5')
          .toList(growable: false);
      final demoAccounts = mapped
          .where((account) => account.type.startsWith('Demo MT5'))
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _accounts
          ..clear()
          ..addAll(liveAccounts);
        _demoAccounts
          ..clear()
          ..addAll(demoAccounts);
        _accountsLoading = false;
      });
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _accountsLoading = false;
        _accountsError = error.statusCode == 401 || error.statusCode == 403
            ? 'Your session is no longer valid. Please sign in again.'
            : error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _accountsLoading = false;
        _accountsError = 'Unable to load trading accounts. Check your connection and try again.';
      });
    }
  }

  final List<BrokerAccount> _demoAccounts = <BrokerAccount>[];

  void _addDemoAccount(BrokerAccount account) {
    if (!mounted) return;
    setState(() => _demoAccounts.insert(0, account));
    showAppMessage('Demo account ${account.login} created successfully.');
  }

  String _getDefaultParentPage(String page) {
    return switch (page) {
      'Profile' ||
      'Security Center' ||
      'Settings' ||
      'MAM' ||
      'MAM Account' ||
      'MAM Manager' ||
      'MAM Investor' ||
      'Available MAM' ||
      'MAM Available' ||
      'Social Trading' ||
      'PAMM Account' ||
      'Platform' ||
      'Tickets' ||
      'Partnership' ||
      'Internal Transfer' => 'More',
      'Theme Mode' || 'Privacy Policy' => 'Settings',
      'Account Details' => _accountDetailsReturnPage,
      'Demo Accounts' => 'Trading Accounts',
      'Deposit' || 'Withdraw' => 'Dashboard',
      'Trade Report' => 'Transactions',
      _ => 'Dashboard',
    };
  }

  void _handleBack() {
    if (_mamKey.currentState?.popSubView() == true) {
      return;
    }

    if (_navigationHistory.isNotEmpty) {
      final prev = _navigationHistory.removeLast();
      _secondaryPageNavId++;
      _resetScrollFor(prev);
      setState(() {
        _selectedPage = prev;
      });
      return;
    }
    final fallback = _getDefaultParentPage(_selectedPage);
    if (fallback != _selectedPage) {
      _secondaryPageNavId++;
      _resetScrollFor(fallback);
      setState(() {
        _selectedPage = fallback;
      });
      return;
    }
    if (_selectedPage != 'Dashboard') {
      _secondaryPageNavId++;
      _resetScrollFor('Dashboard');
      setState(() {
        _selectedPage = 'Dashboard';
      });
    }
  }

  Future<void> _openDashboardTradeReport() async {
    if (_accounts.isEmpty) {
      await _loadTradingAccounts(refresh: true);
    }
    if (!mounted) return;

    final accounts = List<BrokerAccount>.unmodifiable(_accounts);
    final selectedLogin = accounts.any(
      (account) => account.login == _selectedAccount?.login,
    )
        ? _selectedAccount!.login
        : (accounts.isNotEmpty ? accounts.first.login : null);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TradeReportPage(
          accounts: accounts,
          selectedAccountLogin: selectedLogin,
          onAccountChanged: (login) {
            final index = _accounts.indexWhere(
              (account) => account.login == login,
            );
            if (index < 0 || !mounted) return;
            setState(() {
              _selectedAccount = _accounts[index];
            });
          },
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  void _openAccount(BrokerAccount account) {
    _navigationHistory.add(_selectedPage);
    _secondaryPageNavId++;
    setState(() {
      _selectedAccount = account;
      _accountDetailsReturnPage = 'Trading Accounts';
      _selectedPage = 'Account Details';
    });
  }

  void _openDemoAccount(BrokerAccount account) {
    _navigationHistory.add(_selectedPage);
    _secondaryPageNavId++;
    setState(() {
      _selectedAccount = account;
      _accountDetailsReturnPage = 'Demo Accounts';
      _selectedPage = 'Account Details';
    });
  }

  void _selectPage(String rawPage) {
    final page = rawPage == 'activity' ? 'Transactions' : rawPage;
    if (page == _selectedPage) {
      _resetScrollFor(page);
      if (page == 'Transactions') {
        setState(() => _activityRefreshToken++);
      } else if (page == 'Trading Accounts' || page == 'Demo Accounts') {
        unawaited(_loadTradingAccounts(refresh: true));
      }
      return;
    }

    if (page == 'Open Account') {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        builder: (_) => _OpenLiveAccountSheet(onCreated: _addAccount),
      );
      return;
    }
    if (page == 'Create Demo Account' || page == 'Open Demo Account') {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        builder: (_) => _CreateDemoAccountSheet(onCreated: _addDemoAccount),
      );
      return;
    }
    if (page == 'Logout') {
      unawaited(_logoutAndReturnToEntry());
      return;
    }
    if (page == 'Security Center') {
      showSecurityPasswordModal(
        context,
        onVerified: () {
          if (!mounted) return;
          if (_selectedPage == 'Security Center') {
            _resetScrollFor('Security Center');
            return;
          }
          _navigationHistory.add(_selectedPage);
          _secondaryPageNavId++;
          _resetScrollFor('Security Center');
          setState(() => _selectedPage = 'Security Center');
        },
      );
      return;
    }

    switch (page) {
      case 'Dashboard' || 'Transactions' || 'Trading Accounts' || 'More':
        _navigationHistory.clear();
      default:
        _navigationHistory.add(_selectedPage);
    }
    _secondaryPageNavId++;
    _resetScrollFor(page);
    setState(() {
      _selectedPage = page;
      if (page == 'Transactions') _activityRefreshToken++;
    });
    if (page == 'Trading Accounts' || page == 'Demo Accounts') {
      unawaited(_loadTradingAccounts(refresh: true));
    }
  }

  void _handleUnauthorizedSession(int statusCode) {
    if (!mounted || _isLoggingOut) return;
    showAppMessage(
      'Your session has expired. Please sign in again.',
      type: AppFeedbackType.warning,
    );
    unawaited(_logoutAndReturnToEntry());
  }

  Future<void> _logoutAndReturnToEntry() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    _notificationRefreshTimer?.cancel();
    unawaited(AppNotificationCenter.instance.stopPositionMonitoring());
    try {
      await AuthApi.instance.logout();
    } catch (_) {
      // Local credentials are cleared by AuthApi even when the request fails.
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => _AppEntry(
          themeMode: _effectiveThemeMode,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ),
      (route) => false,
    );
  }

  int get _primaryTabIndex => switch (_selectedPage) {
    'Dashboard' => 0,
    'Transactions' => 1,
    'Trading Accounts' => 2,
    'More' => 3,
    _ => -1,
  };

  Widget _buildSecondaryPage(String page) {
    return PageStorage(
      key: ValueKey('$page-$_secondaryPageNavId'),
      bucket: PageStorageBucket(),
      child: KeyedSubtree(
        key: ValueKey('$page-$_secondaryPageNavId'),
        child: switch (page) {
          'Deposit' => BrokerFundsPage(
            withdrawal: false,
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
          'Withdraw' => BrokerFundsPage(
            withdrawal: true,
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
          'Partnership' => BrokerPartnershipPage(
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
          'PAMM Account' => PammPage(
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
          'Internal Transfer' => BrokerInternalTransferPage(
            accounts: _accounts,
            onBack: _handleBack,
            onSelectPage: _selectPage,
            onTransferCompleted: (fromLogin, toLogin, amount) {
              if (!mounted) return;
              setState(() {
                final fromIdx = _accounts.indexWhere(
                  (a) => a.login == fromLogin,
                );
                final toIdx = _accounts.indexWhere((a) => a.login == toLogin);
                if (fromIdx != -1) {
                  final fromAcc = _accounts[fromIdx];
                  final cur =
                      double.tryParse(
                        fromAcc.balance.replaceAll(RegExp(r'[^\d.]'), ''),
                      ) ??
                      0.0;
                  final newBal = (cur - amount).clamp(0.0, double.infinity);
                  final balStr = '\$${newBal.toStringAsFixed(2)}';
                  _accounts[fromIdx] = BrokerAccount(
                    fromAcc.name,
                    fromAcc.login,
                    fromAcc.leverage,
                    balStr,
                    balStr,
                    fromAcc.type,
                    server: fromAcc.server,
                    currency: fromAcc.currency,
                    floatingPnl: fromAcc.floatingPnl,
                    equityHistory: fromAcc.equityHistory,
                    openPositions: fromAcc.openPositions,
                    recentTrades: fromAcc.recentTrades,
                  );
                }
                if (toIdx != -1) {
                  final toAcc = _accounts[toIdx];
                  final cur =
                      double.tryParse(
                        toAcc.balance.replaceAll(RegExp(r'[^\d.]'), ''),
                      ) ??
                      0.0;
                  final newBal = cur + amount;
                  final balStr = '\$${newBal.toStringAsFixed(2)}';
                  _accounts[toIdx] = BrokerAccount(
                    toAcc.name,
                    toAcc.login,
                    toAcc.leverage,
                    balStr,
                    balStr,
                    toAcc.type,
                    server: toAcc.server,
                    currency: toAcc.currency,
                    floatingPnl: toAcc.floatingPnl,
                    equityHistory: toAcc.equityHistory,
                    openPositions: toAcc.openPositions,
                    recentTrades: toAcc.recentTrades,
                  );
                }

                // Record transfer in activity funds tab
                final now = DateTime.now();
                final timeStr =
                    'Today, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                final txId = 'trx-${now.millisecondsSinceEpoch % 1000000}';

                _appFundTransactions
                    .putIfAbsent(fromLogin, () => [])
                    .insert(
                      0,
                      ActivityFundTransaction(
                        id: '$txId-out',
                        isDeposit: false,
                        method: 'Internal Transfer',
                        amount: amount,
                        date: timeStr,
                        status: 'Completed',
                        sourceLogin: fromLogin,
                        destinationLogin: toLogin,
                        isTransfer: true,
                      ),
                    );

                _appFundTransactions
                    .putIfAbsent(toLogin, () => [])
                    .insert(
                      0,
                      ActivityFundTransaction(
                        id: '$txId-in',
                        isDeposit: true,
                        method: 'Internal Transfer',
                        amount: amount,
                        date: timeStr,
                        status: 'Completed',
                        sourceLogin: fromLogin,
                        destinationLogin: toLogin,
                        isTransfer: true,
                      ),
                    );
              });
            },
          ),
          'Demo Accounts' => BrokerDemoAccountsPage(
            accounts: _demoAccounts,
            onAccountCreated: _addDemoAccount,
            onOpenLiveAccounts: () => _selectPage('Trading Accounts'),
            onAccountSelected: _openDemoAccount,
          ),
          'Account Details' when _selectedAccount != null =>
            BrokerAccountDetailsPage(
              account: _selectedAccount!,
              onBack: _handleBack,
              onSelectPage: _selectPage,
              isFavorite: _favoriteAccountLogins.contains(
                _selectedAccount!.login,
              ),
              onToggleFavorite: () =>
                  _toggleFavoriteAccount(_selectedAccount!.login),
            ),
          'Profile' => BrokerProfilePage(
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
          'Platform' => const BrokerDownloadCenterPage(),
          'Settings' => BrokerSettingsPage(
            themeMode: _effectiveThemeMode,
            onThemeModeChanged: _changeThemeMode,
            onSelectPage: _selectPage,
          ),
          'Theme Mode' => BrokerThemeModePage(
            themeMode: _effectiveThemeMode,
            onThemeModeChanged: _changeThemeMode,
          ),
          'Tickets' => const BrokerTicketsPage(),
          'Privacy Policy' => const BrokerPrivacyPolicyPage(),
          'MAM' || 'MAM Account' => MamPage(
            key: _mamKey,
            initialTab: 0,
            onBack: _handleBack,
          ),
          'MAM Manager' => MamPage(
            key: _mamKey,
            initialTab: 0,
            onBack: _handleBack,
          ),
          'MAM Investor' => MamPage(
            key: _mamKey,
            initialTab: 1,
            onBack: _handleBack,
          ),
          'Available MAM' || 'MAM Available' => MamPage(
            key: _mamKey,
            initialTab: 2,
            onBack: _handleBack,
          ),
          'Social Trading' => MamPage(
            key: _mamKey,
            initialTab: 0,
            onBack: _handleBack,
          ),
          'Security Center' => SecurityCenterPage(
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
          'Trade Report' => TradeReportPage(
            accounts: _accounts,
            selectedAccountLogin: _selectedAccount?.login,
            onAccountChanged: (login) {
              if (!mounted) return;
              setState(() {
                final acc = _accounts.firstWhere(
                  (a) => a.login == login,
                  orElse: () => _accounts.first,
                );
                _selectedAccount = acc;
              });
            },
            onBack: _handleBack,
          ),
          'Trade Pattern Analysis' => TradePatternAnalysisPage(
            accounts: _accounts,
            initialAccountLogin: _selectedAccount?.login ?? '3503',
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
          _ => _SectionPage(title: page),
        },
      ),
    );
  }

  Widget _buildPrimaryTabLayer({
    required int index,
    required int activeIndex,
    required Widget child,
  }) {
    final active = activeIndex == index;
    return Offstage(
      offstage: !active,
      child: TickerMode(
        enabled: active,
        child: IgnorePointer(
          ignoring: !active,
          child: ExcludeSemantics(
            excluding: !active,
            child: AnimatedOpacity(
              opacity: active ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryIndex = _primaryTabIndex;
    final isKeyboardOpen = _isKeyboardOpen(context);
    return PopScope(
      key: const Key('app_shell_pop_scope'),
      canPop:
          _selectedPage == 'Dashboard' &&
          _navigationHistory.isEmpty &&
          !(_mamKey.currentState?.hasActiveSubView ?? false),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: _AppHeader(
          title: _selectedPage == 'Platform'
              ? 'Download Center'
              : _selectedPage,
          onBack: switch (_selectedPage) {
            'Dashboard' ||
            'Transactions' ||
            'Trading Accounts' ||
            'More' => null,
            _ => _handleBack,
          },
          onSelectPage: _selectPage,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: LayoutBuilder(
                      builder: (context, constraints) => Center(
                        child: SizedBox(
                          width: constraints.maxWidth.clamp(0.0, 1280.0),
                          height: constraints.maxHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Offstage(
                                offstage: primaryIndex == -1,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildPrimaryTabLayer(
                                      index: 0,
                                      activeIndex: primaryIndex,
                                      child: BrokerDashboardPage(
                                        accounts: List<BrokerAccount>.unmodifiable(_accounts),
                                        onRefreshAccounts: () => _loadTradingAccounts(refresh: true),
                                        balanceVisible: _balanceVisible,
                                        onToggleBalance: () => setState(
                                          () => _balanceVisible =
                                              !_balanceVisible,
                                        ),
                                        onSelectPage: _selectPage,
                                        onOpenReport: _openDashboardTradeReport,
                                        scrollController:
                                            _dashboardScrollController,
                                      ),
                                    ),
                                    _buildPrimaryTabLayer(
                                      index: 1,
                                      activeIndex: primaryIndex,
                                      child: BrokerTransactionsPage(
                                        isActive: primaryIndex == 1,
                                        refreshToken: _activityRefreshToken,
                                        accounts: _accounts,
                                        externalFundTransactions:
                                            _appFundTransactions,
                                        scrollController:
                                            _transactionsScrollController,
                                      ),
                                    ),
                                    _buildPrimaryTabLayer(
                                      index: 2,
                                      activeIndex: primaryIndex,
                                      child: BrokerAccountsPage(
                                        onSelectPage: _selectPage,
                                        accounts: _accounts,
                                        onAccountCreated: _addAccount,
                                        onAccountSelected: _openAccount,
                                        favoriteLogins: _favoriteAccountLogins,
                                        onToggleFavorite:
                                            _toggleFavoriteAccount,
                                        scrollController:
                                            _accountsScrollController,
                                        isLoading: _accountsLoading,
                                        loadError: _accountsError,
                                        onRetry: () => _loadTradingAccounts(refresh: true),
                                      ),
                                    ),
                                    _buildPrimaryTabLayer(
                                      index: 3,
                                      activeIndex: primaryIndex,
                                      child: BrokerMorePage(
                                        onSelectPage: _selectPage,
                                        scrollController: _moreScrollController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (primaryIndex == -1)
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 280),
                                  reverseDuration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: _buildSecondaryPage(_selectedPage),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isKeyboardOpen &&
                    !const {
                      'Settings',
                      'Theme Mode',
                      'Privacy Policy',
                    }.contains(_selectedPage))
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: RepaintBoundary(
                      child: BrokerBottomNavigation(
                        selectedPage: _selectedPage,
                        onSelect: _selectPage,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
