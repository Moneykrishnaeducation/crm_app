part of '../main.dart';

const _brokerNavy = Color(0xFF10264B);
const _brokerPanel = Colors.white;
const _brokerBlue = Color(0xFF174A8B);
const _brokerGold = Color(0xFFD8A82E);
const _brokerMuted = Color(0xFF71809A);

class BrokerDashboardPage extends StatelessWidget {
  const BrokerDashboardPage({
    super.key,
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onSelectPage,
  });
  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WELCOME BACK', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                    SizedBox(height: 3),
                    Text('Dashboard', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 25, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text('Your trading portfolio at a glance', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerColor)),
                child: Row(children: [const Icon(LucideIcons.activity, color: _brokerGold, size: 13), const SizedBox(width: 5), Text('SYSTEM ONLINE', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .4))]),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _BrokerBalance(visible: balanceVisible, onToggle: onToggleBalance),
          const SizedBox(height: 18),
          const _DashboardSectionHeading(title: 'Account overview', subtitle: 'A summary of your live and demo activity'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _BrokerMetric(
                  icon: LucideIcons.userRound,
                  label: 'Live Accounts',
                  value: '1,825',
                  accent: _brokerBlue,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _BrokerMetric(
                  icon: LucideIcons.monitor,
                  label: 'Demo Accounts',
                  value: '588',
                  accent: _brokerBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: _BrokerMetric(
                  icon: LucideIcons.arrowDownLeft,
                  label: 'Total Deposits',
                  value: '\$125.8K',
                  accent: Color(0xFFD8A82E),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _BrokerMetric(
                  icon: LucideIcons.layers,
                  label: 'MAM / Managed Funds',
                  value: '\$42.5K',
                  accent: _brokerGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _DashboardSectionHeading(title: 'Quick actions', subtitle: 'Move funds and manage your accounts'),
          const SizedBox(height: 10),
          Row(
            children: [
              _BrokerShortcut(
                icon: LucideIcons.wallet,
                label: 'Deposit Funds',
                onTap: () => onSelectPage('Deposit'),
              ),
              _BrokerShortcut(
                icon: LucideIcons.upload,
                label: 'Withdraw',
                onTap: () => onSelectPage('Withdraw'),
              ),
              _BrokerShortcut(
                icon: LucideIcons.arrowLeftRight,
                label: 'Internal Transfer',
                onTap: () => onSelectPage('Internal Transfer'),
              ),
              _BrokerShortcut(
                icon: LucideIcons.circlePlus,
                label: 'Open Account',
                onTap: () => onSelectPage('Open Account'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _BrokerFundsPanel(),
          const SizedBox(height: 18),
          _TodayActivity(onSelect: onSelectPage),
        ],
      ),
    ),
  );
}


class _DashboardSectionHeading extends StatelessWidget {
  const _DashboardSectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -.2)),
      const SizedBox(height: 3),
      Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
    ],
  );
}

class _BrokerBalance extends StatelessWidget {
  const _BrokerBalance({required this.visible, required this.onToggle});
  final bool visible;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 14, 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF143B70), Color(0xFF1B4E8B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: const Color(0xFF315E98)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2210244B),
          blurRadius: 20,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Total portfolio balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: onToggle,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                visible ? LucideIcons.eye : LucideIcons.eyeOff,
                color: Colors.white,
                size: 19,
              ),
            ),
            const Spacer(),
            const _LiveUsdBadge(),
          ],
        ),
        Text(
          visible ? '\$125,800.00' : '••••••••',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'CONSOLIDATED PORTFOLIO VALUE',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
        const Text(
          'Across your connected trading accounts',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    ),
  );
}

class _LiveUsdBadge extends StatelessWidget {
  const _LiveUsdBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xCC031638),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0x553EA0FF)),
    ),
    child: const Row(
      children: [
        Icon(LucideIcons.circle, color: Color(0xFFD8A82E), size: 8),
        SizedBox(width: 5),
        Text(
          'Live USD',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _BrokerMetric extends StatelessWidget {
  const _BrokerMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });
  final IconData icon;
  final String label, value;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x090D2C56),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BrokerShortcut extends StatelessWidget {
  const _BrokerShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 9),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: _brokerBlue,
                size: 22,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BrokerFundsPanel extends StatelessWidget {
  const _BrokerFundsPanel();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).dividerColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x090D2C56),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.chartNoAxesColumn,
              color: Theme.of(context).colorScheme.primary,
              size: 19,
            ),
            SizedBox(width: 8),
            Text(
              'Portfolio allocation',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 27, top: 2),
          child: Text(
            'Understand how your capital is distributed',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 112,
              height: 112,
              child: CustomPaint(
                painter: _FundDonutPainter(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TOTAL FUNDS',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 8),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '\$125.8K',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'ALLOCATED',
                        style: TextStyle(color: Color(0xFFD8A82E), fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                children: [
                  _FundLegend(
                    color: Color(0xFF174A8B),
                    label: 'Client Deposits',
                    value: '74%',
                  ),
                  SizedBox(height: 9),
                  _FundLegend(
                    color: _brokerGold,
                    label: 'IB Earnings',
                    value: '18%',
                  ),
                  SizedBox(height: 9),
                  _FundLegend(
                    color: Color(0xFF8AA8D0),
                    label: 'Other Funds',
                    value: '8%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _FundLegend extends StatelessWidget {
  const _FundLegend({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _FundDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sections = [
      (_brokerBlue, 4.65),
      (_brokerGold, 1.13),
      (const Color(0xFF8AA8D0), .5),
    ];
    var start = -1.5708;
    for (final section in sections) {
      final paint = Paint()
        ..color = section.$1
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12;
      canvas.drawArc(rect.deflate(7), start, section.$2, false, paint);
      start += section.$2 + .04;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TodayActivity extends StatelessWidget {
  const _TodayActivity({required this.onSelect});
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Recent activity',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () => onSelect('Transactions'),
            child: const Text(
              'View all',
              style: TextStyle(color: Color(0xFF174A8B), fontSize: 10),
            ),
          ),
        ],
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            const _ActivityTile(
              icon: LucideIcons.arrowDownLeft,
              title: 'Deposit',
              detail: 'Account Funding',
              amount: '+\$2,500.00',
              time: '10:30 AM',
              incoming: true,
            ),
            Divider(
              height: 1,
              indent: 14,
              endIndent: 14,
              color: Theme.of(context).dividerColor,
            ),
            const _ActivityTile(
              icon: LucideIcons.arrowUpRight,
              title: 'Withdrawal',
              detail: 'Payout Request',
              amount: '-\$850.00',
              time: '11:15 AM',
              incoming: false,
            ),
          ],
        ),
      ),
    ],
  );
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.amount,
    required this.time,
    required this.incoming,
  });
  final IconData icon;
  final String title, detail, amount, time;
  final bool incoming;
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    leading: Icon(
      icon,
      color: incoming ? _brokerGold : _brokerBlue,
    ),
    title: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
    subtitle: Text(
      detail,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9),
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount,
          style: TextStyle(
            color: incoming ? _brokerGold : _brokerBlue,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          time,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9),
        ),
      ],
    ),
  );
}

class BrokerTransactionsPage extends StatefulWidget {
  const BrokerTransactionsPage({super.key});
  @override
  State<BrokerTransactionsPage> createState() => _BrokerTransactionsPageState();
}

class _BrokerTransactionsPageState extends State<BrokerTransactionsPage> {
  String _filter = 'All';
  static const _groups = <(String, List<_TransactionData>)>[
    (
      'Today',
      [
        _TransactionData(
          LucideIcons.arrowDownLeft,
          'Deposit',
          'Account Funding',
          '+\$2,500.00',
          '10:30 AM',
          true,
        ),
        _TransactionData(
          LucideIcons.arrowUpRight,
          'Withdrawal',
          'Payout Request',
          '-\$850.00',
          '11:15 AM',
          false,
        ),
      ],
    ),
    (
      'Yesterday',
      [
        _TransactionData(
          LucideIcons.arrowLeftRight,
          'Internal Transfer',
          'Between Accounts',
          '+\$500.00',
          '06:20 PM',
          true,
        ),
        _TransactionData(
          LucideIcons.plus,
          'Account Opening',
          'New Live Account',
          '\$0.00',
          '04:10 PM',
          null,
        ),
      ],
    ),
    (
      'This Month',
      [
        _TransactionData(
          LucideIcons.gift,
          'IB Commission',
          'Partnership Earnings',
          '+\$120.00',
          'Yesterday',
          true,
        ),
        _TransactionData(
          LucideIcons.layers,
          'MAM Allocation',
          'Fund Allocation',
          '\$0.00',
          'Yesterday',
          null,
        ),
      ],
    ),
  ];

  bool _matches(_TransactionData item) => switch (_filter) {
    'Deposits' => item.title == 'Deposit',
    'Withdrawals' => item.title == 'Withdrawal',
    'Transfers' => item.title == 'Internal Transfer',
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Deposits', 'Withdrawals', 'Transfers'];
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width > 900 ? 860 : 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3E8F0)),
                ),
                child: Row(
                  children: [
                    for (final filter in filters)
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _filter = filter),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _filter == filter
                                  ? const Color(0xFF10284F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              filter,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _filter == filter
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE3E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRANSACTION ACTIVITY',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Your account movements',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2C8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.arrowDownUp,
                        color: Color(0xFF9A7000),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              for (final group in _groups) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      group.$1,
                      style: const TextStyle(
                        color: Color(0xFF10213E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _TransactionGroup(items: group.$2.where(_matches).toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionData {
  const _TransactionData(
    this.icon,
    this.title,
    this.detail,
    this.amount,
    this.time,
    this.incoming,
  );
  final IconData icon;
  final String title, detail, amount, time;
  final bool? incoming;
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({required this.items});
  final List<_TransactionData> items;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E7EF)),
    ),
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Divider(height: 1, indent: 14, endIndent: 14, color: Theme.of(context).dividerColor),
          _TransactionTile(data: items[i]),
        ],
      ],
    ),
  );
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data});
  final _TransactionData data;
  @override
  Widget build(BuildContext context) {
    final color = data.incoming == null
        ? const Color(0xFF10213E)
        : data.incoming!
        ? _brokerGold
        : _brokerBlue;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: data.incoming == false
              ? const Color(0xFFF7F1E2)
              : const Color(0xFFEAF0F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          data.icon,
          color: data.incoming == false
              ? _brokerBlue
              : _brokerBlue,
          size: 19,
        ),
      ),
      title: Text(
        data.title,
        style: const TextStyle(
          color: Color(0xFF10213E),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        data.detail,
        style: const TextStyle(color: Color(0xFF7A8799), fontSize: 10),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            data.amount,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.time,
            style: const TextStyle(color: Color(0xFF8C97A7), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class BrokerBottomNavigation extends StatelessWidget {
  const BrokerBottomNavigation({
    super.key,
    required this.selectedPage,
    required this.onSelect,
  });
  final String selectedPage;
  final ValueChanged<String> onSelect;

  void _showQuickActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F1), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A10264B),
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DFEB),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33389BFF),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quick actions',
                style: TextStyle(
                  color: Color(0xFF10264B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              _QuickActionRow(
                icon: LucideIcons.wallet,
                title: 'Deposit funds',
                subtitle: 'Add money to your account',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Deposit');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.arrowUpRight,
                title: 'Withdraw funds',
                subtitle: 'Transfer funds to your bank',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Withdraw');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.userRoundPlus,
                title: 'Open live account',
                subtitle: 'Start trading with real capital',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Open Account');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.arrowLeftRight,
                title: 'Internal transfer',
                subtitle: 'Move balance between accounts',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Internal Transfer');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.monitor,
                title: 'Create demo account',
                subtitle: 'Practice strategies risk-free',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Demo Accounts');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 7),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              margin: const EdgeInsets.fromLTRB(18, 2, 18, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.35 : 0.10,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xEA0E1A2E)
                          : const Color(0xEAFFFFFF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x33475569)
                            : const Color(0x66CBD5E1),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _BrokerNavItem(
                          icon: LucideIcons.house,
                          label: 'Home',
                          selected: selectedPage == 'Dashboard',
                          onTap: () => onSelect('Dashboard'),
                        ),
                        _BrokerNavItem(
                          icon: LucideIcons.receiptText,
                          label: 'Activity',
                          selected: selectedPage == 'Transactions',
                          onTap: () => onSelect('Transactions'),
                        ),
                        SizedBox(
                          width: 62,
                          height: 54,
                          child: Center(
                            child: Transform.translate(
                              offset: const Offset(0, -9),
                              child: _CenterQuickActionButton(
                                onTap: () => _showQuickActions(context),
                              ),
                            ),
                          ),
                        ),
                        _BrokerNavItem(
                          icon: LucideIcons.layers,
                          label: 'Accounts',
                          selected: selectedPage == 'Trading Accounts',
                          onTap: () => onSelect('Trading Accounts'),
                        ),
                        _BrokerNavItem(
                          icon: LucideIcons.grid2x2,
                          label: 'More',
                          selected: selectedPage == 'More',
                          onTap: () => onSelect('More'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterQuickActionButton extends StatefulWidget {
  const _CenterQuickActionButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CenterQuickActionButton> createState() => _CenterQuickActionButtonState();
}

class _CenterQuickActionButtonState extends State<_CenterQuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTap();
          },
          child: AnimatedScale(
            scale: _isPressed ? .93 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _brokerNavy,
                shape: BoxShape.circle,
                border: Border.all(color: _brokerGold, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2610244B),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(LucideIcons.plus, color: _brokerGold, size: 25),
              ),
            ),
          ),
        ),
      );
}

class _QuickActionRow extends StatefulWidget {
  const _QuickActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  State<_QuickActionRow> createState() => _QuickActionRowState();
}

class _QuickActionRowState extends State<_QuickActionRow> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isPressed || _isHovered;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFF2F6FC)
                  : const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFB9CEE9)
                    : const Color(0xFFE7EDF5),
                width: 1,
              ),
              boxShadow: isActive
                  ? const [
                      BoxShadow(
                        color: Color(0x220875F5),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isActive
                          ? const [Color(0x44389BFF), Color(0x280875F5)]
                          : const [Color(0x260875F5), Color(0x1A0875F5)],
                    ),
                    border: Border.all(
                      color: isActive
                          ? const Color(0x665CABFF)
                          : const Color(0x334B96FF),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: isActive
                          ? const Color(0xFF174A8B)
                          : const Color(0xFF5279A9),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFF10264B),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: const TextStyle(
                            color: Color(0xFF71809A),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedSlide(
                  offset: isActive ? const Offset(0.08, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    LucideIcons.chevronRight,
                    color: isActive
                        ? const Color(0xFF174A8B)
                        : const Color(0xFF9AA9BC),
                    size: 18,
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

class _BrokerNavItem extends StatelessWidget {
  const _BrokerNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: RepaintBoundary(
          child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: Tooltip(
            message: label,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: _brokerGold.withValues(alpha: .12),
              highlightColor: _brokerBlue.withValues(alpha: .05),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minHeight: 54),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? _brokerBlue.withValues(alpha: .07)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selected
                        ? _brokerBlue.withValues(alpha: .12)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.08 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        icon,
                        color: selected ? _brokerBlue : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? _brokerBlue : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 9.5,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 15 : 4,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: selected ? _brokerGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
}
