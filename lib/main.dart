import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

part 'widgets/app_header.dart';
part 'pages/dashboard_page.dart';
part 'pages/broker_screens.dart';
part 'pages/accounts_page.dart';
part 'pages/internal_transfer_page.dart';
part 'pages/demo_accounts_page.dart';
part 'pages/more_page.dart';
part 'pages/login_page.dart';

const _background = Color(0xFF06163B);
const _sidebar = Color(0xFF04122F);
const _panel = Color(0xFF0B2452);
const _panelLight = Color(0xFF10316A);
const _border = Color(0xFF174783);
const _muted = Color(0xFFA9B9D5);
const _blue = Color(0xFF0875F5);
const _gold = Color(0xFFF4C84A);

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.dark(primary: _blue, surface: _panel),
        fontFamily: GoogleFonts.poppins().fontFamily,
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

  void _selectPage(String page) {
    setState(() => _selectedPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppHeader(title: _selectedPage),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(children: [
          Expanded(
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
                            ? BrokerAccountsPage(onSelectPage: _selectPage)
                            : _selectedPage == 'Internal Transfer'
                                ? const BrokerInternalTransferPage()
                                : _selectedPage == 'Demo Accounts'
                                    ? const BrokerDemoAccountsPage()
                                    : _selectedPage == 'More'
                                        ? BrokerMorePage(onSelectPage: _selectPage)
                                    : _SectionPage(title: _selectedPage),
          ),
          BrokerBottomNavigation(
            selectedPage: _selectedPage,
            onSelect: _selectPage,
          ),
        ]),
      ),
    );
  }
}
