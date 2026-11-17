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
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(wide ? 24 : 16, wide ? 24 : 16, wide ? 24 : 16, 110),
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
                        showAppToast('Portfolio is up to date.', type: NotchToastType.success);
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
                    fontSize: 8,
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
                          fontSize: 9,
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
