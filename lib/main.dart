import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'app_notifications.dart';
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
      home: _AppEntry(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
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
  const _AppEntry({
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
  });
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _splashFinished = false;

  void _openDashboard() {
    if (!mounted) return;
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
  Widget build(BuildContext context) => _splashFinished
      ? LoginPage(onLogin: _openDashboard)
      : _LogoAnimationSplash(
          onFinished: () {
            if (mounted) setState(() => _splashFinished = true);
          },
        );
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
      if (!mounted) return;
      await _controller.setVolume(0);
      await _controller.play();
      if (mounted) setState(() => _ready = true);
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
  final List<String> _navigationHistory = <String>[];
  final GlobalKey<MamPageState> _mamKey = GlobalKey<MamPageState>();
  BrokerAccount? _selectedAccount;
  String _accountDetailsReturnPage = 'Trading Accounts';
  bool _balanceVisible = true;
  final Set<String> _favoriteAccountLogins = <String>{};
  final Map<String, List<ActivityFundTransaction>> _appFundTransactions = {};
  final ScrollController _dashboardScrollController = ScrollController(keepScrollOffset: false);
  final ScrollController _transactionsScrollController = ScrollController(keepScrollOffset: false);
  final ScrollController _accountsScrollController = ScrollController(keepScrollOffset: false);
  final ScrollController _moreScrollController = ScrollController(keepScrollOffset: false);
  int _secondaryPageNavId = 0;
  double _lastScreenWidth = 0;
  double _maxWindowHeight = 0;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FocusManager.instance.removeListener(_handleFocusChange);
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
  // Local preview fixtures only. Replace with authenticated MT5 API data before production.
  final List<BrokerAccount> _accounts = [
    BrokerAccount(
      'Standard', '3315', '1:500', r'$2,560.00', r'$2,742.50', 'Live MT5',
      server: 'VTIndex-MT5', currency: 'USD', floatingPnl: 182.50,
      equityHistory: [2380, 2410, 2375, 2460, 2430, 2510, 2480, 2570, 2530, 2620, 2590, 2742.50],
      openPositions: [
        BrokerOpenPosition(symbol: 'XAUUSD', side: 'buy', volume: '0.10', openPrice: '2,345.20', currentPrice: '2,351.80', profit: 66.00),
        BrokerOpenPosition(symbol: 'EURUSD', side: 'sell', volume: '0.20', openPrice: '1.08420', currentPrice: '1.08048', profit: 116.50),
      ],
      recentTrades: [
        BrokerTradeRecord(symbol: 'GBPUSD', side: 'buy', volume: '0.10', closedAt: 'Today, 09:42', profit: 38.20),
        BrokerTradeRecord(symbol: 'XAUUSD', side: 'sell', volume: '0.05', closedAt: 'Yesterday', profit: -12.50),
      ],
    ),
    BrokerAccount(
      'ECN', '3311', '1:500', r'$1,240.00', r'$1,180.20', 'Live MT5',
      server: 'VTIndex-MT5', currency: 'USD', floatingPnl: -59.80,
      equityHistory: [1290, 1260, 1280, 1230, 1250, 1200, 1240, 1190, 1220, 1180.20],
      openPositions: [
        BrokerOpenPosition(symbol: 'NAS100', side: 'sell', volume: '0.10', openPrice: '18,420.0', currentPrice: '18,480.0', profit: -59.80),
      ],
      recentTrades: [
        BrokerTradeRecord(symbol: 'EURUSD', side: 'buy', volume: '0.20', closedAt: 'Today, 08:15', profit: 24.80),
        BrokerTradeRecord(symbol: 'USDJPY', side: 'sell', volume: '0.10', closedAt: 'Yesterday', profit: 16.40),
      ],
    ),
    BrokerAccount(
      'Pro', '3312', '1:500', r'$5,000.00', r'$5,320.00', 'Live MT5',
      server: 'VTIndex-MT5', currency: 'USD', floatingPnl: 320.00,
      equityHistory: [5000, 5080, 5050, 5140, 5100, 5200, 5160, 5270, 5230, 5320],
      openPositions: [
        BrokerOpenPosition(symbol: 'BTCUSD', side: 'buy', volume: '0.01', openPrice: '67,100.0', currentPrice: '67,420.0', profit: 320.00),
      ],
      recentTrades: [
        BrokerTradeRecord(symbol: 'XAUUSD', side: 'buy', volume: '0.05', closedAt: 'Today, 07:30', profit: 21.60),
        BrokerTradeRecord(symbol: 'AUDUSD', side: 'sell', volume: '0.10', closedAt: 'Yesterday', profit: 8.30),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_handleFocusChange);
    _currentThemeMode = widget.themeMode;
    _loadFavoriteAccounts();
  }

  Future<void> _loadFavoriteAccounts() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList('vtindex_favorite_account_logins') ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _favoriteAccountLogins
        ..clear()
        ..addAll(stored);
    });
  }

  Future<void> _toggleFavoriteAccount(String login) async {
    setState(() {
      if (!_favoriteAccountLogins.add(login)) {
        _favoriteAccountLogins.remove(login);
      }
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList('vtindex_favorite_account_logins', _favoriteAccountLogins.toList());
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

  void _addAccount(BrokerAccount account) =>
      setState(() => _accounts.insert(0, account));

  final List<BrokerAccount> _demoAccounts = [
    BrokerAccount(
      'Demo Standard',
      '3498102',
      '1:500',
      r'$10,000.00',
      r'$10,000.00',
      'Demo MT5 Standard',
      server: 'VTIndex-Demo',
      currency: 'USD',
      floatingPnl: 0.0,
    ),
    BrokerAccount(
      'Demo ECN Pro',
      '3481940',
      '1:200',
      r'$25,000.00',
      r'$25,180.40',
      'Demo MT5 ECN',
      server: 'VTIndex-Demo',
      currency: 'USD',
      floatingPnl: 180.40,
    ),
  ];

  void _addDemoAccount(BrokerAccount account) {
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => _AppEntry(
            themeMode: _effectiveThemeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ),
        (route) => false,
      );
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
    setState(() => _selectedPage = page);
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
        'Partnership' => const BrokerPartnershipPage(),
        'PAMM Account' => PammPage(
            onBack: _handleBack,
            onSelectPage: _selectPage,
          ),
        'Internal Transfer' => BrokerInternalTransferPage(
            accounts: _accounts,
            onBack: _handleBack,
            onSelectPage: _selectPage,
            onTransferCompleted: (fromLogin, toLogin, amount) {
              setState(() {
                final fromIdx = _accounts.indexWhere((a) => a.login == fromLogin);
                final toIdx = _accounts.indexWhere((a) => a.login == toLogin);
                if (fromIdx != -1) {
                  final fromAcc = _accounts[fromIdx];
                  final cur = double.tryParse(fromAcc.balance.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
                  final newBal = (cur - amount).clamp(0.0, double.infinity);
                  final balStr = '\$${newBal.toStringAsFixed(2)}';
                  _accounts[fromIdx] = BrokerAccount(
                    fromAcc.name, fromAcc.login, fromAcc.leverage,
                    balStr, balStr, fromAcc.type,
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
                  final cur = double.tryParse(toAcc.balance.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
                  final newBal = cur + amount;
                  final balStr = '\$${newBal.toStringAsFixed(2)}';
                  _accounts[toIdx] = BrokerAccount(
                    toAcc.name, toAcc.login, toAcc.leverage,
                    balStr, balStr, toAcc.type,
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
                final timeStr = 'Today, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                final txId = 'trx-${now.millisecondsSinceEpoch % 1000000}';

                _appFundTransactions.putIfAbsent(fromLogin, () => []).insert(
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

                _appFundTransactions.putIfAbsent(toLogin, () => []).insert(
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
        'Account Details' when _selectedAccount != null => BrokerAccountDetailsPage(
            account: _selectedAccount!,
            onBack: _handleBack,
            onSelectPage: _selectPage,
            isFavorite: _favoriteAccountLogins.contains(_selectedAccount!.login),
            onToggleFavorite: () => _toggleFavoriteAccount(_selectedAccount!.login),
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
    return IgnorePointer(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryIndex = _primaryTabIndex;
    final isKeyboardOpen = _isKeyboardOpen(context);
    return PopScope(
      key: const Key('app_shell_pop_scope'),
      canPop: _selectedPage == 'Dashboard' &&
          _navigationHistory.isEmpty &&
          !(_mamKey.currentState?.hasActiveSubView ?? false),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: _AppHeader(
          title: _selectedPage == 'Platform' ? 'Download Center' : _selectedPage,
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
                                      balanceVisible: _balanceVisible,
                                      onToggleBalance: () => setState(
                                        () => _balanceVisible = !_balanceVisible,
                                      ),
                                      onSelectPage: _selectPage,
                                      scrollController: _dashboardScrollController,
                                    ),
                                  ),
                                  _buildPrimaryTabLayer(
                                    index: 1,
                                    activeIndex: primaryIndex,
                                    child: BrokerTransactionsPage(
                                      accounts: _accounts,
                                      externalFundTransactions: _appFundTransactions,
                                      scrollController: _transactionsScrollController,
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
                                      onToggleFavorite: _toggleFavoriteAccount,
                                      scrollController: _accountsScrollController,
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
                                reverseDuration: const Duration(milliseconds: 200),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(opacity: animation, child: child);
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
                  !const {'Settings', 'Theme Mode', 'Privacy Policy'}
                      .contains(_selectedPage))
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
