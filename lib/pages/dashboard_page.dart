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

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OVERVIEW',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Your dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 22 : 26,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'A clear view of your accounts, funds and activity.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _panel,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.chartPie,
                color: Color(0xFF8EBEFF),
                size: 20,
              ),
            ),
          ],
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
                    icon: LucideIcons.chartPie,
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
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff,
                      color: _muted,
                      size: 18,
                    ),
                  ),
                  if (!compact)
                    IconButton(
                      onPressed: () {
                        showAppMessage('Portfolio is up to date.');
                      },
                      tooltip: 'Refresh',
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(LucideIcons.refreshCw, color: _muted, size: 18),
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
              const _IconTile(icon: LucideIcons.wallet),
              const SizedBox(width: 9),
              const Expanded(child: _Label('TOTAL REAL BALANCE')),
              const _Tag(
                label: 'LIVE USD',
                icon: LucideIcons.circle,
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
                  fontSize: 30,
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
            style: TextStyle(color: _muted, fontSize: 11, height: 1.5),
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
                icon: LucideIcons.userRoundPlus,
                accent: Color(0xFF27C7E9),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'DEMO ACCOUNTS',
                value: '0',
                subtitle: 'Practice terminal',
                icon: LucideIcons.creditCard,
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
                icon: LucideIcons.piggyBank,
                accent: Color(0xFF16C9A6),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                title: 'MAM / MANAGED FUNDS',
                value: '\$0',
                subtitle: 'PAMM & Social pool',
                icon: LucideIcons.usersRound,
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
                    fontSize: 16,
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
          const Icon(LucideIcons.chevronRight, color: Color(0xFF617595), size: 15),
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
        LucideIcons.wallet,
        _gold,
        _sidebar,
        'Deposit',
      ),
      _ActionData(
        'WITHDRAWAL',
        LucideIcons.circlePlus,
        const Color(0xFF16C9A6),
        const Color(0xFF0D3040),
        'Withdraw',
      ),
      _ActionData(
        'INTERNAL TRANSFER',
        LucideIcons.send,
        const Color(0xFFAA8CFF),
        const Color(0xFF25265C),
        'Internal Transfer',
      ),
      _ActionData(
        'OPEN ACCOUNT',
        LucideIcons.userRoundPlus,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (action.background == _gold) ...[
                const SizedBox(width: 4),
                const Icon(LucideIcons.arrowRight, color: _sidebar, size: 11),
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
                      fontSize: 9,
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
                    icon: LucideIcons.receiptText,
                    compact: compact,
                    onTap: () => onSelectPage('Transactions'),
                  ),
                  const SizedBox(width: 6),
                  _QuickLink(
                    title: 'Pattern AI',
                    icon: LucideIcons.sparkles,
                    compact: compact,
                    onTap: () => onSelectPage('Trade Pattern Analysis'),
                  ),
                  const SizedBox(width: 6),
                  _QuickLink(
                    title: 'Get MT5',
                    icon: LucideIcons.externalLink,
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
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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
                        fontSize: 8,
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
                        fontSize: 8,
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
        LucideIcons.dollarSign,
        _gold,
      ),
      _FundData(
        'MAM Manager Funds',
        'Capital under management',
        '0.0%',
        '\$0',
        LucideIcons.chartColumn,
        _blue,
      ),
      _FundData(
        'MAM Investor Funds',
        'Allocated to managed pools',
        '0.0%',
        '\$0',
        LucideIcons.wallet,
        Color(0xFF16C9A6),
      ),
      _FundData(
        'IB Earnings (Available)',
        'Withdrawable commission',
        '0.0%',
        '\$0',
        LucideIcons.chartNoAxesColumn,
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
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                fund.percentage,
                style: TextStyle(
                  color: fund.color,
                  fontSize: 8,
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
              const Icon(LucideIcons.chevronRight, color: _muted, size: 13),
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
              _IconTile(icon: LucideIcons.usersRound),
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
              Icon(LucideIcons.share2, size: 13, color: _muted),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(LucideIcons.chevronDown, color: _muted, size: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {},
            iconAlignment: IconAlignment.end,
            icon: const Icon(LucideIcons.arrowRight, size: 12),
            label: const Text('View partnership dashboard'),
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(34),
              textStyle: const TextStyle(
                fontSize: 10,
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
              const _IconTile(icon: LucideIcons.receiptText),
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
                    LucideIcons.receiptText,
                    size: 16,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Nothing to show just yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
          fontSize: 8,
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
              fontSize: 9,
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
      icon: LucideIcons.circle,
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
          const Icon(LucideIcons.info, color: _muted, size: 11),
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
              fontSize: 9,
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
        fontSize: 9,
        letterSpacing: 0.6,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
