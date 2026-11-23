import 'package:crm_app/app_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crm_app/pages/pamm_tab_pages.dart';
import 'package:crm_app/widgets/pool_trades_modal.dart';
import 'package:crm_app/pages/trade_pattern_analysis_page.dart';

part 'pamm_managed_tab_content.dart';
part 'pamm_available_tab_content.dart';
part 'pamm_investments_tab_content.dart';

class PammPage extends StatefulWidget {
  const PammPage({super.key, this.onBack, this.onSelectPage});
  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPage;

  @override
  State<PammPage> createState() => _PammPageState();
}

class _PammPool {
  _PammPool(this.name, this.login, this.leverage, this.equity, this.share, {this.managerBalance = 0, this.pnl = 0, this.server = 'VTIndex-Live', this.status = 'Open', this.manager = 'PAMM Manager'});
  final String name;
  final String login;
  final String leverage;
  final double equity;
  final double share;
  final double managerBalance;
  final double pnl;
  final String server;
  final String manager;
  String status;
}

class _PammInvestment {
  _PammInvestment(this.login, this.name, this.manager, this.value, this.pnl, this.deposit, this.share, {this.joinedOn = '11/17/2026'});
  final String login, name, manager;
  final double value, pnl, deposit, share;
  final String joinedOn;
}

class _PammPageState extends State<PammPage> {
  int _tab = 0;
  String _query = '';
  String _selectedFilter = 'All Pools';
  _PammPool? _selectedManagedPool;
  _PammPool? _selectedAvailablePool;
  _PammPool? _connectedInvestorPool;
  final _search = TextEditingController();

  final List<_PammPool> _managed = [_PammPool('MohanTest', '3503', '1:500', 0, 20, managerBalance: 0, pnl: 0, server: 'VTindex-Live', status: 'Open')];
  final List<_PammPool> _available = [_PammPool('Naveen Test', '3420', '1:500', 0, 10, manager: 'Process Process'), _PammPool('Nani', '2141718258', '1:500', 0, 50, manager: 'Nani Manager'), _PammPool('Testpam1', '2141717469', '1:500', 0.01, 50, manager: 'Test Manager')];
  final List<_PammInvestment> _investments = [_PammInvestment('3420', 'Naveen Test', 'Process Process', 0, 0, 0, 0)];

  static const _blue = Color(0xFF2563EB);
  static const _deepBlue = Color(0xFF1D4ED8);
  static const _gold = Color(0xFFD4AF37);
  static const _green = Color(0xFF10B981);
  static const _rose = Color(0xFFEF4444);

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _card => _dark ? const Color(0xFF0C1833) : Colors.white;
  Color get _surface => _dark ? const Color(0xFF07142A) : const Color(0xFFF8FAFC);
  Color get _border => _dark ? const Color(0xFF223C70) : const Color(0xFFCBD5E1);
  Color get _text => _dark ? Colors.white : const Color(0xFF0A1629);
  Color get _muted => _dark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: Padding(
      padding: const EdgeInsets.only(bottom: 84),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  _selectedManagedPool == null &&
                      _selectedAvailablePool == null &&
                      _connectedInvestorPool == null
                  ? 900
                  : 1280,
            ),
            child: _connectedInvestorPool != null
                ? _buildConnectedInvestorPortfolio(_connectedInvestorPool!)
                : _selectedManagedPool != null
                ? _buildManagedDetail(_selectedManagedPool!)
                : _selectedAvailablePool != null
                ? _buildAvailableDetail(_selectedAvailablePool!)
                : Column(
                    children: [
                      _topBar(),
                      Expanded(
                        child: IndexedStack(
                          index: _tab,
                          children: [
                            PammManagedTabPage(children: _buildPammManagedTabContent(this)),
                            PammAvailableTabPage(children: _buildPammAvailableTabContent(this)),
                            PammInvestmentsTabPage(children: _buildPammInvestmentsTabContent(this)),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );

  Widget _topBar() {
    final labels = ['Managed', 'Available', 'Investments'];
    final counts = [_managed.length, _available.length, _investments.length];
    final icons = [LucideIcons.briefcaseBusiness, LucideIcons.layers, LucideIcons.usersRound];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _dark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _brandIcon(),
              const SizedBox(width: 12),
              Expanded(child: _brandTitle()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _blue.withValues(alpha: 0.22)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.layers, color: _blue, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      'PAMM CENTER',
                      style: GoogleFonts.poppins(
                        color: _blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() {
                          _tab = i;
                          _query = '';
                          _search.clear();
                        }),
                        borderRadius: BorderRadius.circular(11),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOutCubic,
                          constraints: const BoxConstraints(minHeight: 44),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: _tab == i
                                ? const LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: _tab == i
                                ? [
                                    BoxShadow(
                                      color: _blue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icons[i],
                                size: 14,
                                color: _tab == i ? Colors.white : _muted,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  labels[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: _tab == i ? Colors.white : _text,
                                    fontSize: 12.5,
                                    fontWeight: _tab == i ? FontWeight.w900 : FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _tab == i
                                      ? Colors.white.withValues(alpha: 0.22)
                                      : _border.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${counts[i]}',
                                  style: GoogleFonts.poppins(
                                    color: _tab == i ? Colors.white : _muted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandIcon() => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A3A8C), Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: _blue.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: const Icon(LucideIcons.activity, color: Colors.white, size: 21),
  );

  Widget _brandTitle() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PAMM Portfolio',
        style: GoogleFonts.poppins(
          color: _text,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        'Percentage Allocation Management Module',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: _muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _buildCreatePammBanner() => _featureBanner(icon: LucideIcons.layers, title: 'Create PAMM Pool', tag: 'PAMM MANAGER', subtitle: 'Set allocation rules, configure profit share and accept investor capital.', actionLabel: 'Create PAMM Pool', onAction: _createPool);

  Widget _snapshot() {
    final managed = _tab == 0;
    return _metricGrid([
      _metricCard(managed ? 'POOL EQUITY' : 'INVESTED EQUITY', r'$0.00', 'Combined capital', LucideIcons.wallet, _blue),
      _metricCard(managed ? 'MANAGED POOLS' : 'NET PROFIT / LOSS', managed ? '${_managed.length}' : '+\$0.00', managed ? 'Accepting deposits' : 'Active allocations', LucideIcons.trendingUp, _green),
      _metricCard('ALLOCATION', 'Proportional', 'Execution MT5', LucideIcons.activity, _gold),
    ]);
  }

  Widget _metricGrid(List<Widget> cards) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 510 ? 3 : 2;
      const gap = 8.0;
      final regularWidth =
          (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var index = 0; index < cards.length; index++)
            SizedBox(
              width: columns == 2 && cards.length.isOdd && index == cards.length - 1
                  ? constraints.maxWidth
                  : regularWidth,
              child: cards[index],
            ),
        ],
      );
    },
  );
  Widget _featureBanner({
    required IconData icon,
    required String title,
    required String tag,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            _gold.withValues(alpha: _dark ? .5 : .65),
            _blue.withValues(alpha: _dark ? .6 : .75),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(17),
          gradient: LinearGradient(
            colors: [_card, _dark ? const Color(0xFF0C1D3E) : const Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_blue, _deepBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: _text,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: _gold.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _gold.withValues(alpha: .3)),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.poppins(
                                color: _gold,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: _muted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(LucideIcons.arrowRight, size: 15),
                label: Text(
                  actionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, String subtext, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _dark ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: accent, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 7),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(String hint, List<String> filters) {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            style: GoogleFonts.poppins(color: _text, fontSize: 12.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: _muted, fontSize: 11.5),
              prefixIcon: Icon(LucideIcons.search, color: _muted, size: 17),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: _muted, size: 16),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (filters.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = filters[i];
                final isSelected = _selectedFilter == f;
                return InkWell(
                  onTap: () => setState(() => _selectedFilter = f),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? _blue : _card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? _blue : _border,
                      ),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : _muted,
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, int count) => Container(
    padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Text(
            '$count ${count == 1 ? 'item' : 'items'}',
            style: GoogleFonts.poppins(
              color: _muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildManagedDetail(_PammPool pool) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final specifications = _poolSpecificationsCard(pool);
      final management = _poolManagementCard(pool);
      final analytics = _poolAnalyticsCard(pool);
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => setState(() => _selectedManagedPool = null),
                  tooltip: 'Back to managed pools',
                  icon: Icon(Icons.arrow_back, color: _text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              children: [
                _managedHeroCard(pool),
                const SizedBox(height: 12),
                if (wide)
                  Row(
                    children: [
                      Expanded(child: _detailMetric('Total pool equity', _money(pool.equity))),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Profit share', '${pool.share.toStringAsFixed(2)}%')),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Leverage', pool.leverage)),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Pool status', pool.status)),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(child: _detailMetric('Total pool equity', _money(pool.equity))),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Profit share', '${pool.share.toStringAsFixed(2)}%')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _detailMetric('Leverage', pool.leverage)),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Pool status', pool.status)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: specifications),
                      const SizedBox(width: 12),
                      Expanded(child: management),
                      const SizedBox(width: 12),
                      Expanded(child: analytics),
                    ],
                  )
                else ...[
                  specifications,
                  const SizedBox(height: 10),
                  management,
                  const SizedBox(height: 10),
                  analytics,
                ],
              ],
            ),
          ),
        ],
      );
    },
  );

  Widget _buildConnectedInvestorPortfolio(_PammPool pool) {
    final investors = _investments.where((investment) => investment.login == pool.login).toList();
    final capital = investors.fold<double>(0, (sum, investment) => sum + investment.deposit);
    final value = investors.fold<double>(0, (sum, investment) => sum + investment.value);
    final pnl = investors.fold<double>(0, (sum, investment) => sum + investment.pnl);
    final fees = investors.fold<double>(0, (sum, investment) => sum + (investment.pnl > 0 ? investment.pnl * pool.share / 100 : 0));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
          child: Row(
            children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 10),
              Expanded(child: Text('Connected investor portfolio', style: TextStyle(color: _text, fontSize: 15.5, fontWeight: FontWeight.w800))),
              IconButton(
                tooltip: 'Close portfolio',
                onPressed: () => setState(() => _connectedInvestorPool = null),
                icon: Icon(Icons.close, color: _muted, size: 19),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _border),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 12,
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: _blue.withValues(alpha: .1), borderRadius: BorderRadius.circular(13)),
                          child: const Icon(Icons.people_outline, color: _blue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PAMM MANAGER', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8)),
                            const SizedBox(height: 4),
                            Text(pool.name, style: TextStyle(color: _text, fontSize: 16.5, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text('Account ID: ${pool.login} · Investor allocation overview', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _portfolioBadge('${investors.length} investors', _green),
                        _portfolioBadge('${pool.share.toStringAsFixed(2)}% performance fee', _blue),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 4 : 2;
                  final gap = 8.0;
                  final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
                  final items = [
                    ('Net capital invested', _money(capital), Icons.account_balance_wallet_outlined),
                    ('Current investor value', _money(value), Icons.credit_card_outlined),
                    ('Net investor P/L', _money(pnl), Icons.trending_up),
                    ('Manager fees accrued', _money(fees), Icons.verified_user_outlined),
                  ];
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: items.map((item) => SizedBox(
                      width: width,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
                        child: Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(item.$2, style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800)),
                            ])),
                            Icon(item.$3, size: 16, color: _blue),
                          ],
                        ),
                      ),
                    )).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Investor accounts', style: TextStyle(color: _text, fontSize: 13.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('Individual balances, allocation, performance and fee breakdown', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w500)),
                  ])),
                  Text('Total units: ${investors.length}', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              if (investors.isEmpty)
                Container(
                  constraints: const BoxConstraints(minHeight: 155),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border, style: BorderStyle.solid)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 42, height: 42, decoration: BoxDecoration(color: _blue.withValues(alpha: .06), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.people_outline, color: _blue, size: 21)),
                    const SizedBox(height: 10),
                    Text('No connected investors yet', style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('Investor accounts and their portfolio details will appear here once they join this pool.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 11.5, height: 1.35)),
                  ]),
                )
              else
                ...investors.map((investment) => _connectedInvestorCard(investment, pool.share)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: _border))),
          child: Row(
            children: [
              Expanded(child: Text('Values reflect saved PAMM investment records in this preview.', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w500))),
              OutlinedButton(onPressed: () => setState(() => _connectedInvestorPool = null), child: const Text('Close portfolio')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _portfolioBadge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: .06), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: .35))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
  );

  Widget _connectedInvestorCard(_PammInvestment investment, double managerShare) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 10,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(investment.name, style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('Investor account · MT5 ${investment.login}', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
        ]),
        Wrap(spacing: 22, runSpacing: 8, children: [
          _joinPoolValue('Capital invested', _money(investment.deposit)),
          _joinPoolValue('Current value', _money(investment.value)),
          _joinPoolValue('Investor P/L', _money(investment.pnl)),
          _joinPoolValue('Manager fee', _money(investment.pnl > 0 ? investment.pnl * managerShare / 100 : 0)),
        ]),
      ],
    ),
  );

  Widget _buildAvailableDetail(_PammPool pool) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final investment = _investmentFor(pool);
      final status = investment != null
          ? 'Active allocation'
          : pool.status == 'Open'
          ? 'Open for investors'
          : 'Closed';
      final specifications = _managedDetailCard(
        title: 'Pool specifications',
        subtitle: 'Account and connection details',
        icon: Icons.dns_outlined,
        child: Column(
          children: [
            _detailRow('Pool display name', pool.name),
            _detailRow('MT5 login ID', pool.login, copyValue: pool.login),
            _detailRow('Platform', 'MetaTrader 5 (MT5)'),
            _detailRow('Server', pool.server, copyValue: pool.server),
            _detailRow('Leverage', pool.leverage),
            _detailRow('Status', status),
          ],
        ),
      );
      final management = _managedDetailCard(
        title: 'Pool management',
        subtitle: 'Manager and allocation details',
        icon: Icons.tune,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Manager', pool.manager),
            _detailRow('Joined on', investment?.joinedOn ?? 'Not joined'),
            if (investment != null) ...[_detailRow('Investor account alias', investment.name), _detailRow('Initial investment', _money(investment.deposit))],
          ],
        ),
      );
      final analytics = _poolAnalyticsCard(pool);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAMM overview',
                        style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text('Review account details, equity and allocations.', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _detailMetric('Pool equity', _money(pool.equity)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _selectedAvailablePool = null),
                  icon: const Icon(Icons.arrow_back, size: 15),
                  label: const Text('Back to investments'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _text,
                    side: BorderSide(color: _border),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                Text('Pool status  ', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                _statusPill(status),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                _investorHeroCard(pool, investment, status),
                const SizedBox(height: 12),
                if (wide)
                  Row(
                    children: [
                      Expanded(child: _detailMetric('Realized P/L', _money(investment?.pnl ?? pool.pnl))),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Profit share', '${pool.share.toStringAsFixed(2)}%')),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Initial investment', _money(investment?.deposit ?? 0))),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Equity share', '${(investment?.share ?? 0).toStringAsFixed(2)}%')),
                    ],
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(child: _detailMetric('Realized P/L', _money(investment?.pnl ?? pool.pnl))),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Profit share', '${pool.share.toStringAsFixed(2)}%')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _detailMetric('Initial investment', _money(investment?.deposit ?? 0))),
                      const SizedBox(width: 8),
                      Expanded(child: _detailMetric('Equity share', '${(investment?.share ?? 0).toStringAsFixed(2)}%')),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: specifications),
                      const SizedBox(width: 12),
                      Expanded(child: management),
                      const SizedBox(width: 12),
                      Expanded(child: analytics),
                    ],
                  )
                else ...[
                  specifications,
                  const SizedBox(height: 10),
                  management,
                  const SizedBox(height: 10),
                  analytics,
                ],
              ],
            ),
          ),
        ],
      );
    },
  );

  _PammInvestment? _investmentFor(_PammPool pool) {
    for (final investment in _investments) {
      if (investment.login == pool.login) return investment;
    }
    return null;
  }

  Widget _investorHeroCard(_PammPool pool, _PammInvestment? investment, String status) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: _blue.withValues(alpha: .1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                investment == null ? 'Available PAMM pool' : 'My investment',
                style: TextStyle(color: _blue, fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Text('MT5 login  ${pool.login}', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Copy MT5 login',
              onPressed: () => _copyPammValue(pool.login),
              icon: Icon(Icons.copy_outlined, size: 14, color: _muted),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment?.name ?? pool.name,
                    style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('Manager: ${pool.manager}', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('Review your allocation, current value and investment performance.', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Net current value', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                Text(
                  _money(investment?.value ?? pool.equity),
                  style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text('USD', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            if (investment == null)
              FilledButton.icon(
                onPressed: status == 'Closed' ? null : () => _joinInvestmentDialog(pool),
                icon: const Icon(Icons.trending_up, size: 16),
                label: const Text('Invest Now'),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              )
            else ...[
              FilledButton.icon(
                onPressed: status == 'Closed' ? null : () => _depositDialog(investment.name),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Deposit funds'),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showPammMessage('Withdrawal requests are not connected in this preview.'),
                icon: const Icon(Icons.remove, size: 16),
                label: const Text('Withdraw funds'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _text,
                  side: BorderSide(color: _border),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
            OutlinedButton.icon(
              onPressed: () => _showPammMessage('Performance details will appear here.'),
              icon: const Icon(Icons.bar_chart, size: 16),
              label: const Text('Performance'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                side: BorderSide(color: _border),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _statusPill(String status) {
    final active = status != 'Closed';
    final color = active ? _green : const Color(0xFFDC3152);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _poolSpecificationsCard(_PammPool pool) => _managedDetailCard(
    title: 'Pool specifications',
    subtitle: 'Account and connection details',
    icon: Icons.dns_outlined,
    child: Column(
      children: [
        _detailRow('Pool display name', pool.name),
        _detailRow('MT5 login ID', pool.login, copyValue: pool.login),
        _detailRow('Platform', 'MetaTrader 5 (MT5)'),
        _detailRow('Server', pool.server, copyValue: pool.server),
        _detailRow('Leverage', pool.leverage),
        _detailRow('Status', pool.status == 'Open' ? 'Accepting deposits' : 'Closed'),
      ],
    ),
  );

  Widget _poolManagementCard(_PammPool pool) => _managedDetailCard(
    title: 'Pool management',
    subtitle: 'Investor access and status',
    icon: Icons.tune,
    child: Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => setState(() => _connectedInvestorPool = pool),
            icon: const Icon(Icons.people_outline, size: 17),
            label: const Text('Connected investor list'),
            style: FilledButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: pool.status == 'Open' ? () => _closeManagedPool(pool) : null,
            icon: const Icon(Icons.show_chart, size: 17),
            label: Text(pool.status == 'Open' ? 'Close investment pool' : 'Pool closed'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC3152),
              side: const BorderSide(color: Color(0xFFFFC5CF)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ],
    ),
  );

  void _openPoolTrades([_PammPool? pool]) {
    final targetPool = pool ?? _selectedManagedPool ?? _selectedAvailablePool;
    final login = targetPool?.login ?? '3503';
    final name = targetPool?.name ?? 'PAMM Pool';
    PoolTradesModal.show(
      context,
      poolLogin: login,
      poolName: name,
      isManager: targetPool == _selectedManagedPool,
    );
  }

  void _openTradePatternAnalysis([_PammPool? pool]) {
    final targetPool = pool ?? _selectedManagedPool ?? _selectedAvailablePool;
    final login = targetPool?.login ?? '3503';
    if (widget.onSelectPage != null) {
      widget.onSelectPage!('Trade Pattern Analysis');
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TradePatternAnalysisPage(
            initialAccountLogin: login,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }
  }

  Widget _poolAnalyticsCard([_PammPool? pool]) => _managedDetailCard(
    title: 'Analytics and activity',
    subtitle: 'Review trading activity',
    icon: Icons.monitor_heart_outlined,
    child: Column(
      children: [
        _detailAction(
          'View pool trades',
          'Orders and floating P/L',
          Icons.bar_chart,
          () => _openPoolTrades(pool),
        ),
        const SizedBox(height: 8),
        _detailAction(
          'Trade pattern analysis',
          'Behavioral metrics and win rate',
          Icons.trending_up,
          () => _openTradePatternAnalysis(pool),
        ),
      ],
    ),
  );

  Widget _managedHeroCard(_PammPool pool) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: _blue.withValues(alpha: .1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'PAMM manager',
                style: TextStyle(color: _blue, fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Text('MT5 login  ${pool.login}', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Copy MT5 login',
              onPressed: () => _copyPammValue(pool.login),
              icon: Icon(Icons.copy_outlined, size: 14, color: _muted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pool.name,
                    style: TextStyle(color: _text, fontSize: 21, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('Manage your pool, review equity and monitor investor activity.', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.35)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Manager balance', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                Text(
                  _money(pool.managerBalance),
                  style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            FilledButton.icon(
              onPressed: pool.status == 'Open' ? () => _depositDialog(pool.name) : null,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Deposit funds'),
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showPammMessage('Withdrawal requests are not connected in this preview.'),
              icon: const Icon(Icons.remove, size: 16),
              label: const Text('Withdraw funds'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                side: BorderSide(color: _border),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showPammMessage('Performance details will appear here.'),
              icon: const Icon(Icons.bar_chart, size: 16),
              label: const Text('Performance'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                side: BorderSide(color: _border),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showPammMessage('MT5 sync is not connected in this preview.'),
              icon: const Icon(Icons.sync, size: 16),
              label: const Text('Sync MT5'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                side: BorderSide(color: _border),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _detailMetric(String title, String value) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _card,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: _text, fontSize: 15.5, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );

  Widget _managedDetailCard({required String title, required String subtitle, required IconData icon, required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _card,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: _muted, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: _text, fontSize: 14.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: _border),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );

  Widget _detailRow(String label, String value, {String? copyValue}) => Container(
    constraints: const BoxConstraints(minHeight: 36),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: _border.withValues(alpha: .7))),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _text, fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ),
        if (copyValue != null) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _copyPammValue(copyValue),
            child: Icon(Icons.copy_outlined, size: 14, color: _muted),
          ),
        ],
      ],
    ),
  );

  Widget _detailAction(String title, String subtitle, IconData icon, VoidCallback onTap) => Material(
    color: _card,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _blue),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: _muted),
          ],
        ),
      ),
    ),
  );

  Future<void> _copyPammValue(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  void _showPammMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _closeManagedPool(_PammPool pool) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close investment pool?'),
        content: Text('Investors will no longer be able to join ${pool.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Close pool')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      setState(() => pool.status = 'Closed');
      _showPammMessage('${pool.name} is closed.');
    }
  }

  void _openManagedDetails(_PammPool pool) {
    setState(() {
      _selectedManagedPool = pool;
      _selectedAvailablePool = null;
    });
  }

  void _openInvestmentDetails(_PammInvestment investment) {
    _PammPool? pool;
    for (final account in [..._available, ..._managed]) {
      if (account.login == investment.login) {
        pool = account;
        break;
      }
    }
    final selectedPool = pool ?? _PammPool(investment.name, investment.login, '1:500', investment.value, investment.share, pnl: investment.pnl, manager: investment.manager);
    setState(() {
      _selectedAvailablePool = selectedPool;
      _selectedManagedPool = null;
    });
  }

  Widget _buildPoolCard(_PammPool pool, {required bool managed}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _dark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: managed
                        ? const [Color(0xFF1A3A8C), Color(0xFF2563EB)]
                        : const [Color(0xFFD97706), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: (managed ? _blue : _gold).withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    pool.name.isEmpty ? 'P' : pool.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pool.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'MT5 ${pool.login}',
                          style: GoogleFonts.poppins(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => _copyPammValue(pool.login),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.copy_outlined,
                              size: 12,
                              color: _muted,
                            ),
                          ),
                        ),
                        if (!managed) ...[
                          Text(
                            ' • ${pool.manager}',
                            style: GoogleFonts.poppins(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'ACTIVE',
                      style: GoogleFonts.poppins(
                        color: _green,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _border),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(child: _cardStat('LEVERAGE', pool.leverage)),
              Expanded(
                child: _cardStat(
                  managed ? 'MANAGER BALANCE' : 'POOL EQUITY',
                  _money(managed ? pool.managerBalance : pool.equity),
                ),
              ),
              Expanded(
                child: _cardStat(
                  managed ? 'POOL VALUE' : 'PROFIT SHARE',
                  managed ? _money(pool.equity) : '${pool.share.toStringAsFixed(2)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  managed ? 'Managed PAMM Pool' : 'Open for Investor Allocation',
                  style: GoogleFonts.poppins(
                    color: _muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (managed) ...[
                OutlinedButton.icon(
                  onPressed: () => _openManagedDetails(pool),
                  icon: const Icon(LucideIcons.chevronRight, size: 14),
                  label: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _text,
                    side: BorderSide(color: _border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 44),
                  ),
                ),
                const SizedBox(width: 7),
                FilledButton(
                  onPressed: () => _depositDialog(pool.name),
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Deposit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ] else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _joinInvestmentDialog(pool),
                      icon: const Icon(LucideIcons.trendingUp, size: 15),
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      label: const Text(
                        'Invest Now',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardStat(String label, String value, {Color? color}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: _muted,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: color ?? _text,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _buildInvestmentCard(_PammInvestment item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _dark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: _green.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.walletCards, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MT5 ${item.login}  •  Manager: ${item.manager}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _share(item.share),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _border),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(child: _cardStat('CURRENT VALUE', _money(item.value))),
              Expanded(child: _cardStat('PROFIT / LOSS', _money(item.pnl), color: item.pnl >= 0 ? _green : _rose)),
              Expanded(child: _cardStat('INITIAL DEPOSIT', _money(item.deposit))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Active PAMM Allocation',
                  style: GoogleFonts.poppins(
                    color: _muted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _openInvestmentDetails(item),
                icon: const Icon(LucideIcons.chevronRight, size: 14),
                label: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _text,
                  side: BorderSide(color: _border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              const SizedBox(width: 7),
              FilledButton(
                onPressed: () => _depositDialog(item.name),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Deposit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String title, String message) => Container(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: Column(
      children: [
        Icon(LucideIcons.searchX, color: _muted, size: 34),
        const SizedBox(height: 10),
        Text(
          title,
          style: GoogleFonts.poppins(color: _text, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _share(double value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7DF),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: const Color(0xFFF5D77F)),
    ),
    child: Text(
      '${value.toStringAsFixed(2)}%',
      style: const TextStyle(color: Color(0xFF99620A), fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );

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

        Widget sectionTitle(String number, String title, {String? hint}) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: _blue.withValues(alpha: .08), borderRadius: BorderRadius.circular(5)),
                child: Text(
                  number,
                  style: TextStyle(color: _blue, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .25),
              ),
              const Spacer(),
              if (hint != null)
                Flexible(
                  child: Text(
                    hint,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        );

        Widget fieldLabel(String label, {bool required = false, String? suffix}) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(text: label),
                      if (required)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(color: Color(0xFFEF4444)),
                        ),
                    ],
                  ),
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: TextStyle(color: _blue, fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
            ],
          ),
        );

        InputDecoration inputDecoration(String hint, {Widget? prefix, Widget? suffix}) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _muted, fontSize: 12.5),
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

        Widget textField(TextEditingController controller, String label, String hint, {bool number = false, bool password = false, bool visible = false, VoidCallback? onToggle}) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              fieldLabel(label, required: true),
              TextFormField(
                controller: controller,
                obscureText: password && !visible,
                keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                style: TextStyle(color: _text, fontSize: 12.5, fontWeight: FontWeight.w600),
                decoration: inputDecoration(
                  hint,
                  suffix: password
                      ? IconButton(
                          onPressed: onToggle,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 14, color: _muted),
                        )
                      : null,
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
            ],
          );
        }

        Widget passwordCard({required String title, required String access, required TextEditingController controller, required bool visible, required VoidCallback toggle}) => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _surface,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.lock, size: 13, color: _muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(color: _text, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(access, style: TextStyle(color: _muted, fontSize: 9)),
                ],
              ),
              const SizedBox(height: 7),
              TextFormField(
                controller: controller,
                obscureText: !visible,
                style: TextStyle(color: _text, fontSize: 11),
                decoration: inputDecoration(
                  'Enter password',
                  suffix: IconButton(
                    onPressed: toggle,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 14, color: _muted),
                  ),
                ),
                validator: (value) {
                  final text = value ?? '';
                  return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d_]{6,12}$').hasMatch(text) ? null : '6–12 chars, uppercase, lowercase and number';
                },
              ),
              const SizedBox(height: 5),
              Text('6–12 characters, uppercase + lowercase + number; letters, numbers and underscore only.', style: TextStyle(color: _muted, fontSize: 8.5, height: 1.35)),
              const SizedBox(height: 5),
              Wrap(
                spacing: 12,
                children: [
                  TextButton.icon(
                    onPressed: toggle,
                    icon: Icon(visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 12),
                    label: Text(visible ? 'Hide' : 'Reveal', style: const TextStyle(fontSize: 9)),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      controller.text = 'Pamm_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}A1';
                    },
                    icon: const Icon(LucideIcons.refreshCw, size: 12),
                    label: const Text('Regenerate', style: TextStyle(fontSize: 9)),
                  ),
                ],
              ),
            ],
          ),
        );

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(sheetContext).maybePop()),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 980, maxHeight: screenHeight * .82),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                        border: Border(top: BorderSide(color: _border)),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .14), blurRadius: 24, offset: const Offset(0, -5))],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(3)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(color: _blue.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(LucideIcons.usersRound, color: _blue, size: 19),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Create PAMM account',
                                        style: TextStyle(color: _text, fontSize: 16, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 2),
                                      Text('Configure pool, trading preferences and credentials', style: TextStyle(color: _muted, fontSize: 10)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  icon: Icon(LucideIcons.x, size: 17, color: _muted),
                                  tooltip: 'Close',
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: _border),
                          Flexible(
                            child: Form(
                              key: formKey,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    sectionTitle('01', 'Account details'),
                                    TextFormField(
                                      controller: name,
                                      style: TextStyle(color: _text, fontSize: 12),
                                      decoration: inputDecoration('Enter PAMM account name', prefix: Icon(LucideIcons.userRound, size: 15, color: _muted)),
                                      validator: (value) => (value?.trim().isNotEmpty ?? false) ? null : 'Account name is required',
                                    ),
                                    const SizedBox(height: 12),
                                    sectionTitle('02', 'Trading preferences'),
                                    if (wide)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
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
                                                Wrap(
                                                  spacing: 5,
                                                  children: [10, 20, 30, 40, 50]
                                                      .map(
                                                        (v) => ChoiceChip(
                                                          label: Text('$v%', style: const TextStyle(fontSize: 9)),
                                                          selected: share.text == '$v',
                                                          onSelected: (_) {
                                                            share.text = '$v';
                                                            setSheetState(() {});
                                                          },
                                                          visualDensity: VisualDensity.compact,
                                                          padding: EdgeInsets.zero,
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                fieldLabel('Account leverage', required: true, suffix: leverage),
                                                Row(
                                                  children: ['1:100', '1:200', '1:500']
                                                      .map(
                                                        (v) => Expanded(
                                                          child: Padding(
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
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                                const SizedBox(height: 6),
                                                DropdownButtonFormField<String>(
                                                  initialValue: leverage,
                                                  isDense: true,
                                                  decoration: inputDecoration('Custom leverage'),
                                                  dropdownColor: _card,
                                                  style: TextStyle(color: _text, fontSize: 10),
                                                  items: ['1:50', '1:100', '1:200', '1:300', '1:500', '1:1000'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                                                  onChanged: (v) => setSheetState(() => leverage = v ?? leverage),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    else ...[
                                      textField(share, 'Performance fee', '20', number: true),
                                      const SizedBox(height: 8),
                                      fieldLabel('Account leverage', required: true, suffix: leverage),
                                      Wrap(
                                        spacing: 6,
                                        children: ['1:100', '1:200', '1:500']
                                            .map(
                                              (v) => ChoiceChip(
                                                label: Text(v, style: const TextStyle(fontSize: 10)),
                                                selected: leverage == v,
                                                onSelected: (_) => setSheetState(() => leverage = v),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    sectionTitle('03', 'Security credentials', hint: 'Keep master password private'),
                                    if (wide)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: passwordCard(title: 'Master password', access: 'Full access', controller: masterPassword, visible: showMasterPassword, toggle: () => setSheetState(() => showMasterPassword = !showMasterPassword)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: passwordCard(title: 'Investor password', access: 'Read-only', controller: investorPassword, visible: showInvestorPassword, toggle: () => setSheetState(() => showInvestorPassword = !showInvestorPassword)),
                                          ),
                                        ],
                                      )
                                    else ...[
                                      passwordCard(title: 'Master password', access: 'Full access', controller: masterPassword, visible: showMasterPassword, toggle: () => setSheetState(() => showMasterPassword = !showMasterPassword)),
                                      const SizedBox(height: 8),
                                      passwordCard(title: 'Investor password', access: 'Read-only', controller: investorPassword, visible: showInvestorPassword, toggle: () => setSheetState(() => showInvestorPassword = !showInvestorPassword)),
                                    ],
                                    const SizedBox(height: 9),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(color: _blue.withValues(alpha: .055), borderRadius: BorderRadius.circular(9)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(LucideIcons.info, color: _blue, size: 14),
                                          const SizedBox(width: 7),
                                          Expanded(
                                            child: Text('PAMM allocations are based on investor equity ratios. Review details before creating.', style: TextStyle(color: _muted, fontSize: 9, height: 1.35)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(height: 1, color: _border),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.shieldCheck, color: _green, size: 14),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text('Review details before submitting.', style: TextStyle(color: _muted, fontSize: 9)),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _text,
                                    side: BorderSide(color: _border),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                  ),
                                  child: const Text('Cancel', style: TextStyle(fontSize: 10)),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  onPressed: () {
                                    if (!(formKey.currentState?.validate() ?? false)) return;
                                    setState(() => _managed.add(_PammPool(name.text.trim(), 'Pending', leverage, 0, double.tryParse(share.text) ?? 20)));
                                    Navigator.pop(sheetContext, true);
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _blue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                  ),
                                  icon: const Icon(LucideIcons.arrowRight, size: 13),
                                  label: const Text('Create account', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    final route = sheetRoute;
    if (route != null) await route.completed;
    name.dispose();
    share.dispose();
    masterPassword.dispose();
    investorPassword.dispose();
  }

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
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final isDark = _dark;
            final modalText = isDark ? Colors.white : const Color(0xFF091836);
            final modalMuted = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
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
              child: Text(
                text.toUpperCase(),
                style: TextStyle(color: modalText, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .25),
              ),
            );

            Widget paymentTab(int index, IconData icon, String title, String subtitle) {
              final selected = method == index;
              return Expanded(
                child: InkWell(
                  onTap: () => setModalState(() => method = index),
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 12 : 15),
                    decoration: BoxDecoration(
                      gradient: selected ? const LinearGradient(colors: [Color(0xFF293FE1), Color(0xFF3569F6)]) : null,
                      color: selected ? null : modalCard,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: selected ? _blue : modalBorder, width: selected ? 1.3 : 1),
                      boxShadow: selected ? [BoxShadow(color: _blue.withValues(alpha: .18), blurRadius: 12, offset: const Offset(0, 5))] : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 15, color: selected ? Colors.white : modalText),
                            const SizedBox(width: 7),
                            Text(
                              title,
                              style: TextStyle(color: selected ? Colors.white : modalText, fontSize: 12.5, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: TextStyle(color: selected ? Colors.white.withValues(alpha: .85) : modalMuted, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(sheetContext).maybePop()),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(compact ? 16 : 22, compact ? 15 : 20, 12, 17),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1B328D), Color(0xFF315FEA), Color(0xFF356DF5)]),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -32,
                                  bottom: -66,
                                  child: Container(
                                    width: 170,
                                    height: 120,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .055)),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: .13),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withValues(alpha: .28)),
                                          ),
                                          child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Deposit Funds',
                                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                                              ),
                                              const SizedBox(height: 4),
                                              Text('Add funds to your PAMM account using your preferred payment method.', style: TextStyle(color: Colors.white.withValues(alpha: .88), fontSize: 10, height: 1.35)),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Close',
                                          onPressed: () => Navigator.pop(sheetContext),
                                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 19),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF071D57).withValues(alpha: .72),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withValues(alpha: .2)),
                                      ),
                                      child: Wrap(
                                        spacing: 9,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle_outline, color: Color(0xFF2BE3B2), size: 13),
                                          Text(
                                            'Account:  $accountName',
                                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                          ),
                                          const Text('|', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                          const Icon(Icons.shield_outlined, color: Color(0xFF8DEED5), size: 13),
                                          const Text(
                                            'Secure request',
                                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(compact ? 14 : 20, 16, compact ? 14 : 20, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: isDark ? _surface : const Color(0xFFF7F9FE),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: modalBorder),
                                    ),
                                    child: Row(children: [paymentTab(0, Icons.currency_bitcoin_rounded, 'USDT', 'Crypto payment'), const SizedBox(width: 6), paymentTab(1, Icons.account_balance_outlined, 'MANUAL', 'Bank transfer')]),
                                  ),
                                  const SizedBox(height: 15),
                                  Container(
                                    padding: const EdgeInsets.all(13),
                                    decoration: BoxDecoration(
                                      color: isDark ? _surface : const Color(0xFFF3F7FF),
                                      borderRadius: BorderRadius.circular(13),
                                      border: Border.all(color: const Color(0xFFD7E4FF), style: BorderStyle.solid),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(color: modalCard, borderRadius: BorderRadius.circular(10)),
                                          child: Icon(Icons.info_outline_rounded, color: _blue, size: 19),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'PAYMENT INSTRUCTIONS',
                                                style: TextStyle(color: modalText, fontSize: 11.5, fontWeight: FontWeight.w900),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(method == 0 ? 'Send USDT using the TRC20 network and upload your transaction screenshot for verification.' : 'Contact Live Support for official bank details before transferring, then upload your payment proof.', style: TextStyle(color: modalMuted, fontSize: 11.5, height: 1.4)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                                  Text(
                                    r'Minimum deposit: $10.00',
                                    style: TextStyle(color: modalMuted, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
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
                                          ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Unable to open the image picker. Please try again.')));
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
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(color: const Color(0xFFE2ECFF), borderRadius: BorderRadius.circular(11)),
                                            child: const Icon(Icons.cloud_upload_outlined, color: _blue, size: 21),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  proof?.name ?? 'Choose transaction proof',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: modalText, fontSize: 12.5, fontWeight: FontWeight.w800),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(proof == null ? 'JPG or PNG · Tap to browse' : 'Selected · Tap to change file', style: TextStyle(color: modalMuted, fontSize: 11)),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            'Browse',
                                            style: TextStyle(color: _blue, fontSize: 11.5, fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 17),
                                  SizedBox(
                                    height: 45,
                                    child: FilledButton.icon(
                                      onPressed: submitting
                                          ? null
                                          : () {
                                              final value = double.tryParse(amount.text.trim());
                                              if (value == null || value < 10) {
                                                ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text(r'Enter a valid deposit amount of at least $10.00.')));
                                                return;
                                              }
                                              if (proof == null) {
                                                ScaffoldMessenger.of(sheetContext).showSnackBar(const SnackBar(content: Text('Please upload your payment proof.')));
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
                                      label: const Text('SUBMIT DEPOSIT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .2)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: compact ? 13 : 20, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: modalBorder)),
                            ),
                            child: Wrap(alignment: WrapAlignment.spaceBetween, runSpacing: 8, spacing: 12, children: [_depositFooterItem(Icons.verified_user_outlined, 'Secure payments', const Color(0xFF3478FF)), _depositFooterItem(Icons.schedule_rounded, 'Verification required', const Color(0xFFFF9800)), _depositFooterItem(Icons.layers_outlined, 'PAMM funding', const Color(0xFF3478FF))]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
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
      Text(
        label,
        style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    ],
  );

  void _joinInvestmentDialog(_PammPool pool) {
    final alias = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      useSafeArea: false,
      builder: (dialogContext) => Dialog(
        alignment: Alignment.bottomCenter,
        backgroundColor: _card,
        insetPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: _border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 520, maxHeight: MediaQuery.sizeOf(dialogContext).height * .9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 10, 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: _blue.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.usersRound, color: _blue, size: 19),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Join PAMM Investment Pool', style: TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('Review pool terms and create your investment account', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: Icon(Icons.close, color: _muted, size: 18),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: _border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _joinFieldLabel('INVESTOR ACCOUNT ALIAS'),
                        TextFormField(
                          controller: alias,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w600),
                          decoration: _joinInputDecoration('e.g. My PAMM Investment'),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Enter an account alias' : null,
                        ),
                        const SizedBox(height: 18),
                        _joinFieldLabel('TARGET PAMM MT5 LOGIN'),
                        TextFormField(
                          initialValue: pool.login,
                          readOnly: true,
                          style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w700),
                          decoration: _joinInputDecoration(''),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(13),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(color: _blue.withValues(alpha: .1), borderRadius: BorderRadius.circular(9)),
                                      child: Icon(Icons.info_outline, color: _blue, size: 18),
                                    ),
                                    const SizedBox(width: 9),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pool details',
                                          style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w800),
                                        ),
                                        Text('Review the manager settings before joining', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 1, color: _border),
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'ACCOUNT DETAILS',
                                        style: TextStyle(color: _muted, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: .4),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(child: _joinPoolValue('Manager / pool name', pool.name)),
                                        const SizedBox(width: 12),
                                        Expanded(child: _joinPoolValue('Leverage', pool.leverage)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(child: _joinPoolValue('Platform', 'MetaTrader 5 (MT5)')),
                                        const SizedBox(width: 12),
                                        Expanded(child: _joinPoolValue('MT5 server', pool.server)),
                                      ],
                                    ),
                                    const SizedBox(height: 13),
                                    Divider(height: 1, color: _border),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'INVESTMENT TERMS',
                                        style: TextStyle(color: _muted, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: .4),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(child: _joinPoolValue('Pool equity', _money(pool.equity))),
                                        const SizedBox(width: 12),
                                        Expanded(child: _joinPoolValue('Manager profit share', '${pool.share.toStringAsFixed(2)}%', valueColor: _gold)),
                                      ],
                                    ),
                                    const SizedBox(height: 13),
                                    Divider(height: 1, color: _border),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text('Investment availability', style: TextStyle(color: _muted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                                        ),
                                        _statusPill(pool.status == 'Open' ? 'Open for investors' : 'Closed'),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text('Manager profit share is the percentage of eligible profits allocated to the manager, according to the platform’s PAMM rules. Trading returns are variable and are not guaranteed.', style: TextStyle(color: _muted, fontSize: 11, height: 1.45)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: _border),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 9, 16, 10 + MediaQuery.paddingOf(dialogContext).bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _text,
                          side: BorderSide(color: _border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: pool.status != 'Open'
                            ? null
                            : () {
                                if (!(formKey.currentState?.validate() ?? false)) {
                                  return;
                                }
                                final now = DateTime.now();
                                final joinedOn = '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
                                setState(() {
                                  _investments.insert(0, _PammInvestment(pool.login, alias.text.trim(), pool.manager, 0, 0, 0, 0, joinedOn: joinedOn));
                                  _selectedAvailablePool = null;
                                  _tab = 2;
                                  _query = '';
                                  _search.clear();
                                });
                                Navigator.pop(dialogContext);
                                showAppMessage('Investment added to your portfolio preview.');
                              },
                        style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: const Color(0xFF17233D), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: const Text('Confirm Investment', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(alias.dispose);
  }

  Widget _joinFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .35),
    ),
  );

  InputDecoration _joinInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _muted.withValues(alpha: .75), fontSize: 12, fontWeight: FontWeight.w600),
    filled: true,
    fillColor: _surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: _blue),
    ),
  );

  Widget _joinPoolValue(String label, String value, {Color? valueColor}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(color: valueColor ?? _text, fontSize: 12.5, fontWeight: FontWeight.w800),
      ),
    ],
  );
}
