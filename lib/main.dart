import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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
part 'pages/login_page.dart';

const _background = Color(0xFFF5F7FB);
const _sidebar = Color(0xFF10264B);
const _panel = Colors.white;
const _panelLight = Color(0xFFF3F6FB);
const _border = Color(0xFFE2E8F1);
const _muted = Color(0xFF71809A);
const _blue = Color(0xFF174A8B);
const _gold = Color(0xFFD8A82E);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VT Index',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.light(primary: _blue, surface: _panel),
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: const AppBarTheme(foregroundColor: Color(0xFF10264B)),
        useMaterial3: true,
      ),
      home: const _AppEntry(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  @override
  Widget build(BuildContext context) => LoginPage(onLogin: _openDashboard);

  void _openDashboard() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AppShell()),
    );
  }
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
      showDialog<void>(
        context: context,
        barrierColor: const Color(0xCC020817),
        builder: (_) => FundsActionDialog(withdrawal: page == 'Withdraw'),
      );
      return;
    }
    if (page == 'Logout') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const _AppEntry()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppHeader(
        title: _selectedPage,
        onBack:
            (_selectedPage == 'Profile' || _selectedPage == 'Security Center')
            ? () => setState(() => _selectedPage = 'More')
            : null,
        onAvatarTap: () => _selectPage('Profile'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => Center(
                  child: SizedBox(
                    width: constraints.maxWidth.clamp(0.0, 1280.0),
                    child: _selectedPage == 'Dashboard'
                        ? BrokerDashboardPage(
                            balanceVisible: _balanceVisible,
                            onToggleBalance: () => setState(
                              () => _balanceVisible = !_balanceVisible,
                            ),
                            onSelectPage: _selectPage,
                          )
                        : _selectedPage == 'Transactions'
                        ? const BrokerTransactionsPage()
                        : _selectedPage == 'Partnership'
                        ? const BrokerPartnershipPage()
                        : _selectedPage == 'Trading Accounts'
                        ? BrokerAccountsPage(
                            onSelectPage: _selectPage,
                            accounts: _accounts,
                            onAccountCreated: _addAccount,
                          )
                        : _selectedPage == 'Internal Transfer'
                        ? const BrokerInternalTransferPage()
                        : _selectedPage == 'Demo Accounts'
                        ? const BrokerDemoAccountsPage()
                        : _selectedPage == 'More'
                        ? BrokerMorePage(onSelectPage: _selectPage)
                        : _selectedPage == 'Profile'
                        ? BrokerProfilePage(
                            onBack: () =>
                                setState(() => _selectedPage = 'More'),
                            onSelectPage: _selectPage,
                          )
                        : _selectedPage == 'Security Center'
                        ? SecurityCenterPage(
                            onBack: () =>
                                setState(() => _selectedPage = 'More'),
                            onSelectPage: _selectPage,
                          )
                        : _SectionPage(title: _selectedPage),
                  ),
                ),
              ),
            ),
            BrokerBottomNavigation(
              selectedPage: _selectedPage,
              onSelect: _selectPage,
            ),
          ],
        ),
      ),
    );
  }
}
