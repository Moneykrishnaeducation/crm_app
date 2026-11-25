import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_notifications.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../widgets/mam_master_node_workspace.dart';
import '../services/auth_api.dart';
import '../widgets/mam_modals.dart';
import 'mam_investor_page.dart';
import 'funds_action_dialog.dart';

export '../widgets/mam_master_node_workspace.dart' show MamMasterAccount;
export '../widgets/mam_modals.dart';
export 'mam_investor_page.dart' show MamInvestorPage;

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
    required this.greenBorder,
    required this.red,
    required this.redLight,
    required this.redBorder,
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
  final Color greenBorder;
  final Color red;
  final Color redLight;
  final Color redBorder;
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
      greenBorder: isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.35)
          : const Color(0xFFA7F3D0),
      red: const Color(0xFFEF4444),
      redLight: isDark ? const Color(0xFF3B2028) : const Color(0xFFFEF2F2),
      redBorder: isDark
          ? const Color(0xFFEF4444).withValues(alpha: 0.35)
          : const Color(0xFFFECACA),
      navy: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF10264A),
    );
  }
}

// -----------------------------------------------------------------------------
// DATA MODELS (MamMasterAccount imported from mam_master_node_workspace.dart)
// -----------------------------------------------------------------------------

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

  double get returnPercentage => initialCapital == 0
      ? 0
      : ((currentEquity - initialCapital) / initialCapital) * 100;
}

class MamInvestorAccount {
  MamInvestorAccount({
    required this.accountId,
    required this.alias,
    required this.masterAccountId,
    required this.balance,
    required this.totalProfit,
    required this.profitShare,
    required this.isCopying,
  });

  final String accountId;
  final String alias;
  final String masterAccountId;
  final double balance;
  final double totalProfit;
  final double profitShare;
  final bool isCopying;
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
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
      ],
    );
  }
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
  State<MamPage> createState() => MamPageState();
}

class MamPageState extends State<MamPage> {
  late int _tab;

  // Search & Filter controllers
  final TextEditingController _managerSearchController =
      TextEditingController();
  String _managerStatusFilter = 'All Masters';
  String _managerSearchQuery = '';

  final TextEditingController _availableSearchController =
      TextEditingController();
  String _availableFilter = 'All Pools';
  String _availableSearchQuery = '';

  // Data Lists
  MamMasterAccount? _selectedMasterDetail;
  MamInvestmentSubscription? _selectedInvestorDetail;
  String? _selectedInvestorAccountId;
  double _account3511Balance = 0.00;
  bool _account3511IsCopying = true;
  String _account3511ScalingMethod = 'BALANCE RATIO';
  double _account3511Factor = 1.00;
  bool _account3511OrderCloning = false;
  int _account3511CloneCount = 1;
  late List<MamMasterAccount> _masters;
  late List<MamInvestmentSubscription> _investments;
  late List<MamInvestorAccount> _investorAccounts;
  late List<AvailableMamPool> _availablePools;

  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandGold = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);

    _masters = [
      MamMasterAccount(
        name: 'Devo-Testmam',
        login: '2141715173',
        profitShare: 40.0,
        leverage: '1:500',
        balance: 0.00,
        status: 'Active',
        risk: 'Medium',
        payout: 'Weekly',
        allocationMethod: 'Lot Proportional',
        investorsCount: 12,
        totalAum: 482500.0,
        monthlyGain: 14.8,
        server: 'VTindex-MT5',
        tradingPlatform: 'MetaTrader 5 (MT5)',
        algoTrading: 'Manual',
        pendingRelease: 4.03,
        releasedPayout: 0.00,
        pendingWallet: 0.00,
        totalSettled: 0.00,
        tradesProcessed: 0,
      ),
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

    _investorAccounts = [
      MamInvestorAccount(
        accountId: '3511',
        alias: 'testtest1 - Investment',
        masterAccountId: '3510',
        balance: 0.00,
        totalProfit: 0.00,
        profitShare: 10.0,
        isCopying: true,
      ),
      MamInvestorAccount(
        accountId: '3520',
        alias: 'testtest2 - Pro Copier',
        masterAccountId: '3510',
        balance: 2450.00,
        totalProfit: 348.50,
        profitShare: 10.0,
        isCopying: true,
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

    _loadMamAccounts();
    _managerSearchController.addListener(() {
      setState(
        () => _managerSearchQuery = _managerSearchController.text.trim(),
      );
    });
    _availableSearchController.addListener(() {
      setState(
        () => _availableSearchQuery = _availableSearchController.text.trim(),
      );
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
  int get _activeMastersCount =>
      _masters.where((m) => m.status == 'Active').length;
  double get _totalAum => _masters.fold(0.0, (acc, m) => acc + m.totalAum);
  int get _totalInvestorsCount =>
      _masters.fold(0, (acc, m) => acc + m.investorsCount);

  // Tab 1 computed
  double get _totalInvested =>
      _investments.fold(0.0, (acc, item) => acc + item.initialCapital);
  double get _totalEquity =>
      _investments.fold(0.0, (acc, item) => acc + item.currentEquity);
  double get _totalUnrealizedPnl =>
      _investments.fold(0.0, (acc, item) => acc + item.unrealizedPnl);
  int get _activeSubscriptionsCount =>
      _investments.where((item) => item.isMirroringActive).length;

  // Tab 2 computed
  double get _avgMonthlyRoi => _availablePools.isEmpty
      ? 0.0
      : _availablePools.fold(0.0, (acc, p) => acc + p.monthlyRoi) /
            _availablePools.length;
  double get _avgWinRate => _availablePools.isEmpty
      ? 0.0
      : _availablePools.fold(0.0, (acc, p) => acc + p.winRate) /
            _availablePools.length;

  String _formatCurrency(double val) {
    if (val >= 1000000) return '\$${(val / 1000000).toStringAsFixed(2)}M';
    if (val >= 1000) return '\$${(val / 1000).toStringAsFixed(1)}K';
    return '\$${val.toStringAsFixed(0)}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showAppMessage('$label copied: $text');
  }

  bool get hasActiveSubView =>
      _selectedMasterDetail != null ||
      _selectedInvestorAccountId != null ||
      _selectedInvestorDetail != null;

  bool popSubView() {
    if (_selectedMasterDetail != null) {
      setState(() {
        _selectedMasterDetail = null;
      });
      return true;
    }
    if (_selectedInvestorAccountId != null || _selectedInvestorDetail != null) {
      setState(() {
        _selectedInvestorDetail = null;
        _selectedInvestorAccountId = null;
      });
      return true;
    }
    return false;
  }

  void _handleBack() {
    if (popSubView()) {
      return;
    }
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedMasterDetail != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          popSubView();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: MamMasterNodeWorkspace(
              master: _selectedMasterDetail!,
              onBack: () => popSubView(),
              onUpdate: (updatedMaster) {
                setState(() {
                  _selectedMasterDetail = updatedMaster;
                  final idx = _masters.indexWhere(
                    (m) => m.login == updatedMaster.login,
                  );
                  if (idx != -1) {
                    _masters[idx] = updatedMaster;
                  }
                });
              },
            ),
          ),
        ),
      );
    }

    if (_selectedInvestorAccountId != null || _selectedInvestorDetail != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          popSubView();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: MamInvestorPage(
              showBackButton: false,
              initialAccountId: _selectedInvestorAccountId ?? '3511',
              onBack: () => popSubView(),
              onExploreAvailable: () {
                setState(() {
                  _selectedInvestorDetail = null;
                  _selectedInvestorAccountId = null;
                  _tab = 2;
                });
              },
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: !hasActiveSubView,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
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
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              )
            : null,
      ),
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
              if (widget.showBackButton &&
                  (widget.onBack != null || Navigator.canPop(context))) ...[
                IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: _c.text, size: 20),
                  onPressed: _handleBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
              ],
              _brandIcon(),
              const SizedBox(width: 12),
              Expanded(child: _brandTitle()),
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
    child: const Icon(
      LucideIcons.briefcaseBusiness,
      color: Colors.white,
      size: 20,
    ),
  );

  Widget _brandTitle() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          'MAM',
          style: GoogleFonts.inter(
            color: _c.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
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

  Widget _buildTabsBar(List<String> labels) {
    final icons = [
      LucideIcons.briefcaseBusiness,
      LucideIcons.usersRound,
      LucideIcons.layers,
    ];
    final counts = [
      _masters.length,
      _investments.length,
      _availablePools.length,
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _c.isDark ? const Color(0xFF17243A) : const Color(0xFFEAF1FC),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _tab = i),
                  borderRadius: BorderRadius.circular(9),
                  splashColor: _brandBlue.withValues(alpha: 0.15),
                  highlightColor: _brandBlue.withValues(alpha: 0.08),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOutCubic,
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: _tab == i
                          ? const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: _tab == i ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: _tab == i
                          ? [
                              BoxShadow(
                                color: _brandBlue.withValues(alpha: 0.35),
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
                          color: _tab == i ? Colors.white : _c.muted,
                        ),
                        const SizedBox(width: 5),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _tab == i
                                ? Colors.white.withValues(alpha: 0.24)
                                : _c.border.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
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
          _managerStatusFilter == 'All Masters' ||
          m.status == _managerStatusFilter;
      final qMatch =
          q.isEmpty || m.name.toLowerCase().contains(q) || m.login.contains(q);
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: _c.isDark ? 0.45 : 0.6),
            const Color(0xFF2563EB).withValues(alpha: _c.isDark ? 0.55 : 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _brandBlue.withValues(alpha: _c.isDark ? 0.25 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [
              _c.card,
              _c.isDark ? const Color(0xFF131F33) : const Color(0xFFF8FAFC),
            ],
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
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _brandGold.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.crown,
                    color: Colors.white,
                    size: 22,
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
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Create Master Node',
                                style: GoogleFonts.inter(
                                  color: _c.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'MAM LEADER',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFF59E0B),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
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
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: _openCreateMasterSheet,
                icon: const Icon(LucideIcons.plus, size: 16),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '+ Create Master Node',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _brandBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: _brandBlue.withValues(alpha: 0.4),
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
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
              ),
              Icon(icon, color: accent, size: 13),
            ],
          ),
          const SizedBox(height: 5),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: _c.text,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              subtext,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _c.muted, fontSize: 9.5),
            ),
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
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
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
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
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

  int _riskToLevel(String risk) {
    final clean = risk.toLowerCase();
    if (clean.contains('high') ||
        clean.contains('aggress') ||
        clean.contains('speculat')) {
      return 3;
    } else if (clean.contains('med') ||
        clean.contains('moderat') ||
        clean.contains('balanc')) {
      return 2;
    }
    return 1;
  }

  Widget _buildMasterNodeCard(MamMasterAccount master) {
    final isActive = master.status == 'Active';
    final statusColor = isActive ? _c.green : _c.gold;
    final riskLevel = _riskToLevel(master.risk);

    return InkWell(
      onTap: () => _openMasterDetails(master),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive ? _c.greenLight : _c.goldLight,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: isActive
                          ? _c.green.withValues(alpha: 0.35)
                          : _c.goldBorder,
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
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          master.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: _c.text,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'MT5 Node: #${master.login} • ${master.allocationMethod}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: _c.muted, fontSize: 10.5),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _RiskMeter(level: riskLevel),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? _c.greenLight : _c.goldLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isActive
                            ? _c.green.withValues(alpha: 0.35)
                            : _c.goldBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4.5),
                        Text(
                          master.status.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: statusColor,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
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

            // Responsive Action Section (min height 44px)
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row 1: Dual financial actions 50/50
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: FilledButton.icon(
                              onPressed: () => _depositToMaster(master),
                              icon: const Icon(LucideIcons.plusCircle, size: 14),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Deposit Funds',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _c.blue,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _c.blueLight,
                                foregroundColor: _c.blue,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(44),
                                side: BorderSide(color: _c.blueBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                              onPressed: () => _withdrawFromMaster(master),
                              icon: Icon(
                                LucideIcons.arrowUpRight,
                                size: 14,
                                color: _c.gold,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Withdraw Funds',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _c.gold,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _c.goldLight,
                                foregroundColor: _c.gold,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(44),
                                side: BorderSide(color: _c.goldBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Node Status & Detail Actions 50/50
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
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  isActive ? 'Pause Node' : 'Resume Node',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    color: isActive ? _c.gold : _c.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isActive
                                      ? _c.goldBorder
                                      : _c.green.withValues(alpha: 0.4),
                                ),
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                              icon: const Icon(
                                LucideIcons.settings2,
                                size: 14,
                                color: Colors.white,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Account Details',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _brandBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _microStat(
    String label,
    String value, {
    Color? valueColor,
    IconData? icon,
  }) {
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
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
                const SizedBox(height: 1.5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: valueColor ?? _c.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  void _toggleMasterStatus(MamMasterAccount master) {
    setState(() {
      master.status = master.status == 'Active' ? 'Paused' : 'Active';
    });
    showAppMessage('Master Account ${master.login} marked as ${master.status}');
  }

  void _openMasterDetails(MamMasterAccount master) {
    setState(() {
      _selectedMasterDetail = master;
    });
  }

  Future<void> _loadMamAccounts() async {
    try {
      final accounts = await AuthApi.instance.getUserMamAccounts();
      if (!mounted) return;
      setState(() {
        _masters = accounts.map(_mamMasterFromApi).toList();
      });
    } catch (error) {
      debugPrint('Could not load MAM accounts: $error');
      if (mounted) showAppMessage(
        error is AuthApiException ? error.message : 'Could not load MAM accounts.',
      );
    }
  }

  double _apiDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  MamMasterAccount _mamMasterFromApi(Map<String, dynamic> account) {
    final login = (account['account_id'] ?? '').toString();
    final risk = (account['risk_level'] ?? 'medium').toString();
    final payout = (account['payout_frequency'] ?? 'weekly').toString();
    return MamMasterAccount(
      name: (account['account_name'] ?? 'MAM Account $login').toString(),
      login: login,
      profitShare: _apiDouble(account['profit_sharing_percentage']),
      leverage: '1:${account['leverage'] ?? 100}',
      balance: _apiDouble(account['balance']),
      status: (account['status'] ?? 'Active').toString().toLowerCase() == 'active'
          ? 'Active'
          : 'Paused',
      risk: risk[0].toUpperCase() + risk.substring(1),
      payout: payout[0].toUpperCase() + payout.substring(1),
      allocationMethod: 'Lot Proportional',
      investorsCount: 0,
      totalAum: _apiDouble(account['balance']),
      monthlyGain: 0,
    );
  }

  void _openCreateMasterSheet() {
    showEstablishMasterMamSheet(
      context,
      onCreated: (newMaster) {
        setState(() {
          _masters.insert(0, newMaster);
        });
        _loadMamAccounts();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: MAM INVESTOR
  // ---------------------------------------------------------------------------
  List<Widget> _buildInvestorTab() {
    return [
      _buildInvestorAccountsHeader(),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _metricCard(
              label: 'INVESTMENT',
              value:
                  '\$${_investorAccounts.fold<double>(0, (sum, account) => sum + account.balance).toStringAsFixed(0)}',
              subtext: 'Current balance',
              icon: LucideIcons.wallet,
              accent: _c.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _metricCard(
              label: 'ACCOUNTS',
              value: '${_investorAccounts.length}',
              subtext: 'Investor accounts',
              icon: LucideIcons.usersRound,
              accent: _c.gold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _metricCard(
              label: 'PROFIT',
              value:
                  '\$${_investorAccounts.fold<double>(0, (sum, account) => sum + account.totalProfit).toStringAsFixed(0)}',
              subtext: 'Total realized',
              icon: LucideIcons.trendingUp,
              accent: _c.green,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      for (final account in _investorAccounts) ...[
        _buildInvestorAccountCard(account),
        const SizedBox(height: 10),
      ],
    ];
  }

  Widget _buildInvestorAccountsHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _c.blueLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _c.blueBorder),
            ),
            child: Icon(LucideIcons.usersRound, color: _c.blue, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Investor Accounts',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Select an account to view its investment workspace',
                  style: TextStyle(color: _c.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorAccountCard(MamInvestorAccount account) {
    final statusColor = account.isCopying ? _c.green : _c.gold;

    return InkWell(
      onTap: () => _openInvestorAccountDetails(account.accountId),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: account.isCopying ? _c.greenLight : _c.goldLight,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: account.isCopying
                          ? _c.green.withValues(alpha: 0.35)
                          : _c.goldBorder,
                    ),
                  ),
                  child: Icon(
                    account.isCopying ? LucideIcons.radio : LucideIcons.pause,
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.alias,
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
                        'Account #${account.accountId} • Master #${account.masterAccountId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _c.muted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: account.isCopying ? _c.greenLight : _c.goldLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: account.isCopying
                          ? _c.green.withValues(alpha: 0.35)
                          : _c.goldBorder,
                    ),
                  ),
                  child: Text(
                    account.isCopying ? 'COPYING' : 'PAUSED',
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
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
                          'Net Balance',
                          '\$${account.balance.toStringAsFixed(2)}',
                          icon: LucideIcons.wallet,
                        ),
                      ),
                      Container(width: 1, height: 28, color: _c.subBorder),
                      Expanded(
                        child: _microStat(
                          'Total Profit',
                          '${account.totalProfit >= 0 ? '+' : ''}\$${account.totalProfit.toStringAsFixed(2)}',
                          icon: LucideIcons.trendingUp,
                          valueColor: account.totalProfit >= 0
                              ? _c.green
                              : _c.red,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 12, thickness: 1, color: _c.subBorder),
                  Row(
                    children: [
                      Expanded(
                        child: _microStat(
                          'Profit Share',
                          '${account.profitShare.toStringAsFixed(0)}%',
                          icon: LucideIcons.percent,
                        ),
                      ),
                      Container(width: 1, height: 28, color: _c.subBorder),
                      Expanded(
                        child: _microStat(
                          'Platform',
                          'MetaTrader 5',
                          icon: LucideIcons.monitor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: () => _openInvestorAccountDetails(account.accountId),
                icon: const Icon(LucideIcons.settings2, size: 14),
                label: Text(
                  'Account Details',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _brandBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInvestorAccountDetails(String accountId) {
    setState(() {
      _selectedInvestorDetail = null;
      _selectedInvestorAccountId = accountId;
    });
  }

  Widget _buildAccount3511Workspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccount3511HeaderBanner(),
        const SizedBox(height: 12),
        _buildAccount3511HeroBalanceCard(),
        const SizedBox(height: 14),
        _buildAccount3511AllocationSpecsCard(),
        const SizedBox(height: 14),
        _buildAccount3511SecurityCredentialsCard(),
        const SizedBox(height: 14),
        _buildAccount3511LiveOrdersCard(),
        const SizedBox(height: 16),
        _buildAccount3511FullscreenCta(),
      ],
    );
  }

  Widget _buildAccount3511HeaderBanner() {
    final statusColor = _account3511IsCopying ? _c.green : _c.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _c.blueLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _c.blueBorder),
            ),
            child: Icon(LucideIcons.activity, color: _c.blue, size: 18),
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
                        'Account 3511 Workspace',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: _c.text,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _account3511IsCopying
                            ? _c.greenLight
                            : _c.goldLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _account3511IsCopying ? 'COPYING' : 'PAUSED',
                        style: GoogleFonts.inter(
                          color: statusColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Connected to Master #3510 • VTIndex-Live',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _c.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: () {
                setState(() {
                  _selectedInvestorDetail = _investments.first;
                });
              },
              icon: const Icon(LucideIcons.externalLink, size: 14),
              label: Text(
                'Fullscreen',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(96, 44),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccount3511HeroBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Alias Badge & ID with copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: _c.blueLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _c.blueBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.wallet, size: 12, color: _c.blue),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'TESTTEST1 - INVESTMENT',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: _c.blue,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _copyToClipboard('3511', 'Account ID'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 44,
                    minWidth: 44,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ID: 3511',
                        style: GoogleFonts.inter(
                          color: _c.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.copy, size: 13, color: _c.muted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Label: NET AVAILABLE BALANCE
          Text(
            'NET AVAILABLE BALANCE',
            style: GoogleFonts.inter(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),

          // Large Balance Display
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${_account3511Balance.toStringAsFixed(2)} USD',
              style: GoogleFonts.inter(
                color: _c.text,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Responsive Action Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 440;
              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row 1 (Primary Financial Actions)
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: FilledButton.icon(
                              onPressed: _openAccount3511DepositModal,
                              icon: const Icon(LucideIcons.plusCircle, size: 15),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Deposit Funds',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _brandBlue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: _openAccount3511WithdrawModal,
                              icon: Icon(
                                LucideIcons.arrowUpRight,
                                size: 15,
                                color: _c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Withdraw Funds',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    color: _c.text,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(46),
                                side: BorderSide(color: _c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Row 2 (Copy Trading Status & Control Strip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _account3511IsCopying
                            ? _c.greenLight.withValues(alpha: 0.5)
                            : _c.goldLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _account3511IsCopying
                              ? _c.greenBorder
                              : _c.goldBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _account3511IsCopying
                                ? LucideIcons.activity
                                : LucideIcons.circleSlash,
                            size: 16,
                            color: _account3511IsCopying ? _c.green : _c.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _account3511IsCopying
                                      ? 'Trade Copying Active'
                                      : 'Trade Copying Paused',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _c.text,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _account3511IsCopying
                                      ? 'Orders mirrored automatically'
                                      : 'Mirroring paused by user',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: _c.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _account3511IsCopying = !_account3511IsCopying;
                                });
                                showAppMessage(
                                  _account3511IsCopying
                                      ? 'Trade copying resumed for Account 3511'
                                      : 'Trade copying paused for Account 3511',
                                );
                              },
                              icon: Icon(
                                _account3511IsCopying
                                    ? LucideIcons.pause
                                    : LucideIcons.play,
                                size: 13,
                                color: _account3511IsCopying ? _c.gold : _c.green,
                              ),
                              label: Text(
                                _account3511IsCopying ? 'Pause' : 'Resume',
                                style: GoogleFonts.inter(
                                  color: _account3511IsCopying ? _c.gold : _c.green,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _account3511IsCopying
                                      ? _c.goldBorder
                                      : _c.greenBorder,
                                ),
                                backgroundColor: _c.card,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Tablet / Desktop screens (>= 440px)
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 44,
                      child: FilledButton.icon(
                        onPressed: _openAccount3511DepositModal,
                        icon: const Icon(LucideIcons.plusCircle, size: 14),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Deposit Funds',
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _brandBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _account3511IsCopying = !_account3511IsCopying;
                          });
                          showAppMessage(
                            _account3511IsCopying
                                ? 'Trade copying resumed for Account 3511'
                                : 'Trade copying paused for Account 3511',
                          );
                        },
                        icon: Icon(
                          _account3511IsCopying
                              ? LucideIcons.circleSlash
                              : LucideIcons.play,
                          size: 14,
                          color: _account3511IsCopying ? _c.gold : _c.green,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _account3511IsCopying ? 'Pause Copy' : 'Resume Copy',
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.inter(
                              color: _account3511IsCopying ? _c.gold : _c.green,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          side: BorderSide(
                            color: _account3511IsCopying
                                ? _c.goldBorder
                                : _c.greenBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _openAccount3511WithdrawModal,
                        icon: Icon(
                          LucideIcons.arrowUpRight,
                          size: 14,
                          color: _c.text,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Withdraw Funds',
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.inter(
                              color: _c.text,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          side: BorderSide(color: _c.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // 2x2 Key Metrics Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _metricBox(
                        label: 'TOTAL PROFIT',
                        value: '\$0.00',
                        valueColor: _c.green,
                        icon: LucideIcons.trendingUp,
                      ),
                    ),
                    Container(width: 1, height: 36, color: _c.subBorder),
                    Expanded(
                      child: _metricBox(
                        label: 'PROFIT SHARE',
                        value: '10%',
                        valueColor: _c.blue,
                        icon: LucideIcons.percent,
                      ),
                    ),
                  ],
                ),
                Divider(height: 16, thickness: 1, color: _c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _metricBox(
                        label: 'RISK LEVEL',
                        value: 'Medium',
                        valueColor: _c.gold,
                        trailing: const _RiskMeter(level: 2),
                        icon: LucideIcons.shieldAlert,
                      ),
                    ),
                    Container(width: 1, height: 36, color: _c.subBorder),
                    Expanded(
                      child: _metricBox(
                        label: 'LEVERAGE',
                        value: '1:1',
                        valueColor: _c.text,
                        icon: LucideIcons.scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccount3511AllocationSpecsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.blueBorder),
                ),
                child: Icon(
                  LucideIcons.slidersHorizontal,
                  color: _c.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allocation Specifications',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Investor node connection parameters',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Specs Table
          Container(
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              children: [
                _specItemRow('Account ID', '3511', copyable: true),
                Divider(height: 1, thickness: 1, color: _c.subBorder),
                _specItemRow('Master Account ID', '3510', copyable: true),
                Divider(height: 1, thickness: 1, color: _c.subBorder),
                _specItemRow('Account Alias', 'testtest1 - Investment'),
                Divider(height: 1, thickness: 1, color: _c.subBorder),
                _specItemRow('Trading Platform', 'MetaTrader 5 (MT5)'),
                Divider(height: 1, thickness: 1, color: _c.subBorder),
                _specItemRow('Server', 'VTIndex-Live', copyable: true),
                Divider(height: 1, thickness: 1, color: _c.subBorder),
                _specItemRow(
                  'Status',
                  _account3511IsCopying ? 'Active Copying' : 'Copying Paused',
                  isBadge: true,
                  badgeColor: _account3511IsCopying ? _c.green : _c.gold,
                ),
                Divider(height: 1, thickness: 1, color: _c.subBorder),
                _specItemRow('Leverage', '1:1'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccount3511SecurityCredentialsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _c.greenLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.greenBorder),
                ),
                child: Icon(LucideIcons.shieldCheck, color: _c.green, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security & Credentials',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Investor sub-account credentials',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sub-card 1: Investor Password Settings
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.keyRound, size: 16, color: _c.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TERMINAL ACCESS CREDENTIALS',
                            style: GoogleFonts.inter(
                              color: _c.muted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update your investor terminal password anytime. This does not interfere with the master manager\'s trade execution.',
                            style: TextStyle(
                              color: _c.text,
                              fontSize: 11.5,
                              height: 1.35,
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
                  child: OutlinedButton.icon(
                    onPressed: _openAccount3511PasswordModal,
                    icon: Icon(LucideIcons.settings, size: 15, color: _c.text),
                    label: Text(
                      'Investor Password Settings',
                      style: TextStyle(
                        color: _c.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(color: _c.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sub-card 2: Multiplier Scaling
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.sliders, size: 16, color: _c.gold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MULTIPLIER SCALING',
                                style: GoogleFonts.inter(
                                  color: _c.muted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _c.goldLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _c.goldBorder),
                                ),
                                child: Text(
                                  _account3511ScalingMethod == 'BALANCE RATIO'
                                      ? 'Balance Ratio'
                                      : '${_account3511Factor.toStringAsFixed(2)}x Ratio',
                                  style: GoogleFonts.inter(
                                    color: _c.gold,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customize proportional trade volume or enable multi-order execution cloning.',
                            style: TextStyle(
                              color: _c.text,
                              fontSize: 11.5,
                              height: 1.35,
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
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showEditCopyMultipliersModal(
                        context,
                        accountId: '3511',
                        initialMethod: _account3511ScalingMethod,
                        initialFactor: _account3511Factor,
                        initialOrderCloning: _account3511OrderCloning,
                        initialCloneCount: _account3511CloneCount,
                        onDeploy: (method, factor, orderCloning, cloneCount) {
                          setState(() {
                            _account3511ScalingMethod = method;
                            _account3511Factor = factor;
                            _account3511OrderCloning = orderCloning;
                            _account3511CloneCount = cloneCount;
                          });
                          showAppMessage(
                            'Configuration deployed to Account 3511!',
                          );
                        },
                      );
                    },
                    icon: Icon(
                      LucideIcons.arrowLeftRight,
                      size: 15,
                      color: _c.blue,
                    ),
                    label: Text(
                      'Edit Copy Multipliers',
                      style: TextStyle(
                        color: _c.blue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(color: _c.blueBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

  Widget _buildAccount3511LiveOrdersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.blueBorder),
                ),
                child: Icon(LucideIcons.activity, color: _c.blue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Orders & Trades',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Real-time exposure & manager positions',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tile 1: Investor Live Trades
          _account3511NavTile(
            icon: LucideIcons.barChart2,
            iconColor: _c.blue,
            title: 'Investor Live Trades',
            subtitle: 'Your open positions & floating P&L',
            badgeText: '3 Open',
            badgeColor: _c.green,
            onTap: _openAccount3511LiveTradesModal,
          ),
          const SizedBox(height: 10),

          // Tile 2: Master Manager Trades
          _account3511NavTile(
            icon: LucideIcons.usersRound,
            iconColor: _c.gold,
            title: 'Master Manager Trades',
            subtitle: 'Source orders executed by master node',
            badgeText: '5 Master Tickets',
            badgeColor: _c.blue,
            onTap: _openAccount3511MasterTradesModal,
          ),
          const SizedBox(height: 10),

          // Tile 3: Trade Pattern Analysis
          _account3511NavTile(
            icon: LucideIcons.lineChart,
            iconColor: _c.green,
            title: 'Trade Pattern Analysis',
            subtitle: 'AI behavioral metrics & win rate',
            badgeText: '78.4% Win',
            badgeColor: _c.green,
            onTap: _openAccount3511PatternModal,
          ),
        ],
      ),
    );
  }

  Widget _buildAccount3511FullscreenCta() {
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _brandBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.maximize2,
                  size: 16,
                  color: _brandBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dedicated Investor Workspace',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Open the fullscreen view with multi-account switching',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: () {
                setState(() {
                  _selectedInvestorDetail = _investments.first;
                });
              },
              icon: const Icon(LucideIcons.externalLink, size: 16),
              label: Text(
                'Open Fullscreen Workspace',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _specItemRow(
    String label,
    String value, {
    bool copyable = false,
    bool isBadge = false,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: _c.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? _c.green).withValues(
                      alpha: _c.isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (badgeColor ?? _c.green).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: badgeColor ?? _c.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          color: badgeColor ?? _c.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (copyable) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _copyToClipboard(value, label),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      minWidth: 44,
                    ),
                    alignment: Alignment.center,
                    child: Icon(LucideIcons.copy, size: 14, color: _c.blue),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _account3511NavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _c.subCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _c.subBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: _c.isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: _c.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    style: TextStyle(color: _c.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: _c.isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.inter(
                  color: badgeColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(LucideIcons.chevronRight, size: 16, color: _c.muted),
          ],
        ),
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: _c.isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: valueColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _c.muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: valueColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 6),
                      trailing,
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAccount3511DepositModal() {
    showFundsActionDialog(
      context,
      withdrawal: false,
      accountId: '3511',
      accountLabel: 'Live MT5 · 3511',
      onCompleted: (amt) {
        setState(() {
          _account3511Balance += amt;
        });
      },
    );
  }

  void _depositToMaster(MamMasterAccount master) {
    showFundsActionDialog(
      context,
      withdrawal: false,
      accountId: master.login,
      accountLabel: '${master.name} · Master #${master.login}',
      onCompleted: (amt) {
        setState(() {
          master.balance += amt;
          master.totalAum += amt;
        });
        showAppMessage(
          'Deposited \$${amt.toStringAsFixed(2)} to Master Node #${master.login}',
        );
      },
    );
  }

  void _withdrawFromMaster(MamMasterAccount master) {
    showFundsActionDialog(
      context,
      withdrawal: true,
      accountId: master.login,
      accountLabel: '${master.name} · Master #${master.login}',
      onCompleted: (amt) {
        setState(() {
          master.balance = (master.balance - amt).clamp(0.0, double.infinity);
          master.totalAum = (master.totalAum - amt).clamp(0.0, double.infinity);
        });
        showAppMessage(
          'Withdrew \$${amt.toStringAsFixed(2)} from Master Node #${master.login}',
        );
      },
    );
  }

  void _openAccount3511WithdrawModal() {
    showFundsActionDialog(
      context,
      withdrawal: true,
      accountId: '3511',
      accountLabel: 'Live MT5 · 3511',
      onCompleted: (amt) {
        setState(() {
          _account3511Balance = (_account3511Balance - amt).clamp(
            0.0,
            double.infinity,
          );
        });
      },
    );
  }

  void _openAccount3511PasswordModal() {
    bool showTrading = false;
    bool showInvestor = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: _c.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: _c.border),
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
                          color: _c.muted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _c.greenLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _c.green.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Icon(
                                LucideIcons.keyRound,
                                size: 17,
                                color: _c.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Investor Credentials',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _c.text,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Security keys for Account #3511 (VTIndex-Live)',
                      style: TextStyle(fontSize: 11.5, color: _c.muted),
                    ),
                    const SizedBox(height: 16),

                    // Password Card 1: Trading Password
                    _accountCredentialCard(
                      label: 'INVESTOR TRADING PASSWORD',
                      value: showTrading ? 'AlphaTrader@2025' : '••••••••••••',
                      description: 'Used for terminal execution permissions and account verification.',
                      isMasked: !showTrading,
                      onToggleVisibility: () {
                        setModalState(() {
                          showTrading = !showTrading;
                        });
                      },
                      onCopy: () => _copyToClipboard(
                        'AlphaTrader@2025',
                        'Investor Trading Password',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password Card 2: Read-Only Investor Password
                    _accountCredentialCard(
                      label: 'READ-ONLY (INVESTOR) PASSWORD',
                      value: showInvestor ? 'InvestView#8841' : '••••••••••••',
                      description: 'Safe for third-party auditing tools (Myfxbook, FXBlue, etc.).',
                      isMasked: !showInvestor,
                      onToggleVisibility: () {
                        setModalState(() {
                          showInvestor = !showInvestor;
                        });
                      },
                      onCopy: () => _copyToClipboard(
                        'InvestView#8841',
                        'Read-Only Password',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Auth Token Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _c.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _c.subBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MT5 AUTH TOKEN',
                                style: GoogleFonts.inter(
                                  color: _c.muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              InkWell(
                                onTap: () => _copyToClipboard(
                                  'tok_live_3511_98a72b',
                                  'MT5 Auth Token',
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 44,
                                    minWidth: 44,
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Copy',
                                        style: GoogleFonts.inter(
                                          color: _c.blue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        LucideIcons.copy,
                                        size: 13,
                                        color: _c.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'tok_live_3511_98a72b',
                            style: GoogleFonts.firaCode(
                              fontSize: 12.5,
                              color: _c.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: FilledButton.styleFrom(
                          backgroundColor: _brandBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Close Credentials',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _accountCredentialCard({
    required String label,
    required String value,
    required String description,
    required bool isMasked,
    required VoidCallback onToggleVisibility,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.subBorder),
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
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isMasked ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 16,
                      color: _c.muted,
                    ),
                    onPressed: onToggleVisibility,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.copy, size: 16, color: _c.blue),
                    onPressed: onCopy,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(description, style: TextStyle(color: _c.muted, fontSize: 10.5)),
        ],
      ),
    );
  }

  void _openAccount3511LiveTradesModal() {
    final trades = [
      {
        'symbol': 'EURUSD',
        'type': 'BUY',
        'lots': '0.20',
        'open': '1.08450',
        'curr': '1.08720',
        'pnl': '+54.00',
        'ticket': '98201',
        'isPos': true,
      },
      {
        'symbol': 'GBPUSD',
        'type': 'SELL',
        'lots': '0.15',
        'open': '1.29800',
        'curr': '1.29610',
        'pnl': '+28.50',
        'ticket': '98208',
        'isPos': true,
      },
      {
        'symbol': 'XAUUSD',
        'type': 'BUY',
        'lots': '0.05',
        'open': '2685.10',
        'curr': '2685.44',
        'pnl': '+1.70',
        'ticket': '98214',
        'isPos': true,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.80,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _c.border),
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
                    color: _c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _c.blueLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _c.blueBorder),
                        ),
                        child: Icon(
                          LucideIcons.barChart2,
                          size: 17,
                          color: _c.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Investor Live Trades',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _c.text,
                            ),
                          ),
                          Text(
                            'Account #3511 • 3 Active Orders',
                            style: TextStyle(fontSize: 11, color: _c.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _c.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL FLOATING P&L',
                      style: GoogleFonts.inter(
                        color: _c.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '+\$84.20 USD',
                      style: GoogleFonts.inter(
                        color: _c.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: trades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = trades[index];
                    final isPos = t['isPos'] as bool;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _c.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _c.subBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: t['type'] == 'BUY'
                                  ? _c.blueLight
                                  : _c.redLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${t['type']} ${t['lots']}',
                              style: GoogleFonts.inter(
                                color: t['type'] == 'BUY' ? _c.blue : _c.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['symbol'] as String,
                                  style: GoogleFonts.inter(
                                    color: _c.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '#${t['ticket']} • ${t['open']} → ${t['curr']}',
                                  style: TextStyle(
                                    color: _c.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${t['pnl']}',
                            style: GoogleFonts.inter(
                              color: isPos ? _c.green : _c.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAccount3511MasterTradesModal() {
    final masterTrades = [
      {
        'symbol': 'EURUSD',
        'type': 'BUY',
        'lots': '5.00',
        'ticket': '9812044',
        'pnl': '+270.00',
      },
      {
        'symbol': 'GBPUSD',
        'type': 'SELL',
        'lots': '3.50',
        'ticket': '9812110',
        'pnl': '+133.00',
      },
      {
        'symbol': 'USDJPY',
        'type': 'BUY',
        'lots': '2.00',
        'ticket': '9812239',
        'pnl': '-18.00',
      },
      {
        'symbol': 'XAUUSD',
        'type': 'BUY',
        'lots': '2.00',
        'ticket': '9812301',
        'pnl': '+35.00',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.80,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _c.border),
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
                    color: _c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _c.goldLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _c.goldBorder),
                        ),
                        child: Icon(
                          LucideIcons.usersRound,
                          size: 17,
                          color: _c.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master Manager Trades',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _c.text,
                            ),
                          ),
                          Text(
                            'Source Node #3510 • 4 Open Trades',
                            style: TextStyle(fontSize: 11, color: _c.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Expanded(
                child: ListView.separated(
                  itemCount: masterTrades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final mt = masterTrades[index];
                    final isPos = (mt['pnl'] as String).startsWith('+');
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _c.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _c.subBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: mt['type'] == 'BUY'
                                  ? _c.blueLight
                                  : _c.redLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${mt['type']} ${mt['lots']}',
                              style: GoogleFonts.inter(
                                color: mt['type'] == 'BUY' ? _c.blue : _c.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mt['symbol'] as String,
                                  style: GoogleFonts.inter(
                                    color: _c.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Master Ticket #${mt['ticket']}',
                                  style: TextStyle(
                                    color: _c.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${mt['pnl']}',
                            style: GoogleFonts.inter(
                              color: isPos ? _c.green : _c.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAccount3511PatternModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.80,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _c.border),
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
                      color: _c.muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _c.greenLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _c.greenBorder),
                          ),
                          child: Icon(
                            LucideIcons.lineChart,
                            size: 17,
                            color: _c.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trade Pattern Analysis',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _c.text,
                              ),
                            ),
                            Text(
                              'AI Behavioral Metrics & Historical Alpha',
                              style: TextStyle(fontSize: 11, color: _c.muted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _c.subCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _c.subBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Win Rate',
                            style: TextStyle(color: _c.muted, fontSize: 12),
                          ),
                          Text(
                            '78.4%',
                            style: GoogleFonts.inter(
                              color: _c.green,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 14, thickness: 1, color: _c.subBorder),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profit Factor',
                            style: TextStyle(color: _c.muted, fontSize: 12),
                          ),
                          Text(
                            '2.41',
                            style: GoogleFonts.inter(
                              color: _c.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 14, thickness: 1, color: _c.subBorder),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sharpe Ratio',
                            style: TextStyle(color: _c.muted, fontSize: 12),
                          ),
                          Text(
                            '1.84',
                            style: GoogleFonts.inter(
                              color: _c.blue,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 14, thickness: 1, color: _c.subBorder),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Max Drawdown',
                            style: TextStyle(color: _c.muted, fontSize: 12),
                          ),
                          Text(
                            '6.2%',
                            style: GoogleFonts.inter(
                              color: _c.gold,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 14, thickness: 1, color: _c.subBorder),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Avg Trade Duration',
                            style: TextStyle(color: _c.muted, fontSize: 12),
                          ),
                          Text(
                            '4h 12m',
                            style: GoogleFonts.inter(
                              color: _c.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close Analysis',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(88, 44),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
            value:
                '${_totalUnrealizedPnl >= 0 ? '+' : ''}\$${_totalUnrealizedPnl.toStringAsFixed(0)}',
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
            child: Icon(
              LucideIcons.briefcaseBusiness,
              color: _c.blue,
              size: 32,
            ),
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
              label: const Text(
                'Explore Available Pools',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(MamInvestmentSubscription item) {
    final isProfitable = item.unrealizedPnl >= 0;
    final activeStatus = item.isMirroringActive;
    final statusColor = activeStatus ? _c.green : _c.gold;
    final riskLevel = _riskToLevel(item.riskLevel);

    return Container(
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
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activeStatus ? _c.greenLight : _c.goldLight,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: activeStatus
                        ? _c.green.withValues(alpha: 0.35)
                        : _c.goldBorder,
                  ),
                ),
                child: Icon(
                  activeStatus ? LucideIcons.radio : LucideIcons.pause,
                  color: activeStatus ? _c.green : _c.gold,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Master #${item.managerLogin} • ${item.allocationMethod}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _c.muted, fontSize: 10.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _RiskMeter(level: riskLevel),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: activeStatus ? _c.greenLight : _c.goldLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: activeStatus
                        ? _c.green.withValues(alpha: 0.35)
                        : _c.goldBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      activeStatus ? 'ACTIVE' : 'PAUSED',
                      style: GoogleFonts.inter(
                        color: statusColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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
                        icon: isProfitable
                            ? LucideIcons.trendingUp
                            : LucideIcons.trendingDown,
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
                      showAppMessage(
                        item.isMirroringActive
                            ? 'Resumed mirroring for ${item.poolName}'
                            : 'Paused mirroring for ${item.poolName}',
                      );
                    },
                    icon: Icon(
                      item.isMirroringActive
                          ? LucideIcons.pause
                          : LucideIcons.play,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
          style: GoogleFonts.inter(
            color: _c.text,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Your remaining equity of \$${item.currentEquity.toStringAsFixed(2)} will be returned to your main balance after open positions are settled.',
          style: TextStyle(color: _c.muted, fontSize: 12.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(minimumSize: const Size(64, 44)),
            child: Text(
              'Cancel',
              style: TextStyle(color: _c.muted, fontWeight: FontWeight.w600),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirm Detach',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
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
      if (_availableFilter == 'Medium Risk')
        filterMatch = p.riskScore == 'Medium';
      if (_availableFilter == 'High ROI') filterMatch = p.monthlyRoi >= 15.0;
      if (_availableFilter == 'Top Win Rate') filterMatch = p.winRate >= 75.0;

      final qMatch =
          q.isEmpty ||
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
    final filters = [
      'All Pools',
      'Low Risk',
      'Medium Risk',
      'High ROI',
      'Top Win Rate',
    ];

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
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
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
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
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
    int riskLevel = 1;
    if (pool.riskScore == 'Medium') {
      riskColor = _c.gold;
      riskLabel = 'Med Risk';
      riskLevel = 2;
    } else if (pool.riskScore == 'High') {
      riskColor = _c.red;
      riskLabel = 'High Risk';
      riskLevel = 3;
    }

    return InkWell(
      onTap: () => _openManagerProfileModal(pool),
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar with Gradient Border & Verified Badge, Name, Risk Badge
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _brandBlue.withValues(alpha: 0.3),
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
                          pool.name
                              .substring(0, pool.name.length >= 2 ? 2 : 1)
                              .toUpperCase(),
                          style: GoogleFonts.inter(
                            color: _brandBlue,
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
                            child: const Icon(
                              LucideIcons.check,
                              size: 8,
                              color: Colors.white,
                            ),
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
                            Icon(
                              LucideIcons.badgeCheck,
                              color: _c.blue,
                              size: 14,
                            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3.5,
                  ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
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
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(120, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openManagerProfileModal(AvailableMamPool pool) {
    final data = MamManagerProfileData.fromPool(pool);
    showManagerPerformanceProfileModal(
      context,
      manager: data,
      onInvestTap: () {
        Navigator.pop(context);
        _openPasswordInvestModal(pool, data);
      },
    );
  }

  void _openPasswordInvestModal(
    AvailableMamPool pool,
    MamManagerProfileData data,
  ) {
    showInvestInManagerModal(
      context,
      manager: data,
      onConfirmed: (password) {
        final allocatedAmount = 1000.0;
        final newSub = MamInvestmentSubscription(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          poolName: pool.name,
          managerLogin: data.login,
          initialCapital: allocatedAmount,
          currentEquity: allocatedAmount,
          unrealizedPnl: 0.0,
          allocationMethod: 'Direct STP',
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
      },
    );
  }

  void _openInvestModal(AvailableMamPool pool) {
    _openManagerProfileModal(pool);
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
  final TextEditingController _amountController = TextEditingController(
    text: '1000',
  );
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
    final currentAmt =
        double.tryParse(_amountController.text.trim()) ??
        widget.pool.minDeposit;
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
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Select Account
            Text(
              'Source Trading Account',
              style: TextStyle(
                color: c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccount,
              dropdownColor: c.card,
              style: TextStyle(color: c.text, fontSize: 12.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
                  .map(
                    (acc) => DropdownMenuItem(
                      value: acc,
                      child: Text(
                        acc,
                        style: GoogleFonts.inter(color: c.text, fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedAccount = val);
              },
            ),
            const SizedBox(height: 12),

            // Allocation Amount
            Text(
              'Investment Amount (\$ USD)',
              style: TextStyle(
                color: c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.inter(
                color: c.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.dollarSign, size: 17),
                filled: true,
                fillColor: c.subCard,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: c.subCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: c.blue.withValues(alpha: 0.35),
                          ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
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
                          style: TextStyle(color: c.muted, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Drawdown Guard Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Drawdown Stop Guard',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_drawdownGuard.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    color: guardColor,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Slider(
              value: _drawdownGuard,
              min: 5.0,
              max: 50.0,
              divisions: 9,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              guardColor,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
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
                  onChanged: (val) =>
                      setState(() => _agreedToTerms = val ?? true),
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
                            double.tryParse(_amountController.text) ??
                            widget.pool.minDeposit;
                        Navigator.pop(context);
                        widget.onConfirmed(
                          amt,
                          _selectedAccount,
                          _allocationMethod,
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: c.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Confirm Investment',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
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
  const _CreateMamMasterSheet({required this.colors, required this.onCreated});

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
  final List<String> _risks = [
    'Conservative',
    'Low-Risk',
    'Moderate',
    'Aggressive',
  ];

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
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pool Name
            Text(
              'Master Strategy Name',
              style: TextStyle(
                color: c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
              style: TextStyle(
                color: c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedLogin,
              dropdownColor: c.card,
              style: TextStyle(color: c.text, fontSize: 12.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
                  .map(
                    (acc) => DropdownMenuItem(
                      value: acc,
                      child: Text(
                        'MT5 Master Account $acc',
                        style: GoogleFonts.inter(color: c.text, fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLogin = val);
              },
            ),
            const SizedBox(height: 12),

            // Allocation Method
            Text(
              'Allocation Formula',
              style: TextStyle(
                color: c.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _allocationMethod,
              dropdownColor: c.card,
              style: TextStyle(color: c.text, fontSize: 12.5),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
                  .map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(
                        m,
                        style: GoogleFonts.inter(color: c.text, fontSize: 12),
                      ),
                    ),
                  )
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
                        style: TextStyle(
                          color: c.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _leverage,
                        dropdownColor: c.card,
                        style: TextStyle(color: c.text, fontSize: 12.5),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                            .map(
                              (l) => DropdownMenuItem(
                                value: l,
                                child: Text(
                                  l,
                                  style: GoogleFonts.inter(
                                    color: c.text,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
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
                        style: TextStyle(
                          color: c.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _risk,
                        dropdownColor: c.card,
                        style: TextStyle(color: c.text, fontSize: 12.5),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
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
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(
                                  r,
                                  style: GoogleFonts.inter(
                                    color: c.text,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
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
                  style: TextStyle(
                    color: c.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_profitShare.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    color: c.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
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
                  final balance =
                      double.tryParse(_balanceController.text) ?? 10000.0;

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Create Master Node',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
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
  const _MamMasterDetailsSheet({required this.master, required this.colors});

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
                      'MT5 Account ${master.login} • Status: ${master.status}',
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
          _detailRow(
            c,
            'Connected Followers',
            '${master.investorsCount} active accounts',
          ),
          _detailRow(
            c,
            'Total Managed AUM',
            '\$${master.totalAum.toStringAsFixed(2)}',
          ),
          _detailRow(
            c,
            'Performance Fee',
            '${master.profitShare.toStringAsFixed(0)}%',
          ),
          _detailRow(c, 'Account Leverage', master.leverage),
          _detailRow(c, 'Risk Classification', master.risk),
          _detailRow(c, 'Settlement Cycle', master.payout),
          _detailRow(
            c,
            'Trailing 30D Return',
            '+${master.monthlyGain.toStringAsFixed(1)}%',
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: c.blue,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
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
