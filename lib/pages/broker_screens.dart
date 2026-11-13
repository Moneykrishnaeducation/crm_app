part of '../main.dart';

const _brokerNavy = Color(0xFF06163B);
const _brokerPanel = Color(0xFF0B2452);
const _brokerBlue = Color(0xFF0875F5);
const _brokerGold = Color(0xFFF4C84A);
const _brokerMuted = Color(0xFFA9B9D5);

class BrokerDashboardPage extends StatelessWidget {
  const BrokerDashboardPage({super.key, required this.balanceVisible, required this.onToggleBalance, required this.onSelectPage});
  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) => Container(
    color: _brokerNavy,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Good Morning,', style: TextStyle(color: Color(0xFFB9D5FF), fontSize: 13)),
        const SizedBox(height: 2),
        const Text('Admin', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        _BrokerBalance(visible: balanceVisible, onToggle: onToggleBalance),
        const SizedBox(height: 13),
        Row(children: [
          Expanded(child: _BrokerMetric(icon: LucideIcons.userRound, label: 'Live Accounts', value: '1,825', accent: const Color(0xFF23C8E8))),
          const SizedBox(width: 10),
          const Expanded(child: _BrokerMetric(icon: LucideIcons.monitor, label: 'Demo Accounts', value: '588', accent: _brokerBlue)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Expanded(child: _BrokerMetric(icon: LucideIcons.arrowDownLeft, label: 'Total Deposits', value: '\$125.8K', accent: Color(0xFF29D582))),
          const SizedBox(width: 10),
          const Expanded(child: _BrokerMetric(icon: LucideIcons.layers, label: 'MAM / Managed Funds', value: '\$42.5K', accent: _brokerGold)),
        ]),
        const SizedBox(height: 13),
        Row(children: [
          _BrokerShortcut(icon: LucideIcons.wallet, label: 'Deposit Funds', selected: true, onTap: () => onSelectPage('Deposit')),
          _BrokerShortcut(icon: LucideIcons.upload, label: 'Withdraw', onTap: () => onSelectPage('Transactions')),
          _BrokerShortcut(icon: LucideIcons.arrowLeftRight, label: 'Internal Transfer', onTap: () => onSelectPage('Internal Transfer')),
          _BrokerShortcut(icon: LucideIcons.circlePlus, label: 'Open Account', onTap: () => onSelectPage('Trading Accounts')),
        ]),
        const SizedBox(height: 14),
        const _BrokerFundsPanel(),
        const SizedBox(height: 14),
        _TodayActivity(onSelect: onSelectPage),
      ]),
    ),
  );
}

class _BrokerBalance extends StatelessWidget {
  const _BrokerBalance({required this.visible, required this.onToggle});
  final bool visible; final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 14, 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(colors: [Color(0xFF064FB7), Color(0xFF087AF6), Color(0xFF123D9A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      border: Border.all(color: const Color(0xFF4E9AFF)),
      boxShadow: const [BoxShadow(color: Color(0x550875F5), blurRadius: 20, offset: Offset(0, 7))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text('Total Real Balance', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)), IconButton(onPressed: onToggle, visualDensity: VisualDensity.compact, icon: Icon(visible ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.white, size: 19)), const Spacer(), const _LiveUsdBadge()]),
      Text(visible ? '\$125,800.00' : '••••••••', style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      const Text('Real-time consolidated balance', style: TextStyle(color: Colors.white, fontSize: 11)),
      const Text('with instant cross-asset margin allocation.', style: TextStyle(color: Colors.white, fontSize: 11)),
    ]),
  );
}
class _LiveUsdBadge extends StatelessWidget {
  const _LiveUsdBadge();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xCC031638), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x553EA0FF))), child: const Row(children: [Icon(LucideIcons.circle, color: Color(0xFF49E88E), size: 8), SizedBox(width: 5), Text('Live USD', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))]));
}
class _BrokerMetric extends StatelessWidget {
  const _BrokerMetric({required this.icon, required this.label, required this.value, required this.accent});
  final IconData icon; final String label, value; final Color accent;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: _brokerPanel, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF164A91))), child: Row(children: [Container(width: 35, height: 35, decoration: BoxDecoration(color: accent.withValues(alpha: .15), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 18)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))]))]));
}
class _BrokerShortcut extends StatelessWidget {
  const _BrokerShortcut({required this.icon, required this.label, required this.onTap, this.selected = false});
  final IconData icon; final String label; final VoidCallback onTap; final bool selected;
  @override
  Widget build(BuildContext context) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(height: 76, padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 9), decoration: BoxDecoration(gradient: selected ? const LinearGradient(colors: [Color(0xFFFFE88A), _brokerGold]) : null, color: selected ? null : _brokerPanel, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? const Color(0xFFFFE98C) : const Color(0xFF1455A7))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: selected ? _brokerNavy : const Color(0xFF65D9FF), size: 22), const SizedBox(height: 5), Text(label, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(color: selected ? _brokerNavy : Colors.white, fontSize: 8, fontWeight: FontWeight.w600))])))));
}

class _BrokerFundsPanel extends StatelessWidget {
  const _BrokerFundsPanel();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFF081B40), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFF143C78))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Row(children: [Icon(LucideIcons.chartNoAxesColumn, color: Color(0xFF63D5FF), size: 19), SizedBox(width: 8), Text('Your Funds', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))]),
    const Padding(padding: EdgeInsets.only(left: 27, top: 2), child: Text('Portfolio allocation & capital distribution', style: TextStyle(color: _brokerMuted, fontSize: 9))),
    const SizedBox(height: 10),
    Row(children: [SizedBox(width: 112, height: 112, child: CustomPaint(painter: _FundDonutPainter(), child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('TOTAL FUNDS', style: TextStyle(color: Colors.white70, fontSize: 8)), SizedBox(height: 3), Text('\$125.8K', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)), Text('ALLOCATED', style: TextStyle(color: Color(0xFF4BE6A2), fontSize: 8))])))), const SizedBox(width: 12), const Expanded(child: Column(children: [ _FundLegend(color: Color(0xFF25C7F5), label: 'Client Deposits', value: '74%'), SizedBox(height: 9), _FundLegend(color: _brokerGold, label: 'IB Earnings', value: '18%'), SizedBox(height: 9), _FundLegend(color: Color(0xFF36D77F), label: 'Other Funds', value: '8%')]))]),
  ]));
}
class _FundLegend extends StatelessWidget {
  const _FundLegend({required this.color, required this.label, required this.value});
  final Color color; final String label, value;
  @override
  Widget build(BuildContext context) => Row(children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 7), Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9))), Text(value, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))]);
}
class _FundDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final sections = [(const Color(0xFF25C7F5), 4.65), (_brokerGold, 1.13), (const Color(0xFF36D77F), .5)];
    var start = -1.5708;
    for (final section in sections) {
      final paint = Paint()..color = section.$1..style = PaintingStyle.stroke..strokeWidth = 12;
      canvas.drawArc(rect.deflate(7), start, section.$2, false, paint);
      start += section.$2 + .04;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _TodayActivity extends StatelessWidget {
  const _TodayActivity({required this.onSelect}); final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Expanded(child: Text('Recent Transactions', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))), TextButton(onPressed: () => onSelect('Transactions'), child: const Text('View All', style: TextStyle(color: Color(0xFF58B7FF), fontSize: 10)))]),
    Container(decoration: BoxDecoration(color: _brokerPanel, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF164A91))), child: const Column(children: [
      _ActivityTile(icon: LucideIcons.arrowDownLeft, title: 'Deposit', detail: 'Account Funding', amount: '+\$2,500.00', time: '10:30 AM', incoming: true),
      Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFF1B3B68)),
      _ActivityTile(icon: LucideIcons.arrowUpRight, title: 'Withdrawal', detail: 'Payout Request', amount: '-\$850.00', time: '11:15 AM', incoming: false),
    ])),
  ]);
}
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.icon, required this.title, required this.detail, required this.amount, required this.time, required this.incoming});
  final IconData icon; final String title, detail, amount, time; final bool incoming;
  @override
  Widget build(BuildContext context) => ListTile(dense: true, leading: Icon(icon, color: incoming ? const Color(0xFF48E58A) : const Color(0xFFFF746B)), title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)), subtitle: Text(detail, style: const TextStyle(color: _brokerMuted, fontSize: 9)), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(amount, style: TextStyle(color: incoming ? const Color(0xFF48E58A) : const Color(0xFFFF655D), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(time, style: const TextStyle(color: Colors.white, fontSize: 9))]));
}

class BrokerTransactionsPage extends StatelessWidget {
  const BrokerTransactionsPage({super.key});
  @override
  Widget build(BuildContext context) => Container(color: _brokerNavy, child: ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF0A285D), borderRadius: BorderRadius.circular(25), border: Border.all(color: const Color(0xFF174783))), child: const Row(children: [
      _TransactionFilter(label: 'All', selected: true), _TransactionFilter(label: 'Deposits'), _TransactionFilter(label: 'Withdrawals'), _TransactionFilter(label: 'Transfers'),
    ])),
    const SizedBox(height: 20),
    const Text('Today', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
    const _TransactionGroup(items: [
      _TransactionData(LucideIcons.arrowDownLeft, 'Deposit', 'Account Funding', '+\$2,500.00', '10:30 AM', true),
      _TransactionData(LucideIcons.arrowUpRight, 'Withdrawal', 'Payout Request', '-\$850.00', '11:15 AM', false),
    ]),
    const SizedBox(height: 22), const Text('Yesterday', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
    const _TransactionGroup(items: [
      _TransactionData(LucideIcons.arrowLeftRight, 'Internal Transfer', 'Between Accounts', '+\$500.00', '06:20 PM', true),
      _TransactionData(LucideIcons.plus, 'Account Opening', 'New Live Account', '\$0.00', '04:10 PM', null),
    ]),
    const SizedBox(height: 22), const Text('This Month', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 12),
    const _TransactionGroup(items: [_TransactionData(LucideIcons.gift, 'IB Commission', 'Partnership Earnings', '+\$120.00', 'Yesterday', true), _TransactionData(LucideIcons.layers, 'MAM Allocation', 'Fund Allocation', '\$0.00', 'Yesterday', null)]),
  ]));
}
class _TransactionFilter extends StatelessWidget {
  const _TransactionFilter({required this.label, this.selected = false});
  final String label; final bool selected;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: selected ? _brokerGold : Colors.transparent, borderRadius: BorderRadius.circular(20)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? _brokerNavy : Colors.white, fontSize: 9, fontWeight: FontWeight.w700))));
}
class _TransactionData {
  const _TransactionData(this.icon, this.title, this.detail, this.amount, this.time, this.incoming);
  final IconData icon; final String title, detail, amount, time; final bool? incoming;
}
class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({required this.items}); final List<_TransactionData> items;
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: _brokerPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1455A7))), child: Column(children: [for (var i = 0; i < items.length; i++) ...[if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14, color: Color(0xFF1B3B68)), _TransactionTile(data: items[i])]]));
}
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data}); final _TransactionData data;
  @override
  Widget build(BuildContext context) { final color = data.incoming == null ? Colors.white : data.incoming! ? const Color(0xFF4BEA78) : const Color(0xFFFF5C53); return ListTile(leading: Icon(data.icon, color: data.incoming == false ? const Color(0xFFFF746B) : const Color(0xFF59C9FF)), title: Text(data.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)), subtitle: Text(data.detail, style: const TextStyle(color: _brokerMuted, fontSize: 10)), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(data.amount, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(data.time, style: const TextStyle(color: Colors.white, fontSize: 10))])); }
}

class BrokerBottomNavigation extends StatelessWidget {
  const BrokerBottomNavigation({super.key, required this.selectedPage, required this.onSelect});
  final String selectedPage; final ValueChanged<String> onSelect;

  void _showQuickActions(BuildContext context) {
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
            color: _brokerPanel,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFF174783)),
            boxShadow: const [BoxShadow(color: Color(0xAA000817), blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: _brokerMuted.withValues(alpha: .45), borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 18),
              const Text('Quick actions', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _QuickActionRow(icon: LucideIcons.userRoundPlus, title: 'Open live account', onTap: () {
                Navigator.pop(sheetContext);
                showDialog<void>(context: context, builder: (_) => const _OpenLiveAccountDialog());
              }),
              _QuickActionRow(icon: LucideIcons.arrowLeftRight, title: 'Internal transfer', onTap: () {
                Navigator.pop(sheetContext);
                onSelect('Internal Transfer');
              }),
              _QuickActionRow(icon: LucideIcons.monitor, title: 'Create demo account', onTap: () {
                Navigator.pop(sheetContext);
                onSelect('Demo Accounts');
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 18, 14, 4),
              child: CustomPaint(
                painter: _BrokerNavBarPainter(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      _BrokerNavItem(icon: LucideIcons.house, label: 'Dashboard', selected: selectedPage == 'Dashboard', onTap: () => onSelect('Dashboard')),
                      _BrokerNavItem(icon: LucideIcons.receiptText, label: 'Transactions', selected: selectedPage == 'Transactions', onTap: () => onSelect('Transactions')),
                      SizedBox(
                        width: 76,
                        height: 60,
                        child: Center(
                          child: Transform.translate(
                            offset: const Offset(0, -25),
                            child: Material(
                              color: _brokerBlue,
                              shape: const CircleBorder(),
                              elevation: 8,
                              shadowColor: _brokerBlue.withValues(alpha: .5),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _showQuickActions(context),
                                child: const SizedBox(
                                  width: 58,
                                  height: 58,
                                  child: Icon(LucideIcons.plus, color: Colors.white, size: 28),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _BrokerNavItem(icon: LucideIcons.layers, label: 'Accounts', selected: selectedPage == 'Trading Accounts', onTap: () => onSelect('Trading Accounts')),
                      _BrokerNavItem(icon: LucideIcons.grid2x2, label: 'More', selected: selectedPage == 'More', onTap: () => onSelect('More')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _BrokerNavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerRadius = 24.0;
    const r1 = 22.0; // shoulder fillet radius
    const r2 = 36.5; // notch cutout radius
    const cy = 13.0; // vertical center of button/cradle

    final centerX = size.width / 2;
    const d = r1 + r2;
    final dy = (cy - r1).abs();
    final dx = math.sqrt(d * d - dy * dy);

    final c1x = -dx;
    final c1y = r1;

    final tx = c1x + r1 * (0 - c1x) / d;
    final ty = c1y + r1 * (cy - c1y) / d;

    final path = Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(centerX + c1x, 0)
      // Left shoulder curve flowing down into notch
      ..arcToPoint(
        Offset(centerX + tx, ty),
        radius: const Radius.circular(r1),
        clockwise: true,
      )
      // Smooth concave cradle dipping under the + button
      ..arcToPoint(
        Offset(centerX - tx, ty),
        radius: const Radius.circular(r2),
        clockwise: false,
      )
      // Right shoulder curve flowing up into horizontal top edge
      ..arcToPoint(
        Offset(centerX - c1x, 0),
        radius: const Radius.circular(r1),
        clockwise: true,
      )
      // Top-right corner
      ..lineTo(size.width - cornerRadius, 0)
      ..arcToPoint(
        Offset(size.width, cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      // Right edge
      ..lineTo(size.width, size.height - cornerRadius)
      // Bottom-right corner
      ..arcToPoint(
        Offset(size.width - cornerRadius, size.height),
        radius: const Radius.circular(cornerRadius),
      )
      // Bottom edge
      ..lineTo(cornerRadius, size.height)
      // Bottom-left corner
      ..arcToPoint(
        Offset(0, size.height - cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      // Left edge
      ..lineTo(0, cornerRadius)
      // Top-left corner
      ..arcToPoint(
        const Offset(cornerRadius, 0),
        radius: const Radius.circular(cornerRadius),
      )
      ..close();

    // Subtle drop shadow matching the dark theme
    canvas.drawShadow(path, const Color(0x99000817), 16, true);

    // Navbar body fill
    final paint = Paint()
      ..color = const Color(0xFF071B42)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);

    // Outer border stroke
    final borderPaint = Paint()
      ..color = const Color(0xFF1B498C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Material(
          color: const Color(0xFF071B42),
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: SizedBox(
              height: 54,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Icon(icon, color: _brokerBlue, size: 20),
                  const SizedBox(width: 12),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  const Icon(LucideIcons.chevronRight, color: _brokerMuted, size: 17),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      );
}

class _BrokerNavItem extends StatelessWidget {
  const _BrokerNavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon; final String label; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 58,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? _brokerGold.withValues(alpha: .16) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: selected ? 1.08 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(icon, color: selected ? _brokerGold : _brokerMuted, size: 20),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: selected ? _brokerGold : _brokerMuted, fontSize: 8.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
