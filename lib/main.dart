import 'package:flutter/material.dart';

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

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selectedPage,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
    required this.canCollapse,
  });

  final String selectedPage;
  final ValueChanged<String> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;
  final bool canCollapse;

  static const _groups = <String, List<_NavItem>>{
    'OVERVIEW': [
      _NavItem('Dashboard', Icons.grid_view_rounded),
      _NavItem('Trade Pattern Analysis', Icons.show_chart_rounded),
    ],
    'TRADING': [
      _NavItem('Trading Accounts', Icons.credit_card_outlined),
      _NavItem('Deposit', Icons.account_balance_wallet_outlined),
      _NavItem('Social Trading', Icons.people_alt_outlined),
      _NavItem('PAMM Account', Icons.lock_outline_rounded),
    ],
    'SERVICES': [
      _NavItem('Partnership', Icons.handshake_outlined),
      _NavItem('Internal Transfer', Icons.swap_horiz_rounded),
    ],
    'TOOLS': [
      _NavItem('Technical Analysis', Icons.calendar_month_outlined),
      _NavItem('Platform', Icons.desktop_windows_outlined),
    ],
    'ACCOUNT': [
      _NavItem('Support', Icons.confirmation_number_outlined),
      _NavItem('Transactions', Icons.sync_alt_rounded),
      _NavItem('Privacy Policy', Icons.headphones_outlined),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _sidebar,
      child: Column(
        children: [
          Container(
            height: 66,
            padding: EdgeInsets.symmetric(horizontal: collapsed ? 10 : 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _border, width: 0.6)),
            ),
            child: Row(
              children: [
                if (collapsed)
                  Expanded(
                    child: Center(
                      child: IconButton(
                        onPressed: onToggleCollapse,
                        tooltip: 'Expand sidebar',
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.keyboard_double_arrow_right,
                          size: 19,
                          color: _muted,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Image.asset(
                      'assets/images/vtindex_logo.png',
                      height: 36,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                      semanticLabel: 'VT Index',
                    ),
                  ),
                if (!collapsed && canCollapse)
                  IconButton(
                    onPressed: onToggleCollapse,
                    tooltip: 'Collapse sidebar',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.keyboard_double_arrow_left,
                      size: 19,
                      color: _muted,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                collapsed ? 5 : 10,
                14,
                collapsed ? 5 : 10,
                10,
              ),
              children: [
                for (final group in _groups.entries) ...[
                  if (!collapsed)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 7),
                      child: Text(
                        group.key,
                        style: const TextStyle(
                          color: Color(0xFF647694),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  for (final item in group.value)
                    _SidebarItem(
                      item: item,
                      selected: item.label == selectedPage,
                      collapsed: collapsed,
                      onTap: () => onSelect(item.label),
                    ),
                  if (!collapsed) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              collapsed ? 10 : 14,
              10,
              collapsed ? 10 : 14,
              14,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _border, width: 0.6)),
            ),
            child: Row(
              children: [
                const _BrandMark(size: 26),
                if (!collapsed) ...[
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VT Index',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'V4.0.256',
                          style: TextStyle(color: _muted, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Tooltip(
        message: collapsed ? item.label : '',
        child: Material(
          color: selected ? const Color(0xFF172A4E) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: onTap,
            child: SizedBox(
              height: 36,
              child: Row(
                children: [
                  if (selected)
                    Container(
                      width: 3,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  else
                    const SizedBox(width: 3),
                  SizedBox(width: collapsed ? 0 : 13),
                  Icon(
                    item.icon,
                    size: 16,
                    color: selected ? const Color(0xFF92C5FF) : _muted,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFFA0AEC5),
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (selected)
                      const Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.chevron_right,
                          size: 15,
                          color: _muted,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const _AppHeader({
    required this.title,
    required this.showMenu,
    required this.onMenu,
  });

  final String title;
  final bool showMenu;
  final VoidCallback onMenu;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: showMenu ? 52 : 0,
      leading: showMenu
          ? IconButton(
              onPressed: onMenu,
              tooltip: 'Open navigation',
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
            )
          : null,
      titleSpacing: showMenu ? 4 : 20,
      title: LayoutBuilder(
        builder: (context, constraints) {
          final compact = MediaQuery.sizeOf(context).width < 480;
          if (compact) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/vtindex_logo.png',
                width: constraints.maxWidth.clamp(90.0, 150.0).toDouble(),
                height: 36,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                semanticLabel: 'VT Index',
              ),
            );
          }
          return Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
      actions: [
        if (MediaQuery.sizeOf(context).width >= 480) ...[
          const _LiveBadge(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none, color: _muted, size: 21),
          ),
        ],
        const Padding(
          padding: EdgeInsetsDirectional.only(end: 14),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: _panelLight,
            child: Icon(Icons.person_outline, size: 18, color: _gold),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 0.7, color: _border),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onSelectPage,
  });

  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 820;
        return SingleChildScrollView(
          padding: EdgeInsets.all(wide ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PortfolioPanel(
                balanceVisible: balanceVisible,
                onToggleBalance: onToggleBalance,
                wide: wide,
                onSelectPage: onSelectPage,
              ),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 5, child: _FundsPanel()),
                    const SizedBox(width: 14),
                    const Expanded(flex: 3, child: _PartnershipPanel()),
                  ],
                )
              else ...[
                const _FundsPanel(),
                const SizedBox(height: 14),
                const _PartnershipPanel(),
              ],
              const SizedBox(height: 14),
              const _TransactionsPanel(),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'VT INDEX  •  INSTITUTIONAL CLIENT WORKSPACE',
                  style: TextStyle(
                    color: Color(0xFF7085A6),
                    fontSize: 8,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PortfolioPanel extends StatelessWidget {
  const _PortfolioPanel({
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.wide,
    required this.onSelectPage,
  });

  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final bool wide;
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    final children = [
      _BalanceCard(visible: balanceVisible, onToggleBalance: onToggleBalance),
      const SizedBox(height: 12),
      const _PortfolioMetrics(),
    ];
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 480;
              return Row(
                children: [
                  const _Tag(
                    label: 'PORTFOLIO SUMMARY',
                    icon: Icons.donut_small_rounded,
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 8),
                    const _LiveBadge(),
                  ],
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleBalance,
                    tooltip: balanceVisible ? 'Hide balance' : 'Show balance',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      balanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _muted,
                      size: 18,
                    ),
                  ),
                  if (!compact)
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Portfolio is up to date.'),
                          ),
                        );
                      },
                      tooltip: 'Refresh',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.refresh, color: _muted, size: 18),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (wide)
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _BalanceCard(
                    visible: balanceVisible,
                    onToggleBalance: onToggleBalance,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(flex: 6, child: _PortfolioMetrics()),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          const SizedBox(height: 14),
          _ActionButtons(onSelectPage: onSelectPage, wide: wide),
          const SizedBox(height: 14),
          _QuickLinks(onSelectPage: onSelectPage),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.visible, required this.onToggleBalance});

  final bool visible;
  final VoidCallback onToggleBalance;

  @override
  Widget build(BuildContext context) {
    return _BalanceCardContent(
      visible: visible,
      onToggleBalance: onToggleBalance,
    );
  }
}

class _BalanceCardContent extends StatelessWidget {
  const _BalanceCardContent({this.visible = true, this.onToggleBalance});

  final bool visible;
  final VoidCallback? onToggleBalance;

  @override
  Widget build(BuildContext context) {
    return _InsetCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconTile(icon: Icons.account_balance_wallet_outlined),
              const SizedBox(width: 9),
              const Expanded(child: _Label('TOTAL REAL BALANCE')),
              const _Tag(
                label: 'LIVE USD',
                icon: Icons.circle,
                color: Color(0xFF13C7A1),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                visible ? '\$0' : '••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 7),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  'USD',
                  style: TextStyle(color: _muted, fontSize: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 9),
          const Text(
            'Real-time consolidated balance with instant cross-asset margin allocation and 0.0 pip STP routing.',
            style: TextStyle(color: _muted, fontSize: 9, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _PortfolioMetrics extends StatelessWidget {
  const _PortfolioMetrics();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'LIVE ACCOUNTS',
                value: '4',
                subtitle: 'Real trading accounts',
                icon: Icons.person_add_alt_1_outlined,
                accent: Color(0xFF27C7E9),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'DEMO ACCOUNTS',
                value: '0',
                subtitle: 'Practice terminal',
                icon: Icons.credit_card_outlined,
                accent: _gold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'TOTAL DEPOSITS',
                value: '\$0',
                subtitle: 'Cumulative capital',
                icon: Icons.savings_outlined,
                accent: Color(0xFF16C9A6),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'MAM / MANAGED FUNDS',
                value: '\$0',
                subtitle: 'PAMM & Social pool',
                icon: Icons.groups_2_outlined,
                accent: Color(0xFFC56BFF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _InsetCard(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      child: Row(
        children: [
          _IconTile(icon: icon, accent: accent),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(title),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 8),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF617595), size: 15),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onSelectPage, required this.wide});

  final ValueChanged<String> onSelectPage;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        'DEPOSIT FUNDS',
        Icons.account_balance_wallet_outlined,
        _gold,
        _sidebar,
        'Deposit',
      ),
      _ActionData(
        'WITHDRAWAL',
        Icons.add_circle_outline,
        const Color(0xFF16C9A6),
        const Color(0xFF0D3040),
        'Transactions',
      ),
      _ActionData(
        'INTERNAL TRANSFER',
        Icons.send_outlined,
        const Color(0xFFAA8CFF),
        const Color(0xFF25265C),
        'Internal Transfer',
      ),
      _ActionData(
        'OPEN ACCOUNT',
        Icons.person_add_alt_1_outlined,
        const Color(0xFF35A8FF),
        const Color(0xFF0C365F),
        'Trading Accounts',
      ),
    ];
    final columns = wide ? 4 : 2;
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: wide ? 3.25 : 3.8,
      children: [
        for (final action in actions)
          _ActionButton(action: action, onTap: () => onSelectPage(action.page)),
      ],
    );
  }
}

class _ActionData {
  const _ActionData(
    this.label,
    this.icon,
    this.foreground,
    this.background,
    this.page,
  );

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final String page;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onTap});

  final _ActionData action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: action.foreground.withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action.icon, color: action.foreground, size: 12),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: action.foreground,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (action.background == _gold) ...[
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: _sidebar, size: 11),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinks extends StatelessWidget {
  const _QuickLinks({required this.onSelectPage});

  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return _InsetCard(
      padding: const EdgeInsets.all(9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  _Label('QUICK ANALYTICAL SHORTCUTS'),
                  Spacer(),
                  Text(
                    'INSTITUTIONAL',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  _QuickLink(
                    title: 'Transactions',
                    icon: Icons.receipt_long_outlined,
                    compact: compact,
                    onTap: () => onSelectPage('Transactions'),
                  ),
                  const SizedBox(width: 6),
                  _QuickLink(
                    title: 'Pattern AI',
                    icon: Icons.auto_awesome,
                    compact: compact,
                    onTap: () => onSelectPage('Trade Pattern Analysis'),
                  ),
                  const SizedBox(width: 6),
                  _QuickLink(
                    title: 'Get MT5',
                    icon: Icons.open_in_new,
                    compact: compact,
                    onTap: () => onSelectPage('Platform'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.compact,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 11),
      label: compact
          ? const SizedBox.shrink()
          : Text(title, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFBED0EE),
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        textStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
        minimumSize: const Size(0, 31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
    );
    return Expanded(
      child: compact ? Tooltip(message: title, child: button) : button,
    );
  }
}

class _FundsPanel extends StatelessWidget {
  const _FundsPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PanelHeading(
            title: 'Your funds',
            subtitle: 'Portfolio allocation & capital distribution',
            trailing: _Tag(label: 'USD'),
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 390) {
                return const Column(
                  children: [_FundsDonut(), SizedBox(height: 12), _FundGrid()],
                );
              }
              return const Row(
                children: [
                  SizedBox(width: 130, child: _FundsDonut()),
                  SizedBox(width: 12),
                  Expanded(child: _FundGrid()),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          const _HintBar(
            text: 'Click any category to manage funds or review transactions.',
          ),
        ],
      ),
    );
  }
}

class _FundsDonut extends StatelessWidget {
  const _FundsDonut();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF243759),
                      width: 8,
                    ),
                  ),
                ),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL FUNDS',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'UNFUNDED',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '↗  Live allocation breakdown',
            style: TextStyle(color: Color(0xFF68A8FF), fontSize: 7),
          ),
        ],
      ),
    );
  }
}

class _FundGrid extends StatelessWidget {
  const _FundGrid();

  @override
  Widget build(BuildContext context) {
    const funds = [
      _FundData(
        'Real Balance',
        'Trading account balance',
        '0.0%',
        '\$0',
        Icons.attach_money,
        _gold,
      ),
      _FundData(
        'MAM Manager Funds',
        'Capital under management',
        '0.0%',
        '\$0',
        Icons.bar_chart,
        _blue,
      ),
      _FundData(
        'MAM Investor Funds',
        'Allocated to managed pools',
        '0.0%',
        '\$0',
        Icons.account_balance_wallet_outlined,
        Color(0xFF16C9A6),
      ),
      _FundData(
        'IB Earnings (Available)',
        'Withdrawable commission',
        '0.0%',
        '\$0',
        Icons.insert_chart_outlined,
        Color(0xFFC56BFF),
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.45,
      children: [for (final fund in funds) _FundCard(fund: fund)],
    );
  }
}

class _FundData {
  const _FundData(
    this.title,
    this.subtitle,
    this.percentage,
    this.value,
    this.icon,
    this.color,
  );

  final String title;
  final String subtitle;
  final String percentage;
  final String value;
  final IconData icon;
  final Color color;
}

class _FundCard extends StatelessWidget {
  const _FundCard({required this.fund});

  final _FundData fund;

  @override
  Widget build(BuildContext context) {
    return _InsetCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(fund.icon, size: 12, color: fund.color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  fund.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                fund.percentage,
                style: TextStyle(
                  color: fund.color,
                  fontSize: 6,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            fund.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 6),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                fund.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: _muted, size: 13),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartnershipPanel extends StatelessWidget {
  const _PartnershipPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              _IconTile(icon: Icons.people_alt_outlined),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partnership Program',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your introducing broker overview',
                      style: TextStyle(color: _muted, fontSize: 7),
                    ),
                  ],
                ),
              ),
              Icon(Icons.share_outlined, size: 13, color: _muted),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: _SmallStat(label: 'Total clients', value: '0'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SmallStat(label: 'IB Earnings', value: '\$0'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _InsetCard(
            padding: EdgeInsets.all(9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IB partner',
                  style: TextStyle(color: _muted, fontSize: 7),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'cm - 9BSFEEOGTL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: _muted, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {},
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward, size: 12),
            label: const Text('View partnership dashboard'),
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(34),
              textStyle: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _InsetCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _muted, fontSize: 7)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsPanel extends StatelessWidget {
  const _TransactionsPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconTile(icon: Icons.receipt_long_outlined),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent transactions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'A clear ledger of your latest account activity',
                      style: TextStyle(color: _muted, fontSize: 7),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBED0EE),
                  side: const BorderSide(color: _border),
                  minimumSize: const Size(0, 28),
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  textStyle: const TextStyle(fontSize: 7),
                ),
                child: const Text('View all activity  →'),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 9),
          const Row(
            children: [
              _TableHeading('DATE'),
              _TableHeading('DESCRIPTION'),
              _TableHeading('TYPE'),
              _TableHeading('AMOUNT (USD)'),
              _TableHeading('STATUS'),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(height: 1, color: _border),
          SizedBox(
            height: 106,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _panelLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Nothing to show just yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Your recent account transactions will appear here.',
                  style: TextStyle(color: _muted, fontSize: 7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeading extends StatelessWidget {
  const _TableHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF8EA3C7),
          fontSize: 6,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionPage extends StatelessWidget {
  const _SectionPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _Panel(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined, color: _gold, size: 30),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'This section is ready to be connected to your account services.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 7),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(12)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _panel,
        border: Border.all(color: _border, width: 0.8),
        borderRadius: BorderRadius.circular(13),
      ),
      child: child,
    );
  }
}

class _InsetCard extends StatelessWidget {
  const _InsetCard({
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _panelLight.withValues(alpha: 0.55),
        border: Border.all(color: _border.withValues(alpha: 0.8), width: 0.7),
        borderRadius: BorderRadius.circular(9),
      ),
      child: child,
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, this.accent = const Color(0xFF75B8FF)});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.13),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: accent, size: 14),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.icon, this.color = _muted});

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 8),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 7,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return const _Tag(
      label: 'Server: VTIndex-MT5',
      icon: Icons.circle,
      color: Color(0xFF18C7A0),
    );
  }
}

class _HintBar extends StatelessWidget {
  const _HintBar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: _panelLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: _muted, size: 11),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _muted, fontSize: 7),
            ),
          ),
          const Text(
            'History →',
            style: TextStyle(
              color: Color(0xFF68A8FF),
              fontSize: 7,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFFAABAD2),
        fontSize: 7,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.waves_rounded, color: _gold, size: size);
  }
}
