import 'package:crm_app/app_notifications.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PammPage extends StatefulWidget {
  const PammPage({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<PammPage> createState() => _PammPageState();
}

class _PammPool {
  _PammPool(this.name, this.login, this.leverage, this.equity, this.share);
  final String name;
  final String login;
  final String leverage;
  final double equity;
  final double share;
  final double managerBalance = 0;
  final double pnl = 0;
}

class _PammInvestment {
  _PammInvestment(this.login, this.name, this.manager, this.value, this.pnl,
      this.deposit, this.share);
  final String login, name, manager;
  final double value, pnl, deposit, share;
}

class _PammPageState extends State<PammPage> {
  int _tab = 0;
  String _query = '';
  final _search = TextEditingController();

  final List<_PammPool> _managed = [
    _PammPool('MohanTest', '3503', '1:500', 0, 0),
  ];
  final List<_PammPool> _available = [
    _PammPool('Naveen Test', '3420', '1:500', 0, 10),
    _PammPool('Nani', '2141718258', '1:500', 0, 50),
    _PammPool('Testpam1', '2141717469', '1:500', 0.01, 50),
  ];
  final List<_PammInvestment> _investments = [
    _PammInvestment('3420', 'Naveen Test', 'Process Process', 0, 0, 0, 0),
  ];

  static const _blue = Color(0xFF365CEB);
  static const _gold = Color(0xFFF3C744);
  static const _green = Color(0xFF00B889);

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _card => _dark ? const Color(0xFF17243A) : Colors.white;
  Color get _surface => _dark ? const Color(0xFF101D31) : const Color(0xFFF5F8FD);
  Color get _border => _dark ? const Color(0xFF2A3A53) : const Color(0xFFDCE6F5);
  Color get _text => _dark ? const Color(0xFFF1F5F9) : const Color(0xFF10264A);
  Color get _muted => _dark ? const Color(0xFF94A3B8) : const Color(0xFF71839E);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
                  children: [
                    if (_tab != 1) _snapshot(),
                    if (_tab != 1) const SizedBox(height: 12),
                    _tablePanel(true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    floatingActionButton: _tab == 0
        ? FloatingActionButton.extended(
            onPressed: _createPool,
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Create PAMM Pool',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          )
        : null,
  );

  Widget _topBar() {
    final labels = ['Managed', 'Available', 'Investments'];
    final counts = [_managed.length, _available.length, _investments.length];
    final icons = [LucideIcons.briefcaseBusiness, LucideIcons.layers, LucideIcons.usersRound];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _dark ? const Color(0xFF263750) : const Color(0xFFBFD5FF),
        ),
      ),
      child: Column(children: [
        Row(children: [
          _brandIcon(),
          const SizedBox(width: 12),
          Expanded(child: _brandTitle()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: _dark ? const Color(0xFF132D28) : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _green.withValues(alpha: .3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(
                color: _green, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text('Live', style: TextStyle(
                color: _green, fontSize: 10.5, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _dark ? const Color(0xFF17243A) : const Color(0xFFEAF1FC),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _border),
          ),
          child: Row(children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() {
                    _tab = i;
                    _query = '';
                    _search.clear();
                  }),
                  borderRadius: BorderRadius.circular(9),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic,
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _tab == i ? const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ) : null,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: _tab == i ? [BoxShadow(
                        color: _blue.withValues(alpha: .3),
                        blurRadius: 8, offset: const Offset(0, 2),
                      )] : null,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(icons[i], size: 14, color: _tab == i ? Colors.white : _muted),
                      const SizedBox(width: 5),
                      Flexible(child: Text(labels[i], maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _tab == i ? Colors.white : _text,
                          fontSize: 10.5, fontWeight: FontWeight.w700))),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _tab == i ? Colors.white.withValues(alpha: .24)
                              : _border.withValues(alpha: .7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${counts[i]}', style: TextStyle(
                          color: _tab == i ? Colors.white : _muted,
                          fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ]),
                  ),
                ),
              )),
          ]),
        ),
      ]),
    );
  }

  Widget _brandIcon() => Container(width: 48, height: 48,
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF36A9F5), Color(0xFF354CEB)]),
      borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: _blue.withValues(alpha: .22), blurRadius: 12, offset: const Offset(0, 5))]),
    child: const Icon(LucideIcons.activity, color: Colors.white, size: 25));

  Widget _brandTitle() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('PAMM', style: TextStyle(color: _text, fontSize: 21, fontWeight: FontWeight.w800)),
    const SizedBox(height: 4),
    Text('Manage pools, investments and allocations.', style: TextStyle(color: _muted, fontSize: 10.5)),
  ]);

  Widget _snapshot() {
    final managed = _tab == 0;
    return Container(
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(13), border: Border.all(color: _border)),
      child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), child: Row(children: [
          Text(managed ? 'PORTFOLIO SNAPSHOT' : 'INVESTMENT SNAPSHOT',
            style: const TextStyle(color: _blue, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(width: 9),
          Expanded(child: Text(managed ? 'Live overview of your PAMM workspace' : 'Live overview of your PAMM investment portfolio',
            style: TextStyle(color: _muted, fontSize: 9))),
          const Icon(LucideIcons.refreshCw, size: 13, color: Color(0xFF8292A8)),
        ])),
        Divider(height: 1, color: _border),
        LayoutBuilder(builder: (context, c) {
          final metrics = [
            _metric('Total ${managed ? 'pool' : 'invested'} equity', r'$0.00', 'Combined capital', 'USD', LucideIcons.wallet, _blue),
            _metric(managed ? 'Managed pools' : 'Net profit / loss', managed ? _managed.length.toString() : '+\$0.00',
              managed ? 'Accepting deposits' : 'Active allocations', managed ? '1 active' : '1 pool', LucideIcons.trendingUp, _green),
            _metric('Allocation technology', 'Proportional', 'Automated percentage equity distribution', 'Execution MT5', LucideIcons.activity, _gold),
          ];
          return c.maxWidth < 650
            ? Column(children: metrics)
            : Row(children: [for (var i = 0; i < metrics.length; i++) Expanded(child: Container(
                decoration: BoxDecoration(border: i == 0 ? null : Border(left: BorderSide(color: _border))),
                child: metrics[i]))]);
        }),
      ]),
    );
  }

  Widget _metric(String label, String value, String foot, String badge, IconData icon, Color accent) => Padding(
    padding: const EdgeInsets.all(15),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: accent, size: 14), const SizedBox(width: 7),
        Expanded(child: Text(label, style: TextStyle(color: _text, fontSize: 10, fontWeight: FontWeight.w600))),
        Text(badge, style: TextStyle(color: accent, fontSize: 8, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(color: accent == _gold ? const Color(0xFFAE6800) : accent, fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8), Divider(height: 1, color: _border), const SizedBox(height: 8),
      Row(children: [Expanded(child: Text(foot, style: TextStyle(color: _muted, fontSize: 9))), Text(badge, style: TextStyle(color: _text, fontSize: 9))]),
    ]),
  );

  Widget _tablePanel(bool compact) {
    final title = ['Managed PAMM Pools', 'Available Investment Pools', 'My Portfolio Investments'][_tab];
    final source = _tab == 0 ? _managed : _tab == 1 ? _available : <_PammPool>[];
    final q = _query.toLowerCase();
    final pools = source.where((p) => p.name.toLowerCase().contains(q) || p.login.contains(q)).toList();
    final investments = _investments.where((p) => p.name.toLowerCase().contains(q) || p.login.contains(q) || p.manager.toLowerCase().contains(q)).toList();
    return Container(
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(22), border: Border.all(color: _border),
        boxShadow: const [BoxShadow(color: Color(0x0A0F2748), blurRadius: 9, offset: Offset(0, 3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
          child: compact
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Container(width: 5, height: 20, decoration: BoxDecoration(color: const Color(0xFF4C7BFF), borderRadius: BorderRadius.circular(5))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(title, style: TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w800))),
                  Text('${_tab == 0 ? _managed.length : _tab == 1 ? _available.length : _investments.length} records',
                    style: TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 12),
                _searchField(double.infinity),
              ])
            : Row(children: [
                Container(width: 6, height: 18, decoration: BoxDecoration(color: const Color(0xFF4C7BFF), borderRadius: BorderRadius.circular(5))),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w800))),
                _searchField(285),
              ]),
        ),
        Divider(height: 1, color: _border),
        if (_tab == 2)
          _investmentRows(investments, true)
        else
          _poolRows(pools, true),
        Divider(height: 1, color: _border),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15), child: Row(children: [
          Expanded(child: Text('Showing ${_tab == 2 ? investments.length : pools.length} records',
            style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600))),
          Text('1 / 1', style: TextStyle(color: _text, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10), Icon(LucideIcons.chevronRight, color: _muted, size: 17),
        ])),
      ]),
    );
  }

  Widget _searchField(double width) => SizedBox(
    width: width,
    height: 38,
    child: TextField(
      controller: _search,
      onChanged: (v) => setState(() => _query = v),
      style: TextStyle(color: _text, fontSize: 11),
      decoration: InputDecoration(
        hintText: 'Search name, MT5 login...',
        hintStyle: TextStyle(color: _muted, fontSize: 10),
        prefixIcon: Icon(LucideIcons.search, color: _muted, size: 15),
        prefixIconConstraints: const BoxConstraints(minWidth: 36),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _blue)),
      ),
    ),
  );

  Widget _poolRows(List<_PammPool> rows, bool compact) {
    if (rows.isEmpty) return _empty();
    if (compact) {
      return Padding(padding: const EdgeInsets.all(12), child: Column(children: [
        for (final p in rows) _mobilePool(p),
      ]));
    }
    final available = _tab == 1;
    final headers = available
      ? ['PAMM POOL', 'MT5 LOGIN', 'LEVERAGE', 'TOTAL POOL EQUITY', 'PROFIT SHARE', 'STATUS', 'ACTIONS']
      : ['PAMM POOL', 'MT5 LOGIN', 'LEVERAGE', 'MANAGER BALANCE', 'P/L', 'TOTAL POOL VALUE', 'ACTIONS'];
    final widths = [190.0, 130.0, 105.0, 150.0, 110.0, 140.0, 150.0];
    return SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 975), child: Column(children: [
        _headerRow(headers, widths),
        const SizedBox(height: 8),
        for (final p in rows) Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
          child: Row(children: [
            SizedBox(width: widths[0], child: _poolName(p)),
            SizedBox(width: widths[1], child: _login(p.login)),
            SizedBox(width: widths[2], child: _bold(p.leverage)),
            SizedBox(width: widths[3], child: _bold(available ? _money(p.equity) : _money(p.managerBalance))),
            SizedBox(width: widths[4], child: available ? _share(p.share) : _bold(_money(p.pnl), color: _green)),
            SizedBox(width: widths[5], child: available ? _status() : _bold(_money(p.equity), color: _gold)),
            SizedBox(width: widths[6], child: available
              ? Align(alignment: Alignment.centerLeft, child: _goldButton('Invest Now', () => _amountDialog('Invest in ${p.name}')))
              : _actions(p)),
          ]),
        ),
      ])),
    );
  }

  Widget _investmentRows(List<_PammInvestment> rows, bool compact) {
    if (rows.isEmpty) return _empty();
    if (compact) {
      return Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      for (final p in rows) Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: _border)),
        child: Column(children: [
          Row(children: [Expanded(child: _poolNameText(p.name)), _login(p.login)]),
          const SizedBox(height: 9), _labelValue('Manager', p.manager), _labelValue('Current value', _money(p.value)),
          _labelValue('P/L', _money(p.pnl)), _labelValue('Initial deposit', _money(p.deposit)),
          _labelValue('Pool share', '${p.share.toStringAsFixed(2)}%'),
          Align(alignment: Alignment.centerRight, child: _actionsInvestment(p)),
        ])),
      ]));
    }
    final headers = ['INVESTMENT ACCOUNT', 'MANAGER', 'CURRENT VALUE', 'P/L', 'INITIAL DEPOSIT', 'POOL SHARE', 'ACTIONS'];
    final widths = [190.0, 155.0, 135.0, 105.0, 135.0, 115.0, 150.0];
    return SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 985), child: Column(children: [
        _headerRow(headers, widths), const SizedBox(height: 8),
        for (final p in rows) Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
          child: Row(children: [
            SizedBox(width: widths[0], child: _poolNameText(p.name, subtitle: p.login)),
            SizedBox(width: widths[1], child: _bold(p.manager)),
            SizedBox(width: widths[2], child: _bold(_money(p.value))),
            SizedBox(width: widths[3], child: _bold(_money(p.pnl), color: _green)),
            SizedBox(width: widths[4], child: _bold(_money(p.deposit), color: _muted)),
            SizedBox(width: widths[5], child: _share(p.share)),
            SizedBox(width: widths[6], child: _actionsInvestment(p)),
          ]),
        ),
      ])),
    );
  }

  Widget _headerRow(List<String> labels, List<double> widths) => Container(color: _surface,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
    child: Row(children: [for (var i = 0; i < labels.length; i++) SizedBox(width: widths[i],
      child: Text(labels[i], style: TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .6)))]),
  );

  Widget _mobilePool(_PammPool p) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: _border)),
    child: Column(children: [
      Row(children: [Expanded(child: _poolName(p)), _login(p.login)]),
      const SizedBox(height: 9), _labelValue('Leverage', p.leverage),
      _labelValue(_tab == 1 ? 'Profit share' : 'Manager balance', _tab == 1 ? '${p.share.toStringAsFixed(2)}%' : _money(p.managerBalance)),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: _tab == 1
        ? _goldButton('Invest Now', () => _amountDialog('Invest in ${p.name}'))
        : _actions(p)),
    ]));

  Widget _poolName(_PammPool p) => Row(children: [
    Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFFFF6D9), borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFF8D979))),
      child: Center(child: Text(p.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFF99620A), fontWeight: FontWeight.w800)))),
    const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _text, fontSize: 11, fontWeight: FontWeight.w800)),
      if (_tab == 0) const Text('● MT5 Live', style: TextStyle(color: _green, fontSize: 8, fontWeight: FontWeight.w700)),
    ])),
  ]);

  Widget _poolNameText(String name, {String? subtitle}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(name, style: TextStyle(color: _text, fontSize: 11, fontWeight: FontWeight.w800)),
    if (subtitle != null) Text(subtitle, style: TextStyle(color: _muted, fontSize: 9)),
  ]);

  Widget _login(String value) => Align(alignment: Alignment.centerLeft, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(7), border: Border.all(color: _border)),
    child: Text(value, style: TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w700))));

  Widget _bold(String value, {Color? color}) => Text(value, style: TextStyle(color: color ?? _text, fontSize: 10.5, fontWeight: FontWeight.w800));
  Widget _share(double value) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: const Color(0xFFFFF7DF), borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0xFFF5D77F))),
    child: Text('${value.toStringAsFixed(2)}%', style: const TextStyle(color: Color(0xFF99620A), fontSize: 9, fontWeight: FontWeight.w800)));
  Widget _status() => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFFE9FBF4), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF9DEDD1))),
    child: const Text('● Open Pool', style: TextStyle(color: Color(0xFF008B68), fontSize: 9, fontWeight: FontWeight.w700)));

  Widget _goldButton(String label, VoidCallback action) => FilledButton(
    onPressed: action, style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: const Color(0xFF17233D),
      elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), minimumSize: const Size(0, 34),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
    child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)));

  Widget _actions(_PammPool p) => Row(mainAxisSize: MainAxisSize.min, children: [
    _goldButton('Deposit', () => _depositDialog(p.name)), const SizedBox(width: 6),
    OutlinedButton(onPressed: () => _details(p.name, p.login), style: OutlinedButton.styleFrom(
      foregroundColor: _text, side: BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      minimumSize: const Size(0, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
      child: const Row(children: [Text('Details', style: TextStyle(fontSize: 10)), Icon(LucideIcons.chevronRight, size: 13)])),
  ]);

  Widget _actionsInvestment(_PammInvestment p) => Row(mainAxisSize: MainAxisSize.min, children: [
    _goldButton('Deposit', () => _depositDialog(p.name)), const SizedBox(width: 6),
    OutlinedButton(onPressed: () => _details(p.name, p.login), style: OutlinedButton.styleFrom(
      foregroundColor: _text, side: BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      minimumSize: const Size(0, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
      child: const Row(children: [Text('Details', style: TextStyle(fontSize: 10)), Icon(LucideIcons.chevronRight, size: 13)])),
  ]);

  Widget _labelValue(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [Expanded(child: Text(label, style: TextStyle(color: _muted, fontSize: 10))), Text(value, style: TextStyle(color: _text, fontSize: 10, fontWeight: FontWeight.w700))]));

  Widget _empty() => Padding(padding: const EdgeInsets.all(28), child: Center(child: Text('No records found', style: TextStyle(color: _muted, fontSize: 12))));

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  Future<void> _createPool() async {
    final name = TextEditingController();
    final share = TextEditingController(text: '20');
    final masterPassword = TextEditingController();
    final investorPassword = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var leverage = '1:500';
    var showMasterPassword = false;
    var showInvestorPassword = false;

    ModalRoute<dynamic>? sheetRoute;
    await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x660B1730),
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) {
        sheetRoute ??= ModalRoute.of(sheetContext);
        final screenHeight = MediaQuery.sizeOf(sheetContext).height;
        final wide = MediaQuery.sizeOf(sheetContext).width >= 620;

        Widget sectionTitle(String number, String title, {String? hint}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(number, style: TextStyle(
                    color: _blue, fontSize: 9, fontWeight: FontWeight.w800,
                  )),
                ),
                const SizedBox(width: 8),
                Text(title.toUpperCase(), style: TextStyle(
                  color: _text, fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: .25,
                )),
                const Spacer(),
                if (hint != null) Flexible(child: Text(hint, textAlign: TextAlign.right,
                  style: TextStyle(color: _muted, fontSize: 9))),
              ]),
            );

        Widget fieldLabel(String label, {bool required = false, String? suffix}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(children: [
                Expanded(child: RichText(text: TextSpan(
                  style: TextStyle(color: _text, fontSize: 10, fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(text: label),
                    if (required) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                  ],
                ))),
                if (suffix != null) Text(suffix, style: TextStyle(color: _blue, fontSize: 10, fontWeight: FontWeight.w800)),
              ]),
            );

        InputDecoration inputDecoration(String hint, {Widget? prefix, Widget? suffix}) =>
            InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: _muted, fontSize: 11),
              prefixIcon: prefix,
              suffixIcon: suffix,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
              filled: true,
              fillColor: _card,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _blue, width: 1.2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            );

        Widget textField(TextEditingController controller, String label, String hint,
            {bool number = false, bool password = false, bool visible = false,
             VoidCallback? onToggle}) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            fieldLabel(label, required: true),
            TextFormField(
              controller: controller,
              obscureText: password && !visible,
              keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              style: TextStyle(color: _text, fontSize: 11, fontWeight: FontWeight.w600),
              decoration: inputDecoration(hint,
                suffix: password ? IconButton(
                  onPressed: onToggle,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 14, color: _muted),
                ) : null,
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Required';
                if (password && !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d_]{6,12}$').hasMatch(text)) {
                  return 'Use 6–12 chars: upper, lower and number';
                }
                if (number && (double.tryParse(text) == null || double.parse(text) < 0 || double.parse(text) > 100)) {
                  return 'Enter a value from 0 to 100';
                }
                return null;
              },
            ),
          ]);
        }

        Widget passwordCard({
          required String title,
          required String access,
          required TextEditingController controller,
          required bool visible,
          required VoidCallback toggle,
        }) => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _surface,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(LucideIcons.lock, size: 13, color: _muted),
              const SizedBox(width: 6),
              Expanded(child: Text(title, style: TextStyle(color: _text, fontSize: 10, fontWeight: FontWeight.w800))),
              Text(access, style: TextStyle(color: _muted, fontSize: 9)),
            ]),
            const SizedBox(height: 7),
            TextFormField(
              controller: controller,
              obscureText: !visible,
              style: TextStyle(color: _text, fontSize: 11),
              decoration: inputDecoration('Enter password', suffix: IconButton(
                onPressed: toggle,
                visualDensity: VisualDensity.compact,
                icon: Icon(visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 14, color: _muted),
              )),
              validator: (value) {
                final text = value ?? '';
                return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d_]{6,12}$').hasMatch(text)
                    ? null : '6–12 chars, uppercase, lowercase and number';
              },
            ),
            const SizedBox(height: 5),
            Text('6–12 characters, uppercase + lowercase + number; letters, numbers and underscore only.',
              style: TextStyle(color: _muted, fontSize: 8.5, height: 1.35)),
            const SizedBox(height: 5),
            Wrap(spacing: 12, children: [
              TextButton.icon(onPressed: toggle, icon: Icon(visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 12),
                label: Text(visible ? 'Hide' : 'Reveal', style: const TextStyle(fontSize: 9))),
              TextButton.icon(onPressed: () {
                controller.text = 'Pamm_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}A1';
              }, icon: const Icon(LucideIcons.refreshCw, size: 12),
                label: const Text('Regenerate', style: TextStyle(fontSize: 9))),
            ]),
          ]),
        );

        return StatefulBuilder(builder: (sheetContext, setSheetState) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(sheetContext).maybePop(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 980,
                    maxHeight: screenHeight * .82,
                  ),
                  child: Container(
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  border: Border(top: BorderSide(color: _border)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .14), blurRadius: 24, offset: const Offset(0, -5))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(width: 42, height: 4,
                      decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(3))),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
                    child: Row(children: [
                      Container(width: 38, height: 38,
                        decoration: BoxDecoration(color: _blue.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.usersRound, color: _blue, size: 19)),
                      const SizedBox(width: 11),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Create PAMM account', style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Configure pool, trading preferences and credentials',
                          style: TextStyle(color: _muted, fontSize: 10)),
                      ])),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(LucideIcons.x, size: 17, color: _muted),
                        tooltip: 'Close',
                      ),
                    ]),
                  ),
                  Divider(height: 1, color: _border),
                  Flexible(
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          sectionTitle('01', 'Account details'),
                          TextFormField(
                            controller: name,
                            style: TextStyle(color: _text, fontSize: 12),
                            decoration: inputDecoration('Enter PAMM account name',
                              prefix: Icon(LucideIcons.userRound, size: 15, color: _muted)),
                            validator: (value) => (value?.trim().isNotEmpty ?? false) ? null : 'Account name is required',
                          ),
                          const SizedBox(height: 12),
                          sectionTitle('02', 'Trading preferences'),
                          if (wide)
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  fieldLabel('Performance fee', required: true, suffix: '${share.text}%'),
                                TextFormField(
                                  controller: share,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setSheetState(() {}),
                                  style: TextStyle(color: _text, fontSize: 11),
                                  decoration: inputDecoration('20', prefix: Icon(LucideIcons.percent, size: 14, color: _muted)),
                                  validator: (value) {
                                    final n = double.tryParse(value ?? '');
                                    return n != null && n >= 0 && n <= 100 ? null : 'Enter 0–100';
                                  },
                                ),
                                const SizedBox(height: 6),
                                Wrap(spacing: 5, children: [10, 20, 30, 40, 50].map((v) =>
                                  ChoiceChip(
                                    label: Text('$v%', style: const TextStyle(fontSize: 9)),
                                    selected: share.text == '$v',
                                    onSelected: (_) { share.text = '$v'; setSheetState(() {}); },
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  )).toList()),
                              ])),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                fieldLabel('Account leverage', required: true, suffix: leverage),
                                Row(children: ['1:100', '1:200', '1:500'].map((v) => Expanded(child: Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: OutlinedButton(
                                    onPressed: () => setSheetState(() => leverage = v),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: leverage == v ? _blue : _card,
                                      foregroundColor: leverage == v ? Colors.white : _text,
                                      side: BorderSide(color: leverage == v ? _blue : _border),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      minimumSize: const Size(0, 34),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                    ),
                                    child: Text(v, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                                  ),
                                ))).toList()),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: leverage,
                                  isDense: true,
                                  decoration: inputDecoration('Custom leverage'),
                                  dropdownColor: _card,
                                  style: TextStyle(color: _text, fontSize: 10),
                                  items: ['1:50', '1:100', '1:200', '1:300', '1:500', '1:1000']
                                    .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                  onChanged: (v) => setSheetState(() => leverage = v ?? leverage),
                                ),
                              ])),
                            ])
                          else ...[
                            textField(share, 'Performance fee', '20', number: true),
                            const SizedBox(height: 8),
                            fieldLabel('Account leverage', required: true, suffix: leverage),
                            Wrap(spacing: 6, children: ['1:100', '1:200', '1:500'].map((v) => ChoiceChip(
                              label: Text(v, style: const TextStyle(fontSize: 10)),
                              selected: leverage == v,
                              onSelected: (_) => setSheetState(() => leverage = v),
                            )).toList()),
                          ],
                          const SizedBox(height: 12),
                          sectionTitle('03', 'Security credentials', hint: 'Keep master password private'),
                          if (wide)
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: passwordCard(
                                title: 'Master password', access: 'Full access', controller: masterPassword,
                                visible: showMasterPassword,
                                toggle: () => setSheetState(() => showMasterPassword = !showMasterPassword),
                              )),
                              const SizedBox(width: 10),
                              Expanded(child: passwordCard(
                                title: 'Investor password', access: 'Read-only', controller: investorPassword,
                                visible: showInvestorPassword,
                                toggle: () => setSheetState(() => showInvestorPassword = !showInvestorPassword),
                              )),
                            ])
                          else ...[
                            passwordCard(title: 'Master password', access: 'Full access', controller: masterPassword,
                              visible: showMasterPassword, toggle: () => setSheetState(() => showMasterPassword = !showMasterPassword)),
                            const SizedBox(height: 8),
                            passwordCard(title: 'Investor password', access: 'Read-only', controller: investorPassword,
                              visible: showInvestorPassword, toggle: () => setSheetState(() => showInvestorPassword = !showInvestorPassword)),
                          ],
                          const SizedBox(height: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(color: _blue.withValues(alpha: .055), borderRadius: BorderRadius.circular(9)),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Icon(LucideIcons.info, color: _blue, size: 14),
                              const SizedBox(width: 7),
                              Expanded(child: Text('PAMM allocations are based on investor equity ratios. Review details before creating.',
                                style: TextStyle(color: _muted, fontSize: 9, height: 1.35))),
                            ]),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: _border),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
                    child: Row(children: [
                      Expanded(child: Row(children: [
                        const Icon(LucideIcons.shieldCheck, color: _green, size: 14),
                        const SizedBox(width: 6),
                        Flexible(child: Text('Review details before submitting.',
                          style: TextStyle(color: _muted, fontSize: 9))),
                      ])),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _text, side: BorderSide(color: _border),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          setState(() => _managed.add(_PammPool(
                            name.text.trim(), 'Pending', leverage, 0,
                            double.tryParse(share.text) ?? 20,
                          )));
                          Navigator.pop(sheetContext, true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue, foregroundColor: Colors.white,
                          elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                        icon: const Icon(LucideIcons.arrowRight, size: 13),
                        label: const Text('Create account', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                    ]),
                  ),
                ]),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
    final route = sheetRoute;
    if (route != null) await route.completed;
    name.dispose();
    share.dispose();
    masterPassword.dispose();
    investorPassword.dispose();
  }

  Widget _dialogField(TextEditingController c, String hint, {bool number = false}) => TextField(
    controller: c, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    style: TextStyle(color: _text, fontSize: 12),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: _muted, fontSize: 11), filled: true, fillColor: _surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border))));

  Future<void> _depositDialog(String accountName) async {
    final amount = TextEditingController();
    final picker = ImagePicker();
    var method = 0;
    XFile? proof;
    var submitting = false;
    ModalRoute<dynamic>? sheetRoute;

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x9907132D),
      isDismissible: true,
      enableDrag: true,
      builder: (sheetContext) {
        sheetRoute ??= ModalRoute.of(sheetContext);
        final screen = MediaQuery.sizeOf(sheetContext);
        final compact = screen.width < 600;
        final maxHeight = screen.height * .94;
        return StatefulBuilder(builder: (sheetContext, setModalState) {
          final isDark = _dark;
          final modalText = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF14265A);
          final modalMuted = isDark ? const Color(0xFF9AABC4) : const Color(0xFF6D7F9D);
          final modalCard = _card;
          final modalBorder = _border;

          InputDecoration amountDecoration() => InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(color: modalMuted, fontSize: 15, fontWeight: FontWeight.w700),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 10),
              child: Icon(Icons.attach_money_rounded, color: Color(0xFF1D348A), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 42),
            filled: true,
            fillColor: modalCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: modalBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _blue, width: 1.4),
            ),
          );

          Widget sectionLabel(String text) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Text(text.toUpperCase(), style: TextStyle(
              color: modalText, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .25,
            )),
          );

          Widget paymentTab(int index, IconData icon, String title, String subtitle) {
            final selected = method == index;
            return Expanded(child: InkWell(
              onTap: () => setModalState(() => method = index),
              borderRadius: BorderRadius.circular(13),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 12 : 15),
                decoration: BoxDecoration(
                  gradient: selected ? const LinearGradient(
                    colors: [Color(0xFF293FE1), Color(0xFF3569F6)],
                  ) : null,
                  color: selected ? null : modalCard,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: selected ? _blue : modalBorder, width: selected ? 1.3 : 1),
                  boxShadow: selected ? [BoxShadow(
                    color: _blue.withValues(alpha: .18), blurRadius: 12, offset: const Offset(0, 5),
                  )] : null,
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(icon, size: 15, color: selected ? Colors.white : modalText),
                    const SizedBox(width: 7),
                    Text(title, style: TextStyle(
                      color: selected ? Colors.white : modalText, fontSize: 11, fontWeight: FontWeight.w800,
                    )),
                  ]),
                  const SizedBox(height: 5),
                  Text(subtitle, style: TextStyle(
                    color: selected ? Colors.white.withValues(alpha: .85) : modalMuted, fontSize: 9, fontWeight: FontWeight.w600,
                  )),
                ]),
              ),
            ));
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(sheetContext).maybePop(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 780, maxHeight: maxHeight),
                  child: Container(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: modalCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .2), blurRadius: 28, offset: const Offset(0, 10))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(compact ? 16 : 22, compact ? 15 : 20, 12, 17),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF1B328D), Color(0xFF315FEA), Color(0xFF356DF5)],
                      ),
                    ),
                    child: Stack(children: [
                      Positioned(right: -32, bottom: -66, child: Container(
                        width: 170, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: .055),
                        ),
                      )),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .13),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: .28)),
                            ),
                            child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Deposit Funds', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('Add funds to your PAMM account using your preferred payment method.',
                              style: TextStyle(color: Colors.white.withValues(alpha: .88), fontSize: 10, height: 1.35)),
                          ])),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 19),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF071D57).withValues(alpha: .72),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: .2)),
                          ),
                          child: Wrap(spacing: 9, crossAxisAlignment: WrapCrossAlignment.center, children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF2BE3B2), size: 13),
                            Text('Account:  $accountName', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                            const Text('|', style: TextStyle(color: Colors.white54, fontSize: 10)),
                            const Icon(Icons.shield_outlined, color: Color(0xFF8DEED5), size: 13),
                            const Text('Secure request', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ]),
                    ]),
                  ),
                  Flexible(child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(compact ? 14 : 20, 16, compact ? 14 : 20, 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? _surface : const Color(0xFFF7F9FE),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: modalBorder),
                        ),
                        child: Row(children: [
                          paymentTab(0, Icons.currency_bitcoin_rounded, 'USDT', 'Crypto payment'),
                          const SizedBox(width: 6),
                          paymentTab(1, Icons.account_balance_outlined, 'MANUAL', 'Bank transfer'),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: isDark ? _surface : const Color(0xFFF3F7FF),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: const Color(0xFFD7E4FF), style: BorderStyle.solid),
                        ),
                        child: Row(children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(color: modalCard, borderRadius: BorderRadius.circular(10)),
                            child: Icon(Icons.info_outline_rounded, color: _blue, size: 19),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('PAYMENT INSTRUCTIONS', style: TextStyle(color: modalText, fontSize: 10, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 5),
                            Text(
                              method == 0
                                ? 'Send USDT using the TRC20 network and upload your transaction screenshot for verification.'
                                : 'Contact Live Support for official bank details before transferring, then upload your payment proof.',
                              style: TextStyle(color: modalMuted, fontSize: 10, height: 1.4),
                            ),
                          ])),
                        ]),
                      ),
                      const SizedBox(height: 17),
                      sectionLabel('Deposit amount (USD)'),
                      TextField(
                        controller: amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: modalText, fontSize: 15, fontWeight: FontWeight.w800),
                        decoration: amountDecoration(),
                      ),
                      const SizedBox(height: 6),
                      Text(r'Minimum deposit: $10.00', style: TextStyle(color: modalMuted, fontSize: 9, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 17),
                      sectionLabel('Upload payment proof'),
                      InkWell(
                        onTap: () async {
                          try {
                            final selected = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
                            if (selected != null && sheetContext.mounted) {
                              setModalState(() => proof = selected);
                            }
                          } catch (_) {
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Unable to open the image picker. Please try again.')),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: isDark ? _surface : const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: modalBorder, style: BorderStyle.solid),
                          ),
                          child: Row(children: [
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(color: const Color(0xFFE2ECFF), borderRadius: BorderRadius.circular(11)),
                              child: const Icon(Icons.cloud_upload_outlined, color: _blue, size: 21),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(proof?.name ?? 'Choose transaction proof', maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: modalText, fontSize: 11, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(proof == null ? 'JPG or PNG · Tap to browse' : 'Selected · Tap to change file',
                                style: TextStyle(color: modalMuted, fontSize: 9)),
                            ])),
                            Text('Browse', style: TextStyle(color: _blue, fontSize: 9, fontWeight: FontWeight.w900)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 17),
                      SizedBox(
                        height: 45,
                        child: FilledButton.icon(
                          onPressed: submitting ? null : () {
                            final value = double.tryParse(amount.text.trim());
                            if (value == null || value < 10) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text(r'Enter a valid deposit amount of at least $10.00.')),
                              );
                              return;
                            }
                            if (proof == null) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(content: Text('Please upload your payment proof.')),
                              );
                              return;
                            }
                            setModalState(() => submitting = true);
                            Navigator.pop(sheetContext, true);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _blue.withValues(alpha: .45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: const Text('SUBMIT DEPOSIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .2)),
                        ),
                      ),
                    ]),
                  )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 13 : 20, vertical: 12),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: modalBorder))),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 8,
                      spacing: 12,
                      children: [
                        _depositFooterItem(Icons.verified_user_outlined, 'Secure payments', const Color(0xFF3478FF)),
                        _depositFooterItem(Icons.schedule_rounded, 'Verification required', const Color(0xFFFF9800)),
                        _depositFooterItem(Icons.layers_outlined, 'PAMM funding', const Color(0xFF3478FF)),
                      ],
                    ),
                  ),
                ]),
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
    final route = sheetRoute;
    if (route != null) await route.completed;
    amount.dispose();
    if (submitted == true && mounted) {
      showAppMessage('Deposit UI preview only. Connect the payment API to submit this request.');
    }
  }

  Widget _depositFooterItem(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(color: _muted, fontSize: 9, fontWeight: FontWeight.w700)),
    ],
  );

  void _amountDialog(String title) {
    final amount = TextEditingController();
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      backgroundColor: _card, title: Text(title, style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800)),
      content: SizedBox(width: 350, child: _dialogField(amount, 'Enter amount (USD)', number: true)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          Navigator.pop(d);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UI preview only. Connect the PAMM API to process transactions.')));
        }, style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: const Color(0xFF17233D)), child: const Text('Continue')),
      ],
    )).whenComplete(amount.dispose);
  }

  void _details(String name, String login) => showModalBottomSheet<void>(
    context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
    builder: (d) => Container(margin: const EdgeInsets.all(14), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
      child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('PAMM details', style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12), _labelValue('Pool / account', name), _labelValue('MT5 login', login),
        _labelValue('Allocation', 'Proportional'), _labelValue('Platform', 'MT5'),
        const SizedBox(height: 10), SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.pop(d), child: const Text('Close'))),
      ])),
    ),
  );
}
