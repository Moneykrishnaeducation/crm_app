part of '../main.dart';

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
        final horizontal = wide ? 28.0 : 16.0;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, wide ? 26 : 18, horizontal, 112),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DashboardHeader(onSelectPage: onSelectPage),
                  const SizedBox(height: 22),
                  _DashboardAccountOverview(
                    balanceVisible: balanceVisible,
                    onToggleBalance: onToggleBalance,
                    onSelectPage: onSelectPage,
                  ),
                  const SizedBox(height: 18),
                  _DashboardQuickActions(onSelectPage: onSelectPage, wide: wide),
                  const SizedBox(height: 18),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _DashboardFunds(onSelectPage: onSelectPage)),
                        const SizedBox(width: 16),
                        Expanded(flex: 4, child: _DashboardPartnership(onSelectPage: onSelectPage)),
                      ],
                    )
                  else ...[
                    _DashboardFunds(onSelectPage: onSelectPage),
                    const SizedBox(height: 16),
                    _DashboardPartnership(onSelectPage: onSelectPage),
                  ],
                  const SizedBox(height: 18),
                  _DashboardActivity(onSelectPage: onSelectPage),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'VT INDEX  •  CLIENT WORKSPACE',
                      style: TextStyle(
                        color: Color(0xFF7085A6),
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CLIENT OVERVIEW',
                style: TextStyle(color: _gold, fontSize: 10, letterSpacing: 1.6, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              const Text(
                'Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 27, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -0.7),
              ),
              const SizedBox(height: 6),
              Text(
                'Your accounts, funds and recent activity in one place.',
                style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: _panel,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: () => onSelectPage('Settings'),
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(border: Border.all(color: _border), borderRadius: BorderRadius.circular(13)),
              child: const Icon(LucideIcons.settings2, color: Color(0xFF9DB8DD), size: 19),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardAccountOverview extends StatelessWidget {
  const _DashboardAccountOverview({
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onSelectPage,
  });
  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconTile(icon: LucideIcons.wallet, accent: _gold),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PORTFOLIO OVERVIEW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.7)),
                    SizedBox(height: 3),
                    Text('Account snapshot', style: TextStyle(color: _muted, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFF25344B), borderRadius: BorderRadius.circular(20)),
                child: const Text('PREVIEW DATA', style: TextStyle(color: Color(0xFFB6C7DF), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
              ),
              IconButton(
                onPressed: onToggleBalance,
                tooltip: balanceVisible ? 'Hide balance' : 'Show balance',
                visualDensity: VisualDensity.compact,
                icon: Icon(balanceVisible ? LucideIcons.eye : LucideIcons.eyeOff, color: _muted, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 540;
              final balance = _DashboardValue(
                label: 'TOTAL BALANCE',
                value: balanceVisible ? '—' : '••••••',
                helper: 'Connect account data to display balance',
                prominent: true,
              );
              final metrics = Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _DashboardMiniMetric(label: 'EQUITY', value: '—', icon: LucideIcons.chartNoAxesCombined),
                  _DashboardMiniMetric(label: 'FREE MARGIN', value: '—', icon: LucideIcons.wallet),
                  _DashboardMiniMetric(label: 'FLOATING P&L', value: '—', icon: LucideIcons.activity),
                ],
              );
              if (compact) {
                return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [balance, const SizedBox(height: 16), metrics]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 4, child: balance),
                  Container(width: 1, height: 82, margin: const EdgeInsets.symmetric(horizontal: 18), color: _border),
                  Expanded(flex: 6, child: metrics),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(LucideIcons.info, color: _muted, size: 13),
              const SizedBox(width: 7),
              const Expanded(child: Text('Portfolio figures will appear when your account data is connected.', style: TextStyle(color: _muted, fontSize: 10, height: 1.4))),
              TextButton(
                onPressed: () => onSelectPage('Trading Accounts'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8EBEFF), padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 30)),
                child: const Text('Accounts', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardValue extends StatelessWidget {
  const _DashboardValue({required this.label, required this.value, required this.helper, this.prominent = false});
  final String label;
  final String value;
  final String helper;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _muted, fontSize: 9, letterSpacing: 0.8, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: Colors.white, fontSize: prominent ? 34 : 19, height: 1, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
        const SizedBox(height: 7),
        Text(helper, style: const TextStyle(color: _muted, fontSize: 9, height: 1.35)),
      ],
    );
  }
}

class _DashboardMiniMetric extends StatelessWidget {
  const _DashboardMiniMetric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(color: _panelLight.withValues(alpha: 0.65), border: Border.all(color: _border), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF82B9FF)),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.4)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
        ],
      ),
    );
  }
}

class _DashboardQuickActions extends StatelessWidget {
  const _DashboardQuickActions({required this.onSelectPage, required this.wide});
  final ValueChanged<String> onSelectPage;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _DashboardAction('Deposit', 'Add funds to an account', LucideIcons.arrowDownToLine, _gold, 'Deposit'),
      _DashboardAction('Withdraw', 'Request a withdrawal', LucideIcons.arrowUpFromLine, const Color(0xFF22C9A5), 'Withdraw'),
      _DashboardAction('Transfer', 'Move funds internally', LucideIcons.arrowLeftRight, const Color(0xFFB49AFF), 'Internal Transfer'),
      _DashboardAction('Open account', 'Create a trading account', LucideIcons.plus, const Color(0xFF69B7FF), 'Open Account'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('QUICK ACTIONS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.7)),
        const SizedBox(height: 10),
        GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: wide ? 82 : 88,
          ),
          itemBuilder: (context, index) => _DashboardActionTile(action: actions[index], onTap: () => onSelectPage(actions[index].page)),
        ),
      ],
    );
  }
}

class _DashboardAction {
  const _DashboardAction(this.title, this.subtitle, this.icon, this.accent, this.page);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String page;
}

class _DashboardActionTile extends StatelessWidget {
  const _DashboardActionTile({required this.action, required this.onTap});
  final _DashboardAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _panel,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(border: Border.all(color: _border), borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: action.accent.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(10)),
                child: Icon(action.icon, color: action.accent, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(action.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 8)),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: _muted, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardFunds extends StatelessWidget {
  const _DashboardFunds({required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACCOUNT CENTRE', style: TextStyle(color: _gold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          const Text('Manage your accounts', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('Open your live or demo account list and review account details.', style: TextStyle(color: _muted, fontSize: 10, height: 1.45)),
          const SizedBox(height: 14),
          _DashboardNavigationRow(icon: LucideIcons.chartNoAxesCombined, title: 'Trading accounts', subtitle: 'Live account details and balances', onTap: () => onSelectPage('Trading Accounts')),
          const SizedBox(height: 8),
          _DashboardNavigationRow(icon: LucideIcons.monitorPlay, title: 'Demo accounts', subtitle: 'Practice accounts and details', onTap: () => onSelectPage('Demo Accounts')),
        ],
      ),
    );
  }
}

class _DashboardNavigationRow extends StatelessWidget {
  const _DashboardNavigationRow({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _panelLight.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _IconTile(icon: icon),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(color: _muted, fontSize: 9)),
              ])),
              const Icon(LucideIcons.chevronRight, color: _muted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardPartnership extends StatelessWidget {
  const _DashboardPartnership({required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const _IconTile(icon: LucideIcons.usersRound, accent: const Color(0xFFC58AFF)),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PARTNERSHIP', style: TextStyle(color: _gold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              SizedBox(height: 4),
              Text('Partner workspace', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            ])),
          ]),
          const SizedBox(height: 12),
          const Text('Review your introducing broker activity, referrals and commission information.', style: TextStyle(color: _muted, fontSize: 10, height: 1.5)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => onSelectPage('Partnership'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFBBD5F8),
                side: const BorderSide(color: _border),
                minimumSize: const Size.fromHeight(40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Open partnership', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                SizedBox(width: 7),
                Icon(LucideIcons.arrowUpRight, size: 14),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardActivity extends StatelessWidget {
  const _DashboardActivity({required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const _IconTile(icon: LucideIcons.history),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recent activity', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
              SizedBox(height: 3),
              Text('Your latest transactions and account updates', style: TextStyle(color: _muted, fontSize: 9)),
            ])),
            TextButton(
              onPressed: () => onSelectPage('Transactions'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF8EBEFF), padding: const EdgeInsets.symmetric(horizontal: 7), minimumSize: const Size(0, 32)),
              child: const Text('View all', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
            decoration: BoxDecoration(color: _panelLight.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
            child: const Column(children: [
              Icon(LucideIcons.receiptText, color: _muted, size: 22),
              SizedBox(height: 9),
              Text('No recent activity', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Transactions will appear here when available.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 9)),
            ]),
          ),
        ],
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
            const Icon(LucideIcons.construction, color: _gold, size: 30),
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
