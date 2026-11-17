import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

// -----------------------------------------------------------------------------
// DYNAMIC THEME COLORS HELPER
// -----------------------------------------------------------------------------
class _AvailableColors {
  const _AvailableColors({
    required this.isDark,
    required this.card,
    required this.subCard,
    required this.border,
    required this.subBorder,
    required this.text,
    required this.muted,
    required this.blue,
    required this.blueLight,
    required this.blueBorder,
    required this.gold,
    required this.goldLight,
    required this.goldBorder,
    required this.green,
    required this.greenLight,
    required this.red,
    required this.redLight,
    required this.navy,
  });

  final bool isDark;
  final Color card;
  final Color subCard;
  final Color border;
  final Color subBorder;
  final Color text;
  final Color muted;
  final Color blue;
  final Color blueLight;
  final Color blueBorder;
  final Color gold;
  final Color goldLight;
  final Color goldBorder;
  final Color green;
  final Color greenLight;
  final Color red;
  final Color redLight;
  final Color navy;

  factory _AvailableColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _AvailableColors(
      isDark: isDark,
      card: isDark ? const Color(0xFF17243A) : Colors.white,
      subCard: isDark ? const Color(0xFF101D31) : const Color(0xFFF7F9FC),
      border: isDark ? const Color(0xFF263750) : const Color(0xFFE2E8F0),
      subBorder: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEDF2F7),
      text: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
      muted: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      blue: const Color(0xFF2563EB),
      blueLight: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEFF6FF),
      blueBorder: isDark ? const Color(0xFF2563EB).withValues(alpha: 0.35) : const Color(0xFFBFDBFE),
      gold: const Color(0xFFEAB308),
      goldLight: isDark ? const Color(0xFF2D2619) : const Color(0xFFFEFCE8),
      goldBorder: isDark ? const Color(0xFFEAB308).withValues(alpha: 0.35) : const Color(0xFFFEF08A),
      green: const Color(0xFF10B981),
      greenLight: isDark ? const Color(0xFF132D28) : const Color(0xFFECFDF5),
      red: const Color(0xFFEF4444),
      redLight: isDark ? const Color(0xFF3B2028) : const Color(0xFFFEF2F2),
      navy: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF10264A),
    );
  }
}

// -----------------------------------------------------------------------------
// DATA MODEL: AVAILABLE MAM POOL
// -----------------------------------------------------------------------------
class AvailableMamPool {
  AvailableMamPool({
    required this.id,
    required this.name,
    required this.traderHandle,
    required this.winRate,
    required this.monthlyRoi,
    required this.maxDrawdown,
    required this.copiersCount,
    required this.totalAum,
    required this.riskScore,
    required this.performanceFee,
    required this.minDeposit,
    required this.pairs,
    required this.isVerified,
  });

  final String id;
  final String name;
  final String traderHandle;
  final double winRate;
  final double monthlyRoi;
  final double maxDrawdown;
  int copiersCount;
  double totalAum;
  final int riskScore; // 1 - 10
  final double performanceFee; // e.g. 20.0%
  final double minDeposit;
  final List<String> pairs;
  final bool isVerified;
}

// -----------------------------------------------------------------------------
// MAM AVAILABLE PAGE
// -----------------------------------------------------------------------------
class MamAvailablePage extends StatefulWidget {
  const MamAvailablePage({
    super.key,
    this.onBack,
    this.onJoinedPool,
  });

  final VoidCallback? onBack;
  final ValueChanged<AvailableMamPool>? onJoinedPool;

  @override
  State<MamAvailablePage> createState() => _MamAvailablePageState();
}

class _MamAvailablePageState extends State<MamAvailablePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All Pools';

  late List<AvailableMamPool> _pools;

  @override
  void initState() {
    super.initState();
    _pools = [
      AvailableMamPool(
        id: 'POOL-1',
        name: 'Quantum Hyper-Scalp',
        traderHandle: '@quant_alex',
        winRate: 84.5,
        monthlyRoi: 24.8,
        maxDrawdown: 5.6,
        copiersCount: 142,
        totalAum: 480200.0,
        riskScore: 3,
        performanceFee: 20.0,
        minDeposit: 500.0,
        pairs: ['EURUSD', 'GBPUSD', 'USDJPY'],
        isVerified: true,
      ),
      AvailableMamPool(
        id: 'POOL-2',
        name: 'Gold & Macro Swing',
        traderHandle: '@aurum_capital',
        winRate: 79.2,
        monthlyRoi: 18.5,
        maxDrawdown: 8.2,
        copiersCount: 98,
        totalAum: 310500.0,
        riskScore: 4,
        performanceFee: 25.0,
        minDeposit: 1000.0,
        pairs: ['XAUUSD', 'XAGUSD', 'USOIL'],
        isVerified: true,
      ),
      AvailableMamPool(
        id: 'POOL-3',
        name: 'Apex Crypto Momentum',
        traderHandle: '@satoshi_labs',
        winRate: 71.0,
        monthlyRoi: 38.4,
        maxDrawdown: 14.2,
        copiersCount: 76,
        totalAum: 195000.0,
        riskScore: 7,
        performanceFee: 30.0,
        minDeposit: 250.0,
        pairs: ['BTCUSD', 'ETHUSD', 'SOLUSD'],
        isVerified: true,
      ),
      AvailableMamPool(
        id: 'POOL-4',
        name: 'Conservative Index Guard',
        traderHandle: '@safe_yields',
        winRate: 88.0,
        monthlyRoi: 11.2,
        maxDrawdown: 3.4,
        copiersCount: 210,
        totalAum: 890000.0,
        riskScore: 2,
        performanceFee: 15.0,
        minDeposit: 2000.0,
        pairs: ['US500', 'NAS100', 'GER40'],
        isVerified: true,
      ),
    ];

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _AvailableColors get _c => _AvailableColors.of(context);

  List<AvailableMamPool> get _filteredPools => _pools.where((p) {
    final q = _searchQuery.toLowerCase();
    final matchesQuery = q.isEmpty ||
        p.name.toLowerCase().contains(q) ||
        p.traderHandle.toLowerCase().contains(q) ||
        p.pairs.any((pair) => pair.toLowerCase().contains(q));

    if (!matchesQuery) return false;

    if (_selectedFilter == 'Low Risk') return p.riskScore <= 3;
    if (_selectedFilter == 'Medium Risk') return p.riskScore > 3 && p.riskScore <= 6;
    if (_selectedFilter == 'High ROI') return p.monthlyRoi >= 20.0;
    if (_selectedFilter == 'Top Win Rate') return p.winRate >= 80.0;

    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              children: [
                _buildTopAppBar(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    children: [
                      _buildHeaderBanner(),
                      const SizedBox(height: 14),
                      _buildMarketMetrics(),
                      const SizedBox(height: 16),
                      _buildSearchAndFilters(),
                      const SizedBox(height: 14),
                      _buildPoolsList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // APP BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _c.card,
        border: Border(bottom: BorderSide(color: _c.border)),
      ),
      child: Row(
        children: [
          if (widget.onBack != null || Navigator.canPop(context))
            IconButton(
              icon: Icon(LucideIcons.arrowLeft, color: _c.text, size: 20),
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available MAM Pools',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Verified Strategy Providers & Master Allocations',
                  style: TextStyle(
                    color: _c.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER BANNER
  // ---------------------------------------------------------------------------
  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAB308), Color(0xFFCA8A04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(LucideIcons.wallet, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Available Master Pools',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Evaluate verified win rates, historical drawdowns, and allocate capital with automatic risk stops.',
                  style: TextStyle(
                    color: _c.muted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MARKET METRICS
  // ---------------------------------------------------------------------------
  Widget _buildMarketMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'Total Pools',
            value: '${_pools.length}',
            accent: _c.blue,
            icon: LucideIcons.layers,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'Avg 30D ROI',
            value: '+23.2%',
            accent: _c.green,
            icon: LucideIcons.trendingUp,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'Avg Win Rate',
            value: '80.7%',
            accent: _c.gold,
            icon: LucideIcons.award,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required Color accent,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _c.muted, fontSize: 10.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH & FILTERS
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilters() {
    final filters = ['All Pools', 'Low Risk', 'Medium Risk', 'High ROI', 'Top Win Rate'];

    return Column(
      children: [
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _c.border),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: _c.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by strategy, trader handle or pairs...',
              hintStyle: TextStyle(color: _c.muted, fontSize: 12),
              prefixIcon: Icon(LucideIcons.search, size: 16, color: _c.muted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, size: 14, color: _c.muted),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = _selectedFilter == filter;
              return InkWell(
                onTap: () => setState(() => _selectedFilter = filter),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? _c.blue : _c.subCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? _c.blue : _c.border),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _c.text,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // POOLS LIST
  // ---------------------------------------------------------------------------
  Widget _buildPoolsList() {
    if (_filteredPools.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.border),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.searchX, size: 38, color: _c.muted),
            const SizedBox(height: 12),
            Text(
              'No Master Pools Match Criteria',
              style: GoogleFonts.inter(color: _c.text, fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Try clearing your search query or selecting a different filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _c.muted, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPools.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pool = _filteredPools[index];
        return _buildPoolCard(pool);
      },
    );
  }

  Widget _buildPoolCard(AvailableMamPool pool) {
    Color riskColor;
    if (pool.riskScore <= 3) {
      riskColor = _c.green;
    } else if (pool.riskScore <= 6) {
      riskColor = _c.gold;
    } else {
      riskColor = _c.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_c.blue, _c.navy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    pool.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
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
                            pool.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(color: _c.text, fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (pool.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(LucideIcons.badgeCheck, size: 14, color: _c.blue),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pool.traderHandle} • ${pool.copiersCount} investors',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Risk ${pool.riskScore}/10',
                  style: TextStyle(color: riskColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _c.subBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _cardStat('Monthly ROI', '+${pool.monthlyRoi.toStringAsFixed(1)}%', valueColor: _c.green),
                _cardStat('Win Rate', '${pool.winRate.toStringAsFixed(1)}%'),
                _cardStat('Max DD', '${pool.maxDrawdown.toStringAsFixed(1)}%', valueColor: _c.red),
                _cardStat('Fee Rate', '${pool.performanceFee.toStringAsFixed(0)}%'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: pool.pairs
                      .map((pair) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _c.subCard,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: _c.subBorder),
                            ),
                            child: Text(pair, style: TextStyle(color: _c.muted, fontSize: 9.5, fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openInvestModal(pool),
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Invest in Pool', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardStat(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: _c.muted, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor ?? _c.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _openInvestModal(AvailableMamPool pool) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InvestInMamModal(
        pool: pool,
        colors: _c,
        onConfirmed: (allocatedAmount) {
          setState(() {
            pool.copiersCount += 1;
            pool.totalAum += allocatedAmount;
          });
          if (widget.onJoinedPool != null) {
            widget.onJoinedPool!(pool);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully invested \$${allocatedAmount.toStringAsFixed(0)} in ${pool.name}!'),
              backgroundColor: _c.green,
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// INVEST IN MAM MODAL
// -----------------------------------------------------------------------------
class _InvestInMamModal extends StatefulWidget {
  const _InvestInMamModal({
    required this.pool,
    required this.colors,
    required this.onConfirmed,
  });

  final AvailableMamPool pool;
  final _AvailableColors colors;
  final ValueChanged<double> onConfirmed;

  @override
  State<_InvestInMamModal> createState() => _InvestInMamModalState();
}

class _InvestInMamModalState extends State<_InvestInMamModal> {
  final _amountController = TextEditingController(text: '1000');
  String _selectedAccount = 'MT5 Standard #1029482 (\$8,420.00)';
  double _drawdownGuard = 15.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Invest in ${widget.pool.name}',
              style: GoogleFonts.inter(color: c.text, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Allocate trading capital to this verified MAM master node.',
              style: TextStyle(color: c.muted, fontSize: 11.5),
            ),
            const SizedBox(height: 16),
            Text('From Trading Account', style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccount,
              dropdownColor: c.card,
              style: TextStyle(color: c.text, fontSize: 12.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: c.subCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
              ),
              items: const [
                DropdownMenuItem(value: 'MT5 Standard #1029482 (\$8,420.00)', child: Text('MT5 Standard #1029482 (\$8,420.00)')),
                DropdownMenuItem(value: 'MT5 Pro #1084920 (\$15,200.00)', child: Text('MT5 Pro #1084920 (\$15,200.00)')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedAccount = val);
              },
            ),
            const SizedBox(height: 12),
            Text('Allocation Capital (\$)', style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: c.text, fontSize: 12.5),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: c.text, fontWeight: FontWeight.w700),
                filled: true,
                fillColor: c.subCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.border)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Drawdown Guard Threshold', style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('${_drawdownGuard.toInt()}%', style: GoogleFonts.inter(color: c.red, fontSize: 12.5, fontWeight: FontWeight.w700)),
              ],
            ),
            Slider(
              value: _drawdownGuard,
              min: 5,
              max: 30,
              divisions: 5,
              activeColor: c.red,
              inactiveColor: c.border,
              onChanged: (val) => setState(() => _drawdownGuard = val),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.subCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.subBorder),
              ),
              child: Column(
                children: [
                  _infoRow('Manager Fee', '${widget.pool.performanceFee.toStringAsFixed(0)}% High-Water Mark', c),
                  _infoRow('Execution Model', 'Proportional Lot Allocation', c),
                  _infoRow('Drawdown Cutoff', 'Auto-detach at ${_drawdownGuard.toInt()}% drop', c),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text.trim()) ?? 1000.0;
                  widget.onConfirmed(amount);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Confirm Investment', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, _AvailableColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: c.muted, fontSize: 11)),
          Text(value, style: TextStyle(color: c.text, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
