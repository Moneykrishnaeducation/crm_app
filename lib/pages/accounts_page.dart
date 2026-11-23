part of '../main.dart';

class BrokerAccountsPage extends StatefulWidget {
  const BrokerAccountsPage({
    super.key,
    required this.onSelectPage,
    required this.accounts,
    required this.onAccountCreated,
    required this.onAccountSelected,
    required this.favoriteLogins,
    required this.onToggleFavorite,
    this.scrollController,
    this.isLoading = false,
    this.loadError,
    this.onRetry,
  });
  final ValueChanged<String> onSelectPage;
  final List<BrokerAccount> accounts;
  final ValueChanged<BrokerAccount> onAccountCreated;
  final ValueChanged<BrokerAccount> onAccountSelected;
  final Set<String> favoriteLogins;
  final ValueChanged<String> onToggleFavorite;
  final ScrollController? scrollController;
  final bool isLoading;
  final String? loadError;
  final VoidCallback? onRetry;
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
    final filtered = liveAccounts.where((a) => query.isEmpty || a.login.toLowerCase().contains(query) || a.name.toLowerCase().contains(query)).toList()
      ..sort((a, b) => (widget.favoriteLogins.contains(b.login) ? 1 : 0).compareTo(widget.favoriteLogins.contains(a.login) ? 1 : 0));
    final surface = theme.colorScheme.surface;
    final border = theme.dividerColor.withValues(alpha: dark ? .72 : .8);
    final fg = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final bottomNavPadding = 116.0 + MediaQuery.paddingOf(context).bottom;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        controller: widget.scrollController,
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
          if (widget.isLoading && widget.accounts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 44),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.loadError != null && widget.accounts.isEmpty)
            _AccountLoadError(message: widget.loadError!, onRetry: widget.onRetry)
          else if (filtered.isEmpty)
            _AccountEmptyState(searching: _query.isNotEmpty, onClear: () { _searchController.clear(); setState(() => _query = ''); })
          else
            ...filtered.map((account) => _ReferenceAccountCard(account: account, isFavorite: widget.favoriteLogins.contains(account.login), onToggleFavorite: () => widget.onToggleFavorite(account.login), onTap: () => widget.onAccountSelected(account))),
        ],
      ),
    );
  }
}

class _ReferenceAccountCard extends StatelessWidget {
  const _ReferenceAccountCard({
    required this.account,
    this.isFavorite = false,
    this.onToggleFavorite,
    required this.onTap,
    bool? selected,
  }) : _legacySelected = selected;

  final BrokerAccount account;
  final bool isFavorite;
  final bool? _legacySelected;
  final VoidCallback? onToggleFavorite;
  final VoidCallback onTap;

  bool get effectiveFavorite => isFavorite || (_legacySelected ?? false);

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
    final neutralChartColor = dark ? const Color(0xFF75A9FF) : const Color(0xFF2865D8);
    final chartColor = pnl > 0 ? green : pnl < 0 ? red : neutralChartColor;
    final fg = theme.colorScheme.onSurface;
    final muted = theme.colorScheme.onSurfaceVariant;
    final fav = effectiveFavorite;
    final border = fav ? gold.withValues(alpha: .9) : theme.dividerColor.withValues(alpha: dark ? .75 : .9);
    final equity = account.equityHistory.isNotEmpty ? account.equityHistory : <double>[1, 1.1, 1.04, 1.2, 1.13, 1.3, 1.26, 1.4];
    final sparkWidth = MediaQuery.sizeOf(context).width < 380 ? 48.0 : 70.0;

    return Padding(padding: const EdgeInsets.only(bottom: 11), child: Material(
      color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: fav ? 1.6 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: dark ? .10 : .035), blurRadius: 14, offset: const Offset(0, 5)),
            if (fav) BoxShadow(color: gold.withValues(alpha: dark ? .08 : .06), blurRadius: 14),
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
            SizedBox(width: sparkWidth, height: 35, child: CustomPaint(
              key: const ValueKey('account_list_performance_chart'),
              painter: _PortfolioLinePainter(
                values: equity,
                lineColor: chartColor,
                fillColor: chartColor.withValues(alpha: .10),
              ),
            )),
            const SizedBox(width: 2),
            if (onToggleFavorite != null)
              IconButton(
                tooltip: fav ? 'Remove from favorites' : 'Add to favorites',
                onPressed: onToggleFavorite,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                padding: EdgeInsets.zero,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.elasticOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => RotationTransition(
                    turns: Tween<double>(begin: -.12, end: 0).animate(animation),
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Icon(
                    fav ? Icons.star_rounded : Icons.star_outline_rounded,
                    key: ValueKey<bool>(fav),
                    color: fav ? gold : muted,
                    size: 21,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(fav ? LucideIcons.star : LucideIcons.chevronRight, color: fav ? gold : muted, size: 19),
              ),
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

class _AccountLoadError extends StatelessWidget {
  const _AccountLoadError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.wifiOff, color: theme.colorScheme.error, size: 28),
          const SizedBox(height: 12),
          Text(
            'Unable to load accounts',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
              height: 1.45,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 15),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
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

  BrokerAccount copyWith({
    String? name,
    String? login,
    String? leverage,
    String? balance,
    String? equity,
    String? type,
    String? server,
    String? currency,
    double? floatingPnl,
    List<double>? equityHistory,
    List<BrokerOpenPosition>? openPositions,
    List<BrokerTradeRecord>? recentTrades,
  }) {
    return BrokerAccount(
      name ?? this.name,
      login ?? this.login,
      leverage ?? this.leverage,
      balance ?? this.balance,
      equity ?? this.equity,
      type ?? this.type,
      server: server ?? this.server,
      currency: currency ?? this.currency,
      floatingPnl: floatingPnl ?? this.floatingPnl,
      equityHistory: equityHistory ?? this.equityHistory,
      openPositions: openPositions ?? this.openPositions,
      recentTrades: recentTrades ?? this.recentTrades,
    );
  }
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

enum _SettingsView { menu, investorPassword, updateLeverage }
enum _PasswordStep { input, confirm, done }

class _BrokerAccountSettingsSheet extends StatefulWidget {
  const _BrokerAccountSettingsSheet({
    required this.account,
    this.onLeverageUpdated,
  });

  final BrokerAccount account;
  final ValueChanged<String>? onLeverageUpdated;

  @override
  State<_BrokerAccountSettingsSheet> createState() => _BrokerAccountSettingsSheetState();
}

typedef _ChangeInvestorPasswordSheet = _BrokerAccountSettingsSheet;

class _BrokerAccountSettingsSheetState extends State<_BrokerAccountSettingsSheet> {
  _SettingsView _activeView = _SettingsView.menu;

  // Investor password state
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;
  _PasswordStep _step = _PasswordStep.input;
  String? _savedPassword;

  // Leverage state
  late String _currentLeverage = widget.account.leverage;
  late String _selectedLeverage = widget.account.leverage;
  bool _leverageUpdated = false;

  static const List<String> _leverageOptions = [
    '1:50',
    '1:100',
    '1:200',
    '1:300',
    '1:400',
    '1:500',
  ];

  static const Map<String, String> _leverageMargins = {
    '1:50': '2.00% Margin',
    '1:100': '1.00% Margin',
    '1:200': '0.50% Margin',
    '1:300': '0.33% Margin',
    '1:400': '0.25% Margin',
    '1:500': '0.20% Margin',
  };

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

  void _onApplyLeverage() {
    if (_selectedLeverage == _currentLeverage) {
      showAppMessage('Selected leverage is already active.');
      return;
    }

    setState(() {
      _currentLeverage = _selectedLeverage;
      _leverageUpdated = true;
    });

    widget.onLeverageUpdated?.call(_selectedLeverage);

    unawaited(AppNotificationCenter.instance.sendNotification(
      title: 'Leverage Updated (#${widget.account.login})',
      body: 'Account #${widget.account.login} leverage changed to $_selectedLeverage.',
      category: 'Trading',
      icon: LucideIcons.scale,
      isGold: true,
      sendToMobilePanel: true,
    ));
    showAppMessage('Leverage updated to $_selectedLeverage successfully.');
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

    IconData headerIcon;
    Color headerIconColor;
    String headerTitle;
    String headerSubtitle;
    bool canGoBack;

    switch (_activeView) {
      case _SettingsView.menu:
        headerIcon = LucideIcons.settings;
        headerIconColor = _brokerGold;
        headerTitle = 'Account Settings';
        headerSubtitle = 'Account #${widget.account.login} (${widget.account.name})';
        canGoBack = false;
        break;
      case _SettingsView.investorPassword:
        headerIcon = isDone
            ? LucideIcons.shieldCheck
            : (isConfirm ? LucideIcons.shieldAlert : LucideIcons.keyRound);
        headerIconColor = isDone
            ? const Color(0xFF10B981)
            : (isConfirm ? const Color(0xFFD8A82E) : cs.primary);
        headerTitle = isDone
            ? 'Password Updated'
            : (isConfirm ? 'Confirm Password Change' : 'Change Investor Password');
        headerSubtitle = isDone
            ? 'Account #${widget.account.login} · Ready'
            : (isConfirm
                ? 'Review and confirm update for #${widget.account.login}'
                : 'MT5 Read-only access for #${widget.account.login}');
        canGoBack = !isDone;
        break;
      case _SettingsView.updateLeverage:
        if (_leverageUpdated) {
          headerIcon = LucideIcons.shieldCheck;
          headerIconColor = const Color(0xFF10B981);
          headerTitle = 'Leverage Updated';
          headerSubtitle = 'Account #${widget.account.login} · Active';
          canGoBack = false;
        } else {
          headerIcon = LucideIcons.scale;
          headerIconColor = const Color(0xFFD8A82E);
          headerTitle = 'Update Leverage';
          headerSubtitle = 'Account #${widget.account.login} · Current: $_currentLeverage';
          canGoBack = true;
        }
        break;
    }

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
                    padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
                    child: Row(
                      children: [
                        if (canGoBack) ...[
                          IconButton(
                            tooltip: 'Back to Settings',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              if (_activeView == _SettingsView.investorPassword && _step == _PasswordStep.confirm) {
                                setState(() => _step = _PasswordStep.input);
                              } else {
                                setState(() => _activeView = _SettingsView.menu);
                              }
                            },
                            icon: Icon(LucideIcons.arrowLeft, color: cs.onSurface, size: 20),
                          ),
                          const SizedBox(width: 4),
                        ],
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
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                headerSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      child: switch (_activeView) {
                        _SettingsView.menu => _buildMenuView(cs, border, muted, dark),
                        _SettingsView.investorPassword => switch (_step) {
                          _PasswordStep.input => _buildInputView(cs, border, muted, dark),
                          _PasswordStep.confirm => _buildConfirmView(cs, border, muted, dark),
                          _PasswordStep.done => _buildSuccessView(cs, border, muted),
                        },
                        _SettingsView.updateLeverage => _leverageUpdated
                            ? _buildLeverageSuccessView(cs, border, muted, dark)
                            : _buildLeverageInputView(cs, border, muted, dark),
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

  Widget _buildMenuView(ColorScheme cs, Color border, Color muted, bool dark) {
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
              Icon(LucideIcons.sparkles, color: cs.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Manage security credentials and leverage parameters for MT5 Account #${widget.account.login}.',
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
        Row(
          children: [
            Text('01', style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text('ACCOUNT FUNCTIONS', style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
          ],
        ),
        const SizedBox(height: 12),

        // Function 1: Change Investor Password
        _buildFunctionCard(
          cs: cs,
          border: border,
          muted: muted,
          dark: dark,
          icon: LucideIcons.keyRound,
          iconColor: cs.primary,
          title: 'Change Investor Password',
          subtitle: 'Set or update MT5 read-only access password',
          trailingText: 'Security',
          onTap: () => setState(() => _activeView = _SettingsView.investorPassword),
        ),

        const SizedBox(height: 12),

        // Function 2: Update Leverage
        _buildFunctionCard(
          cs: cs,
          border: border,
          muted: muted,
          dark: dark,
          icon: LucideIcons.scale,
          iconColor: const Color(0xFFD8A82E),
          title: 'Update Leverage',
          subtitle: 'Current: $_currentLeverage · Modify purchasing power & margin',
          trailingText: _currentLeverage,
          onTap: () => setState(() => _activeView = _SettingsView.updateLeverage),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: dark ? .35 : .45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.shieldCheck, size: 18, color: const Color(0xFF10B981)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Trading operations, floating P/L, and open positions are preserved during settings updates.',
                  style: TextStyle(color: muted, fontSize: 11, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionCard({
    required ColorScheme cs,
    required Color border,
    required Color muted,
    required bool dark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? .18 : .04),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingText,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(LucideIcons.chevronRight, size: 17, color: muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeverageInputView(ColorScheme cs, Color border, Color muted, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFD8A82E).withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8A82E).withValues(alpha: .28)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.info, color: Color(0xFFD8A82E), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Changing your account leverage will adjust the margin requirements for all new positions.',
                  style: TextStyle(color: cs.onSurface, fontSize: 11, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Current Leverage Tile
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: dark ? .35 : .45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.scale, size: 18, color: Color(0xFFD8A82E)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT LEVERAGE', style: TextStyle(color: muted, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: .6)),
                    const SizedBox(height: 2),
                    Text(_currentLeverage, style: TextStyle(color: cs.onSurface, fontSize: 16, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: .30)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 7),
                    SizedBox(width: 5),
                    Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Text('01', style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Text('CHOOSE NEW LEVERAGE RATIO', style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
          ],
        ),
        const SizedBox(height: 12),

        // Grid of leverage options
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _leverageOptions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemBuilder: (context, index) {
            final option = _leverageOptions[index];
            final isSelected = option == _selectedLeverage;
            final isCurrent = option == _currentLeverage;
            final marginDesc = _leverageMargins[option] ?? '';

            return InkWell(
              onTap: () => setState(() => _selectedLeverage = option),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _brokerGold.withValues(alpha: dark ? .15 : .10)
                      : cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _brokerGold : border,
                    width: isSelected ? 1.8 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _brokerGold.withValues(alpha: .18),
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                option,
                                style: TextStyle(
                                  color: isSelected ? _brokerGold : cs.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: muted.withValues(alpha: .15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Current', style: TextStyle(color: muted, fontSize: 8.5, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            marginDesc,
                            style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? _brokerGold : muted.withValues(alpha: .5),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // Risk warning
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: dark ? .30 : .40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(LucideIcons.alertTriangle, size: 15, color: Color(0xFFD8A82E)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'High leverage increases risk. Ensure your account margin is adequate before applying changes.',
                  style: TextStyle(color: muted, fontSize: 10.5, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeverageSuccessView(ColorScheme cs, Color border, Color muted, bool dark) {
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
            'Leverage Successfully Updated',
            style: TextStyle(color: cs.onSurface, fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'The new leverage ratio has been applied to account #${widget.account.login}.',
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ),
        const SizedBox(height: 20),
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
              _summaryRow('Previous Leverage', widget.account.leverage, cs, muted),
              Divider(height: 18, color: border.withValues(alpha: .5)),
              _summaryRow('Active New Leverage', _selectedLeverage, cs, muted),
              Divider(height: 18, color: border.withValues(alpha: .5)),
              _summaryRow('Effective Margin', _leverageMargins[_selectedLeverage] ?? '', cs, muted),
              Divider(height: 18, color: border.withValues(alpha: .5)),
              _summaryRow('Status', 'Active & Applied', cs, muted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, ColorScheme cs, Color border) {
    switch (_activeView) {
      case _SettingsView.menu:
        return SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.onSurface,
              side: BorderSide(color: border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('CLOSE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35)),
          ),
        );
      case _SettingsView.investorPassword:
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
      case _SettingsView.updateLeverage:
        if (_leverageUpdated) {
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
              label: const Text('DONE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35)),
            ),
          );
        }
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _activeView = _SettingsView.menu),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('BACK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _onApplyLeverage,
                  style: FilledButton.styleFrom(
                    backgroundColor: _brokerGold,
                    foregroundColor: const Color(0xFF142238),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text('CONFIRM LEVERAGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35)),
                ),
              ),
            ),
          ],
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
  const BrokerAccountDetailsPage({super.key, required this.account, required this.onBack, required this.onSelectPage, required this.isFavorite, required this.onToggleFavorite});
  final BrokerAccount account;
  final VoidCallback onBack;
  final ValueChanged<String> onSelectPage;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  @override
  State<BrokerAccountDetailsPage> createState() => _BrokerAccountDetailsPageState();
}

class _BrokerAccountDetailsPageState extends State<BrokerAccountDetailsPage> {
  String _tab = 'Overview';
  String _range = '1W';
  late BrokerAccount _account = widget.account;
  List<Map<String, dynamic>> _livePositions = <Map<String, dynamic>>[];
  bool _detailsLoading = false;
  bool _positionsLoading = false;
  String? _detailsError;
  String? _positionsError;
  final Set<String> _closingTickets = <String>{};

  @override
  void initState() {
    super.initState();
    _loadAccountData();
  }

  @override
  void didUpdateWidget(covariant BrokerAccountDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.login != widget.account.login) {
      _account = widget.account;
      _livePositions = <Map<String, dynamic>>[];
      _loadAccountData();
    } else if (oldWidget.account != widget.account) {
      _account = widget.account;
    }
  }

  double _apiNumber(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _apiMoney(dynamic value, String currency) {
    final amount = _apiNumber(value);
    return '$currency ' + amount.toStringAsFixed(2);
  }

  Future<void> _loadAccountData() async {
    await Future.wait<void>([
      _loadAccountDetails(),
      _loadOpenPositions(),
    ]);
  }

  Future<void> _loadAccountDetails() async {
    if (mounted) setState(() { _detailsLoading = true; _detailsError = null; });
    try {
      final data = await AuthApi.instance.getAccountDetails(_account.login);
      if (!mounted) return;
      final currency = (data['currency'] ?? _account.currency).toString();
      setState(() {
        _account = _account.copyWith(
          name: (data['account_name'] ?? data['name'] ?? _account.name).toString(),
          balance: _apiMoney(data['balance'] ?? _account.balance, currency),
          equity: _apiMoney(data['equity'] ?? _account.equity, currency),
          leverage: '1:${data['leverage'] ?? _account.leverage.replaceFirst('1:', '')}',
          currency: currency,
          floatingPnl: _apiNumber(data['profit'] ?? data['floating_pnl'] ?? 0),
          server: (data['server'] ?? data['server_name'] ?? _account.server)?.toString(),
        );
        _detailsLoading = false;
      });
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() { _detailsLoading = false; _detailsError = error.message; });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _detailsLoading = false;
        _detailsError = 'Unable to load account information. Try again.';
      });
    }
  }

  Future<void> _loadOpenPositions() async {
    if (mounted) setState(() { _positionsLoading = true; _positionsError = null; });
    try {
      final positions = await AuthApi.instance.getOpenPositions(_account.login);
      if (!mounted) return;
      setState(() {
        _livePositions = positions;
        _positionsLoading = false;
      });
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() { _positionsLoading = false; _positionsError = error.message; });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _positionsLoading = false;
        _positionsError = 'Unable to load open positions. Try again.';
      });
    }
  }

  Future<void> _confirmAndClosePosition(Map<String, dynamic> position) async {
    final ticket = (position['ticket'] ?? position['id'] ?? '').toString();
    if (ticket.isEmpty) {
      showAppMessage('This position does not include a valid MT5 ticket.');
      return;
    }
    final symbol = (position['symbol'] ?? 'this position').toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close position?'),
        content: Text('You are about to close $symbol (ticket $ticket). This action will be sent to MT5 and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Close position'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _closingTickets.add(ticket));
    try {
      final result = await AuthApi.instance.closePosition(
        accountId: _account.login,
        ticket: ticket,
      );
      if (!mounted) return;
      if (result['success'] == false) {
        throw AuthApiException(
          (result['message'] ?? 'MT5 could not close this position.').toString(),
        );
      }
      showAppMessage((result['message'] ?? 'Position closed successfully.').toString());
      await _loadAccountData();
    } on AuthApiException catch (error) {
      if (mounted) showAppMessage(error.message);
    } catch (_) {
      if (mounted) showAppMessage('Unable to close this position. Refresh and check its status before retrying.');
    } finally {
      if (mounted) setState(() => _closingTickets.remove(ticket));
    }
  }

  String _money(double value) => (value < 0 ? '-' : '') + r'$' + value.abs().toStringAsFixed(2);

  void _showChangeInvestorPassword(BrokerAccount a) => _showAccountSettings(a);

  void _showAccountSettings(BrokerAccount a) {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: Colors.transparent, barrierColor: Colors.black54,
      builder: (_) => _BrokerAccountSettingsSheet(
        account: _account,
        onLeverageUpdated: (newLeverage) {
          setState(() {
            _account = _account.copyWith(leverage: newLeverage);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = _account;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    const navy = Color(0xFF071629);
    const panel = Color(0xFF101F34);
    const gold = Color(0xFFFFC533);
    const blue = Color(0xFF39B5FF);
    const green = Color(0xFF08D879);
    const red = Color(0xFFFF6268);
    final neutralChartColor = dark ? const Color(0xFF75A9FF) : const Color(0xFF2865D8);
    final bg = dark ? navy : theme.scaffoldBackgroundColor;
    final surface = dark ? panel : Colors.white;
    final border = dark ? const Color(0xFF29415F) : const Color(0xFFD9E2EE);
    final fg = dark ? const Color(0xFFF5F7FC) : const Color(0xFF10213A);
    final muted = dark ? const Color(0xFFA9B9CE) : const Color(0xFF718096);
    final isLive = a.type == 'Live MT5';
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
    final chartColor = changePct > 0 ? green : changePct < 0 ? red : neutralChartColor;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
    final bottomNavPadding = 116.0 + MediaQuery.paddingOf(context).bottom;
    final actionWidth = (screenWidth - horizontalPadding * 2 - 24) / 4;

    Widget metric(String label, String value, {Color? valueColor, bool prominent = false}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .35)),
          const SizedBox(height: 6),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(color: valueColor ?? fg, fontSize: prominent ? 21 : 16, fontWeight: FontWeight.w900, letterSpacing: -.4))),
        ]),
      ),
    );

    Widget infoCell(IconData icon, String label, String value) => Expanded(
      child: Row(children: [
        Icon(icon, color: const Color(0xFF8FB5E0), size: 17),
        const SizedBox(width: 7),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w800)),
        ])),
      ]),
    );

    Widget action(IconData icon, String label, bool primary, VoidCallback onTap, double width) => SizedBox(
      width: width, height: 68,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: primary ? gold : surface,
          foregroundColor: primary ? const Color(0xFF101A29) : fg,
          side: BorderSide(color: primary ? gold : border, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 19), const SizedBox(height: 5),
          FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
        ]),
      ),
    );

    Widget tab(String value) {
      final selected = _tab == value;
      return Expanded(child: Semantics(
        button: true, selected: selected, label: value + ' tab',
        child: InkWell(
          onTap: () => setState(() => _tab = value),
          borderRadius: BorderRadius.circular(11),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160), height: 42,
            decoration: BoxDecoration(color: selected ? gold : Colors.transparent, borderRadius: BorderRadius.circular(11)),
            alignment: Alignment.center,
            child: Text(value, style: TextStyle(color: selected ? const Color(0xFF101A29) : fg, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        ),
      ));
    }

    Widget stat(IconData icon, String label, String value, Color accent) => Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: border)),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: accent.withValues(alpha: .13), shape: BoxShape.circle), child: Icon(icon, color: accent, size: 16)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 9, height: 1.2)),
          const SizedBox(height: 4),
          FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w900))),
        ])),
      ]),
    );

    Widget sectionTitle(String title, {String? trailing}) => Row(children: [
      Expanded(child: Text(title, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -.2))),
      if (trailing != null) Text(trailing, style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w700)),
    ]);

    Widget panelCard({required Widget child, EdgeInsets padding = const EdgeInsets.all(14)}) => Container(
      padding: padding,
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
      child: child,
    );

    return Container(
      color: bg,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, bottomNavPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark ? const [Color(0xFF173B60), Color(0xFF10243D)] : const [Color(0xFF173F68), Color(0xFF102B4B)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: const Color(0xFF4A7198).withValues(alpha: .45)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .18 : .08), blurRadius: 18, offset: const Offset(0, 7))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 56, height: 56, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)),
                  child: const _AccountLogoBadge(size: 46)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.login, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .68), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: .45)),
                  const SizedBox(height: 5),
                  Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                ])),
                IconButton(
                  onPressed: widget.onToggleFavorite,
                  tooltip: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(width: 42, height: 42),
                  padding: EdgeInsets.zero,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.elasticOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => RotationTransition(
                      turns: Tween<double>(begin: -.12, end: 0).animate(animation),
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Icon(
                      widget.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      key: ValueKey<bool>(widget.isFavorite),
                      color: widget.isFavorite ? gold : Colors.white.withValues(alpha: .75),
                      size: 25,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              Text('ACCOUNT BALANCE', style: TextStyle(color: Colors.white.withValues(alpha: .68), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.15)),
              const SizedBox(height: 5),
              Text(a.balance, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.8)),
              const SizedBox(height: 16),
              Container(height: 1, color: Colors.white.withValues(alpha: .15)),
              const SizedBox(height: 12),
              Row(children: [
                metric('EQUITY', a.equity, valueColor: Colors.white),
                Container(width: 1, height: 34, color: Colors.white.withValues(alpha: .2)),
                metric('FLOATING P/L', pnl == null ? '—' : _money(pnl), valueColor: pnlColor == muted ? Colors.white70 : pnlColor),
              ]),
            ]),
          ),
          const SizedBox(height: 13),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (isLive) ...[
              action(LucideIcons.arrowDownToLine, 'Deposit', true, () => widget.onSelectPage('Deposit'), actionWidth),
              action(LucideIcons.arrowUpFromLine, 'Withdraw', false, () => widget.onSelectPage('Withdraw'), actionWidth),
              action(LucideIcons.arrowLeftRight, 'Transfer', false, () => widget.onSelectPage('Internal Transfer'), actionWidth),
            ],
            action(LucideIcons.settings, 'Settings', false, () => _showAccountSettings(_account), isLive ? actionWidth : (screenWidth - horizontalPadding * 2 - 8) / 2),
          ]),
          const SizedBox(height: 17),
          panelCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(children: [
              infoCell(LucideIcons.scale, 'Leverage', a.leverage),
              Container(width: 1, height: 34, color: border),
              const SizedBox(width: 9),
              infoCell(LucideIcons.coins, 'Currency', a.currency),
              Container(width: 1, height: 34, color: border),
              const SizedBox(width: 9),
              infoCell(LucideIcons.server, 'Server', a.server ?? 'Not connected'),
            ]),
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: border)),
            child: Row(children: [tab('Overview'), tab('Trading Stats'), tab('History')]),
          ),
          const SizedBox(height: 13),
          if (_tab == 'Overview') ...[
            panelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 34, height: 34, decoration: BoxDecoration(color: blue.withValues(alpha: .12), borderRadius: BorderRadius.circular(11)), child: const Icon(LucideIcons.chartNoAxesCombined, color: blue, size: 18)),
                const SizedBox(width: 9),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Account performance', style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w900)),
                  Text('Equity history', style: TextStyle(color: muted, fontSize: 9)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(color: (changePct >= 0 ? green : red).withValues(alpha: .13), borderRadius: BorderRadius.circular(20)),
                  child: Text((changePct >= 0 ? '+' : '') + changePct.toStringAsFixed(2) + '%', style: TextStyle(color: changePct >= 0 ? green : red, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              ]),
              const SizedBox(height: 13),
              if (history.length > 1)
                LayoutBuilder(builder: (context, constraints) {
                  final chartHeight = (constraints.maxWidth * .30).clamp(92.0, 124.0);
                  return SizedBox(
                    height: chartHeight,
                    width: double.infinity,
                    child: CustomPaint(
                      key: const ValueKey('account_detail_performance_chart'),
                      painter: _PortfolioLinePainter(
                        values: chartHistory,
                        lineColor: chartColor,
                        fillColor: chartColor.withValues(alpha: .10),
                      ),
                    ),
                  );
                })
              else
                SizedBox(height: 105, child: Center(child: Text('Performance history will appear after MT5 sync.', style: TextStyle(color: muted, fontSize: 10)))),
              const SizedBox(height: 8),
              Row(children: ['1D', '1W', '1M', '3M', 'YTD', 'All'].map((value) {
                final selected = _range == value;
                return Expanded(child: Semantics(button: true, selected: selected, label: value + ' performance range', child: InkWell(
                  onTap: () => setState(() => _range = value),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    constraints: const BoxConstraints(minHeight: 40),
                    decoration: BoxDecoration(
                      color: selected
                          ? (dark ? const Color(0xFF1D3B68) : const Color(0xFFEAF1FF))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: selected
                            ? (dark ? const Color(0xFF9CC3FF) : const Color(0xFF2459C7))
                            : muted,
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                )));
              }).toList()),
            ])),
            const SizedBox(height: 13),
            sectionTitle('Trading snapshot', trailing: 'Based on available records'),
            const SizedBox(height: 9),
            Row(children: [
              Expanded(child: stat(LucideIcons.receiptText, 'Closed trades', trades.length.toString(), blue)),
              const SizedBox(width: 9),
              Expanded(child: stat(LucideIcons.target, 'Win rate', trades.isEmpty ? '—' : winRate.toStringAsFixed(1) + '%', blue)),
            ]),
            const SizedBox(height: 9),
            Row(children: [
              Expanded(child: stat(LucideIcons.trendingUp, 'Winning trades', wins.toString(), green)),
              const SizedBox(width: 9),
              Expanded(child: stat(LucideIcons.trendingDown, 'Losing trades', losses.toString(), red)),
            ]),
            const SizedBox(height: 13),
            panelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              sectionTitle('Account information', trailing: 'MT5'),
              const SizedBox(height: 9),
              _detailInfoRow(context, LucideIcons.hash, 'Login ID', a.login, fg, muted, border),
              _detailInfoRow(context, LucideIcons.server, 'Server', a.server ?? 'Not provided', fg, muted, border),
              _detailInfoRow(context, LucideIcons.gauge, 'Leverage', a.leverage, fg, muted, border),
              _detailInfoRow(context, LucideIcons.coins, 'Currency', a.currency, fg, muted, border),
              _detailInfoRow(context, LucideIcons.shieldCheck, 'Account type', a.type, fg, muted, border),
            ])),
          ] else if (_tab == 'Trading Stats') ...[
            Row(children: [
              Expanded(child: stat(LucideIcons.trendingUp, 'Average win', _money(averageWin), green)),
              const SizedBox(width: 9),
              Expanded(child: stat(LucideIcons.trendingDown, 'Average loss', _money(-averageLoss), red)),
            ]),
            const SizedBox(height: 9),
            Row(children: [
              Expanded(child: stat(LucideIcons.chartLine, 'Net P/L (shown trades)', _money(totalProfit), totalProfit >= 0 ? green : red)),
              const SizedBox(width: 9),
              Expanded(child: stat(LucideIcons.activity, 'Open positions', a.openPositions.length.toString(), blue)),
            ]),
            const SizedBox(height: 13),
            panelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              sectionTitle('Open positions', trailing: a.openPositions.length.toString() + ' positions'),
              const SizedBox(height: 8),
              if (a.openPositions.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 17), child: Center(child: Text('No open positions.', style: TextStyle(color: muted, fontSize: 11)))),
              ...a.openPositions.map((p) => _detailTradeRow(context, p.symbol, p.side.toUpperCase() + ' • ' + p.volume + ' lots • Entry ' + p.openPrice + ' • Mark ' + p.currentPrice, _money(p.profit), p.profit >= 0 ? green : red, fg, muted, border)),
            ])),
          ] else ...[
            panelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              sectionTitle('Trade history', trailing: trades.length.toString() + ' records'),
              const SizedBox(height: 8),
              if (trades.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 17), child: Center(child: Text('No closed trades are available in this account preview.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 10)))),
              ...trades.map((t) => _detailTradeRow(context, t.symbol, t.side.toUpperCase() + ' • ' + t.volume + ' lots • ' + t.closedAt, _money(t.profit), t.profit >= 0 ? green : red, fg, muted, border)),
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
