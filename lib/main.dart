import 'package:flutter/material.dart';

part 'widgets/sidebar.dart';
part 'widgets/app_header.dart';
part 'pages/dashboard_page.dart';

const _background = Color(0xFF0B1730);
const _sidebar = Color(0xFF091323);
const _panel = Color(0xFF111F3C);
const _panelLight = Color(0xFF172747);
const _border = Color(0xFF293D62);
const _muted = Color(0xFF8A9AB8);
const _blue = Color(0xFF3865D7);
const _gold = Color(0xFFF0C84B);

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
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPage = 'Dashboard';
  bool _balanceVisible = true;
  bool _sidebarCollapsed = false;

  void _selectPage(String page) {
    setState(() => _selectedPage = page);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 760;
        return Scaffold(
          key: _scaffoldKey,
          drawer: showSidebar
              ? null
              : Drawer(
                  width: 270,
                  backgroundColor: _sidebar,
                  child: _Sidebar(
                    selectedPage: _selectedPage,
                    onSelect: _selectPage,
                    collapsed: false,
                    onToggleCollapse: () {},
                    canCollapse: false,
                  ),
                ),
          appBar: _AppHeader(
            title: _selectedPage,
            showMenu: !showSidebar,
            onMenu: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: Row(
              children: [
                if (showSidebar)
                  SizedBox(
                    width: _sidebarCollapsed ? 68 : 228,
                    child: _Sidebar(
                      selectedPage: _selectedPage,
                      onSelect: _selectPage,
                      collapsed: _sidebarCollapsed,
                      onToggleCollapse: () => setState(
                        () => _sidebarCollapsed = !_sidebarCollapsed,
                      ),
                      canCollapse: true,
                    ),
                  ),
                Expanded(
                  child: _selectedPage == 'Dashboard'
                      ? DashboardPage(
                          balanceVisible: _balanceVisible,
                          onToggleBalance: () => setState(
                            () => _balanceVisible = !_balanceVisible,
                          ),
                          onSelectPage: _selectPage,
                        )
                      : _SectionPage(title: _selectedPage),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
