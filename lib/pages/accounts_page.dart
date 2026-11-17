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
    final liveAccounts = widget.accounts.where((a) => a.type == 'Live MT5').toList();
    final filtered = liveAccounts.where((a) {
      final q = _query.trim().toLowerCase();
      return q.isEmpty || a.login.toLowerCase().contains(q) || a.name.toLowerCase().contains(q);
    }).toList();
    final totalBalance = liveAccounts.fold<double>(0, (sum, a) => sum + (double.tryParse(a.balance.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0));
    final surface = dark ? panel : Colors.white;
    final border = dark ? const Color(0xFF29415F) : const Color(0xFFD9E2EE);
    final text = dark ? const Color(0xFFF5F7FC) : const Color(0xFF10213A);
    final muted = dark ? const Color(0xFFA9B9CE) : const Color(0xFF6F7F95);



    return Container(
      color: dark ? navy : Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ACCOUNTS', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              const SizedBox(height: 5),
              Text('Trading Accounts', style: TextStyle(color: text, fontSize: 26, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.65)),
              const SizedBox(height: 5),
              Text('Your live MT5 trading accounts', style: TextStyle(color: muted, fontSize: 12, height: 1.35)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: border)), child: Row(children: [
              const Icon(LucideIcons.walletCards, color: blue, size: 15), const SizedBox(width: 6),
              Text('${liveAccounts.length} Live', style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.w800)),
            ])),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black54,
                  builder: (_) => _OpenLiveAccountSheet(onCreated: widget.onAccountCreated),
                ),
                style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF101A29), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                icon: const Icon(LucideIcons.plusCircle, size: 18),
                label: const Text('Open Account', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => widget.onSelectPage('Demo Accounts'),
                style: OutlinedButton.styleFrom(foregroundColor: text, side: BorderSide(color: border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: const Icon(LucideIcons.flaskConical, size: 18),
                label: const Text('Demo Accounts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            )),
          ]),
          const SizedBox(height: 12),
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

          ]),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            _AccountEmptyState(searching: _query.isNotEmpty, onClear: () { _searchController.clear(); setState(() { _query = ''; }); })
          else
            ...filtered.map((account) => _ReferenceAccountCard(
              account: account,
              selected: liveAccounts.isNotEmpty && account.login == liveAccounts.first.login,
              onTap: () => widget.onAccountSelected(account),
            )),
          const SizedBox(height: 7),
          Text('Combined live balance  ${liveAccounts.isEmpty ? 'â€”' : String.fromCharCode(36) + totalBalance.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 9)),
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
    final sparkWidth = MediaQuery.sizeOf(context).width < 380 ? 54.0 : 82.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: border, width: selected ? 1.8 : 1.2),
              boxShadow: selected && dark ? [BoxShadow(color: gold.withValues(alpha: .13), blurRadius: 13, spreadRadius: 1)] : null,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFF163D70), borderRadius: BorderRadius.circular(13)), child: const Icon(LucideIcons.chartNoAxesColumnIncreasing, color: blue, size: 23)),
                const SizedBox(width: 11),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _AccountPill(label: live ? 'Live' : 'Demo', color: live ? const Color(0xFF0B9E55) : const Color(0xFF4C91E8), foreground: Colors.white),
                    const SizedBox(width: 6),
                    const _AccountPill(label: 'MT5', color: Color(0xFF315D86), foreground: Colors.white),
                    const SizedBox(width: 9),
                    Flexible(child: Text(account.login, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 16, fontWeight: FontWeight.w800))),
                  ]),
                  const SizedBox(height: 7),
                  Text('${account.name}  â€¢  ${account.leverage}', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w500)),
                ])),
                SizedBox(width: sparkWidth, height: 42, child: CustomPaint(painter: _AccountSparkPainter(values: equity, color: pnl < 0 ? red : live ? green : const Color(0xFF78A9DC)))),
                const SizedBox(width: 5),
                Icon(selected ? Icons.star : Icons.star_border, color: selected ? gold : muted, size: 22),
              ]),
              const SizedBox(height: 11),
              Row(children: [
                Expanded(child: _ReferenceMetric(label: 'Balance', value: account.balance, color: fg, muted: muted)),
                Container(width: 1, height: 35, color: dark ? const Color(0xFF29415F) : const Color(0xFFE0E7F0)),
                Expanded(child: _ReferenceMetric(label: 'Equity', value: account.equity, color: fg, muted: muted)),
                Container(width: 1, height: 35, color: dark ? const Color(0xFF29415F) : const Color(0xFFE0E7F0)),
                Expanded(child: _ReferenceMetric(label: 'P/L', value: account.floatingPnl == null ? 'â€”' : (pnl > 0 ? '+' : pnl < 0 ? '-' : '') + r'$' + pnl.abs().toStringAsFixed(2), color: pnlColor, muted: muted)),
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
    padding: const EdgeInsets.symmetric(horizontal: 7),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w500)),
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
  const _AccountEmptyState({required this.searching, required this.onClear});
  final bool searching;
  final VoidCallback onClear;

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
      if (searching) OutlinedButton(onPressed: onClear, child: const Text('Clear search')),
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

class _OpenLiveAccountSheet extends StatefulWidget {
  const _OpenLiveAccountSheet({required this.onCreated});
  final ValueChanged<BrokerAccount> onCreated;
  @override
  State<_OpenLiveAccountSheet> createState() => _OpenLiveAccountSheetState();
}

class _OpenLiveAccountSheetState extends State<_OpenLiveAccountSheet> {
  final _nameController = TextEditingController();
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
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final border = theme.dividerColor;
    final muted = cs.onSurfaceVariant;
    final screen = MediaQuery.sizeOf(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560, maxHeight: screen.height * .92),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border.all(color: border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .34 : .12), blurRadius: 30, offset: const Offset(0, -8))],
              ),
              child: Column(mainAxisSize: MainAxisSize.max, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 2),
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: muted.withValues(alpha: .45), borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 12, 15),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: cs.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)), child: Icon(LucideIcons.walletCards, color: cs.primary, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Open Live Account', style: TextStyle(color: cs.onSurface, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text('Configure your new MT5 trading account', style: TextStyle(color: muted, fontSize: 11)),
                ])),
                IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: Icon(LucideIcons.x, color: muted, size: 19)),
              ]),
            ),
            Divider(height: 1, color: border),
            Flexible(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionHeading('ACCOUNT PROFILE', '01'),
                const SizedBox(height: 10),
                _fieldLabel('Account name'),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: _inputDecoration('Enter account holder name', LucideIcons.userRound, cs, border, muted),
                ),
                const SizedBox(height: 18),
                _sectionHeading('TRADING CONFIGURATION', '02'),
                const SizedBox(height: 10),
                _fieldLabel('Trading group'),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: dark ? .45 : .55), borderRadius: BorderRadius.circular(13), border: Border.all(color: border)),
                  child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                    value: _group, isExpanded: true, dropdownColor: cs.surface,
                    icon: Icon(LucideIcons.chevronDown, color: muted, size: 18),
                    style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(value: 'VIP - Recommended (Default)', child: Text('VIP - Recommended (Default)')),
                      DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                      DropdownMenuItem(value: 'ECN', child: Text('ECN')),
                    ],
                    onChanged: (value) { if (value != null) setState(() => _group = value); },
                  )),
                ),
                const SizedBox(height: 14),
                _fieldLabel('Leverage'),
                const SizedBox(height: 7),
                Row(children: [
                  for (final value in const ['1:100', '1:200', '1:500'])
                    Expanded(child: Padding(
                      padding: EdgeInsets.only(right: value == '1:500' ? 0 : 8),
                      child: InkWell(
                        onTap: () => setState(() => _leverage = value),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _leverage == value ? cs.primary.withValues(alpha: .10) : cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _leverage == value ? cs.primary : border, width: _leverage == value ? 1.5 : 1),
                          ),
                          alignment: Alignment.center,
                          child: Text(value, style: TextStyle(color: _leverage == value ? cs.primary : cs.onSurface, fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    )),
                ]),
                const SizedBox(height: 18),
                _sectionHeading('ACCOUNT SECURITY', '03'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: cs.primary.withValues(alpha: .06), borderRadius: BorderRadius.circular(13), border: Border.all(color: cs.primary.withValues(alpha: .18))),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(LucideIcons.shieldCheck, color: cs.primary, size: 17),
                    const SizedBox(width: 9),
                    Expanded(child: Text('Use separate passwords for trading access and read-only monitoring. Keep both credentials private.', style: TextStyle(color: muted, fontSize: 10, height: 1.45))),
                  ]),
                ),
                const SizedBox(height: 13),
                _fieldLabel('Master password Â· Trading access'),
                const SizedBox(height: 6),
                _PasswordInput(controller: _masterPassword),
                const SizedBox(height: 12),
                _fieldLabel('Investor password Â· Read-only access'),
                const SizedBox(height: 6),
                _PasswordInput(controller: _investorPassword),
              ]),
            )),
            Divider(height: 1, color: border),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 13, 18, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(height: 48, child: FilledButton.icon(
                  onPressed: _createAccount,
                  style: FilledButton.styleFrom(backgroundColor: _brokerGold, foregroundColor: const Color(0xFF142238), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('CREATE LIVE ACCOUNT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35)),
                )),
                const SizedBox(height: 9),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(LucideIcons.lockKeyhole, color: muted, size: 12),
                  const SizedBox(width: 5),
                  Text('Account provisioning is not connected in this preview', style: TextStyle(color: muted, fontSize: 9)),
                ]),
              ]),
            ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, String number) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Text(number, style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w800)),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
    ]);
  }

  Widget _fieldLabel(String value) => Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w700));

  InputDecoration _inputDecoration(String hint, IconData icon, ColorScheme cs, Color border, Color muted) => InputDecoration(
    prefixIcon: Icon(icon, size: 17, color: muted),
    hintText: hint,
    hintStyle: TextStyle(color: muted, fontSize: 11),
    filled: true,
    fillColor: cs.surfaceContainerHighest.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .45 : .55),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: cs.primary, width: 1.4)),
  );

  void _createAccount() {
    final accountName = _nameController.text.trim();
    if (accountName.isEmpty || _masterPassword.text.isEmpty || _investorPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an account name and both passwords to continue.')));
      return;
    }
    final login = '34${DateTime.now().millisecondsSinceEpoch.remainder(100000)}';
    widget.onCreated(BrokerAccount(accountName, login, _leverage, '\$0.00', '\$0.00', 'Live MT5'));
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('Live account preview $login added.')));
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor;
    final muted = cs.onSurfaceVariant;
    return TextField(
      controller: widget.controller,
      obscureText: !_visible,
      style: TextStyle(color: cs.onSurface, fontSize: 12),
      decoration: InputDecoration(
        prefixIcon: Icon(LucideIcons.lockKeyhole, size: 16, color: muted),
        suffixIcon: IconButton(
          tooltip: _visible ? 'Hide password' : 'Show password',
          onPressed: () => setState(() => _visible = !_visible),
          icon: Icon(_visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 17, color: muted),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .45 : .55),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: cs.primary, width: 1.4)),
      ),
    );
  }
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
    final winningTrades = trades.where((t) => t.profit > 0).toList();
    final losingTrades = trades.where((t) => t.profit < 0).toList();
    final averageWin = winningTrades.isEmpty ? 0.0 : winningTrades.fold<double>(0, (sum, t) => sum + t.profit) / winningTrades.length;
    final averageLoss = losingTrades.isEmpty ? 0.0 : losingTrades.fold<double>(0, (sum, t) => sum + t.profit.abs()) / losingTrades.length;
    final history = a.equityHistory;
    final rangeCount = switch (_range) { '1D' => 3, '1W' => 5, '1M' => 8, '3M' => 10, 'YTD' => 12, _ => history.length };
    final chartHistory = history.length > rangeCount ? history.sublist(history.length - rangeCount) : history;
    final changePct = chartHistory.length > 1 && chartHistory.first != 0 ? ((chartHistory.last - chartHistory.first) / chartHistory.first) * 100 : 0.0;

    Widget metric(String label, String value, {Color? valueColor}) => Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(color: valueColor ?? fg, fontSize: 19, fontWeight: FontWeight.w800))),
      ]),
    ));

    Widget infoCell(IconData icon, String label, String value) => Expanded(child: Row(children: [
      Icon(icon, color: const Color(0xFF8FB5E0), size: 20),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: muted, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
      ])),
    ]));

    Widget action(IconData icon, String label, bool primary, VoidCallback onTap) => Expanded(child: SizedBox(
      height: 64,
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
          Icon(icon, size: 20), const SizedBox(height: 4),
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
          height: 42,
          decoration: BoxDecoration(color: selected ? gold : Colors.transparent, borderRadius: BorderRadius.circular(11)),
          alignment: Alignment.center,
          child: Text(value, style: TextStyle(color: selected ? const Color(0xFF101A29) : fg, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      ));
    }

    Widget stat(IconData icon, String label, String value, Color accent) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: accent.withValues(alpha: .13), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 17)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: muted, fontSize: 9)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w800)),
        ])),
      ]),
    );

    return Container(
      color: bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
              Padding(padding: const EdgeInsets.fromLTRB(12, 11, 12, 10), child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF163D70), borderRadius: BorderRadius.circular(13)), child: const Icon(LucideIcons.chartNoAxesColumnIncreasing, color: blue, size: 25)),
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
              Padding(padding: const EdgeInsets.fromLTRB(7, 2, 7, 10), child: Row(children: [
                metric('Balance', a.balance),
                Container(width: 1, height: 42, color: border),
                metric('Equity', a.equity),
                Container(width: 1, height: 42, color: border),
                metric('Floating P/L', pnl == null ? 'â€”' : _money(pnl), valueColor: pnlColor),
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
          const SizedBox(height: 12),
          Row(children: [
            action(LucideIcons.arrowDown, 'Deposit', true, () => widget.onSelectPage('Deposit')),
            const SizedBox(width: 8),
            action(LucideIcons.arrowUp, 'Withdraw', false, () => widget.onSelectPage('Withdraw')),
            const SizedBox(width: 8),
            action(LucideIcons.arrowLeftRight, 'Transfer', false, () => widget.onSelectPage('Internal Transfer')),
            const SizedBox(width: 8),
            action(LucideIcons.settings, 'Settings', false, () => widget.onSelectPage('Settings')),
          ]),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)), child: Row(children: [tab('Overview'), tab('Trading Stats'), tab('History')])),
          const SizedBox(height: 10),
          if (_tab == 'Overview') ...[
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(19), border: Border.all(color: border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(LucideIcons.chartNoAxesColumnIncreasing, color: blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Account Performance', style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: (changePct >= 0 ? green : red).withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(2)}%',
                      style: TextStyle(color: changePct >= 0 ? green : red, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                if (history.length > 1)
                  SizedBox(height: MediaQuery.sizeOf(context).height < 760 ? 88 : 108, width: double.infinity, child: CustomPaint(painter: _EquityHistoryPainter(values: chartHistory, color: green, gridColor: border)))
                else
                  SizedBox(height: 112, child: Center(child: Text('Performance history will appear after MT5 sync.', style: TextStyle(color: muted, fontSize: 10)))),
                const SizedBox(height: 8),
                Row(children: ['1D', '1W', '1M', '3M', 'YTD', 'All'].map((value) {
                  final selected = _range == value;
                  return Expanded(child: InkWell(onTap: () => setState(() => _range = value), borderRadius: BorderRadius.circular(18), child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(color: selected ? gold : Colors.transparent, borderRadius: BorderRadius.circular(18)),
                    alignment: Alignment.center,
                    child: Text(value, style: TextStyle(color: selected ? const Color(0xFF101A29) : fg, fontSize: 9, fontWeight: FontWeight.w800)),
                  )));
                }).toList()),
                const SizedBox(height: 9),
                Row(children: [
                  Expanded(child: stat(LucideIcons.receiptText, 'Closed trades shown', '${trades.length}', blue)),
                  const SizedBox(width: 9),
                  Expanded(child: stat(LucideIcons.target, 'Sample win rate', trades.isEmpty ? 'â€”' : '${winRate.toStringAsFixed(1)}%', blue)),
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
              _detailInfoRow(context, LucideIcons.shieldCheck, 'Account type', a.type, fg, muted, border),
            ])),
            const SizedBox(height: 12),
            _detailSectionCard(
              title: 'Open positions',
              subtitle: '${a.openPositions.length} currently open',
              icon: LucideIcons.activity,
              surface: surface, border: border, fg: fg, muted: muted,
              children: [
                if (a.openPositions.isEmpty)
                  _detailEmptyLine('No open positions on this account.', muted)
                else
                  ...a.openPositions.map((p) => _detailTradeRow(
                    context, p.symbol,
                    '${p.side.toUpperCase()} â€¢ ${p.volume} lots â€¢ Entry ${p.openPrice} â€¢ Mark ${p.currentPrice}',
                    _money(p.profit), p.profit >= 0 ? green : red, fg, muted, border,
                  )),
              ],
            ),
            const SizedBox(height: 12),
            _detailSectionCard(
              title: 'Recent closed trades',
              subtitle: '${trades.length} records in this preview',
              icon: LucideIcons.history,
              surface: surface, border: border, fg: fg, muted: muted,
              children: [
                if (trades.isEmpty)
                  _detailEmptyLine('Closed trades will appear after MT5 history sync.', muted)
                else
                  ...trades.map((t) => _detailTradeRow(
                    context, t.symbol,
                    '${t.side.toUpperCase()} â€¢ ${t.volume} lots â€¢ ${t.closedAt}',
                    _money(t.profit), t.profit >= 0 ? green : red, fg, muted, border,
                  )),
              ],
            ),
          ] else if (_tab == 'Trading Stats') ...[
            Row(children: [
              Expanded(child: stat(LucideIcons.trendingUp, 'Avg. win (shown)', _money(averageWin), green)),
              const SizedBox(width: 9),
              Expanded(child: stat(LucideIcons.trendingDown, 'Avg. loss (shown)', _money(-averageLoss), red)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: stat(LucideIcons.chartLine, 'Net P/L (shown trades)', _money(totalProfit), totalProfit >= 0 ? green : red)),
              const SizedBox(width: 9),
              Expanded(child: stat(LucideIcons.activity, 'Open positions', '${a.openPositions.length}', blue)),
            ]),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Open positions', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (a.openPositions.isEmpty) Text('No open positions.', style: TextStyle(color: muted, fontSize: 10)),
              ...a.openPositions.map((p) => _detailTradeRow(context, p.symbol, '${p.side.toUpperCase()} â€¢ ${p.volume} lots â€¢ Entry ${p.openPrice} â€¢ Mark ${p.currentPrice}', _money(p.profit), p.profit >= 0 ? green : red, fg, muted, border)),
            ])),
          ] else ...[
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Trade history', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (trades.isEmpty) Text('No closed trades are available in this account preview.', style: TextStyle(color: muted, fontSize: 10)),
              ...trades.map((t) => _detailTradeRow(context, t.symbol, '${t.side.toUpperCase()} â€¢ ${t.volume} lots â€¢ ${t.closedAt}', _money(t.profit), t.profit >= 0 ? green : red, fg, muted, border)),
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
Widget _detailEmptyLine(String message, Color muted) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 14),
  child: Row(children: [
    Icon(LucideIcons.info, size: 15, color: muted),
    const SizedBox(width: 8),
    Expanded(child: Text(message, style: TextStyle(color: muted, fontSize: 10))),
  ]),
);

Widget _detailSectionCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color surface,
  required Color border,
  required Color fg,
  required Color muted,
  required List<Widget> children,
}) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(17),
    border: Border.all(color: border),
  ),
  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Icon(icon, color: const Color(0xFF39B5FF), size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(title, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800))),
      Text(subtitle, style: TextStyle(color: muted, fontSize: 9)),
    ]),
    const SizedBox(height: 8),
    ...children,
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
    final fillPath = Path.from(path)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: .25), color.withValues(alpha: .015)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.4..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }
  @override
  bool shouldRepaint(covariant _EquityHistoryPainter old) => old.values != values || old.color != color || old.gridColor != gridColor;
}
