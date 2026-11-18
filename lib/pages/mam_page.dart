import 'package:flutter/material.dart';
import '../app_notifications.dart';
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
  int copiersCount;
  double totalAum;
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
    this.showBackButton = false,
  });

  final int initialTab;
  final VoidCallback? onBack;
  final bool showBackButton;

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
  static const Color _brandGold = Color(0xFFF59E0B);
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
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
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
  // TOP BAR
  // ---------------------------------------------------------------------------
  Widget _buildTopBar() {
    final labels = ['Manager', 'Investor', 'Available'];

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _c.isDark ? const Color(0xFF263750) : const Color(0xFFBFD5FF),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (widget.showBackButton && (widget.onBack != null || Navigator.canPop(context))) ...[
                IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: _c.text, size: 20),
                  onPressed: _handleBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
              ],
              _brandIcon(),
              const SizedBox(width: 12),
              Expanded(child: _brandTitle()),
              _buildLiveStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          _buildTabsBar(labels),
        ],
      ),
    );
  }

  Widget _brandIcon() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _brandBlue.withValues(alpha: .28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(LucideIcons.briefcaseBusiness, color: Colors.white, size: 20),
      );

  Widget _brandTitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MAM',
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Multi-Account Manager & Pooled Allocations',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );

  Widget _buildLiveStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _c.greenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _c.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _c.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: GoogleFonts.inter(
              color: _c.green,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsBar(List<String> labels) {
    final icons = [LucideIcons.briefcaseBusiness, LucideIcons.usersRound, LucideIcons.layers];
    final counts = [_masters.length, _investments.length, _availablePools.length];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _c.isDark ? const Color(0xFF17243A) : const Color(0xFFEAF1FC),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _tab = i),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                  decoration: BoxDecoration(
                    color: _tab == i ? _brandBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _tab == i
                        ? [
                            BoxShadow(
                              color: _brandBlue.withValues(alpha: .25),
                              blurRadius: 6,
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
                            fontSize: 11,
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
                            fontSize: 9,
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
      _buildCreateMasterNodeBanner(),
      const SizedBox(height: 12),
      _buildManagerSummaryMetrics(),
      const SizedBox(height: 14),
      _buildManagerSearchAndFilters(),
      const SizedBox(height: 12),
      if (filtered.isEmpty)
        _buildEmptyManagerSearch()
      else
        for (final master in filtered) ...[
          _buildMasterNodeCard(master),
          const SizedBox(height: 10),
        ],
    ];
  }

  Widget _buildCreateMasterNodeBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _c.isDark
              ? const Color(0xFF2563EB).withValues(alpha: 0.35)
              : const Color(0xFFBFDBFE),
        ),
        boxShadow: [
          BoxShadow(
            color: _brandBlue.withValues(alpha: _c.isDark ? 0.2 : 0.06),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _brandGold.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.plus, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Master Node',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Set allocation rules, profit share %, and accept investor capital',
                      style: TextStyle(
                        color: _c.muted,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: _openCreateMasterSheet,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: Text(
                '+ Create Master Node',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
            subtext: 'Combined capital',
            icon: LucideIcons.wallet,
            accent: _c.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'ACTIVE NODES',
            value: '$_activeMastersCount',
            subtext: 'Live masters',
            icon: LucideIcons.server,
            accent: _c.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'INVESTORS',
            value: '$_totalInvestorsCount',
            subtext: 'Connected followers',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _c.muted,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(icon, color: accent, size: 13),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
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
          height: 44,
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
              hintStyle: GoogleFonts.inter(color: _c.muted, fontSize: 12),
              prefixIcon: Icon(LucideIcons.search, color: _c.muted, size: 17),
              suffixIcon: _managerSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: _c.muted, size: 16),
                      onPressed: () => _managerSearchController.clear(),
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
              final f = filters[index];
              final isSelected = _managerStatusFilter == f;
              return InkWell(
                onTap: () => setState(() => _managerStatusFilter = f),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _brandBlue : _c.subCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _brandBlue : _c.border,
                    ),
                  ),
                  child: Text(
                    f,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : _c.text,
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

  Widget _buildEmptyManagerSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.searchX, color: _c.muted, size: 36),
          const SizedBox(height: 10),
          Text(
            'No Master Accounts Found',
            style: GoogleFonts.inter(color: _c.text, fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Try clearing your search query or switching filters.',
            style: TextStyle(color: _c.muted, fontSize: 11.5),
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
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isActive ? _c.greenLight : _c.goldLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? _c.green.withValues(alpha: 0.3) : _c.goldBorder,
                  ),
                ),
                child: Icon(
                  isActive ? LucideIcons.radio : LucideIcons.pause,
                  color: isActive ? _c.green : _c.gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      master.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MT5 Node: #${master.login} • ${master.allocationMethod}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _c.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // 2x2 Grid for Mobile Card Layout
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
                        'Managed AUM',
                        _formatCurrency(master.totalAum),
                        icon: LucideIcons.wallet,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Followers',
                        '${master.investorsCount} active',
                        icon: LucideIcons.users,
                      ),
                    ),
                  ],
                ),
                Divider(height: 12, thickness: 1, color: _c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _microStat(
                        'Performance Fee',
                        '${master.profitShare.toStringAsFixed(0)}%',
                        icon: LucideIcons.percent,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Leverage / 30D Gain',
                        '${master.leverage} • +${master.monthlyGain.toStringAsFixed(1)}%',
                        icon: LucideIcons.trendingUp,
                        valueColor: _c.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),

          // Actions Row (min 44px)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
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
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(color: _c.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
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
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 11, color: _c.muted),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _c.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: valueColor ?? _c.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMasterStatus(MamMasterAccount master) {
    setState(() {
      master.status = master.status == 'Active' ? 'Paused' : 'Active';
    });
    showAppMessage('Master node #${master.login} marked as ${master.status}');
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
          showAppMessage('MAM Master Node "${newMaster.name}" created successfully!');
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: MAM INVESTOR
  // ---------------------------------------------------------------------------
  List<Widget> _buildInvestorTab() {
    return [
      _buildInvestorExploreBanner(),
      const SizedBox(height: 12),
      _buildInvestorSummaryMetrics(),
      const SizedBox(height: 14),
      if (_investments.isEmpty)
        _buildInvestorEmptyState()
      else
        for (final item in _investments) ...[
          _buildSubscriptionCard(item),
          const SizedBox(height: 10),
        ],
    ];
  }

  Widget _buildInvestorExploreBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _brandBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.compass, color: _brandBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Master Pools',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${_availablePools.length} verified strategy providers ready to mirror',
                  style: TextStyle(color: _c.muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: () => setState(() => _tab = 2),
              icon: const Icon(LucideIcons.arrowRight, size: 14),
              label: Text(
                'Explore',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(88, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
            subtext: 'Allocated capital',
            icon: LucideIcons.wallet,
            accent: _c.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'UNREALIZED PnL',
            value: '${_totalUnrealizedPnl >= 0 ? '+' : ''}\$${_totalUnrealizedPnl.toStringAsFixed(0)}',
            subtext: 'Floating return',
            icon: LucideIcons.trendingUp,
            accent: _totalUnrealizedPnl >= 0 ? _c.green : _c.red,
          ),
        ),
        const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _c.blueLight,
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.briefcaseBusiness, color: _c.blue, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'No Active MAM Allocations',
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'You haven\'t invested in any MAM master pools yet. Discover top-performing pools and start earning.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _c.muted, fontSize: 11.5, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: () => setState(() => _tab = 2),
              icon: const Icon(LucideIcons.compass, size: 16),
              label: const Text('Explore Available Pools', style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.isMirroringActive ? _c.greenLight : _c.goldLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: item.isMirroringActive ? _c.green.withValues(alpha: 0.3) : _c.goldBorder,
                  ),
                ),
                child: Icon(
                  item.isMirroringActive ? LucideIcons.radio : LucideIcons.pause,
                  color: item.isMirroringActive ? _c.green : _c.gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.poolName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Master #${item.managerLogin} • ${item.allocationMethod}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _c.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isProfitable ? _c.greenLight : _c.redLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isProfitable ? _c.green.withValues(alpha: 0.3) : _c.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${isProfitable ? '+' : ''}\$${item.unrealizedPnl.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    color: isProfitable ? _c.green : _c.red,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // 2x2 Grid for Mobile
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
                        'Allocated Capital',
                        '\$${item.initialCapital.toStringAsFixed(0)}',
                        icon: LucideIcons.dollarSign,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Current Equity',
                        '\$${item.currentEquity.toStringAsFixed(2)}',
                        icon: LucideIcons.wallet,
                        valueColor: isProfitable ? _c.green : _c.red,
                      ),
                    ),
                  ],
                ),
                Divider(height: 12, thickness: 1, color: _c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _microStat(
                        'Floating PnL',
                        '${isProfitable ? '+' : ''}\$${item.unrealizedPnl.toStringAsFixed(2)} (${isProfitable ? '+' : ''}${item.returnPercentage.toStringAsFixed(1)}%)',
                        icon: isProfitable ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                        valueColor: isProfitable ? _c.green : _c.red,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Performance Fee',
                        '${item.feePercentage.toStringAsFixed(0)}% Fee',
                        icon: LucideIcons.percent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),

          // Actions (min 44px)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        item.isMirroringActive = !item.isMirroringActive;
                      });
                      showAppMessage(item.isMirroringActive
                            ? 'Resumed mirroring for ${item.poolName}'
                            : 'Paused mirroring for ${item.poolName}');
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
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(color: _c.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
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
                      foregroundColor: _c.red,
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(color: _c.red.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
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
          'Your remaining equity of \$${item.currentEquity.toStringAsFixed(2)} will be returned to your main balance after open positions are settled.',
          style: TextStyle(color: _c.muted, fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(minimumSize: const Size(64, 44)),
            child: Text('Cancel', style: TextStyle(color: _c.muted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _investments.removeWhere((i) => i.id == item.id);
              });
              showAppMessage('Detached successfully from ${item.poolName}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
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
      _buildAvailableSummaryMetrics(),
      const SizedBox(height: 14),
      _buildAvailableSearchAndFilters(),
      const SizedBox(height: 12),
      if (filtered.isEmpty)
        _buildEmptyAvailableSearch()
      else
        for (final pool in filtered) ...[
          _buildAvailablePoolCard(pool),
          const SizedBox(height: 10),
        ],
    ];
  }

  Widget _buildAvailableSummaryMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'AVAILABLE POOLS',
            value: '${_availablePools.length}',
            subtext: 'Audited strategies',
            icon: LucideIcons.layers,
            accent: _c.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'AVG 30D ROI',
            value: '+${_avgMonthlyRoi.toStringAsFixed(1)}%',
            subtext: 'Across active pools',
            icon: LucideIcons.trendingUp,
            accent: _c.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'AVG WIN RATE',
            value: '${_avgWinRate.toStringAsFixed(1)}%',
            subtext: 'Trade accuracy',
            icon: LucideIcons.award,
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
          height: 44,
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _c.border),
          ),
          child: TextField(
            controller: _availableSearchController,
            style: GoogleFonts.inter(color: _c.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search pool name, trader, or pairs...',
              hintStyle: GoogleFonts.inter(color: _c.muted, fontSize: 12),
              prefixIcon: Icon(LucideIcons.search, color: _c.muted, size: 17),
              suffixIcon: _availableSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: _c.muted, size: 16),
                      onPressed: () => _availableSearchController.clear(),
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
              final f = filters[index];
              final isSelected = _availableFilter == f;
              return InkWell(
                onTap: () => setState(() => _availableFilter = f),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _brandBlue : _c.subCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _brandBlue : _c.border,
                    ),
                  ),
                  child: Text(
                    f,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : _c.text,
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

  Widget _buildEmptyAvailableSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.searchX, color: _c.muted, size: 36),
          const SizedBox(height: 10),
          Text(
            'No Master Pools Found',
            style: GoogleFonts.inter(color: _c.text, fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            'Try adjusting your search keywords or risk filter selection.',
            style: TextStyle(color: _c.muted, fontSize: 11.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePoolCard(AvailableMamPool pool) {
    Color riskColor = _c.green;
    String riskLabel = 'Low Risk';
    if (pool.riskScore == 'Medium') {
      riskColor = _c.gold;
      riskLabel = 'Med Risk';
    } else if (pool.riskScore == 'High') {
      riskColor = _c.red;
      riskLabel = 'High Risk';
    }

    return Container(
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Avatar, Name, Handle, Verified badge, Risk badge
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 18),
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
                            style: GoogleFonts.inter(
                              color: _c.text,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (pool.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(LucideIcons.badgeCheck, color: _c.blue, size: 14),
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
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  riskLabel,
                  style: GoogleFonts.inter(
                    color: riskColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
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
                        icon: LucideIcons.percent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Traded Pairs Chips & Action Button
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final p in pool.pairs)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _c.subCard,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: _c.subBorder),
                        ),
                        child: Text(
                          p,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: _c.muted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: FilledButton.icon(
                  onPressed: () => _openInvestModal(pool),
                  icon: const Icon(LucideIcons.plus, size: 15),
                  label: Text(
                    'Invest in Pool',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _brandBlue,
                    foregroundColor: Colors.white,
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
            managerLogin:
                '88${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}',
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
            pool.copiersCount += 1;
            pool.totalAum += allocatedAmount;
            _investments.insert(0, newSub);
            _tab = 1; // Switch to Tab 1 to see the newly joined pool!
          });
          showAppMessage('Successfully invested \$${allocatedAmount.toStringAsFixed(0)} in ${pool.name}!');
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
                      Text(
                        'Managed by ${widget.pool.traderHandle} • ${widget.pool.performanceFee.toStringAsFixed(0)}% Perf Fee',
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

            // Select Account
            Text(
              'Source Trading Account',
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
            const SizedBox(height: 12),

            // Allocation Amount
            Text(
              'Investment Amount (\$ USD)',
              style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(color: c.text, fontSize: 13, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.dollarSign, size: 17),
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
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.subCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.border),
                        ),
                        child: Text(
                          '\$$amt',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: c.text,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Drawdown Guard Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Drawdown Stop Guard',
                  style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_drawdownGuard.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(color: c.red, fontSize: 12.5, fontWeight: FontWeight.w800),
                ),
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
              'Mirroring stops and detaches automatically if portfolio drop reaches this limit.',
              style: TextStyle(color: c.muted, fontSize: 10.5),
            ),
            const SizedBox(height: 12),

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
                    style: TextStyle(color: c.muted, fontSize: 10.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: _agreedToTerms
                    ? () {
                        final amt =
                            double.tryParse(_amountController.text) ?? widget.pool.minDeposit;
                        Navigator.pop(context);
                        widget.onConfirmed(amt, _selectedAccount, _allocationMethod);
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: c.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        'Deploy MAM Master Node',
                        style: GoogleFonts.inter(
                          color: c.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Configure trading pool and allocation parameters.',
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

            // Pool Name
            Text(
              'Master Strategy Name',
              style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              style: GoogleFonts.inter(color: c.text, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Apex Multi-Strategy Pool',
                hintStyle: TextStyle(color: c.muted, fontSize: 12),
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
            const SizedBox(height: 12),

            // MT5 Account
            Text(
              'MT5 Master Account',
              style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedLogin,
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
              items: _accounts
                  .map((acc) => DropdownMenuItem(
                        value: acc,
                        child: Text('MT5 Master Node #$acc',
                            style: GoogleFonts.inter(color: c.text, fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLogin = val);
              },
            ),
            const SizedBox(height: 12),

            // Allocation Method
            Text(
              'Allocation Formula',
              style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _allocationMethod,
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
              items: _methods
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m, style: GoogleFonts.inter(color: c.text, fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _allocationMethod = val);
              },
            ),
            const SizedBox(height: 12),

            // Leverage & Risk Profile
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leverage',
                        style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _leverage,
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
                        items: _leverages
                            .map((l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(l,
                                      style: GoogleFonts.inter(color: c.text, fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _leverage = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Profile',
                        style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _risk,
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
                        items: _risks
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r,
                                      style: GoogleFonts.inter(color: c.text, fontSize: 12)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _risk = val);
                        },
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
                Text(
                  'Performance Fee Share',
                  style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_profitShare.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(color: c.blue, fontSize: 13, fontWeight: FontWeight.w800),
                ),
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
            const SizedBox(height: 14),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: () {
                  final name = _nameController.text.trim().isEmpty
                      ? 'Custom MAM Pool #$_selectedLogin'
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
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Create Master Node',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                ),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
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
                      master.name,
                      style: GoogleFonts.inter(
                        color: c.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'MT5 Node #${master.login} • Status: ${master.status}',
                      style: TextStyle(color: c.muted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                onPressed: () => Navigator.pop(context),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 12),

          _detailRow(c, 'Allocation Method', master.allocationMethod),
          _detailRow(c, 'Connected Followers', '${master.investorsCount} active accounts'),
          _detailRow(c, 'Total Managed AUM', '\$${master.totalAum.toStringAsFixed(2)}'),
          _detailRow(c, 'Performance Fee', '${master.profitShare.toStringAsFixed(0)}%'),
          _detailRow(c, 'Account Leverage', master.leverage),
          _detailRow(c, 'Risk Classification', master.risk),
          _detailRow(c, 'Settlement Cycle', master.payout),
          _detailRow(c, 'Trailing 30D Return', '+${master.monthlyGain.toStringAsFixed(1)}%'),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: c.blue,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(_MamColors c, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: c.muted, fontSize: 11.5)),
          Text(
            value,
            style: GoogleFonts.inter(
              color: c.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
