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
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    const gold = Color(0xFFFFC533);
    const blue = Color(0xFF35A9F5);
    const green = Color(0xFF0B9E68);
    final liveAccounts = widget.accounts.where((a) => a.type == 'Live MT5').toList();
    final query = _query.trim().toLowerCase();
    final filtered = liveAccounts.where((a) => query.isEmpty || a.login.toLowerCase().contains(query) || a.name.toLowerCase().contains(query)).toList();
    final surface = theme.colorScheme.surface;
    final border = theme.dividerColor.withValues(alpha: dark ? .72 : .8);
    final fg = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final bottomNavPadding = 116.0 + MediaQuery.paddingOf(context).bottom;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomNavPadding),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('MY PORTFOLIO', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 6),
              Text('Trading accounts', style: TextStyle(color: fg, fontSize: 25, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -.7)),
              const SizedBox(height: 5),
              Text('Manage your MT5 accounts in one place', style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(color: green.withValues(alpha: dark ? .16 : .09), borderRadius: BorderRadius.circular(30), border: Border.all(color: green.withValues(alpha: .25))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 7, height: 7, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Text('${liveAccounts.length} LIVE', style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .5)),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: SizedBox(height: 48, child: FilledButton.icon(
              onPressed: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, isDismissible: true, useSafeArea: true, backgroundColor: Colors.transparent, barrierColor: Colors.black54,
                builder: (_) => _OpenLiveAccountSheet(onCreated: widget.onAccountCreated)),
              style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF17243A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
              icon: const Icon(LucideIcons.plus, size: 17),
              label: const Text('Open live account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ))),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 48, child: OutlinedButton.icon(
              onPressed: () => widget.onSelectPage('Demo Accounts'),
              style: OutlinedButton.styleFrom(foregroundColor: fg, backgroundColor: surface, side: BorderSide(color: border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              icon: const Icon(LucideIcons.flaskConical, size: 17, color: blue),
              label: const Text('Demo accounts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
            ))),
          ]),
          const SizedBox(height: 21),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LIVE ACCOUNTS', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .5)),
              const SizedBox(height: 3),
              Text('Select an account to view its details', style: TextStyle(color: muted, fontSize: 10)),
            ])),
            Text('${filtered.length} shown', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 11),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            style: TextStyle(color: fg, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search name or account number', hintStyle: TextStyle(color: muted, fontSize: 11),
              prefixIcon: Icon(LucideIcons.search, color: muted, size: 18),
              suffixIcon: _query.isEmpty ? null : IconButton(tooltip: 'Clear search', onPressed: () { _searchController.clear(); setState(() => _query = ''); }, icon: Icon(LucideIcons.x, color: muted, size: 16)),
              filled: true, fillColor: surface, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: blue, width: 1.4)),
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            _AccountEmptyState(searching: _query.isNotEmpty, onClear: () { _searchController.clear(); setState(() => _query = ''); })
          else
            ...filtered.map((account) => _ReferenceAccountCard(account: account, selected: liveAccounts.isNotEmpty && account.login == liveAccounts.first.login, onTap: () => widget.onAccountSelected(account))),
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
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    const gold = Color(0xFFFFC533);
    const green = Color(0xFF08B779);
    const red = Color(0xFFE45C68);
    final live = account.type == 'Live MT5';
    final pnl = account.floatingPnl ?? 0;
    final pnlColor = pnl > 0 ? green : pnl < 0 ? red : theme.colorScheme.onSurface;
    final fg = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final border = selected ? gold.withValues(alpha: .9) : theme.dividerColor.withValues(alpha: dark ? .75 : .9);
    final equity = account.equityHistory.isNotEmpty ? account.equityHistory : <double>[1, 1.1, 1.04, 1.2, 1.13, 1.3, 1.26, 1.4];
    final sparkWidth = MediaQuery.sizeOf(context).width < 380 ? 48.0 : 70.0;

    return Padding(padding: const EdgeInsets.only(bottom: 11), child: Material(
      color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: selected ? 1.6 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: dark ? .10 : .035), blurRadius: 14, offset: const Offset(0, 5)),
            if (selected) BoxShadow(color: gold.withValues(alpha: dark ? .08 : .06), blurRadius: 14),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 43, height: 43, padding: const EdgeInsets.all(7), decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B4E82), Color(0xFF102B4B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14)),
              child: Image.network('https://image.vtindex.com/Logo-img.png', fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/vtindex_logo_img.png', fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(LucideIcons.chartNoAxesColumnIncreasing, color: Color(0xFF39B5FF)))),
            ),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _AccountPill(label: live ? 'LIVE' : 'DEMO', color: live ? const Color(0xFF0B9E68) : const Color(0xFF4C91E8), foreground: Colors.white),
                const SizedBox(width: 6),
                const _AccountPill(label: 'MT5', color: Color(0xFF315D86), foreground: Colors.white),
                const SizedBox(width: 7),
                Flexible(child: Text(account.login, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .1))),
              ]),
              const SizedBox(height: 5),
              Text(account.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
            ])),
            SizedBox(width: sparkWidth, height: 35, child: CustomPaint(painter: _AccountSparkPainter(values: equity, color: pnl < 0 ? red : live ? green : const Color(0xFF78A9DC)))),
            const SizedBox(width: 5),
            Icon(selected ? LucideIcons.star : LucideIcons.chevronRight, color: selected ? gold : muted, size: 19),
          ]),
          const SizedBox(height: 13),
          Container(height: 1, color: theme.dividerColor.withValues(alpha: .65)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ReferenceMetric(label: 'BALANCE', value: account.balance, color: fg, muted: muted)),
            Container(width: 1, height: 34, color: theme.dividerColor),
            Expanded(child: _ReferenceMetric(label: 'EQUITY', value: account.equity, color: fg, muted: muted)),
            Container(width: 1, height: 34, color: theme.dividerColor),
            Expanded(child: _ReferenceMetric(label: 'FLOATING P/L', value: account.floatingPnl == null ? '—' : '${pnl > 0 ? "+" : pnl < 0 ? "-" : ""}\$${pnl.abs().toStringAsFixed(2)}', color: pnlColor, muted: muted)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(LucideIcons.gauge, color: muted, size: 13),
            const SizedBox(width: 5),
            Text(account.leverage, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w600)),
            if (account.server != null && account.server!.isNotEmpty) ...[
              const SizedBox(width: 11), Icon(LucideIcons.server, color: muted, size: 12), const SizedBox(width: 5),
              Expanded(child: Text(account.server!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w600))),
            ] else const Spacer(),
            Text('View details', style: TextStyle(color: theme.colorScheme.primary, fontSize: 9, fontWeight: FontWeight.w800)),
            const SizedBox(width: 3), Icon(LucideIcons.arrowUpRight, color: theme.colorScheme.primary, size: 13),
          ]),
        ]),
      )),
    ));
  }
}

class _AccountLogoBadge extends StatelessWidget {
  const _AccountLogoBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF163D70),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Image.network(
        'https://image.vtindex.com/Logo-img.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/vtindex_logo_img.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            LucideIcons.chartNoAxesColumnIncreasing,
            color: Color(0xFF39B5FF),
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

class _AccountCredentialsPanel extends StatelessWidget {
  const _AccountCredentialsPanel({
    required this.accountNumber,
    required this.masterPassword,
    required this.investorPassword,
  });

  final String accountNumber;
  final String masterPassword;
  final String investorPassword;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor;
    final muted = cs.onSurfaceVariant;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: cs.primary.withValues(alpha: .25)),
        ),
        child: Row(children: [
          Icon(LucideIcons.sparkles, color: cs.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(
            'Save these credentials now. The passwords will not be shown again after you close this sheet.',
            style: TextStyle(color: cs.onSurface, fontSize: 11, height: 1.45, fontWeight: FontWeight.w600),
          )),
        ]),
      ),
      const SizedBox(height: 18),
      _credentialSectionHeading('LOGIN CREDENTIALS', cs),
      const SizedBox(height: 10),
      _credentialRow('Account number', accountNumber, cs, border, muted),
      const SizedBox(height: 9),
      _credentialRow('Master password', masterPassword, cs, border, muted),
      const SizedBox(height: 9),
      _credentialRow('Investor password', investorPassword, cs, border, muted),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(
              text: 'Account number: $accountNumber\n'
                  'Master password: $masterPassword\n'
                  'Investor password: $investorPassword',
            ));
            showAppMessage('Account credentials copied to clipboard.');
          },
          icon: const Icon(LucideIcons.copy, size: 14),
          label: const Text('Copy all credentials'),
        ),
      ),
    ]);
  }

  Widget _credentialRow(String label, String value, ColorScheme cs, Color border, Color muted) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 5, 11),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          SelectableText(value, style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: .3)),
        ])),
        IconButton(
          tooltip: 'Copy $label',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            showAppMessage('$label copied to clipboard.');
          },
          icon: Icon(LucideIcons.copy, color: cs.primary, size: 16),
        ),
      ]),
    );
  }
}

Widget _credentialSectionHeading(String title, ColorScheme cs) => Row(children: [
  Text('03', style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w800)),
  const SizedBox(width: 8),
  Text(title, style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
]);

String _generateAccountPassword() {
  const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  const lower = 'abcdefghijkmnopqrstuvwxyz';
  const digits = '23456789';
  const symbols = '!@#%';
  const characters = '$upper$lower$digits$symbols';
  final random = math.Random.secure();
  String pick(String from) => from[random.nextInt(from.length)];
  final password = <String>[
    pick(upper),
    pick(lower),
    pick(digits),
    pick(symbols),
    ...List.generate(12, (_) => pick(characters)),
  ]..shuffle(random);
  return password.join();
}

class _OpenLiveAccountSheet extends StatefulWidget {
  const _OpenLiveAccountSheet({required this.onCreated});
  final ValueChanged<BrokerAccount> onCreated;
  @override
  State<_OpenLiveAccountSheet> createState() => _OpenLiveAccountSheetState();
}

class _OpenLiveAccountSheetState extends State<_OpenLiveAccountSheet> {
  final _nameController = TextEditingController();
  String _group = 'VIP - Recommended (Default)';
  String _leverage = '1:500';
  String? _accountNumber;
  String? _masterPassword;
  String? _investorPassword;

  bool get _accountCreated => _accountNumber != null;

  @override
  void dispose() {
    _nameController.dispose();
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
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
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
              child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                Container(width: 44, height: 44, decoration: BoxDecoration(color: cs.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)), child: Icon(_accountCreated ? LucideIcons.sparkles : LucideIcons.walletCards, color: cs.primary, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_accountCreated ? 'Account Created' : 'Open Live Account', style: TextStyle(color: cs.onSurface, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(_accountCreated ? 'Your account credentials are ready' : 'Configure your new MT5 trading account', style: TextStyle(color: muted, fontSize: 11)),
                ])),
                IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: Icon(LucideIcons.x, color: muted, size: 19)),
              ]),
            ),
            Divider(height: 1, color: border),
            Flexible(child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: _accountCreated
                  ? _AccountCredentialsPanel(
                      accountNumber: _accountNumber!,
                      masterPassword: _masterPassword!,
                      investorPassword: _investorPassword!,
                    )
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

              ]),
            )),
            Divider(height: 1, color: border),
            Padding(
              padding: EdgeInsets.fromLTRB(18, 13, 18, 16 + MediaQuery.viewPaddingOf(context).bottom),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(height: 48, child: FilledButton.icon(
                  onPressed: _accountCreated ? () => Navigator.pop(context) : _createAccount,
                  style: FilledButton.styleFrom(backgroundColor: _brokerGold, foregroundColor: const Color(0xFF142238), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  icon: Icon(_accountCreated ? LucideIcons.check : LucideIcons.plus, size: 18),
                  label: Text(_accountCreated ? 'DONE' : 'CREATE LIVE ACCOUNT', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35)),
                )),
                const SizedBox(height: 9),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(LucideIcons.lockKeyhole, color: muted, size: 12),
                  const SizedBox(width: 5),
                  Flexible(child: Text(
                    _accountCreated
                        ? 'Preview credentials only; not valid for MT5 until provisioning is connected'
                        : 'Account provisioning is not connected in this preview',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 9),
                  )),
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
    if (accountName.isEmpty) {
      showAppMessage('Enter an account name to continue.');
      return;
    }
    final login = '34${DateTime.now().millisecondsSinceEpoch.remainder(100000)}';
    final masterPassword = _generateAccountPassword();
    final investorPassword = _generateAccountPassword();
    widget.onCreated(BrokerAccount(accountName, login, _leverage, '\$0.00', '\$0.00', 'Live MT5'));
    setState(() {
      _accountNumber = login;
      _masterPassword = masterPassword;
      _investorPassword = investorPassword;
    });
    unawaited(AppNotificationCenter.instance.sendNotification(
      title: 'Live Account Preview Created (#$login)',
      body: 'Live MT5 preview account #$login was added. Connect provisioning before using MT5.',
      category: 'Trading',
      icon: LucideIcons.shieldCheck,
      isGold: true,
      sendToMobilePanel: true,
    ));
  }
}

enum _PasswordStep { input, confirm, done }

class _ChangeInvestorPasswordSheet extends StatefulWidget {
  const _ChangeInvestorPasswordSheet({required this.account});

  final BrokerAccount account;

  @override
  State<_ChangeInvestorPasswordSheet> createState() => _ChangeInvestorPasswordSheetState();
}

class _ChangeInvestorPasswordSheetState extends State<_ChangeInvestorPasswordSheet> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  _PasswordStep _step = _PasswordStep.input;
  String? _savedPassword;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    final generated = _generateAccountPassword();
    setState(() {
      _passwordController.text = generated;
      _confirmController.text = generated;
      _obscurePassword = false;
      _obscureConfirm = false;
      _error = null;
    });
  }

  void _onContinue() {
    final pwd = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pwd.isEmpty) {
      setState(() => _error = 'Please enter a new investor password.');
      return;
    }
    if (pwd.length < 8) {
      setState(() => _error = 'Password must be at least 8 characters long.');
      return;
    }
    if (pwd != confirm) {
      setState(() => _error = 'Passwords do not match. Please re-enter.');
      return;
    }

    setState(() {
      _savedPassword = pwd;
      _step = _PasswordStep.confirm;
      _error = null;
    });
  }

  void _onConfirm() {
    setState(() {
      _step = _PasswordStep.done;
      _error = null;
    });

    unawaited(AppNotificationCenter.instance.sendNotification(
      title: 'Investor Password Preview (#${widget.account.login})',
      body: 'A new investor password was prepared locally for account #${widget.account.login}. No MT5 password change was submitted.',
      category: 'Security',
      icon: LucideIcons.keyRound,
      isGold: true,
      sendToMobilePanel: true,
    ));
    showAppMessage('Password preview prepared. No MT5 password change was submitted.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final border = theme.dividerColor;
    final muted = cs.onSurfaceVariant;
    final screen = MediaQuery.sizeOf(context);

    final isDone = _step == _PasswordStep.done;
    final isConfirm = _step == _PasswordStep.confirm;

    final headerIcon = isDone
        ? LucideIcons.shieldCheck
        : (isConfirm ? LucideIcons.shieldAlert : LucideIcons.keyRound);
    final headerIconColor = isDone
        ? const Color(0xFF10B981)
        : (isConfirm ? const Color(0xFFD8A82E) : cs.primary);
    final headerTitle = isDone
        ? 'Password Updated'
        : (isConfirm ? 'Confirm Password Change' : 'Change Investor Password');
    final headerSubtitle = isDone
        ? 'Account #${widget.account.login} · Ready'
        : (isConfirm
            ? 'Review and confirm update for #${widget.account.login}'
            : 'MT5 Read-only access for #${widget.account.login}');

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560, maxHeight: screen.height * .92),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? .34 : .12),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: muted.withValues(alpha: .45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 12, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: headerIconColor.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(headerIcon, color: headerIconColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headerTitle,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                headerSubtitle,
                                style: TextStyle(color: muted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(LucideIcons.x, color: muted, size: 19),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: border),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      child: switch (_step) {
                        _PasswordStep.input => _buildInputView(cs, border, muted, dark),
                        _PasswordStep.confirm => _buildConfirmView(cs, border, muted, dark),
                        _PasswordStep.done => _buildSuccessView(cs, border, muted),
                      },
                    ),
                  ),
                  Divider(height: 1, color: border),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18, 13, 18, 16 + MediaQuery.viewPaddingOf(context).bottom),
                    child: _buildBottomActions(context, cs, border),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, ColorScheme cs, Color border) {
    switch (_step) {
      case _PasswordStep.input:
        return SizedBox(
          height: 48,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: _brokerGold,
              foregroundColor: const Color(0xFF142238),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(LucideIcons.arrowRight, size: 18),
            label: const Text(
              'CONTINUE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35),
            ),
          ),
        );
      case _PasswordStep.confirm:
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _step = _PasswordStep.input),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text(
                    'CANCEL',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _onConfirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: _brokerGold,
                    foregroundColor: const Color(0xFF142238),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text(
                    'CONFIRM',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35),
                  ),
                ),
              ),
            ),
          ],
        );
      case _PasswordStep.done:
        return SizedBox(
          height: 48,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(LucideIcons.check, size: 18),
            label: const Text(
              'DONE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35),
            ),
          ),
        );
    }
  }

  Widget _buildInputView(ColorScheme cs, Color border, Color muted, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.primary.withValues(alpha: .22)),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.info, color: cs.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The investor password gives read-only access to view trades and performance. It cannot be used to open or close orders.',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: dark ? .35 : .45),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.userRoundCheck, size: 17, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Account #${widget.account.login} (${widget.account.name})',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                widget.account.type,
                style: TextStyle(
                  color: widget.account.type == 'Live MT5' ? const Color(0xFF10B981) : const Color(0xFF39B5FF),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text('01', style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text('NEW INVESTOR PASSWORD', style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
          ],
        ),
        const SizedBox(height: 10),
        Text('New password', style: TextStyle(color: cs.onSurface, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.lock, size: 17, color: muted),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye, size: 17, color: muted),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            hintText: 'Enter new investor password',
            hintStyle: TextStyle(color: muted, fontSize: 11),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: dark ? .45 : .55),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: cs.primary, width: 1.4)),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _generatePassword,
            icon: const Icon(LucideIcons.sparkles, size: 14),
            label: const Text('Generate Strong Password', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('Confirm password', style: TextStyle(color: cs.onSurface, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmController,
          obscureText: _obscureConfirm,
          style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(LucideIcons.lockKeyhole, size: 17, color: muted),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye, size: 17, color: muted),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            hintText: 'Confirm new investor password',
            hintStyle: TextStyle(color: muted, fontSize: 11),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: dark ? .45 : .55),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: cs.primary, width: 1.4)),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: .35)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.alertCircle, color: Color(0xFFEF4444), size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmView(ColorScheme cs, Color border, Color muted, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFD8A82E).withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8A82E).withValues(alpha: .30)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(LucideIcons.alertTriangle, color: Color(0xFFD8A82E), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Password Preview',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Are you sure you want to change the investor password for account #${widget.account.login}? Any active read-only sessions will be disconnected.',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: .85),
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'SUMMARY OF CHANGES',
          style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: dark ? .35 : .45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              _summaryRow('Account Number', '#${widget.account.login}', cs, muted),
              Divider(height: 18, color: border.withValues(alpha: .5)),
              _summaryRow('Account Name', widget.account.name, cs, muted),
              Divider(height: 18, color: border.withValues(alpha: .5)),
              _summaryRow('Platform & Type', widget.account.type, cs, muted),
              Divider(height: 18, color: border.withValues(alpha: .5)),
              _summaryRow('Access Permission', 'Read-Only (Investor)', cs, muted),
              Divider(height: 18, color: border.withValues(alpha: .5)),
              _summaryRow('New Password', _savedPassword ?? '', cs, muted, isPassword: true),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.info, size: 15, color: muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap "CONFIRM" to create this local preview. No MT5 password change will be submitted.',
                  style: TextStyle(color: muted, fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, ColorScheme cs, Color muted, {bool isPassword = false}) {
    return Row(
      children: [
        Text(label, style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            fontFamily: isPassword ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(ColorScheme cs, Color border, Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.checkCheck, color: Color(0xFF10B981), size: 30),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'Investor Password Preview Ready',
            style: TextStyle(color: cs.onSurface, fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'This password is shown for preview only and has not been applied to MT5.',
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ),
        const SizedBox(height: 20),
        _credentialRow('New investor password', _savedPassword ?? '', cs, border, muted),
      ],
    );
  }

  Widget _credentialRow(String label, String value, ColorScheme cs, Color border, Color muted) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 5, 11),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          SelectableText(value, style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: .3)),
        ])),
        IconButton(
          tooltip: 'Copy $label',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            showAppMessage('$label copied to clipboard.');
          },
          icon: Icon(LucideIcons.copy, color: cs.primary, size: 16),
        ),
      ]),
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

  void _showChangeInvestorPassword(BrokerAccount a) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _ChangeInvestorPasswordSheet(account: a),
    );
  }

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

    final bottomNavPadding = 116.0 + MediaQuery.paddingOf(context).bottom;

    return Container(
      color: bg,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(14, 4, 14, bottomNavPadding),
        children: [
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: border)),
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(12, 11, 12, 10), child: Row(children: [
                const _AccountLogoBadge(size: 48),
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
          const SizedBox(height: 12),
          if (a.type == 'Live MT5') ...[
            Row(children: [
              action(LucideIcons.arrowDown, 'Deposit', true, () => widget.onSelectPage('Deposit')),
              const SizedBox(width: 8),
              action(LucideIcons.arrowUp, 'Withdraw', false, () => widget.onSelectPage('Withdraw')),
              const SizedBox(width: 8),
              action(LucideIcons.arrowLeftRight, 'Transfer', false, () => widget.onSelectPage('Internal Transfer')),
              const SizedBox(width: 8),
              action(LucideIcons.settings, 'Settings', false, () => _showChangeInvestorPassword(a)),
            ]),
            const SizedBox(height: 14),
          ] else ...[
            Row(children: [
              action(LucideIcons.settings, 'Settings', false, () => _showChangeInvestorPassword(a)),
            ]),
            const SizedBox(height: 14),
          ],
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
                  Expanded(child: stat(LucideIcons.target, 'Sample win rate', trades.isEmpty ? '—' : '${winRate.toStringAsFixed(1)}%', blue)),
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
              ...a.openPositions.map((p) => _detailTradeRow(context, p.symbol, '${p.side.toUpperCase()} • ${p.volume} lots • Entry ${p.openPrice} • Mark ${p.currentPrice}', _money(p.profit), p.profit >= 0 ? green : red, fg, muted, border)),
            ])),
          ] else ...[
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Trade history', style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (trades.isEmpty) Text('No closed trades are available in this account preview.', style: TextStyle(color: muted, fontSize: 10)),
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
