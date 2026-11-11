part of '../main.dart';

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
