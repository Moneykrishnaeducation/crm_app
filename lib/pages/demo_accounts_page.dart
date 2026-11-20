part of '../main.dart';

class BrokerDemoAccountsPage extends StatefulWidget {
  const BrokerDemoAccountsPage({
    super.key,
    VoidCallback? onOpenLiveAccounts,
    VoidCallback? onOpenTradingAccounts,
    this.onAccountSelected = _noopAccount,
    this.accounts,
    this.onAccountCreated,
  })  : onOpenLiveAccounts = onOpenLiveAccounts ?? onOpenTradingAccounts ?? _noop;

  static void _noop() {}
  static void _noopAccount(BrokerAccount account) {}
  final VoidCallback onOpenLiveAccounts;
  final ValueChanged<BrokerAccount> onAccountSelected;
  final List<BrokerAccount>? accounts;
  final ValueChanged<BrokerAccount>? onAccountCreated;
  @override
  State<BrokerDemoAccountsPage> createState() => _BrokerDemoAccountsPageState();
}

class _BrokerDemoAccountsPageState extends State<BrokerDemoAccountsPage> {
  final _searchController = TextEditingController();
  final List<BrokerAccount> _localDemoAccounts = [
    BrokerAccount(
      'Demo Standard',
      '3498102',
      '1:500',
      r'$10,000.00',
      r'$10,000.00',
      'Demo MT5 Standard',
      server: 'VTIndex-Demo',
      currency: 'USD',
      floatingPnl: 0.0,
    ),
  ];
  String _query = '';

  List<BrokerAccount> get _effectiveAccounts =>
      widget.accounts ?? _localDemoAccounts;

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
    final surface = dark ? panel : Colors.white;
    final border = dark ? const Color(0xFF29415F) : const Color(0xFFD9E2EE);
    final fg = dark ? const Color(0xFFF5F7FC) : const Color(0xFF10213A);
    final muted = dark ? const Color(0xFFA9B9CE) : const Color(0xFF6F7F95);
    final accounts = _effectiveAccounts;
    final filtered = accounts.where((a) {
      final q = _query.trim().toLowerCase();
      return q.isEmpty || a.login.toLowerCase().contains(q) || a.name.toLowerCase().contains(q);
    }).toList();
    final totalBalance = accounts.fold<double>(0, (sum, a) =>
        sum + (double.tryParse(a.balance.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0));

    final bottomNavPadding = 110.0 + MediaQuery.paddingOf(context).bottom;

    return Container(
      color: dark ? navy : Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.fromLTRB(14, 12, 14, bottomNavPadding),
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ACCOUNTS', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              const SizedBox(height: 5),
              Text('Demo Accounts', style: TextStyle(color: fg, fontSize: 26, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.65)),
              const SizedBox(height: 5),
              Text('Your simulated MT5 trading accounts', style: TextStyle(color: muted, fontSize: 12, height: 1.35)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: border)),
              child: Row(children: [
                const Icon(LucideIcons.flaskConical, color: blue, size: 15),
                const SizedBox(width: 6),
                Text('${_effectiveAccounts.length} Demo', style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: widget.onOpenLiveAccounts,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: dark ? const Color(0xFF8CCBFF) : const Color(0xFF174A8B),
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  icon: const Icon(LucideIcons.chartCandlestick, size: 16),
                  label: const Text('Live Accounts', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: SizedBox(
                height: 46,
                child: FilledButton.icon(
                  onPressed: _showCreateSheet,
                  style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF101A29),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8)),
                  icon: const Icon(LucideIcons.plusCircle, size: 16),
                  label: const Text('Create Demo', maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DemoMetric(icon: LucideIcons.wallet, label: 'VIRTUAL BALANCE',
              value: r'$ ' + totalBalance.toStringAsFixed(2), surface: surface, border: border, fg: fg, muted: muted, accent: blue)),
            const SizedBox(width: 9),
            Expanded(child: _DemoMetric(icon: LucideIcons.flaskConical, label: 'DEMO ACCOUNTS',
              value: '${_effectiveAccounts.length}', surface: surface, border: border, fg: fg, muted: muted, accent: gold)),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(color: fg, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search by account number, name...',
              hintStyle: TextStyle(color: muted, fontSize: 11),
              prefixIcon: Icon(LucideIcons.search, color: muted, size: 19),
              filled: true, fillColor: surface, isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: blue, width: 1.3)),
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 30, 18, 30),
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
              child: Column(children: [
                Container(width: 62, height: 62,
                  decoration: BoxDecoration(color: blue.withValues(alpha: .10), shape: BoxShape.circle),
                  child: Icon(_query.isEmpty ? LucideIcons.flaskConical : LucideIcons.searchX, color: blue, size: 27)),
                const SizedBox(height: 13),
                Text(_query.isEmpty ? 'No demo accounts yet' : 'No matching demo accounts',
                  textAlign: TextAlign.center, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(_query.isEmpty
                    ? 'Create a virtual MT5 account to practise with a balance and leverage of your choice.'
                    : 'Try another account name or login ID, or clear your search.',
                  textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 11, height: 1.5)),
                const SizedBox(height: 15),
                if (_query.isEmpty)
                  OutlinedButton.icon(onPressed: _showCreateSheet, icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Create Demo Account'))
                else
                  OutlinedButton.icon(onPressed: () { _searchController.clear(); setState(() => _query = ''); },
                    icon: const Icon(LucideIcons.x, size: 15), label: const Text('Clear search')),
                const SizedBox(height: 8),
                Text('Demo trading only · No real-money transactions', style: TextStyle(color: muted, fontSize: 9)),
              ]),
            )
          else
            ...filtered.map((account) => _ReferenceAccountCard(
              account: account,
              isFavorite: false,
              onTap: () => widget.onAccountSelected(account),
            )),
        ],
      ),
    );
  }

  void _showCreateSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _CreateDemoAccountSheet(
        onCreated: (newAccount) {
          if (widget.onAccountCreated != null) {
            widget.onAccountCreated!(newAccount);
          } else {
            setState(() {
              _localDemoAccounts.insert(0, newAccount);
            });
            showAppMessage('Demo account ${newAccount.login} created successfully.');
          }
        },
      ),
    );
  }
}

class _DemoMetric extends StatelessWidget {
  const _DemoMetric({required this.icon, required this.label, required this.value,
    required this.surface, required this.border, required this.fg, required this.muted, required this.accent});
  final IconData icon;
  final String label, value;
  final Color surface, border, fg, muted, accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
    child: Row(children: [
      Icon(icon, color: accent, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .3)),
        const SizedBox(height: 4),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(value, style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800))),
      ])),
    ]),
  );
}

class _CreateDemoAccountSheet extends StatefulWidget {
  const _CreateDemoAccountSheet({required this.onCreated});
  final ValueChanged<BrokerAccount> onCreated;

  @override
  State<_CreateDemoAccountSheet> createState() => _CreateDemoAccountSheetState();
}

class _CreateDemoAccountSheetState extends State<_CreateDemoAccountSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '10000');
  String _leverage = '1:500';
  String? _accountNumber;
  String? _masterPassword;
  String? _investorPassword;

  bool get _accountCreated => _accountNumber != null;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: cs.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)),
                      child: Icon(_accountCreated ? LucideIcons.sparkles : LucideIcons.flaskConical, color: cs.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_accountCreated ? 'Demo Account Created' : 'Create Demo Account', style: TextStyle(color: cs.onSurface, fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(_accountCreated ? 'Your demo credentials are ready' : 'Configure your virtual MT5 practice account', style: TextStyle(color: muted, fontSize: 11)),
                    ])),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(LucideIcons.x, color: muted, size: 19),
                    ),
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
                    _demoSectionHeading('ACCOUNT PROFILE', '01', cs),
                    const SizedBox(height: 10),
                    _demoFieldLabel('Account name', cs),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: _demoInputDecoration('Enter account name (e.g. Practice Pro)', LucideIcons.userRound, cs, border, muted, dark),
                    ),
                    const SizedBox(height: 18),
                    _demoSectionHeading('TRADING CONFIGURATION', '02', cs),
                    const SizedBox(height: 10),
                    _demoFieldLabel('Leverage', cs),
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
                                border: Border.all(
                                  color: _leverage == value ? cs.primary : border,
                                  width: _leverage == value ? 1.5 : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: _leverage == value ? cs.primary : cs.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )),
                    ]),
                    const SizedBox(height: 16),
                    _demoFieldLabel('Virtual balance (USD)', cs),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _balanceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
                      decoration: _demoInputDecoration('Enter starting balance', LucideIcons.wallet, cs, border, muted, dark).copyWith(prefixText: r'$ '),
                    ),
                  ]),
                )),
                Divider(height: 1, color: border),
                Padding(
                  padding: EdgeInsets.fromLTRB(18, 10, 18, 8 + MediaQuery.viewPaddingOf(context).bottom),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    SizedBox(height: 48, child: FilledButton.icon(
                      onPressed: _accountCreated ? () => Navigator.pop(context) : _createAccount,
                      style: FilledButton.styleFrom(
                        backgroundColor: _brokerGold,
                        foregroundColor: const Color(0xFF142238),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: Icon(_accountCreated ? LucideIcons.check : LucideIcons.plus, size: 18),
                      label: Text(_accountCreated ? 'DONE' : 'CREATE DEMO ACCOUNT', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .35)),
                    )),
                    const SizedBox(height: 9),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(LucideIcons.shieldCheck, color: muted, size: 12),
                      const SizedBox(width: 5),
                      Flexible(child: Text(
                        _accountCreated
                            ? 'Preview credentials only · Virtual practice account · No real-money transactions'
                            : 'Virtual practice funds only · Zero real financial risk',
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

  Widget _demoSectionHeading(String title, String number, ColorScheme cs) => Row(children: [
    Text(number, style: TextStyle(color: cs.primary, fontSize: 10, fontWeight: FontWeight.w800)),
    const SizedBox(width: 8),
    Text(title, style: TextStyle(color: cs.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
  ]);

  Widget _demoFieldLabel(String value, ColorScheme cs) =>
      Text(value, style: TextStyle(color: cs.onSurface, fontSize: 11, fontWeight: FontWeight.w700));

  InputDecoration _demoInputDecoration(String hint, IconData icon, ColorScheme cs, Color border, Color muted, bool dark) =>
      InputDecoration(
        prefixIcon: Icon(icon, size: 17, color: muted),
        hintText: hint,
        hintStyle: TextStyle(color: muted, fontSize: 11),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: dark ? .45 : .55),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: cs.primary, width: 1.4)),
      );

  void _createAccount() {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text.trim());
    if (name.isEmpty) {
      showAppMessage('Enter an account name to continue.');
      return;
    }
    if (balance == null || !balance.isFinite || balance <= 0) {
      showAppMessage('Enter a valid virtual balance greater than zero.');
      return;
    }
    final login = '34${DateTime.now().millisecondsSinceEpoch.remainder(100000)}';
    final formatted = '\$${balance.toStringAsFixed(2)}';
    final newAccount = BrokerAccount(
      name,
      login,
      _leverage,
      formatted,
      formatted,
      'Demo MT5',
      server: 'VTIndex-Demo',
      currency: 'USD',
      floatingPnl: 0.0,
    );
    final masterPassword = _generateAccountPassword();
    final investorPassword = _generateAccountPassword();
    widget.onCreated(newAccount);
    setState(() {
      _accountNumber = login;
      _masterPassword = masterPassword;
      _investorPassword = investorPassword;
    });
    unawaited(AppNotificationCenter.instance.sendNotification(
      title: 'Demo Account Preview Created (#${newAccount.login})',
      body: 'MT5 demo preview account #${newAccount.login} was created with \$${newAccount.balance} virtual funds.',
      category: 'Trading',
      icon: LucideIcons.badgeCheck,
      isGold: false,
      sendToMobilePanel: true,
    ));
  }
}
