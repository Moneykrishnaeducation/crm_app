part of '../main.dart';

class BrokerAccountsPage extends StatefulWidget {
  const BrokerAccountsPage({super.key, required this.onSelectPage, required this.accounts, required this.onAccountCreated, required this.onAccountSelected});
  final ValueChanged<String> onSelectPage;
  final List<BrokerAccount> accounts;
  final ValueChanged<BrokerAccount> onAccountCreated;
  final ValueChanged<BrokerAccount> onAccountSelected;
  @override
  State<BrokerAccountsPage> createState() => _BrokerAccountsPageState();
}

class _BrokerAccountsPageState extends State<BrokerAccountsPage> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const navy = Color(0xFF071629);
    const panel = Color(0xFF101F34);
    const gold = Color(0xFFFFC533);
    const blue = Color(0xFF35A9F5);
    const green = Color(0xFF08D879);
    const red = Color(0xFFFF6268);
    final all = widget.accounts;
    final liveCount = all.where((a) => a.type == 'Live MT5').length;
    final demoCount = all.length - liveCount;
    final filtered = all.where((a) {
      final q = _query.trim().toLowerCase();
      final matchText = q.isEmpty || a.login.toLowerCase().contains(q) || a.name.toLowerCase().contains(q) || a.type.toLowerCase().contains(q);
      final matchFilter = _filter == 'All' || (_filter == 'Live' && a.type == 'Live MT5') || (_filter == 'Demo' && a.type != 'Live MT5');
      return matchText && matchFilter;
    }).toList();
    final totalBalance = all.fold<double>(0, (sum, a) => sum + (double.tryParse(a.balance.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0));
    final surface = dark ? panel : Colors.white;
    final border = dark ? const Color(0xFF29415F) : const Color(0xFFD9E2EE);
    final text = dark ? const Color(0xFFF5F7FC) : const Color(0xFF10213A);
    final muted = dark ? const Color(0xFFA9B9CE) : const Color(0xFF6F7F95);

    Widget filter(String label, String value, String count, {Color? dot}) {
      final selected = _filter == value;
      return Expanded(child: InkWell(
        onTap: () => setState(() => _filter = value),
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          decoration: BoxDecoration(
            color: selected ? gold : surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: selected ? gold : border, width: 1.2),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (dot != null) ...[Container(width: 9, height: 9, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)), const SizedBox(width: 6)],
            Text('$label ($count)', style: TextStyle(color: selected ? const Color(0xFF101A29) : text, fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
        ),
      ));
    }

    return Container(
      color: dark ? navy : Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 126),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ACCOUNTS', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              const SizedBox(height: 5),
              Text('Trading Accounts', style: TextStyle(color: text, fontSize: 26, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.65)),
              const SizedBox(height: 5),
              Text('Manage your live and demo trading accounts', style: TextStyle(color: muted, fontSize: 12, height: 1.35)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: border)), child: Row(children: [
              const Icon(LucideIcons.walletCards, color: blue, size: 15), const SizedBox(width: 6),
              Text('${all.length} Accounts', style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.w800)),
            ])),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            filter('All', 'All', '${all.length}'),
            const SizedBox(width: 8),
            filter('Live', 'Live', '$liveCount', dot: green),
            const SizedBox(width: 8),
            filter('Demo', 'Demo', '$demoCount', dot: blue),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: text, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search by account number, name...',
                hintStyle: TextStyle(color: muted, fontSize: 11),
                prefixIcon: Icon(LucideIcons.search, color: muted, size: 19),
                filled: true, fillColor: surface, isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: blue, width: 1.3)),
              ),
            )),
            const SizedBox(width: 9),
            Container(width: 48, height: 46, decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)), child: IconButton(
              tooltip: 'Filter accounts',
              onPressed: () => setState(() { _filter = _filter == 'All' ? 'Live' : _filter == 'Live' ? 'Demo' : 'All'; }),
              icon: Icon(LucideIcons.slidersHorizontal, color: text, size: 19),
            )),
          ]),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            _AccountEmptyState(searching: _query.isNotEmpty || _filter != 'All', onClear: () { _searchController.clear(); setState(() { _query = ''; _filter = 'All'; }); }, onOpen: () => showDialog<void>(context: context, builder: (_) => _OpenLiveAccountDialog(onCreated: widget.onAccountCreated)))
          else
            ...filtered.map((account) => _ReferenceAccountCard(
              account: account,
              selected: all.isNotEmpty && account.login == all.first.login,
              onTap: () => widget.onAccountSelected(account),
            )),
          const SizedBox(height: 5),
          SizedBox(height: 52, child: FilledButton.icon(
            onPressed: () => showDialog<void>(context: context, builder: (_) => _OpenLiveAccountDialog(onCreated: widget.onAccountCreated)),
            style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF101A29), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
            icon: const Icon(LucideIcons.plusCircle, size: 20),
            label: const Text('Open New Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          )),
          const SizedBox(height: 7),
          Text('Combined balance  ${all.isEmpty ? '—' : String.fromCharCode(36) + totalBalance.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 9)),
        ],
      ),
    );
  }
}


class _ReferenceAccountCard extends StatelessWidget {
  const _ReferenceAccountCard({required this.account, required this.selected, required this.onTap});
  final BrokerAccount account;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    const gold = Color(0xFFFFC533);
    const blue = Color(0xFF39B5FF);
    const green = Color(0xFF08D879);
    const red = Color(0xFFFF6268);
    final live = account.type == 'Live MT5';
    final pnl = account.floatingPnl ?? 0;
    final pnlColor = pnl > 0 ? green : pnl < 0 ? red : (dark ? Colors.white : const Color(0xFF10213A));
    final bg = dark ? const Color(0xFF101F34) : Colors.white;
    final fg = dark ? const Color(0xFFF5F7FC) : const Color(0xFF10213A);
    final muted = dark ? const Color(0xFFA9B9CE) : const Color(0xFF718096);
    final border = selected ? gold : (dark ? const Color(0xFF29415F) : const Color(0xFFD9E2EE));
    final equity = account.equityHistory.isNotEmpty ? account.equityHistory : <double>[1, 1.1, 1.04, 1.2, 1.13, 1.3, 1.26, 1.4];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: border, width: selected ? 1.8 : 1.2),
              boxShadow: selected && dark ? [BoxShadow(color: gold.withValues(alpha: .13), blurRadius: 13, spreadRadius: 1)] : null,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF163D70), borderRadius: BorderRadius.circular(14)), child: const Icon(LucideIcons.chartNoAxesColumnIncreasing, color: blue, size: 25)),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _AccountPill(label: live ? 'Live' : 'Demo', color: live ? const Color(0xFF0B9E55) : const Color(0xFF4C91E8), foreground: Colors.white),
                    const SizedBox(width: 6),
                    const _AccountPill(label: 'MT5', color: Color(0xFF315D86), foreground: Colors.white),
                    const SizedBox(width: 9),
                    Flexible(child: Text(account.login, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 18, fontWeight: FontWeight.w800))),
                  ]),
                  const SizedBox(height: 7),
                  Text('${account.name}  •  ${account.leverage}', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w500)),
                ])),
                SizedBox(width: 82, height: 42, child: CustomPaint(painter: _AccountSparkPainter(values: equity, color: pnl < 0 ? red : live ? green : const Color(0xFF78A9DC)))),
                const SizedBox(width: 5),
                Icon(selected ? Icons.star : Icons.star_border, color: selected ? gold : muted, size: 22),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _ReferenceMetric(label: 'Balance', value: account.balance, color: fg, muted: muted)),
                Container(width: 1, height: 35, color: dark ? const Color(0xFF29415F) : const Color(0xFFE0E7F0)),
                Expanded(child: _ReferenceMetric(label: 'Equity', value: account.equity, color: fg, muted: muted)),
                Container(width: 1, height: 35, color: dark ? const Color(0xFF29415F) : const Color(0xFFE0E7F0)),
                Expanded(child: _ReferenceMetric(label: 'P/L', value: account.floatingPnl == null ? '—' : (pnl > 0 ? '+' : pnl < 0 ? '-' : '') + r'$' + pnl.abs().toStringAsFixed(2), color: pnlColor, muted: muted)),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

class _AccountPill extends StatelessWidget {
  const _AccountPill({required this.label, required this.color, required this.foreground});
  final String label;
  final Color color;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
    child: Text(label, style: TextStyle(color: foreground, fontSize: 10, fontWeight: FontWeight.w800)),
  );
}

class _ReferenceMetric extends StatelessWidget {
  const _ReferenceMetric({required this.label, required this.value, required this.color, required this.muted});
  final String label, value;
  final Color color, muted;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w500)),
      const SizedBox(height: 5),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800))),
    ]),
  );
}

class _AccountSparkPainter extends CustomPainter {
  const _AccountSparkPainter({required this.values, required this.color});
  final List<double> values;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.isEmpty) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < .000001 ? 1.0 : maxV - minV;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - 3 - ((values[i] - minV) / range) * (size.height - 7);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 1.8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }
  @override
  bool shouldRepaint(covariant _AccountSparkPainter old) => old.values != values || old.color != color;
}

class _AccountEmptyState extends StatelessWidget {
  const _AccountEmptyState({required this.searching, required this.onClear, required this.onOpen});
  final bool searching;
  final VoidCallback onClear;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)),
    child: Column(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFEFF5FC), borderRadius: BorderRadius.circular(16)), child: const Icon(LucideIcons.wallet, color: _brokerBlue, size: 23)),
      const SizedBox(height: 12),
      Text(searching ? 'No matching accounts' : 'No trading accounts yet', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(searching ? 'Try another account name or login ID.' : 'Open a live account to start managing your trading activity.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, height: 1.5)),
      const SizedBox(height: 14),
      if (searching) OutlinedButton(onPressed: onClear, child: const Text('Clear filters')) else FilledButton.icon(onPressed: onOpen, icon: const Icon(LucideIcons.plus, size: 15), label: const Text('Open account')),
    ]),
  );
}

class BrokerAccount {
  const BrokerAccount(this.name, this.login, this.leverage, this.balance, this.equity, this.type, {
    this.server, this.currency = 'USD', this.floatingPnl,
    this.equityHistory = const [], this.openPositions = const [], this.recentTrades = const [],
  });
  final String name, login, leverage, balance, equity, type;
  final String? server;
  final String currency;
  final double? floatingPnl;
  final List<double> equityHistory;
  final List<BrokerOpenPosition> openPositions;
  final List<BrokerTradeRecord> recentTrades;
}
class BrokerOpenPosition {
  const BrokerOpenPosition({required this.symbol, required this.side, required this.volume, required this.openPrice, required this.currentPrice, required this.profit});
  final String symbol, side, volume, openPrice, currentPrice;
  final double profit;
}
class BrokerTradeRecord {
  const BrokerTradeRecord({required this.symbol, required this.side, required this.volume, required this.closedAt, required this.profit});
  final String symbol, side, volume, closedAt;
  final double profit;
}

class _OpenLiveAccountDialog extends StatefulWidget {
  const _OpenLiveAccountDialog({required this.onCreated});
  final ValueChanged<BrokerAccount> onCreated;
  @override
  State<_OpenLiveAccountDialog> createState() => _OpenLiveAccountDialogState();
}

class _OpenLiveAccountDialogState extends State<_OpenLiveAccountDialog> {
  final _nameController = TextEditingController(text: 'Mohanprasath R');
  final _masterPassword = TextEditingController();
  final _investorPassword = TextEditingController();
  String _group = 'VIP - Recommended (Default)';
  String _leverage = '1:500';

  @override
  void dispose() {
    _nameController.dispose();
    _masterPassword.dispose();
    _investorPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: SizedBox(
        width: 420,
        height: (screen.height * .84).clamp(400.0, 700.0).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1766C8)),
            boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 26, offset: Offset(0, 12))],
          ),
          child: Column(children: [
            _dialogHeader(),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _sectionLabel('ACCOUNT NAME', required: true),
              const SizedBox(height: 5),
              _textInput(_nameController, hint: 'Enter account name', prefix: LucideIcons.userRound),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: _sectionLabel('TRADING GROUP', required: true)), const Text('VIP', style: TextStyle(color: Color(0xFF5DB5FF), fontSize: 9, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 5),
              _groupPicker(),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: _sectionLabel('ACCOUNT LEVERAGE', required: true)), const Text('MAX 1:500', style: TextStyle(color: _brokerGold, fontSize: 9, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 6),
              _leverageSelector(),
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(9), border: Border.all(color: Theme.of(context).dividerColor)), child: Row(children: [Expanded(child: Text('Custom Leverage: 1:500', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 9, fontWeight: FontWeight.w600))), Text('Selected:  $_leverage', style: TextStyle(color: _brokerGold, fontSize: 9, fontWeight: FontWeight.w700))])),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: Theme.of(context).dividerColor)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(LucideIcons.info, color: Color(0xFF64B9FF), size: 15), SizedBox(width: 7), Expanded(child: Text('SECURITY NOTICE: Master password executes trades; Investor password provides read-only monitoring.', style: TextStyle(color: _brokerMuted, fontSize: 9, height: 1.35)))])),
              const SizedBox(height: 12),
              _sectionLabel('MASTER PASSWORD', required: true, trailing: 'FULL TRADING CONTROL'),
              const SizedBox(height: 5),
              _PasswordInput(controller: _masterPassword),
              const SizedBox(height: 10),
              _sectionLabel('INVESTOR PASSWORD', required: true, trailing: 'READ-ONLY (MONITORING)'),
              const SizedBox(height: 5),
              _PasswordInput(controller: _investorPassword),
            ]))),
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: SizedBox(width: double.infinity, height: 42, child: FilledButton.icon(onPressed: _createAccount, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF174A8B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))), icon: const Icon(LucideIcons.arrowRight, size: 16), label: const Text('CREATE LIVE ACCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .5))))),
            Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: const BoxDecoration(color: Color(0xFF06132C), borderRadius: BorderRadius.vertical(bottom: Radius.circular(17))), child: Row(children: [Icon(LucideIcons.shieldCheck, color: Color(0xFF10D6B2), size: 14), SizedBox(width: 6), Text('SECURE MT5', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)), Spacer(), Icon(LucideIcons.zap, color: Color(0xFF45A8FF), size: 15), SizedBox(width: 5), Text('INSTANT SETUP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)), Spacer(), Icon(LucideIcons.lockKeyhole, color: Color(0xFF45A8FF), size: 14), SizedBox(width: 5), Text('REGULATED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))])),
          ]),
        ),
      ),
    );
  }

  Widget _dialogHeader() => Container(padding: const EdgeInsets.fromLTRB(16, 12, 10, 10), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1A2D55)))), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF3478FF)), borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.wallet, color: Color(0xFF5EA3FF), size: 19)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Open Live Account', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w800)), SizedBox(height: 3), Row(children: [Icon(LucideIcons.circle, color: Color(0xFF00D98A), size: 7), SizedBox(width: 5), Text('Live MT5 Engine', style: TextStyle(color: Color(0xFF00D98A), fontSize: 8, fontWeight: FontWeight.w700)), SizedBox(width: 8), Text('â€¢  Direct STP Execution', style: TextStyle(color: _brokerMuted, fontSize: 8))])])), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: _brokerMuted, size: 18), visualDensity: VisualDensity.compact)]));

  Widget _sectionLabel(String label, {bool required = false, String? trailing}) => Row(children: [Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .2)), if (required) const Padding(padding: EdgeInsets.only(left: 5), child: Text('*', style: TextStyle(color: Color(0xFFFF5867), fontSize: 10, fontWeight: FontWeight.w800))), const Spacer(), if (trailing != null) Text(trailing, style: const TextStyle(color: Color(0xFF59AFFF), fontSize: 8, fontWeight: FontWeight.w700))]);

  Widget _textInput(TextEditingController controller, {required String hint, required IconData prefix}) => TextField(controller: controller, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w600), decoration: _inputDecoration(hint, prefix));

  InputDecoration _inputDecoration(String hint, IconData prefix) => InputDecoration(prefixIcon: Icon(prefix, size: 16, color: const Color(0xFF5E8BD5)), hintText: hint, hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), filled: true, fillColor: const Color(0xFFFFFFFF), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).dividerColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3478FF))));

  Widget _groupPicker() => Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: Theme.of(context).dividerColor)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _group, isExpanded: true, dropdownColor: _brokerPanel, iconEnabledColor: _brokerMuted, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.w600), items: const [DropdownMenuItem(value: 'VIP - Recommended (Default)', child: Text('VIP - Recommended (Default)')), DropdownMenuItem(value: 'Standard', child: Text('Standard')), DropdownMenuItem(value: 'ECN', child: Text('ECN'))], onChanged: (value) { if (value != null) setState(() => _group = value); })));

  Widget _leverageSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          for (final value in const ['1:100', '1:200', '1:500'])
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _leverage = value),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: _leverage == value
                        ? const Color(0xFF3E5EF0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    value == '1:500' ? '$value (Max)' : value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _leverage == value ? _brokerNavy : _brokerMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _createAccount() {
    final accountName = _nameController.text.trim();
    if (accountName.isEmpty || _masterPassword.text.isEmpty || _investorPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an account name and both passwords to continue.')));
      return;
    }
    final login = '34${DateTime.now().millisecondsSinceEpoch.remainder(100000)}';
    widget.onCreated(BrokerAccount('XRSIM-USD-$login', login, _leverage, '\$0.00', '\$0.00', 'Live MT5'));
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('Live account $login created.')));
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput({required this.controller});
  final TextEditingController controller;
  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}
class _PasswordInputState extends State<_PasswordInput> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => TextField(controller: widget.controller, obscureText: !_visible, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11), decoration: InputDecoration(prefixIcon: const Icon(LucideIcons.lockKeyhole, size: 15, color: Color(0xFF5E8BD5)), suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () {}, icon: Icon(LucideIcons.copy, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant), visualDensity: VisualDensity.compact), IconButton(onPressed: () {}, icon: Icon(LucideIcons.refreshCw, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant), visualDensity: VisualDensity.compact), IconButton(onPressed: () => setState(() => _visible = !_visible), icon: Icon(_visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant), visualDensity: VisualDensity.compact)]), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), filled: true, fillColor: const Color(0xFFFFFFFF), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).dividerColor)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3478FF)))));
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({required this.icon, required this.label, required this.onTap, this.highlighted = false});
  final IconData icon; final String label; final VoidCallback onTap; final bool highlighted;
  @override
  Widget build(BuildContext context) => Expanded(child: SizedBox(height: 38, child: FilledButton.icon(
    onPressed: onTap,
    style: FilledButton.styleFrom(backgroundColor: highlighted ? _brokerGold : const Color(0xFFFFFFFF), foregroundColor: highlighted ? _brokerNavy : _brokerNavy, padding: const EdgeInsets.symmetric(horizontal: 4), side: BorderSide(color: highlighted ? const Color(0xFFFFE991) : const Color(0xFFE2E8F1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
    icon: Icon(icon, size: 14),
    label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))),
  )));
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.icon, required this.title, required this.value, required this.detail, required this.accent});
  final IconData icon; final String title, value, detail; final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    height: 83,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: Theme.of(context).dividerColor)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: accent, size: 15), const SizedBox(width: 4), Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 8)))]),
      const SizedBox(height: 5),
      FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w700))),
      const Spacer(),
      Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 6)),
    ]),
  );
}

class _AccountFilter extends StatelessWidget {
  const _AccountFilter({required this.label, required this.count, required this.selected, required this.onTap});
  final String label, count; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? _brokerNavy : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selected ? _brokerNavy : const Color(0xFFE2E8F1)),
      ),
      child: Row(children: [
        Text(label, style: TextStyle(color: selected ? Colors.white : _brokerNavy, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: selected ? Colors.white.withValues(alpha: .16) : const Color(0xFFF0F4F9), borderRadius: BorderRadius.circular(10)),
          child: Text(count, style: TextStyle(color: selected ? Colors.white : _brokerMuted, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
      ]),
    ),
  );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.onTap, required this.onDeposit});
  final BrokerAccount account; final VoidCallback onTap; final VoidCallback onDeposit;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final live = account.type == 'Live MT5';
    return Padding(padding: const EdgeInsets.only(bottom: 11), child: Material(
      color: cs.surface, borderRadius: BorderRadius.circular(18),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(13)), child: Icon(LucideIcons.chartNoAxesCombined, color: cs.primary, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(account.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: live ? const Color(0xFF20B981) : const Color(0xFF3998F5), shape: BoxShape.circle)),
                const SizedBox(width: 5), Text(account.type, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9)),
                const SizedBox(width: 8), Text('MT5', style: TextStyle(color: cs.primary, fontSize: 9, fontWeight: FontWeight.w800)),
              ]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('LOGIN ID', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 7, letterSpacing: .7)),
              const SizedBox(height: 3), Text(account.login, style: TextStyle(color: cs.onSurface, fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(width: 5), Icon(LucideIcons.chevronRight, color: cs.onSurfaceVariant, size: 17),
          ]),
          const SizedBox(height: 14), Container(height: 1, color: Theme.of(context).dividerColor), const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _AccountValue(label: 'BALANCE', value: account.balance)),
            Expanded(child: _AccountValue(label: 'EQUITY', value: account.equity, green: true)),
            Expanded(child: _AccountValue(label: 'LEVERAGE', value: account.leverage)),
          ]),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: onTap, style: OutlinedButton.styleFrom(foregroundColor: cs.primary, side: BorderSide(color: Theme.of(context).dividerColor), minimumSize: const Size(0, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))), child: const Text('View details', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 8),
            Expanded(child: FilledButton.icon(onPressed: onDeposit, style: FilledButton.styleFrom(backgroundColor: _brokerGold, foregroundColor: _brokerNavy, minimumSize: const Size(0, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))), icon: const Icon(LucideIcons.arrowDownToLine, size: 14), label: const Text('Deposit', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)))),
          ]),
        ]),
      )),
    ));
  }
}

class _AccountValue extends StatelessWidget {
  const _AccountValue({required this.label, required this.value, this.green = false});
  final String label, value; final bool green;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: .5)),
      const SizedBox(height: 5),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: green ? const Color(0xFF20B981) : cs.onSurface, fontSize: 11, fontWeight: FontWeight.w800)),
    ]);
  }
}

class _AccountTable extends StatelessWidget {
  const _AccountTable({required this.accounts, required this.onSelect});
  final List<BrokerAccount> accounts; final ValueChanged<BrokerAccount> onSelect;
  @override
  Widget build(BuildContext context) => Column(children: [
    for (final account in accounts) _AccountCard(account: account, onTap: () => onSelect(account), onDeposit: () {}),
  ]);
}

class BrokerAccountDetailsPage extends StatefulWidget {
  const BrokerAccountDetailsPage({super.key, required this.account, required this.onBack, required this.onSelectPage});
  final BrokerAccount account;
  final VoidCallback onBack;
  final ValueChanged<String> onSelectPage;
  @override
  State<BrokerAccountDetailsPage> createState() => _BrokerAccountDetailsPageState();
}

class _BrokerAccountDetailsPageState extends State<BrokerAccountDetailsPage> {
  String _tab = 'Overview';
  String _range = '1W';

  String _money(double value) => (value < 0 ? '-' : '') + r'$' + value.abs().toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final a = widget.account;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const navy = Color(0xFF071629);
    const panel = Color(0xFF101F34);
    const gold = Color(0xFFFFC533);
    const blue = Color(0xFF39B5FF);
    const green = Color(0xFF08D879);
    const red = Color(0xFFFF6268);
    final bg = dark ? navy : Theme.of(context).scaffoldBackgroundColor;
    final surface = dark ? panel : Colors.white;
    final border = dark ? const Color(0xFF29415F) : const Color(0xFFD9E2EE);
    final fg = dark ? const Color(0xFFF5F7FC) : const Color(0xFF10213A);
    final muted = dark ? const Color(0xFFA9B9CE) : const Color(0xFF718096);
    final pnl = a.floatingPnl;
    final pnlColor = pnl == null ? muted : pnl >= 0 ? green : red;
    final trades = a.recentTrades;
    final wins = trades.where((t) => t.profit > 0).length;
    final losses = trades.where((t) => t.profit < 0).length;
    final winRate = trades.isEmpty ? 0.0 : wins * 100 / trades.length;
    final totalProfit = trades.fold<double>(0, (sum, t) => sum + t.profit);
    final history = a.equityHistory;
    final rangeCount = switch (_range) { '1D' => 3, '1W' => 5, '1M' => 8, '3M' => 10, 'YTD' => 12, _ => history.length };
    final chartHistory = history.length > rangeCount ? history.sublist(history.length - rangeCount) : history;
    final changePct = chartHistory.length > 1 && chartHistory.first != 0 ? ((chartHistory.last - chartHistory.first) / chartHistory.first) * 100 : 0.0;

    Widget metric(String label, String value, {Color? valueColor}) => Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(color: valueColor ?? fg, fontSize: 17, fontWeight: FontWeight.w800))),
      ]),
    ));

    Widget infoCell(IconData icon, String label, String value) => Expanded(child: Row(children: [
      Icon(icon, color: const Color(0xFF8FB5E0), size: 20),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: muted, fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
      ])),
    ]));

    Widget action(IconData icon, String label, bool primary, VoidCallback onTap) => Expanded(child: SizedBox(
      height: 78,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: primary ? gold : surface,
          foregroundColor: primary ? const Color(0xFF101A29) : fg,
          side: BorderSide(color: primary ? gold : border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 2),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 22), const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ]),
      ),
    ));

    Widget tab(String value) {
      final selected = _tab == value;
      return Expanded(child: InkWell(
        onTap: () => setState(() => _tab = value),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 46,
          decoration: BoxDecoration(color: selected ? gold : Colors.transparent, borderRadius: BorderRadius.circular(11)),
          alignment: Alignment.center,
          child: Text(value, style: TextStyle(color: selected ? const Color(0xFF101A29) : fg, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      ));
    }

    Widget stat(IconData icon, String label, String value, Color accent) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: border)),
      child: Row(children: [
        Container(width: 37, height: 37, decoration: BoxDecoration(color: accent.withValues(alpha: .13), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 19)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: muted, fontSize: 8)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800)),
        ])),
      ]),
    );

    return Container(
      color: bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 126),
        children: [
          Row(children: [
            IconButton(onPressed: widget.onBack, icon: Icon(LucideIcons.arrowLeft, color: fg, size: 23)),
            Expanded(child: Text('Account Details', style: TextStyle(color: fg, fontSize: 20, fontWeight: FontWeight.w800))),
            IconButton(
              tooltip: 'Copy account login',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: a.login));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account login copied')));
              },
              icon: Icon(LucideIcons.share2, color: fg, size: 20),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 12), child: Row(children: [
                Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFF163D70), borderRadius: BorderRadius.circular(14)), child: const Icon(LucideIcons.chartNoAxesColumnIncreasing, color: blue, size: 28)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _AccountPill(label: a.type == 'Live MT5' ? 'Live' : 'Demo', color: a.type == 'Live MT5' ? const Color(0xFF0B9E55) : const Color(0xFF4C91E8), foreground: Colors.white),
                    const SizedBox(width: 7),
                    const _AccountPill(label: 'MT5', color: Color(0xFF315D86), foreground: Colors.white),
                    const SizedBox(width: 9),
                    Text(a.login, style: TextStyle(color: fg, fontSize: 17, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 7),
                  Text('${a.name} Account', style: TextStyle(color: muted, fontSize: 12)),
                ])),
                Icon(LucideIcons.star, color: gold, size: 24),
              ])),
              Padding(padding: const EdgeInsets.fromLTRB(8, 2, 8, 12), child: Row(children: [
                metric('Balance', a.balance),
                Container(width: 1, height: 42, color: border),
                metric('Equity', a.equity),
                Container(width: 1, height: 42, color: border),
                metric('Floating P/L', pnl == null ? '—' : _money(pnl), valueColor: pnlColor),
              ])),
              Container(height: 1, color: border),
              Padding(padding: const EdgeInsets.fromLTRB(13, 12, 13, 12), child: Row(children: [
                infoCell(LucideIcons.scale, 'Leverage', a.leverage),
                Container(width: 1, height: 36, color: border),
                infoCell(LucideIcons.layers, 'Currency', a.currency),
                Container(width: 1, height: 36, color: border),
                infoCell(LucideIcons.server, 'Server', a.server ?? 'Not connected'),
              ])),
            ]),
          ),
          const SizedBox(height: 15),
          Row(children: [
            action(LucideIcons.arrowDown, 'Deposit', true, () => widget.onSelectPage('Deposit')),
            const SizedBox(width: 8),
            action(LucideIcons.arrowUp, 'Withdraw', false, () => widget.onSelectPage('Withdraw')),
            const SizedBox(width: 8),
            action(LucideIcons.arrowLeftRight, 'Transfer', false, () => widget.onSelectPage('Internal Transfer')),
            const SizedBox(width: 8),
            action(LucideIcons.settings, 'Settings', false, () => widget.onSelectPage('Settings')),
          ]),
          const SizedBox(height: 19),
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)), child: Row(children: [tab('Overview'), tab('Trading Stats'), tab('History')])),
          const SizedBox(height: 14),
          if (_tab == 'Overview') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(19), border: Border.all(color: border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(LucideIcons.chartNoAxesColumnIncreasing, color: blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Account Performance', style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w800))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF075B3A), borderRadius: BorderRadius.circular(20)), child: Text('${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(2)}%', style: const TextStyle(color: green, fontSize: 11, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 12),
                if (history.length > 1)
                  SizedBox(height: 120, width: double.infinity, child: CustomPaint(painter: _EquityHistoryPainter(values: chartHistory, color: green, gridColor: border)))
                else
                  SizedBox(height: 112, child: Center(child: Text('Performance history will appear after MT5 sync.', style: TextStyle(color: muted, fontSize: 10)))),
                const SizedBox(height: 12),
                Row(children: ['1D', '1W', '1M', '3M', 'YTD', 'All'].map((value) {
                  final selected = _range == value;
                  return Expanded(child: InkWell(onTap: () => setState(() => _range = value), borderRadius: BorderRadius.circular(18), child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(color: selected ? gold : Colors.transparent, borderRadius: BorderRadius.circular(18)),
                    alignment: Alignment.center,
                    child: Text(value, style: TextStyle(color: selected ? const Color(0xFF101A29) : fg, fontSize: 9, fontWeight: FontWeight.w800)),
                  )));
                }).toList()),
                const SizedBox(height: 13),
                Row(children: [
                  Expanded(child: stat(LucideIcons.trendingUp, 'Total trades', '${a.openPositions.length + trades.length}', blue)),
                  const SizedBox(width: 9),
                  Expanded(child: stat(LucideIcons.target, 'Win rate', trades.isEmpty ? '—' : '${winRate.toStringAsFixed(1)}%', blue)),
                ]),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: stat(LucideIcons.trendingUp, 'Profit trades', '$wins', green)),
                  const SizedBox(width: 9),
                  Expanded(child: stat(LucideIcons.trendingDown, 'Loss trades', '$losses', red)),
                ]),
              ]),
            ),
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Column(children: [
              Row(children: [Expanded(child: Text('Account information', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800))), Text('MT5', style: TextStyle(color: muted, fontSize: 9))]),
              const SizedBox(height: 12),
              _detailInfoRow(context, LucideIcons.hash, 'Login ID', a.login, fg, muted, border),
              _detailInfoRow(context, LucideIcons.server, 'Server', a.server ?? 'Not provided', fg, muted, border),
              _detailInfoRow(context, LucideIcons.gauge, 'Leverage', a.leverage, fg, muted, border),
              _detailInfoRow(context, LucideIcons.coins, 'Currency', a.currency, fg, muted, border),
            ])),
          ] else if (_tab == 'Trading Stats') ...[
            Row(children: [
              Expanded(child: stat(LucideIcons.chartLine, 'Net closed P/L', _money(totalProfit), totalProfit >= 0 ? green : red)),
              const SizedBox(width: 9),
              Expanded(child: stat(LucideIcons.activity, 'Open positions', '${a.openPositions.length}', blue)),
            ]),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Open positions', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (a.openPositions.isEmpty) Text('No open positions.', style: TextStyle(color: muted, fontSize: 10)),
              ...a.openPositions.map((p) => _detailTradeRow(context, p.symbol, '${p.side.toUpperCase()} • ${p.volume} lots', _money(p.profit), p.profit >= 0 ? green : red, fg, muted, border)),
            ])),
          ] else ...[
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Trade history', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (trades.isEmpty) Text('Closed trades will appear after MT5 history sync.', style: TextStyle(color: muted, fontSize: 10)),
              ...trades.map((t) => _detailTradeRow(context, t.symbol, '${t.side.toUpperCase()} • ${t.volume} lots • ${t.closedAt}', _money(t.profit), t.profit >= 0 ? green : red, fg, muted, border)),
            ])),
          ],
        ],
      ),
    );
  }
}

Widget _detailInfoRow(BuildContext context, IconData icon, String label, String value, Color fg, Color muted, Color border) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Column(children: [
    Row(children: [Icon(icon, color: const Color(0xFF8FB5E0), size: 16), const SizedBox(width: 10), Expanded(child: Text(label, style: TextStyle(color: muted, fontSize: 10))), Text(value, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700))]),
    const SizedBox(height: 8),
    Container(height: 1, color: border),
  ]),
);

Widget _detailTradeRow(BuildContext context, String symbol, String detail, String profit, Color profitColor, Color fg, Color muted, Color border) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 9),
  child: Column(children: [
    Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFF163D70), borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.activity, color: Color(0xFF39B5FF), size: 17)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(symbol, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(detail, style: TextStyle(color: muted, fontSize: 8)),
      ])),
      Text(profit, style: TextStyle(color: profitColor, fontSize: 11, fontWeight: FontWeight.w800)),
    ]),
    const SizedBox(height: 9),
    Container(height: 1, color: border),
  ]),
);
class _EquityHistoryPainter extends CustomPainter {
  const _EquityHistoryPainter({required this.values, required this.color, required this.gridColor});
  final List<double> values; final Color color, gridColor;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.isEmpty) return;
    final minV = values.reduce((a, b) => a < b ? a : b); final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < .000001 ? 1.0 : maxV - minV;
    final rect = Rect.fromLTWH(0, 4, size.width, size.height - 8);
    final grid = Paint()..color = gridColor..strokeWidth = 1;
    for (var i = 0; i < 4; i++) { final y = rect.top + rect.height * i / 3; canvas.drawLine(Offset(0, y), Offset(size.width, y), grid); }
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = rect.width * i / (values.length - 1); final y = rect.bottom - ((values[i] - minV) / range) * rect.height;
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }
  @override
  bool shouldRepaint(covariant _EquityHistoryPainter old) => old.values != values || old.color != color || old.gridColor != gridColor;
}
