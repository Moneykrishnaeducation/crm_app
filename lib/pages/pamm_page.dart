import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PammPage extends StatefulWidget {
  const PammPage({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<PammPage> createState() => _PammPageState();
}

class _PammPool {
  _PammPool(this.name, this.login, this.leverage, this.equity, this.share,
      {this.managerBalance = 0, this.pnl = 0});
  final String name;
  final String login;
  final String leverage;
  final double equity;
  final double share;
  final double managerBalance;
  final double pnl;
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
    body: SafeArea(child: LayoutBuilder(builder: (context, box) {
      final compact = box.maxWidth < 760;
      return Column(children: [
        _topBar(compact),
        Expanded(child: ListView(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 16, 14, compact ? 12 : 16, 110),
          children: [
            if (_tab != 1) _snapshot(),
            if (_tab != 1) const SizedBox(height: 18),
            _tablePanel(compact),
          ],
        )),
      ]);
    })),
  );

  Widget _topBar(bool compact) {
    final labels = ['Managed pools', 'Available pools', 'My investments'];
    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 10 : 14, 8, compact ? 10 : 14, 0),
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFD5FF))),
      child: compact
        ? Column(children: [
            Row(children: [_brandIcon(), const SizedBox(width: 10), Expanded(child: _brandTitle()), _createButton(true)]),
            const SizedBox(height: 12),
            _tabs(labels, true),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _miniStat('POOL EQUITY', r'$0.00', LucideIcons.wallet, _blue)),
              const SizedBox(width: 8),
              Expanded(child: _miniStat('MANAGED POOLS', _managed.length.toString() + ' live', LucideIcons.usersRound, const Color(0xFFF59E0B))),
            ]),
          ])
        : Row(children: [
            _brandIcon(), const SizedBox(width: 12), SizedBox(width: 225, child: _brandTitle()),
            const SizedBox(width: 16), Expanded(child: _tabs(labels, false)),
            const SizedBox(width: 14), SizedBox(width: 170, child: _miniStat('POOL EQUITY', r'$0.00', LucideIcons.wallet, _blue)),
            const SizedBox(width: 10), SizedBox(width: 170, child: _miniStat('MANAGED POOLS', _managed.length.toString() + ' live', LucideIcons.usersRound, const Color(0xFFF59E0B))),
            const SizedBox(width: 10), _createButton(false),
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

  Widget _tabs(List<String> labels, bool compact) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(color: _dark ? const Color(0xFF17243A) : const Color(0xFFEAF1FC),
      borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
    child: Row(children: [
      for (var i = 0; i < labels.length; i++)
        Expanded(child: InkWell(
          onTap: () => setState(() { _tab = i; _query = ''; _search.clear(); }),
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(duration: const Duration(milliseconds: 160),
            padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8, vertical: 10),
            decoration: BoxDecoration(color: _tab == i ? _blue : Colors.transparent, borderRadius: BorderRadius.circular(9)),
            child: Center(child: Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _tab == i ? Colors.white : _text, fontSize: compact ? 9 : 10.5, fontWeight: FontWeight.w700))),
          ),
        )),
    ]),
  );

  Widget _miniStat(String label, String value, IconData icon, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
    child: Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: accent.withValues(alpha: .08), borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, color: accent, size: 16)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w700)),
        Text(value, style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w800)),
      ])),
    ]),
  );

  Widget _createButton(bool compact) => FilledButton.icon(
    onPressed: _createPool,
    icon: const Icon(LucideIcons.plus, size: 15),
    label: Text(compact ? 'Create' : 'CREATE PAMM', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
    style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: const Color(0xFF17233D),
      elevation: 0, padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 16, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
  );

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
            _metric('Total ' + (managed ? 'pool' : 'invested') + ' equity', r'$0.00', 'Combined capital', 'USD', LucideIcons.wallet, _blue),
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
        Padding(padding: const EdgeInsets.fromLTRB(18, 16, 18, 15), child: Row(children: [
          Container(width: 6, height: 18, decoration: BoxDecoration(color: const Color(0xFF4C7BFF), borderRadius: BorderRadius.circular(5))),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w800))),
          SizedBox(width: compact ? 145 : 285, height: 36, child: TextField(controller: _search,
            onChanged: (v) => setState(() => _query = v), style: TextStyle(color: _text, fontSize: 11),
            decoration: InputDecoration(hintText: 'Search name, MT5 login...', hintStyle: TextStyle(color: _muted, fontSize: 10),
              prefixIcon: Icon(LucideIcons.search, color: _muted, size: 15), prefixIconConstraints: const BoxConstraints(minWidth: 34),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), filled: true, fillColor: _surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _blue)))),
          ),
        ])),
        Divider(height: 1, color: _border),
        if (_tab == 2)
          _investmentRows(investments, compact)
        else
          _poolRows(pools, compact),
        Divider(height: 1, color: _border),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15), child: Row(children: [
          Expanded(child: Text('Showing ' + ((_tab == 2 ? investments.length : pools.length).toString()) + ' records',
            style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w600))),
          Text('1 / 1', style: TextStyle(color: _text, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10), Icon(LucideIcons.chevronRight, color: _muted, size: 17),
        ])),
      ]),
    );
  }

  Widget _poolRows(List<_PammPool> rows, bool compact) {
    if (rows.isEmpty) return _empty();
    if (compact) return Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      for (final p in rows) _mobilePool(p),
    ]));
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
              ? Align(alignment: Alignment.centerLeft, child: _goldButton('Invest Now', () => _amountDialog('Invest in ' + p.name)))
              : _actions(p)),
          ]),
        ),
      ])),
    );
  }

  Widget _investmentRows(List<_PammInvestment> rows, bool compact) {
    if (rows.isEmpty) return _empty();
    if (compact) return Padding(padding: const EdgeInsets.all(12), child: Column(children: [
      for (final p in rows) Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: _border)),
        child: Column(children: [
          Row(children: [Expanded(child: _poolNameText(p.name)), _login(p.login)]),
          const SizedBox(height: 9), _labelValue('Manager', p.manager), _labelValue('Current value', _money(p.value)),
          _labelValue('P/L', _money(p.pnl)), _labelValue('Initial deposit', _money(p.deposit)),
          _labelValue('Pool share', p.share.toStringAsFixed(2) + '%'),
          Align(alignment: Alignment.centerRight, child: _actionsInvestment(p)),
        ])),
    ]));
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
      _labelValue(_tab == 1 ? 'Profit share' : 'Manager balance', _tab == 1 ? p.share.toStringAsFixed(2) + '%' : _money(p.managerBalance)),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: _tab == 1
        ? _goldButton('Invest Now', () => _amountDialog('Invest in ' + p.name))
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
    child: Text(value.toStringAsFixed(2) + '%', style: const TextStyle(color: Color(0xFF99620A), fontSize: 9, fontWeight: FontWeight.w800)));
  Widget _status() => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFFE9FBF4), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF9DEDD1))),
    child: const Text('● Open Pool', style: TextStyle(color: Color(0xFF008B68), fontSize: 9, fontWeight: FontWeight.w700)));

  Widget _goldButton(String label, VoidCallback action) => FilledButton(
    onPressed: action, style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: const Color(0xFF17233D),
      elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), minimumSize: const Size(0, 34),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
    child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)));

  Widget _actions(_PammPool p) => Row(mainAxisSize: MainAxisSize.min, children: [
    _goldButton('Deposit', () => _amountDialog('Deposit to ' + p.name)), const SizedBox(width: 6),
    OutlinedButton(onPressed: () => _details(p.name, p.login), style: OutlinedButton.styleFrom(
      foregroundColor: _text, side: BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      minimumSize: const Size(0, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
      child: const Row(children: [Text('Details', style: TextStyle(fontSize: 10)), Icon(LucideIcons.chevronRight, size: 13)])),
  ]);

  Widget _actionsInvestment(_PammInvestment p) => Row(mainAxisSize: MainAxisSize.min, children: [
    _goldButton('Deposit', () => _amountDialog('Deposit to ' + p.name)), const SizedBox(width: 6),
    OutlinedButton(onPressed: () => _details(p.name, p.login), style: OutlinedButton.styleFrom(
      foregroundColor: _text, side: BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
      minimumSize: const Size(0, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))),
      child: const Row(children: [Text('Details', style: TextStyle(fontSize: 10)), Icon(LucideIcons.chevronRight, size: 13)])),
  ]);

  Widget _labelValue(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [Expanded(child: Text(label, style: TextStyle(color: _muted, fontSize: 10))), Text(value, style: TextStyle(color: _text, fontSize: 10, fontWeight: FontWeight.w700))]));

  Widget _empty() => Padding(padding: const EdgeInsets.all(28), child: Center(child: Text('No records found', style: TextStyle(color: _muted, fontSize: 12))));

  String _money(double value) => '\$' + value.toStringAsFixed(2);

  void _createPool() {
    final name = TextEditingController();
    final login = TextEditingController();
    final share = TextEditingController(text: '20');
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      backgroundColor: _card,
      title: Text('Create PAMM pool', style: TextStyle(color: _text, fontWeight: FontWeight.w800)),
      content: SizedBox(width: 380, child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dialogField(name, 'Pool name'), const SizedBox(height: 9),
        _dialogField(login, 'MT5 login'), const SizedBox(height: 9),
        _dialogField(share, 'Profit share (%)', number: true),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (name.text.trim().isEmpty || login.text.trim().isEmpty) return;
          setState(() => _managed.add(_PammPool(name.text.trim(), login.text.trim(), '1:500', 0, double.tryParse(share.text) ?? 20)));
          Navigator.pop(d);
        }, style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: const Color(0xFF17233D)), child: const Text('Create pool')),
      ],
    )).whenComplete(() { name.dispose(); login.dispose(); share.dispose(); });
  }

  Widget _dialogField(TextEditingController c, String hint, {bool number = false}) => TextField(
    controller: c, keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    style: TextStyle(color: _text, fontSize: 12),
    decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: _muted, fontSize: 11), filled: true, fillColor: _surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _border))));

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
