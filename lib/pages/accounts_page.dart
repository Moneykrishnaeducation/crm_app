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
          height: 43,
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
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 126),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ACCOUNTS', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              const SizedBox(height: 5),
              Text('Trading Accounts', style: TextStyle(color: text, fontSize: 25, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -.6)),
              const SizedBox(height: 5),
              Text('Manage your live and demo trading accounts', style: TextStyle(color: muted, fontSize: 11)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: border)), child: Row(children: [
              const Icon(LucideIcons.walletCards, color: blue, size: 15), const SizedBox(width: 6),
              Text('${all.length} Accounts', style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.w800)),
            ])),
          ]),
          const SizedBox(height: 19),
          Row(children: [
            filter('All', 'All', '${all.length}'),
            const SizedBox(width: 8),
            filter('Live', 'Live', '$liveCount', dot: green),
            const SizedBox(width: 8),
            filter('Demo', 'Demo', '$demoCount', dot: blue),
          ]),
          const SizedBox(height: 17),
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
          const SizedBox(height: 17),
          if (filtered.isEmpty)
            _AccountEmptyState(searching: _query.isNotEmpty || _filter != 'All', onClear: () { _searchController.clear(); setState(() { _query = ''; _filter = 'All'; }); }, onOpen: () => showDialog<void>(context: context, builder: (_) => _OpenLiveAccountDialog(onCreated: widget.onAccountCreated)))
          else
            ...filtered.map((account) => _ReferenceAccountCard(
              account: account,
              selected: false,
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
          Text('Combined balance  ${all.isEmpty ? '—' : '$' + totalBalance.toStringAsFixed(2)}', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 9)),
        ],
      ),
    );
  }
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
  final BrokerAccount account; final VoidCallback onBack; final ValueChanged<String> onSelectPage;
  @override
  State<BrokerAccountDetailsPage> createState() => _BrokerAccountDetailsPageState();
}
class _BrokerAccountDetailsPageState extends State<BrokerAccountDetailsPage> {
  String _tab = 'Positions';
  String _money(double v) => (v < 0 ? '-' : '') + widget.account.currency + ' ' + v.abs().toStringAsFixed(2);
  Widget _empty(BuildContext context, IconData icon, String title, String message) {
    final cs = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10), child: Column(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: cs.primary)),
      const SizedBox(height: 9), Text(title, style: TextStyle(color: cs.onSurface, fontSize: 11, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5), Text(message, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9, height: 1.5)),
    ]));
  }
  Widget _metric(BuildContext context, String label, String value, IconData icon, {Color? valueColor}) {
    final cs = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: .4), borderRadius: BorderRadius.circular(13)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: cs.primary, size: 15), const SizedBox(height: 8), Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9)),
      const SizedBox(height: 4), FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(color: valueColor ?? cs.onSurface, fontSize: 15, fontWeight: FontWeight.w800))),
    ]));
  }
  Widget _heading(BuildContext context, String title, String note) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [Expanded(child: Text(title, style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w800))), Text(note, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9))]);
  }
  Widget _info(BuildContext context, IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [
      Icon(icon, color: cs.primary, size: 16), const SizedBox(width: 10), Expanded(child: Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10))),
      Flexible(child: Text(value, textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w700))),
    ]));
  }
  @override
  Widget build(BuildContext context) {
    final a = widget.account; final cs = Theme.of(context).colorScheme;
    final pnl = a.floatingPnl; final hasChart = a.equityHistory.length > 1;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 125), children: [
      Row(children: [IconButton(onPressed: widget.onBack, icon: const Icon(LucideIcons.arrowLeft)), Expanded(child: Text('Account details', style: TextStyle(color: cs.onSurface, fontSize: 20, fontWeight: FontWeight.w800))), IconButton(onPressed: () => widget.onSelectPage('Trading Accounts'), icon: const Icon(LucideIcons.layoutGrid))]),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(
        gradient: LinearGradient(colors: Theme.of(context).brightness == Brightness.dark ? const [Color(0xFF172B49), Color(0xFF101D32)] : const [Color(0xFFEAF2FF), Colors.white]),
        borderRadius: BorderRadius.circular(19), border: Border.all(color: Theme.of(context).dividerColor)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 43, height: 43, decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(13)), child: Icon(LucideIcons.chartNoAxesCombined, color: cs.primary, size: 21)),
            const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.name, style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5), Wrap(spacing: 7, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a.type == 'Live MT5' ? const Color(0xFF145C43) : const Color(0xFF174A8B), borderRadius: BorderRadius.circular(20)), child: Text(a.type, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800))),
                Text('MT5 â€¢ Login \${a.login}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9)),
              ]),
            ])),
          ]),
          const SizedBox(height: 16), Row(children: [
            Expanded(child: _metric(context, 'Balance', a.balance, LucideIcons.wallet)),
            const SizedBox(width: 8), Expanded(child: _metric(context, 'Equity', a.equity, LucideIcons.chartNoAxesCombined, valueColor: const Color(0xFF20B981))),
          ]),
          const SizedBox(height: 8), _metric(context, 'Floating P/L', pnl == null ? 'Not synced' : _money(pnl), LucideIcons.activity, valueColor: pnl == null ? cs.onSurfaceVariant : pnl >= 0 ? const Color(0xFF20B981) : const Color(0xFFDC5B63)),
        ]),
      ),
      const SizedBox(height: 14), Row(children: [
        _action(context, LucideIcons.arrowDownToLine, 'Deposit', true, () => widget.onSelectPage('Deposit')),
        const SizedBox(width: 7), _action(context, LucideIcons.arrowUpFromLine, 'Withdraw', false, () => widget.onSelectPage('Withdraw')),
        const SizedBox(width: 7), _action(context, LucideIcons.arrowLeftRight, 'Transfer', false, () => widget.onSelectPage('Internal Transfer')),
      ]),
      const SizedBox(height: 20), _heading(context, 'Performance', hasChart ? 'Equity history' : 'Awaiting data'),
      const SizedBox(height: 8), Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)), child:
        hasChart ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Equity movement', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9)), const SizedBox(height: 8),
          SizedBox(height: 110, width: double.infinity, child: CustomPaint(painter: _EquityHistoryPainter(values: a.equityHistory, color: cs.primary, gridColor: Theme.of(context).dividerColor))),
        ]) : _empty(context, LucideIcons.chartNoAxesCombined, 'Performance data not available', 'The equity chart will appear after MT5 equity history is connected. No performance values are estimated.'),
      ),
      const SizedBox(height: 20), _heading(context, 'Trading activity', '\${a.openPositions.length} open â€¢ \${a.recentTrades.length} closed'),
      const SizedBox(height: 8), Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)), child: Column(children: [
        Row(children: [Expanded(child: _tabButton(context, 'Positions')), const SizedBox(width: 7), Expanded(child: _tabButton(context, 'History'))]),
        const SizedBox(height: 7),
        if (_tab == 'Positions')
          if (a.openPositions.isEmpty) _empty(context, LucideIcons.activity, 'No open positions', 'Open MT5 positions will appear here when account synchronization is enabled.')
          else ...a.openPositions.map((p) => _position(context, p))
        else if (a.recentTrades.isEmpty)
          _empty(context, LucideIcons.history, 'No trading history', 'Closed trades will appear here when MT5 deal history is available.')
        else ...a.recentTrades.map((t) => _trade(context, t)),
      ])),
      const SizedBox(height: 20), _heading(context, 'Account information', ''),
      const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)), child: Column(children: [
        _info(context, LucideIcons.hash, 'Login ID', a.login), Divider(height: 1, color: Theme.of(context).dividerColor),
        _info(context, LucideIcons.server, 'Server', a.server ?? 'Not provided'), Divider(height: 1, color: Theme.of(context).dividerColor),
        _info(context, LucideIcons.monitor, 'Platform', 'MetaTrader 5'), Divider(height: 1, color: Theme.of(context).dividerColor),
        _info(context, LucideIcons.gauge, 'Leverage', a.leverage), Divider(height: 1, color: Theme.of(context).dividerColor),
        _info(context, LucideIcons.wallet, 'Account type', a.type), Divider(height: 1, color: Theme.of(context).dividerColor),
        _info(context, LucideIcons.coins, 'Currency', a.currency),
      ])),
      const SizedBox(height: 14), Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: Theme.of(context).dividerColor)), child: Row(children: [
        Icon(LucideIcons.shieldCheck, color: cs.primary, size: 18), const SizedBox(width: 9), Expanded(child: Text('Never share your master password or investor credentials.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9, height: 1.5))),
      ])),
    ]);
  }
  Widget _action(BuildContext context, IconData icon, String label, bool primary, VoidCallback tap) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(child: SizedBox(height: 68, child: OutlinedButton(onPressed: tap, style: OutlinedButton.styleFrom(backgroundColor: primary ? _brokerGold : cs.surface, foregroundColor: primary ? _brokerNavy : cs.onSurface, side: BorderSide(color: primary ? _brokerGold : Theme.of(context).dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), padding: const EdgeInsets.symmetric(horizontal: 2)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 18), const SizedBox(height: 5), Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800))]))));
  }
  Widget _tabButton(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme; final selected = _tab == label;
    return InkWell(onTap: () => setState(() => _tab = label), borderRadius: BorderRadius.circular(9), child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: selected ? cs.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(9), border: Border.all(color: selected ? cs.primary.withValues(alpha: .25) : Theme.of(context).dividerColor)), child: Center(child: Text(label, style: TextStyle(color: selected ? cs.primary : cs.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w800)))));
  }
  Widget _position(BuildContext context, BrokerOpenPosition p) {
    final cs = Theme.of(context).colorScheme; final color = p.profit >= 0 ? const Color(0xFF20B981) : const Color(0xFFDC5B63);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
      Icon(p.side.toLowerCase() == 'buy' ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: cs.primary, size: 18), const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.symbol, style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800)),
        Text('\${p.side.toUpperCase()} â€¢ \${p.volume} lots', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 8)),
        Text('\${p.openPrice} â†’ \${p.currentPrice}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 8)),
      ])), Text(_money(p.profit), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    ]));
  }
  Widget _trade(BuildContext context, BrokerTradeRecord t) {
    final cs = Theme.of(context).colorScheme; final color = t.profit >= 0 ? const Color(0xFF20B981) : const Color(0xFFDC5B63);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
      Icon(LucideIcons.history, color: cs.primary, size: 18), const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.symbol, style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800)),
        Text('\${t.side.toUpperCase()} â€¢ \${t.volume} lots â€¢ \${t.closedAt}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 8)),
      ])), Text(_money(t.profit), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    ]));
  }
}
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
