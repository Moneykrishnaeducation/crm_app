import 'package:flutter/material.dart';
import 'package:flutter_notch_toast/flutter_notch_toast.dart';
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
      text: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      muted: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      blue: const Color(0xFF2563EB),
      blueLight: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEFF6FF),
      blueBorder: isDark
          ? const Color(0xFF2563EB).withValues(alpha: 0.35)
          : const Color(0xFFBFDBFE),
      gold: const Color(0xFFF59E0B),
      goldLight: isDark ? const Color(0xFF2D2619) : const Color(0xFFFEFCE8),
      goldBorder: isDark
          ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
          : const Color(0xFFFEF08A),
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
// VISUAL RISK GAUGE METER (3-BAR SEGMENTED)
// -----------------------------------------------------------------------------
class _RiskMeter extends StatelessWidget {
  const _RiskMeter({
    required this.level,
    this.barWidth = 3.0,
    this.barSpacing = 2.0,
  });

  final int level; // 1 = Low, 2 = Med, 3 = High
  final double barWidth;
  final double barSpacing;

  @override
  Widget build(BuildContext context) {
    Color activeColor;
    if (level <= 1) {
      activeColor = const Color(0xFF10B981);
    } else if (level == 2) {
      activeColor = const Color(0xFFF59E0B);
    } else {
      activeColor = const Color(0xFFEF4444);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heights = [5.5, 8.5, 11.5];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < 3; i++)
          Container(
            width: barWidth,
            height: heights[i],
            margin: EdgeInsets.only(right: i < 2 ? barSpacing : 0),
            decoration: BoxDecoration(
              color: i < level
                  ? activeColor
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// MAM AVAILABLE PAGE
// -----------------------------------------------------------------------------
class MamAvailablePage extends StatefulWidget {
  const MamAvailablePage({
    super.key,
    this.onBack,
    this.onJoinedPool,
    this.showBackButton = false,
  });

  final VoidCallback? onBack;
  final ValueChanged<AvailableMamPool>? onJoinedPool;
  final bool showBackButton;

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

  String _formatCurrency(double val) {
    if (val >= 1000000) return '\$${(val / 1000000).toStringAsFixed(2)}M';
    if (val >= 1000) return '\$${(val / 1000).toStringAsFixed(1)}K';
    return '\$${val.toStringAsFixed(0)}';
  }

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
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
                    children: [
                      _buildHeaderBanner(),
                      const SizedBox(height: 12),
                      _buildMarketMetrics(),
                      const SizedBox(height: 14),
                      _buildSearchAndFilters(),
                      const SizedBox(height: 12),
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
      padding: const EdgeInsets.fromLTRB(12, 8, 14, 8),
      decoration: BoxDecoration(
        color: _c.card,
        border: Border(bottom: BorderSide(color: _c.border)),
      ),
      child: Row(
        children: [
          if (widget.showBackButton && (widget.onBack != null || Navigator.canPop(context)))
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
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              tooltip: 'Back',
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
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Verified Strategy Providers & Master Allocations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _c.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _c.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _c.blueBorder),
            ),
            child: Text(
              '${_pools.length} Pools',
              style: GoogleFonts.inter(
                color: _c.blue,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAB308), Color(0xFFCA8A04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.compass, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Available Master Pools',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Evaluate audited win rates, live drawdowns, and allocate capital with automatic stop guards.',
                  style: TextStyle(
                    color: _c.muted,
                    fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(13),
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
                  style: TextStyle(
                    color: _c.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 14,
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
          height: 44,
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _c.border),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: _c.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search pool name, trader, or pairs...',
              hintStyle: TextStyle(color: _c.muted, fontSize: 12),
              prefixIcon: Icon(LucideIcons.search, size: 17, color: _c.muted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, size: 16, color: _c.muted),
                      onPressed: () => _searchController.clear(),
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
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
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _c.blue : _c.subCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _c.blue : _c.border,
                    ),
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
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.border),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.searchX, size: 36, color: _c.muted),
            const SizedBox(height: 10),
            Text(
              'No Master Pools Match Criteria',
              style: GoogleFonts.inter(
                color: _c.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Try clearing your search query or selecting another filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _c.muted, fontSize: 11.5),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPools.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final pool = _filteredPools[index];
        return _buildPoolCard(pool);
      },
    );
  }

  Widget _buildPoolCard(AvailableMamPool pool) {
    Color riskColor;
    String riskLabel;
    int riskLevel = 1;
    if (pool.riskScore <= 3) {
      riskColor = _c.green;
      riskLabel = 'Low Risk';
      riskLevel = 1;
    } else if (pool.riskScore <= 6) {
      riskColor = _c.gold;
      riskLabel = 'Med Risk';
      riskLevel = 2;
    } else {
      riskColor = _c.red;
      riskLabel = 'High Risk';
      riskLevel = 3;
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _c.card,
            _c.isDark ? const Color(0xFF131F33) : const Color(0xFFFBFDFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Avatar with Gradient Border & Verified Badge, Info, Risk Badge
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_c.blue, _c.navy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _c.blue.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _c.card,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        pool.name.substring(0, pool.name.length >= 2 ? 2 : 1).toUpperCase(),
                        style: GoogleFonts.inter(
                          color: _c.blue,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (pool.isVerified)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: _c.card,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.check, size: 8, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
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
                            style: GoogleFonts.inter(
                              color: _c.text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
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
                      '${pool.traderHandle} • ${pool.copiersCount} investors • AUM ${_formatCurrency(pool.totalAum)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _c.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _RiskMeter(level: riskLevel),
                    const SizedBox(width: 5),
                    Text(
                      riskLabel,
                      style: GoogleFonts.inter(
                        color: riskColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // 2x2 Grid of Key Stats
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _microStat(
                        'Monthly ROI',
                        '+${pool.monthlyRoi.toStringAsFixed(1)}%',
                        valueColor: _c.green,
                        icon: LucideIcons.trendingUp,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Win Rate',
                        '${pool.winRate.toStringAsFixed(1)}%',
                        valueColor: _c.text,
                        icon: LucideIcons.award,
                      ),
                    ),
                  ],
                ),
                Divider(height: 12, thickness: 1, color: _c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _microStat(
                        'Max Drawdown',
                        '${pool.maxDrawdown.toStringAsFixed(1)}%',
                        valueColor: _c.red,
                        icon: LucideIcons.shieldAlert,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Perf Fee / Min Dep',
                        '${pool.performanceFee.toStringAsFixed(0)}% • \$${pool.minDeposit.toStringAsFixed(0)}',
                        valueColor: _c.text,
                        icon: LucideIcons.percent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Pairs & Action Button
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: pool.pairs
                      .map((pair) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _c.subCard,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: _c.subBorder),
                            ),
                            child: Text(
                              pair,
                              style: TextStyle(
                                color: _c.muted,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _openInvestModal(pool),
                  icon: const Icon(LucideIcons.plus, size: 15),
                  label: const Text(
                    'Invest in Pool',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _c.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(120, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _microStat(String label, String value, {Color? valueColor, IconData? icon}) {
    final tintColor = valueColor ?? _c.blue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: tintColor.withValues(alpha: _c.isDark ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 13, color: tintColor),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _c.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1.5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: valueColor ?? _c.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          toast.success(
            'Successfully invested \$${allocatedAmount.toStringAsFixed(0)} in ${pool.name}!',
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
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addQuickAmount(double delta) {
    final cur = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final next = (cur + delta).clamp(100.0, 1000000.0);
    setState(() {
      _amountController.text = next.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentAmt = double.tryParse(_amountController.text.trim()) ?? widget.pool.minDeposit;
    final grossGain = currentAmt * (widget.pool.monthlyRoi / 100);
    final feeAmount = grossGain * (widget.pool.performanceFee / 100);
    final netGain = grossGain - feeAmount;
    final maxLoss = currentAmt * (_drawdownGuard / 100);
    final stopEquity = (currentAmt - maxLoss).clamp(0.0, double.infinity);
    final guardColor = _drawdownGuard <= 15
        ? c.green
        : (_drawdownGuard <= 25 ? c.gold : c.red);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 20 + bottomInset),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invest in ${widget.pool.name}',
                        style: GoogleFonts.inter(
                          color: c.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Allocate capital to this verified master node.',
                        style: TextStyle(color: c.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, size: 20, color: c.muted),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'From Trading Account',
              style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccount,
              dropdownColor: c.card,
              style: TextStyle(color: c.text, fontSize: 12.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: c.subCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.border),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'MT5 Standard #1029482 (\$8,420.00)',
                  child: Text('MT5 Standard #1029482 (\$8,420.00)'),
                ),
                DropdownMenuItem(
                  value: 'MT5 Pro #1084920 (\$15,200.00)',
                  child: Text('MT5 Pro #1084920 (\$15,200.00)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedAccount = val);
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Allocation Capital (\$ USD)',
              style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: c.text, fontWeight: FontWeight.w700),
                filled: true,
                fillColor: c.subCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: c.border),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Quick-select amount chips: +$500, +$1,000, +$2,500, +$5,000
            Row(
              children: [
                for (final delta in [500.0, 1000.0, 2500.0, 5000.0])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => _addQuickAmount(delta),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.subCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.blue.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '+\$${delta >= 1000 ? '${(delta / 1000).toStringAsFixed(delta % 1000 == 0 ? 0 : 1)}k' : delta.toInt()}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: c.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Dynamic Projected Yield Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: c.isDark
                      ? [const Color(0xFF132D28), const Color(0xFF0F2420)]
                      : [const Color(0xFFECFDF5), const Color(0xFFE6F9F0)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.green.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 14, color: c.green),
                          const SizedBox(width: 6),
                          Text(
                            'Live Projected Yield Preview',
                            style: GoogleFonts.inter(
                              color: c.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: c.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${widget.pool.monthlyRoi.toStringAsFixed(1)}% Past 30D',
                          style: GoogleFonts.inter(
                            color: c.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '+\$${netGain.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          color: c.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Est. Monthly Gain (net of ${widget.pool.performanceFee.toStringAsFixed(0)}% fee)',
                          style: TextStyle(
                            color: c.muted,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Drawdown Guard Threshold
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Drawdown Guard Threshold',
                  style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_drawdownGuard.toInt()}%',
                  style: GoogleFonts.inter(
                    color: guardColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Slider(
              value: _drawdownGuard,
              min: 5,
              max: 30,
              divisions: 5,
              activeColor: guardColor,
              inactiveColor: c.border,
              onChanged: (val) => setState(() => _drawdownGuard = val),
            ),
            const SizedBox(height: 6),

            // Color-coded Drawdown Guard Cutoff Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: c.subCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: guardColor.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 16, color: guardColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Capital Protected: \$${stopEquity.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                color: c.text,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Max Buffer: -\$${maxLoss.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                color: guardColor,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (100 - _drawdownGuard) / 100,
                            backgroundColor: guardColor.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(guardColor),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

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
            const SizedBox(height: 16),
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
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm Investment',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                ),
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
          Text(
            value,
            style: TextStyle(color: c.text, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
