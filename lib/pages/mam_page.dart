import 'package:flutter/material.dart';
import 'package:flutter_notch_toast/flutter_notch_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

// -----------------------------------------------------------------------------
// DYNAMIC THEME COLORS HELPER
// -----------------------------------------------------------------------------
class _MamColors {
  const _MamColors({
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

  factory _MamColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _MamColors(
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
// DATA MODELS
// -----------------------------------------------------------------------------
class MamMasterAccount {
  MamMasterAccount({
    required this.name,
    required this.login,
    required this.profitShare,
    required this.leverage,
    required this.balance,
    required this.status,
    required this.risk,
    required this.payout,
    this.allocationMethod = 'Lot Proportional',
    this.investorsCount = 0,
    this.totalAum = 0.0,
    this.monthlyGain = 0.0,
  });

  String name;
  String login;
  double profitShare;
  String leverage;
  double balance;
  String status; // Active, Paused, Draft
  String risk;
  String payout;
  String allocationMethod;
  int investorsCount;
  double totalAum;
  double monthlyGain;
}

class MamInvestmentSubscription {
  MamInvestmentSubscription({
    required this.id,
    required this.poolName,
    required this.managerLogin,
    required this.initialCapital,
    required this.currentEquity,
    required this.unrealizedPnl,
    required this.allocationMethod,
    required this.feePercentage,
    required this.joinedDate,
    required this.isMirroringActive,
    required this.riskLevel,
  });

  final String id;
  final String poolName;
  final String managerLogin;
  final double initialCapital;
  double currentEquity;
  double unrealizedPnl;
  final String allocationMethod;
  final double feePercentage;
  final String joinedDate;
  bool isMirroringActive;
  final String riskLevel;

  double get returnPercentage =>
      initialCapital == 0 ? 0 : ((currentEquity - initialCapital) / initialCapital) * 100;
}

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
  final int copiersCount;
  final double totalAum;
  final String riskScore;
  final double performanceFee;
  final double minDeposit;
  final List<String> pairs;
  final bool isVerified;
}

// -----------------------------------------------------------------------------
// MAIN MAM PAGE WIDGET
// -----------------------------------------------------------------------------
class MamPage extends StatefulWidget {
  const MamPage({
    super.key,
    this.initialTab = 0,
    this.onBack,
  });

  final int initialTab;
  final VoidCallback? onBack;

  @override
  State<MamPage> createState() => _MamPageState();
}

class _MamPageState extends State<MamPage> {
  late int _tab;

  // Search & Filter controllers
  final TextEditingController _managerSearchController = TextEditingController();
  String _managerStatusFilter = 'All Masters';
  String _managerSearchQuery = '';

  final TextEditingController _availableSearchController = TextEditingController();
  String _availableFilter = 'All Pools';
  String _availableSearchQuery = '';

  // Data Lists
  late List<MamMasterAccount> _masters;
  late List<MamInvestmentSubscription> _investments;
  late List<AvailableMamPool> _availablePools;

  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandGold = Color(0xFFEAB308);
  static const Color _brandGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);

    _masters = [
      MamMasterAccount(
        name: 'Alpha Quant Alpha-1',
        login: '8849102',
        profitShare: 20.0,
        leverage: '1:500',
        balance: 45200.00,
        status: 'Active',
        risk: 'Moderate',
        payout: 'Monthly',
        allocationMethod: 'Equity Proportional',
        investorsCount: 48,
        totalAum: 482500.0,
        monthlyGain: 14.8,
      ),
      MamMasterAccount(
        name: 'Prime Trend Rider',
        login: '8850231',
        profitShare: 25.0,
        leverage: '1:200',
        balance: 18500.00,
        status: 'Active',
        risk: 'Low-Risk',
        payout: 'Bi-Weekly',
        allocationMethod: 'Lot Proportional',
        investorsCount: 64,
        totalAum: 620400.0,
        monthlyGain: 11.2,
      ),
      MamMasterAccount(
        name: 'Apex Scalper High-Freq',
        login: '8839014',
        profitShare: 30.0,
        leverage: '1:500',
        balance: 8900.00,
        status: 'Paused',
        risk: 'Aggressive',
        payout: 'Weekly',
        allocationMethod: 'Equity Ratio',
        investorsCount: 19,
        totalAum: 115000.0,
        monthlyGain: 26.5,
      ),
    ];

    _investments = [
      MamInvestmentSubscription(
        id: 'sub_101',
        poolName: 'Alpha Quant Alpha-1',
        managerLogin: '8849102',
        initialCapital: 5000.00,
        currentEquity: 5740.00,
        unrealizedPnl: 740.00,
        allocationMethod: 'Equity Proportional',
        feePercentage: 20.0,
        joinedDate: '12 Oct 2026',
        isMirroringActive: true,
        riskLevel: 'Moderate',
      ),
      MamInvestmentSubscription(
        id: 'sub_102',
        poolName: 'Prime Trend Rider',
        managerLogin: '8850231',
        initialCapital: 3000.00,
        currentEquity: 3336.00,
        unrealizedPnl: 336.00,
        allocationMethod: 'Lot Proportional',
        feePercentage: 25.0,
        joinedDate: '28 Oct 2026',
        isMirroringActive: true,
        riskLevel: 'Low-Risk',
      ),
    ];

    _availablePools = [
      AvailableMamPool(
        id: 'pool_1',
        name: 'Alpha Quant Alpha-1',
        traderHandle: '@quant_master',
        winRate: 78.4,
        monthlyRoi: 14.8,
        maxDrawdown: 6.2,
        copiersCount: 48,
        totalAum: 482500.0,
        riskScore: 'Low',
        performanceFee: 20.0,
        minDeposit: 500.0,
        pairs: ['EURUSD', 'GBPUSD', 'USDJPY'],
        isVerified: true,
      ),
      AvailableMamPool(
        id: 'pool_2',
        name: 'Prime Trend Rider',
        traderHandle: '@trend_prime',
        winRate: 71.9,
        monthlyRoi: 11.2,
        maxDrawdown: 4.8,
        copiersCount: 64,
        totalAum: 620400.0,
        riskScore: 'Low',
        performanceFee: 25.0,
        minDeposit: 250.0,
        pairs: ['XAUUSD', 'US30', 'EURUSD'],
        isVerified: true,
      ),
      AvailableMamPool(
        id: 'pool_3',
        name: 'Apex Scalper High-Freq',
        traderHandle: '@apex_trader',
        winRate: 84.1,
        monthlyRoi: 26.5,
        maxDrawdown: 14.2,
        copiersCount: 19,
        totalAum: 115000.0,
        riskScore: 'High',
        performanceFee: 30.0,
        minDeposit: 1000.0,
        pairs: ['BTCUSD', 'ETHUSD', 'NAS100'],
        isVerified: true,
      ),
      AvailableMamPool(
        id: 'pool_4',
        name: 'Titan Gold Algorithmic',
        traderHandle: '@gold_bot_algo',
        winRate: 76.5,
        monthlyRoi: 18.3,
        maxDrawdown: 8.9,
        copiersCount: 92,
        totalAum: 890000.0,
        riskScore: 'Medium',
        performanceFee: 22.0,
        minDeposit: 500.0,
        pairs: ['XAUUSD', 'XAGUSD'],
        isVerified: true,
      ),
    ];

    _managerSearchController.addListener(() {
      setState(() => _managerSearchQuery = _managerSearchController.text.trim());
    });
    _availableSearchController.addListener(() {
      setState(() => _availableSearchQuery = _availableSearchController.text.trim());
    });
  }

  @override
  void didUpdateWidget(covariant MamPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _tab = widget.initialTab.clamp(0, 2);
      });
    }
  }

  @override
  void dispose() {
    _managerSearchController.dispose();
    _availableSearchController.dispose();
    super.dispose();
  }

  _MamColors get _c => _MamColors.of(context);

  // Tab 0 computed
  int get _activeMastersCount => _masters.where((m) => m.status == 'Active').length;
  double get _totalAum => _masters.fold(0.0, (acc, m) => acc + m.totalAum);
  int get _totalInvestorsCount => _masters.fold(0, (acc, m) => acc + m.investorsCount);

  // Tab 1 computed
  double get _totalInvested => _investments.fold(0.0, (acc, item) => acc + item.initialCapital);
  double get _totalEquity => _investments.fold(0.0, (acc, item) => acc + item.currentEquity);
  double get _totalUnrealizedPnl => _investments.fold(0.0, (acc, item) => acc + item.unrealizedPnl);
  int get _activeSubscriptionsCount => _investments.where((item) => item.isMirroringActive).length;

  // Tab 2 computed
  double get _avgMonthlyRoi => _availablePools.isEmpty
      ? 0.0
      : _availablePools.fold(0.0, (acc, p) => acc + p.monthlyRoi) / _availablePools.length;
  double get _avgWinRate => _availablePools.isEmpty
      ? 0.0
      : _availablePools.fold(0.0, (acc, p) => acc + p.winRate) / _availablePools.length;

  String _formatCurrency(double val) {
    if (val >= 1000000) return '\$${(val / 1000000).toStringAsFixed(2)}M';
    if (val >= 1000) return '\$${(val / 1000).toStringAsFixed(1)}K';
    return '\$${val.toStringAsFixed(0)}';
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    children: [
                      if (_tab == 0) ..._buildManagerTab(),
                      if (_tab == 1) ..._buildInvestorTab(),
                      if (_tab == 2) ..._buildAvailableTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _openCreateMasterSheet,
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(
                'Create Master Node',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            )
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR (Matching PAMM Layout and Visuals)
  // ---------------------------------------------------------------------------
  Widget _buildTopBar() {
    final labels = ['MAM Manager', 'MAM Investor', 'MAM Available'];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _c.isDark ? const Color(0xFF263750) : const Color(0xFFBFD5FF),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(LucideIcons.arrowLeft, color: _c.text, size: 20),
                onPressed: _handleBack,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: 'Back',
              ),
              const SizedBox(width: 4),
              _brandIcon(),
              const SizedBox(width: 10),
              Expanded(child: _brandTitle()),
              _topBarActionButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildTabsBar(labels),
          const SizedBox(height: 10),
          _buildTopBarMiniStats(),
        ],
      ),
    );
  }

  Widget _brandIcon() => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _brandBlue.withValues(alpha: .28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(LucideIcons.briefcaseBusiness, color: Colors.white, size: 22),
      );

  Widget _brandTitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MAM',
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Multi-Account Manager & Pooled Allocations',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _c.muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _topBarActionButton() {
    if (_tab == 0) {
      return FilledButton.icon(
        onPressed: _openCreateMasterSheet,
        icon: const Icon(LucideIcons.plus, size: 14),
        label: const Text('Create', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: _brandGold,
          foregroundColor: const Color(0xFF17233D),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (_tab == 1) {
      return FilledButton.icon(
        onPressed: () => setState(() => _tab = 2),
        icon: const Icon(LucideIcons.compass, size: 14),
        label: const Text('Explore', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: _brandBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: () => setState(() => _tab = 1),
        icon: const Icon(LucideIcons.wallet, size: 14),
        label: const Text('My Allocations', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: _c.text,
          side: BorderSide(color: _c.border),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildTabsBar(List<String> labels) {
    final icons = [LucideIcons.briefcaseBusiness, LucideIcons.usersRound, LucideIcons.layers];
    final counts = [_masters.length, _investments.length, _availablePools.length];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _c.isDark ? const Color(0xFF17243A) : const Color(0xFFEAF1FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _tab = i),
                borderRadius: BorderRadius.circular(9),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
                  decoration: BoxDecoration(
                    color: _tab == i ? _brandBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: _tab == i
                        ? [
                            BoxShadow(
                              color: _brandBlue.withValues(alpha: .25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[i],
                        size: 13,
                        color: _tab == i ? Colors.white : _c.muted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: _tab == i ? Colors.white : _c.text,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: _tab == i
                              ? Colors.white.withValues(alpha: .22)
                              : _c.border.withValues(alpha: .7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${counts[i]}',
                          style: GoogleFonts.inter(
                            color: _tab == i ? Colors.white : _c.muted,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBarMiniStats() {
    if (_tab == 0) {
      return Row(
        children: [
          Expanded(
            child: _miniStat(
              'MANAGED AUM',
              _formatCurrency(_totalAum),
              LucideIcons.wallet,
              _brandBlue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _miniStat(
              'ACTIVE NODES',
              '$_activeMastersCount of ${_masters.length} live',
              LucideIcons.server,
              _brandGreen,
            ),
          ),
        ],
      );
    } else if (_tab == 1) {
      return Row(
        children: [
          Expanded(
            child: _miniStat(
              'TOTAL INVESTED',
              '\$${_totalInvested.toStringAsFixed(0)}',
              LucideIcons.wallet,
              _brandBlue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _miniStat(
              'NET UNREALIZED',
              '${_totalUnrealizedPnl >= 0 ? '+' : ''}\$${_totalUnrealizedPnl.toStringAsFixed(0)}',
              LucideIcons.trendingUp,
              _totalUnrealizedPnl >= 0 ? _brandGreen : _c.red,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: _miniStat(
              'AVAILABLE POOLS',
              '${_availablePools.length} verified',
              LucideIcons.layers,
              _brandBlue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _miniStat(
              'AVG 30D ROI',
              '+${_avgMonthlyRoi.toStringAsFixed(1)}%',
              LucideIcons.percent,
              _brandGold,
            ),
          ),
        ],
      );
    }
  }

  Widget _miniStat(String label, String value, IconData icon, Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accent, size: 15),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: _c.muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      color: _c.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  // ---------------------------------------------------------------------------
  // TAB 0: MAM MANAGER
  // ---------------------------------------------------------------------------
  List<Widget> _buildManagerTab() {
    final q = _managerSearchQuery.toLowerCase();
    final filtered = _masters.where((m) {
      final statusMatch =
          _managerStatusFilter == 'All Masters' || m.status == _managerStatusFilter;
      final qMatch = q.isEmpty || m.name.toLowerCase().contains(q) || m.login.contains(q);
      return statusMatch && qMatch;
    }).toList();

    return [
      _buildManagerHeaderBanner(),
      const SizedBox(height: 14),
      _buildManagerSummaryMetrics(),
      const SizedBox(height: 16),
      _buildManagerSearchAndFilters(),
      const SizedBox(height: 14),
      if (filtered.isEmpty)
        _buildEmptyManagerSearch()
      else
        for (final master in filtered) ...[
          _buildMasterNodeCard(master),
          const SizedBox(height: 12),
        ],
    ];
  }

  Widget _buildManagerHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _c.isDark
              ? [const Color(0xFF1E2E48), const Color(0xFF132034)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.blueBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _c.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.shieldCheck, color: _c.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-Account Manager Hub',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Execute bulk trades across connected accounts with instant proportional allocations and customizable fee tiers.',
                  style: TextStyle(color: _c.muted, fontSize: 11, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerSummaryMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'MANAGED AUM',
            value: _formatCurrency(_totalAum),
            subtext: 'Combined investor capital',
            icon: LucideIcons.wallet,
            accent: _c.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'ACTIVE NODES',
            value: '$_activeMastersCount',
            subtext: 'Trading master accounts',
            icon: LucideIcons.server,
            accent: _c.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'INVESTORS',
            value: '$_totalInvestorsCount',
            subtext: 'Linked follower accounts',
            icon: LucideIcons.usersRound,
            accent: _c.gold,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: _c.muted,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: accent, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _c.muted, fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerSearchAndFilters() {
    final filters = ['All Masters', 'Active', 'Paused'];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _c.border),
          ),
          child: TextField(
            controller: _managerSearchController,
            style: GoogleFonts.inter(color: _c.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search master nodes by name or login...',
              hintStyle: GoogleFonts.inter(color: _c.muted, fontSize: 13),
              prefixIcon: Icon(LucideIcons.search, color: _c.muted, size: 18),
              suffixIcon: _managerSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: _c.muted, size: 16),
                      onPressed: () => _managerSearchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final f in filters)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    f,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _managerStatusFilter == f ? Colors.white : _c.text,
                    ),
                  ),
                  selected: _managerStatusFilter == f,
                  selectedColor: _brandBlue,
                  backgroundColor: _c.card,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _managerStatusFilter == f ? _brandBlue : _c.border,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _managerStatusFilter = f);
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyManagerSearch() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.searchX, color: _c.muted, size: 36),
          const SizedBox(height: 12),
          Text(
            'No Master Accounts Found',
            style: GoogleFonts.inter(color: _c.text, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Try clearing your search query or switching filters.',
            style: TextStyle(color: _c.muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMasterNodeCard(MamMasterAccount master) {
    final isActive = master.status == 'Active';

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? _c.greenLight : _c.goldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isActive ? LucideIcons.radio : LucideIcons.pause,
                  color: isActive ? _c.green : _c.gold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.name,
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MT5 Account: #${master.login} • ${master.allocationMethod}',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? _c.greenLight : _c.goldLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isActive ? _c.green.withValues(alpha: 0.3) : _c.goldBorder,
                  ),
                ),
                child: Text(
                  master.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: isActive ? _c.green : _c.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _c.subBorder),
          const SizedBox(height: 12),

          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _nodeSubMetric(
                  'Managed AUM',
                  _formatCurrency(master.totalAum),
                  LucideIcons.wallet,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Investors',
                  '${master.investorsCount} followers',
                  LucideIcons.users,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Performance Fee',
                  '${master.profitShare.toStringAsFixed(0)}%',
                  LucideIcons.percent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _nodeSubMetric(
                  'Leverage',
                  master.leverage,
                  LucideIcons.zap,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Risk Profile',
                  master.risk,
                  LucideIcons.shield,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  '30D Gain',
                  '+${master.monthlyGain.toStringAsFixed(1)}%',
                  LucideIcons.trendingUp,
                  valueColor: _c.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _c.subBorder),
          const SizedBox(height: 12),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleMasterStatus(master),
                  icon: Icon(
                    isActive ? LucideIcons.pause : LucideIcons.play,
                    size: 14,
                    color: isActive ? _c.gold : _c.green,
                  ),
                  label: Text(
                    isActive ? 'Pause Node' : 'Resume Node',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _c.text,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: _c.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openMasterDetails(master),
                  icon: const Icon(LucideIcons.info, size: 14),
                  label: Text(
                    'Node Details',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nodeSubMetric(String label, String value, IconData icon, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: _c.muted),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: _c.muted, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor ?? _c.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _toggleMasterStatus(MamMasterAccount master) {
    setState(() {
      master.status = master.status == 'Active' ? 'Paused' : 'Active';
    });
    toast.success('Master node #${master.login} marked as ${master.status}');
  }

  void _openMasterDetails(MamMasterAccount master) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MamMasterDetailsSheet(master: master, colors: _c),
    );
  }

  void _openCreateMasterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateMamMasterSheet(
        colors: _c,
        onCreated: (newMaster) {
          setState(() {
            _masters.insert(0, newMaster);
          });
          toast.success('MAM Master Node "${newMaster.name}" created successfully!');
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: MAM INVESTOR
  // ---------------------------------------------------------------------------
  List<Widget> _buildInvestorTab() {
    return [
      _buildInvestorHeaderBanner(),
      const SizedBox(height: 14),
      _buildInvestorSummaryMetrics(),
      const SizedBox(height: 16),
      if (_investments.isEmpty)
        _buildInvestorEmptyState()
      else
        for (final item in _investments) ...[
          _buildSubscriptionCard(item),
          const SizedBox(height: 12),
        ],
    ];
  }

  Widget _buildInvestorHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _c.isDark
              ? [const Color(0xFF1E2E48), const Color(0xFF132034)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.blueBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _c.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.wallet, color: _c.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Investor Allocation Portfolio',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Track your capital mirrored across master pools, monitor real-time PnL, and manage risk controls.',
                  style: TextStyle(color: _c.muted, fontSize: 11, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorSummaryMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'TOTAL INVESTED',
            value: '\$${_totalInvested.toStringAsFixed(0)}',
            subtext: 'Allocated across pools',
            icon: LucideIcons.wallet,
            accent: _c.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'UNREALIZED PnL',
            value: '${_totalUnrealizedPnl >= 0 ? '+' : ''}\$${_totalUnrealizedPnl.toStringAsFixed(0)}',
            subtext: 'Net floating return',
            icon: LucideIcons.trendingUp,
            accent: _totalUnrealizedPnl >= 0 ? _c.green : _c.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'ACTIVE POOLS',
            value: '$_activeSubscriptionsCount',
            subtext: '${_investments.length} total joined',
            icon: LucideIcons.layers,
            accent: _c.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestorEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _c.blueLight,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.briefcaseBusiness, color: _c.blue, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active MAM Allocations',
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You haven\'t invested in any MAM master pools yet. Discover top-performing pools and start earning with proportional allocations.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _c.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => setState(() => _tab = 2),
            icon: const Icon(LucideIcons.compass, size: 16),
            label: const Text('Explore Available Pools', style: TextStyle(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              backgroundColor: _brandBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(MamInvestmentSubscription item) {
    final isProfitable = item.unrealizedPnl >= 0;

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.isMirroringActive ? _c.greenLight : _c.goldLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.isMirroringActive ? LucideIcons.zap : LucideIcons.pause,
                  color: item.isMirroringActive ? _c.green : _c.gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.poolName,
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Master #${item.managerLogin} • Joined ${item.joinedDate}',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isProfitable ? _c.greenLight : _c.redLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isProfitable ? '+' : ''}\$${item.unrealizedPnl.toStringAsFixed(2)} (${isProfitable ? '+' : ''}${item.returnPercentage.toStringAsFixed(1)}%)',
                  style: GoogleFonts.inter(
                    color: isProfitable ? _c.green : _c.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _c.subBorder),
          const SizedBox(height: 12),

          // Details Row
          Row(
            children: [
              Expanded(
                child: _nodeSubMetric(
                  'Allocated Capital',
                  '\$${item.initialCapital.toStringAsFixed(2)}',
                  LucideIcons.dollarSign,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Current Equity',
                  '\$${item.currentEquity.toStringAsFixed(2)}',
                  LucideIcons.wallet,
                  valueColor: isProfitable ? _c.green : _c.red,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Perf. Fee',
                  '${item.feePercentage.toStringAsFixed(0)}%',
                  LucideIcons.percent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _c.subBorder),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      item.isMirroringActive = !item.isMirroringActive;
                    });
                    toast.success(
                      item.isMirroringActive
                          ? 'Resumed mirroring for ${item.poolName}'
                          : 'Paused mirroring for ${item.poolName}',
                    );
                  },
                  icon: Icon(
                    item.isMirroringActive ? LucideIcons.pause : LucideIcons.play,
                    size: 14,
                    color: item.isMirroringActive ? _c.gold : _c.green,
                  ),
                  label: Text(
                    item.isMirroringActive ? 'Pause Mirror' : 'Resume Mirror',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _c.text,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: _c.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDetachPool(item),
                  icon: Icon(LucideIcons.logOut, size: 14, color: _c.red),
                  label: Text(
                    'Stop / Detach',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _c.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: _c.red.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDetachPool(MamInvestmentSubscription item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Detach from ${item.poolName}?',
          style: GoogleFonts.inter(color: _c.text, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Your remaining equity of \$${item.currentEquity.toStringAsFixed(2)} will be immediately returned to your main trading balance. Any open mirrored positions will be closed at the current market rate.',
          style: TextStyle(color: _c.muted, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _c.muted)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _investments.removeWhere((i) => i.id == item.id);
              });
              toast.success('Detached successfully from ${item.poolName}');
            },
            style: FilledButton.styleFrom(backgroundColor: _c.red),
            child: const Text('Confirm Detach', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: MAM AVAILABLE
  // ---------------------------------------------------------------------------
  List<Widget> _buildAvailableTab() {
    final q = _availableSearchQuery.toLowerCase();
    final filtered = _availablePools.where((p) {
      bool filterMatch = true;
      if (_availableFilter == 'Low Risk') filterMatch = p.riskScore == 'Low';
      if (_availableFilter == 'Medium Risk') filterMatch = p.riskScore == 'Medium';
      if (_availableFilter == 'High ROI') filterMatch = p.monthlyRoi >= 15.0;
      if (_availableFilter == 'Top Win Rate') filterMatch = p.winRate >= 75.0;

      final qMatch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.traderHandle.toLowerCase().contains(q) ||
          p.pairs.any((pair) => pair.toLowerCase().contains(q));

      return filterMatch && qMatch;
    }).toList();

    return [
      _buildAvailableHeaderBanner(),
      const SizedBox(height: 14),
      _buildAvailableSummaryMetrics(),
      const SizedBox(height: 16),
      _buildAvailableSearchAndFilters(),
      const SizedBox(height: 14),
      if (filtered.isEmpty)
        _buildEmptyAvailableSearch()
      else
        for (final pool in filtered) ...[
          _buildAvailablePoolCard(pool),
          const SizedBox(height: 14),
        ],
    ];
  }

  Widget _buildAvailableHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _c.isDark
              ? [const Color(0xFF1E2E48), const Color(0xFF132034)]
              : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.blueBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _c.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.compass, color: _c.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Master Pools Directory',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Browse audited algorithmic and discretionary MAM managers. Review win rates, risk scores, and historical drawdowns before investing.',
                  style: TextStyle(color: _c.muted, fontSize: 11, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSummaryMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'AVAILABLE POOLS',
            value: '${_availablePools.length}',
            subtext: 'Audited master strategies',
            icon: LucideIcons.layers,
            accent: _c.blue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'AVG 30D ROI',
            value: '+${_avgMonthlyRoi.toStringAsFixed(1)}%',
            subtext: 'Across all active pools',
            icon: LucideIcons.trendingUp,
            accent: _c.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            label: 'AVG WIN RATE',
            value: '${_avgWinRate.toStringAsFixed(1)}%',
            subtext: 'Historical trade accuracy',
            icon: LucideIcons.checkCheck,
            accent: _c.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableSearchAndFilters() {
    final filters = ['All Pools', 'Low Risk', 'Medium Risk', 'High ROI', 'Top Win Rate'];

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _c.border),
          ),
          child: TextField(
            controller: _availableSearchController,
            style: GoogleFonts.inter(color: _c.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by pool name, trader, or currency pair...',
              hintStyle: GoogleFonts.inter(color: _c.muted, fontSize: 13),
              prefixIcon: Icon(LucideIcons.search, color: _c.muted, size: 18),
              suffixIcon: _availableSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: _c.muted, size: 16),
                      onPressed: () => _availableSearchController.clear(),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final f in filters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      f,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _availableFilter == f ? Colors.white : _c.text,
                      ),
                    ),
                    selected: _availableFilter == f,
                    selectedColor: _brandBlue,
                    backgroundColor: _c.card,
                    checkmarkColor: Colors.white,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _availableFilter == f ? _brandBlue : _c.border,
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _availableFilter = f);
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAvailableSearch() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.searchX, color: _c.muted, size: 36),
          const SizedBox(height: 12),
          Text(
            'No Master Pools Found',
            style: GoogleFonts.inter(color: _c.text, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search keywords or risk filter selection.',
            style: TextStyle(color: _c.muted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePoolCard(AvailableMamPool pool) {
    Color riskColor = _c.green;
    if (pool.riskScore == 'Medium') riskColor = _c.gold;
    if (pool.riskScore == 'High') riskColor = _c.red;

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Avatar, Name, Handle, Verified badge, Risk badge
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 20),
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
                            style: GoogleFonts.inter(
                              color: _c.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pool.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(LucideIcons.badgeCheck, color: _c.blue, size: 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${pool.riskScore} Risk',
                  style: GoogleFonts.inter(
                    color: riskColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _c.subBorder),
          const SizedBox(height: 12),

          // Main Stats
          Row(
            children: [
              Expanded(
                child: _nodeSubMetric(
                  'Monthly ROI',
                  '+${pool.monthlyRoi.toStringAsFixed(1)}%',
                  LucideIcons.trendingUp,
                  valueColor: _c.green,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Win Rate',
                  '${pool.winRate.toStringAsFixed(1)}%',
                  LucideIcons.checkCheck,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Max Drawdown',
                  '${pool.maxDrawdown.toStringAsFixed(1)}%',
                  LucideIcons.activity,
                  valueColor: _c.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _nodeSubMetric(
                  'Total AUM',
                  _formatCurrency(pool.totalAum),
                  LucideIcons.wallet,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Min Deposit',
                  '\$${pool.minDeposit.toStringAsFixed(0)}',
                  LucideIcons.dollarSign,
                ),
              ),
              Expanded(
                child: _nodeSubMetric(
                  'Perf. Fee',
                  '${pool.performanceFee.toStringAsFixed(0)}%',
                  LucideIcons.percent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Traded Pairs Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in pool.pairs)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _c.subCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _c.border),
                  ),
                  child: Text(
                    p,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _c.muted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: _c.subBorder),
          const SizedBox(height: 12),

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openInvestModal(pool),
              icon: const Icon(LucideIcons.plusCircle, size: 16),
              label: Text(
                'Invest in Pool',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
        onConfirmed: (allocatedAmount, selectedAccount, allocationMethod) {
          final newSub = MamInvestmentSubscription(
            id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
            poolName: pool.name,
            managerLogin: '88${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}',
            initialCapital: allocatedAmount,
            currentEquity: allocatedAmount,
            unrealizedPnl: 0.0,
            allocationMethod: allocationMethod,
            feePercentage: pool.performanceFee,
            joinedDate: 'Today',
            isMirroringActive: true,
            riskLevel: pool.riskScore,
          );
          setState(() {
            _investments.insert(0, newSub);
            _tab = 1; // Switch to Tab 1 to see the newly joined pool!
          });
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
  final _MamColors colors;
  final void Function(double amount, String account, String method) onConfirmed;

  @override
  State<_InvestInMamModal> createState() => _InvestInMamModalState();
}

class _InvestInMamModalState extends State<_InvestInMamModal> {
  final TextEditingController _amountController = TextEditingController(text: '1000');
  String _selectedAccount = 'MT5 Standard - #8841029 (\$12,450.00)';
  String _allocationMethod = 'Equity Proportional';
  double _drawdownGuard = 20.0;
  bool _agreedToTerms = true;

  final List<String> _accounts = [
    'MT5 Standard - #8841029 (\$12,450.00)',
    'MT5 Pro Raw - #8859182 (\$5,120.00)',
    'MT5 Scalper - #8830194 (\$2,800.00)',
  ];

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
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
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
                  color: c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Invest in ${widget.pool.name}',
              style: GoogleFonts.inter(
                color: c.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Managed by ${widget.pool.traderHandle} • ${widget.pool.performanceFee.toStringAsFixed(0)}% Perf Fee',
              style: TextStyle(color: c.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),

            // Select Account
            Text('Source Trading Account',
                style: GoogleFonts.inter(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: c.subCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAccount,
                  isExpanded: true,
                  dropdownColor: c.card,
                  icon: Icon(LucideIcons.chevronDown, color: c.muted, size: 18),
                  items: _accounts
                      .map((acc) => DropdownMenuItem(
                            value: acc,
                            child: Text(acc, style: GoogleFonts.inter(color: c.text, fontSize: 12)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAccount = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Allocation Amount
            Text('Investment Amount (USD)',
                style: GoogleFonts.inter(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(color: c.text, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.dollarSign, size: 18),
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
            Row(
              children: [
                for (final amt in [500, 1000, 2500, 5000])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => setState(() => _amountController.text = amt.toString()),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: c.subCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: c.border),
                        ),
                        child: Text(
                          '\$$amt',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Drawdown Guard Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Drawdown Stop Guard',
                    style: GoogleFonts.inter(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('${_drawdownGuard.toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(color: c.red, fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
            Slider(
              value: _drawdownGuard,
              min: 5.0,
              max: 50.0,
              divisions: 9,
              activeColor: c.red,
              inactiveColor: c.border,
              onChanged: (val) => setState(() => _drawdownGuard = val),
            ),
            Text(
              'Mirroring will automatically stop and detach if portfolio drawdown hits this threshold.',
              style: TextStyle(color: c.muted, fontSize: 10),
            ),
            const SizedBox(height: 16),

            // Terms
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  activeColor: c.blue,
                  onChanged: (val) => setState(() => _agreedToTerms = val ?? true),
                ),
                Expanded(
                  child: Text(
                    'I acknowledge MAM market risk and understand past performance does not guarantee future results.',
                    style: TextStyle(color: c.muted, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _agreedToTerms
                    ? () {
                        final amt = double.tryParse(_amountController.text) ?? widget.pool.minDeposit;
                        Navigator.pop(context);
                        widget.onConfirmed(amt, _selectedAccount, _allocationMethod);
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: c.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Confirm Investment',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CREATE MAM MASTER SHEET
// -----------------------------------------------------------------------------
class _CreateMamMasterSheet extends StatefulWidget {
  const _CreateMamMasterSheet({
    required this.colors,
    required this.onCreated,
  });

  final _MamColors colors;
  final ValueChanged<MamMasterAccount> onCreated;

  @override
  State<_CreateMamMasterSheet> createState() => _CreateMamMasterSheetState();
}

class _CreateMamMasterSheetState extends State<_CreateMamMasterSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '10000');
  String _selectedLogin = '8890214';
  String _allocationMethod = 'Lot Proportional';
  String _leverage = '1:500';
  String _risk = 'Moderate';
  String _payout = 'Monthly';
  double _profitShare = 20.0;

  final List<String> _accounts = ['8890214', '8841029', '8859182'];
  final List<String> _methods = [
    'Lot Proportional',
    'Equity Proportional',
    'Balance Proportional',
    'Equity Ratio',
  ];
  final List<String> _leverages = ['1:100', '1:200', '1:500', '1:1000'];
  final List<String> _risks = ['Conservative', 'Low-Risk', 'Moderate', 'Aggressive'];
  final List<String> _payouts = ['Daily', 'Weekly', 'Bi-Weekly', 'Monthly'];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
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
                  color: c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create New MAM Master Node',
              style: GoogleFonts.inter(
                color: c.text,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Configure your master trading pool and distribution parameters.',
              style: TextStyle(color: c.muted, fontSize: 12),
            ),
            const SizedBox(height: 18),

            // Pool Name
            Text('Master Strategy Name',
                style: GoogleFonts.inter(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: GoogleFonts.inter(color: c.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Apex Multi-Strategy Pool',
                hintStyle: TextStyle(color: c.muted, fontSize: 13),
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
            const SizedBox(height: 14),

            // MT5 Account
            Text('MT5 Master Account',
                style: GoogleFonts.inter(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: c.subCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLogin,
                  isExpanded: true,
                  dropdownColor: c.card,
                  items: _accounts
                      .map((acc) => DropdownMenuItem(
                            value: acc,
                            child: Text('MT5 Master Node #$acc',
                                style: GoogleFonts.inter(color: c.text, fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLogin = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Allocation Method
            Text('Allocation Formula',
                style: GoogleFonts.inter(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: c.subCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _allocationMethod,
                  isExpanded: true,
                  dropdownColor: c.card,
                  items: _methods
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m, style: GoogleFonts.inter(color: c.text, fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _allocationMethod = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Profit Share & Leverage
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Leverage',
                          style: GoogleFonts.inter(
                              color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: c.subCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _leverage,
                            isExpanded: true,
                            dropdownColor: c.card,
                            items: _leverages
                                .map((l) => DropdownMenuItem(
                                      value: l,
                                      child: Text(l,
                                          style:
                                              GoogleFonts.inter(color: c.text, fontSize: 13)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _leverage = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Risk Profile',
                          style: GoogleFonts.inter(
                              color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: c.subCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _risk,
                            isExpanded: true,
                            dropdownColor: c.card,
                            items: _risks
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r,
                                          style:
                                              GoogleFonts.inter(color: c.text, fontSize: 13)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _risk = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Performance Fee Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Performance Fee Share',
                    style: GoogleFonts.inter(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
                Text('${_profitShare.toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(color: c.blue, fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
            Slider(
              value: _profitShare,
              min: 5.0,
              max: 50.0,
              divisions: 9,
              activeColor: c.blue,
              inactiveColor: c.border,
              onChanged: (val) => setState(() => _profitShare = val),
            ),
            const SizedBox(height: 18),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final name = _nameController.text.trim().isEmpty
                      ? 'Custom MAM Pool #${_selectedLogin}'
                      : _nameController.text.trim();
                  final balance = double.tryParse(_balanceController.text) ?? 10000.0;

                  final newMaster = MamMasterAccount(
                    name: name,
                    login: _selectedLogin,
                    profitShare: _profitShare,
                    leverage: _leverage,
                    balance: balance,
                    status: 'Active',
                    risk: _risk,
                    payout: _payout,
                    allocationMethod: _allocationMethod,
                    investorsCount: 0,
                    totalAum: balance,
                    monthlyGain: 0.0,
                  );

                  Navigator.pop(context);
                  widget.onCreated(newMaster);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: c.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Create Master Node',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MAM MASTER DETAILS SHEET
// -----------------------------------------------------------------------------
class _MamMasterDetailsSheet extends StatelessWidget {
  const _MamMasterDetailsSheet({
    required this.master,
    required this.colors,
  });

  final MamMasterAccount master;
  final _MamColors colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.name,
                      style: GoogleFonts.inter(
                        color: c.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'MT5 Node #${master.login} • Status: ${master.status}',
                      style: TextStyle(color: c.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 16),

          _detailRow(c, 'Allocation Method', master.allocationMethod),
          _detailRow(c, 'Connected Investors', '${master.investorsCount} followers'),
          _detailRow(c, 'Total Managed AUM', '\$${master.totalAum.toStringAsFixed(2)}'),
          _detailRow(c, 'Performance Fee', '${master.profitShare.toStringAsFixed(0)}%'),
          _detailRow(c, 'Account Leverage', master.leverage),
          _detailRow(c, 'Risk Classification', master.risk),
          _detailRow(c, 'Settlement Cycle', master.payout),
          _detailRow(c, 'Trailing 30D Return', '+${master.monthlyGain.toStringAsFixed(1)}%'),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: c.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(_MamColors c, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.inter(
              color: c.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
