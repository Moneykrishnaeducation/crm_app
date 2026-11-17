import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/partnership_page.dart';
import 'pages/profile_page.dart';
import 'pages/security_center_page.dart';

part 'widgets/app_header.dart';
part 'pages/dashboard_page.dart';
part 'pages/broker_screens.dart';
part 'pages/funds_action_dialog.dart';
part 'pages/accounts_page.dart';
part 'pages/internal_transfer_page.dart';
part 'pages/demo_accounts_page.dart';
part 'pages/more_page.dart';
part 'pages/settings_page.dart';
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
      title: 'VT Index',
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
  Widget build(BuildContext context) => LoginPage(onLogin: _openDashboard);
}

class _AppShellState extends State<AppShell> {
  String _selectedPage = 'Dashboard';
  bool _balanceVisible = true;
  final List<BrokerAccount> _accounts = [
    BrokerAccount(
      'XRSIM-USD-1',
      '3315',
      '1:500',
      '\$0.00',
      '\$0.00',
      'Live MT5',
    ),
    BrokerAccount(
      'XRSIM-USD-2',
      '3311',
      '1:500',
      '\$0.00',
      '\$0.00',
      'Live MT5',
    ),
    BrokerAccount(
      'XRSIM-USD-3',
      '3312',
      '1:500',
      '\$0.00',
      '\$0.00',
      'Live MT5',
    ),
    BrokerAccount(
      'XRSIM-USD-4',
      '3327',
      '1:500',
      '\$0.00',
      '\$0.00',
      'Live MT5',
    ),
  ];

  void _addAccount(BrokerAccount account) =>
      setState(() => _accounts.insert(0, account));

  void _selectPage(String page) {
    if (page == 'Open Account') {
      showDialog<void>(
        context: context,
        builder: (_) => _OpenLiveAccountDialog(onCreated: _addAccount),
      );
      return;
    }
    if (page == 'Deposit' || page == 'Withdraw') {
      setState(() => _selectedPage = page);
      return;
    }
    if (page == 'Logout') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => _AppEntry(
            themeMode: widget.themeMode,
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
          setState(() => _selectedPage = 'Security Center');
        },
      );
      return;
    }
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
    return KeyedSubtree(
      key: ValueKey(page),
      child: switch (page) {
        'Deposit' => BrokerFundsPage(
            withdrawal: false,
            onBack: () => setState(() => _selectedPage = 'Dashboard'),
            onSelectPage: _selectPage,
          ),
        'Withdraw' => BrokerFundsPage(
            withdrawal: true,
            onBack: () => setState(() => _selectedPage = 'Dashboard'),
            onSelectPage: _selectPage,
          ),
        'Partnership' => const BrokerPartnershipPage(),
        'Internal Transfer' => const BrokerInternalTransferPage(),
        'Demo Accounts' => const BrokerDemoAccountsPage(),
        'Profile' => BrokerProfilePage(
            onBack: () => setState(() => _selectedPage = 'More'),
            onSelectPage: _selectPage,
          ),
        'Settings' => BrokerSettingsPage(
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        'MAM Manager' => const BrokerMamManagerPage(),
        'Security Center' => SecurityCenterPage(
            onBack: () => setState(() => _selectedPage = 'More'),
            onSelectPage: _selectPage,
          ),
        _ => _SectionPage(title: page),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryIndex = _primaryTabIndex;
    return Scaffold(
      appBar: _AppHeader(
        title: _selectedPage,
        onBack: switch (_selectedPage) {
          'Profile' || 'Security Center' => () => setState(() => _selectedPage = 'More'),
          'Deposit' || 'Withdraw' => () => setState(() => _selectedPage = 'Dashboard'),
          _ => null,
        },
        onAvatarTap: () => _selectPage('Profile'),
        onSelectPage: _selectPage,
      ),
      body: SafeArea(
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
                            child: IndexedStack(
                              index: primaryIndex < 0 ? 0 : primaryIndex,
                              children: [
                                BrokerDashboardPage(
                                  balanceVisible: _balanceVisible,
                                  onToggleBalance: () => setState(
                                    () => _balanceVisible = !_balanceVisible,
                                  ),
                                  onSelectPage: _selectPage,
                                ),
                                const BrokerTransactionsPage(),
                                BrokerAccountsPage(
                                  onSelectPage: _selectPage,
                                  accounts: _accounts,
                                  onAccountCreated: _addAccount,
                                ),
                                BrokerMorePage(onSelectPage: _selectPage),
                              ],
                            ),
                          ),
                          if (primaryIndex == -1)
                            _buildSecondaryPage(_selectedPage),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
    );
  }
}
