import 'dart:async';
import 'package:flutter/material.dart';

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
  const _RiskMeter({required this.level});

  final int level; // 1 = Low, 2 = Med, 3 = High

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
            width: 3.0,
            height: heights[i],
            margin: EdgeInsets.only(right: i < 2 ? 2.0 : 0),
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
  Timer? _managerSearchDebounce;
  String _managerStatusFilter = 'All Masters';
  String _managerSearchQuery = '';

  final TextEditingController _availableSearchController =
      TextEditingController();
  Timer? _availableSearchDebounce;
  String _availableFilter = 'All Pools';
  String _availableSearchQuery = '';

  // Data Lists
  MamMasterAccount? _selectedMasterDetail;
  MamInvestmentSubscription? _selectedInvestorDetail;
  String? _selectedInvestorAccountId;
  late List<MamMasterAccount> _masters;
  late List<MamInvestmentSubscription> _investments;
  late List<MamInvestorAccount> _investorAccounts;
  late List<AvailableMamPool> _availablePools;
  final Set<String> _mamStatusUpdating = <String>{};
  bool _isLoadingMamAccounts = true;
  String? _mamAccountsError;

  static const Color _brandBlue = Color(0xFF2563EB);
  static const Color _brandGold = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);

    // Master accounts are loaded from the authenticated backend API.
    _masters = [];

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
      _managerSearchDebounce?.cancel();
      _managerSearchDebounce = Timer(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(
            () => _managerSearchQuery = _managerSearchController.text.trim(),
          );
        }
      });
    });
    _availableSearchController.addListener(() {
      _availableSearchDebounce?.cancel();
      _availableSearchDebounce = Timer(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(
            () => _availableSearchQuery = _availableSearchController.text.trim(),
          );
        }
      });
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
    _managerSearchDebounce?.cancel();
    _availableSearchDebounce?.cancel();
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
    return '\$${val.toStringAsFixed(2)}';
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
      if (_isLoadingMamAccounts && _masters.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        )
      else if (_mamAccountsError != null && _masters.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _c.border),
          ),
          child: Column(
            children: [
              Text(_mamAccountsError!, textAlign: TextAlign.center,
                  style: TextStyle(color: _c.muted, fontSize: 12)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _loadMamAccounts,
                icon: const Icon(LucideIcons.refreshCw, size: 15),
                label: const Text('Retry'),
              ),
            ],
          ),
        )
      else if (filtered.isEmpty)
        _buildEmptyManagerSearch()
      else
        for (final master in filtered) ...[
          _buildMasterNodeCard(master),
          const SizedBox(height: 10),
        ],
      if (_isLoadingMamAccounts && _masters.isNotEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Center(child: SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )),
        ),
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

    return RepaintBoundary(
      child: InkWell(
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
                              onPressed: _mamStatusUpdating.contains(master.login)
                                  ? null
                                  : () => _toggleMasterStatus(master),
                              icon: _mamStatusUpdating.contains(master.login)
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
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
    ));
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

  bool _apiBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (['true', '1', 'yes', 'enabled', 'active'].contains(normalized)) {
        return true;
      }
      if (['false', '0', 'no', 'disabled', 'paused', 'inactive'].contains(normalized)) {
        return false;
      }
    }
    return fallback;
  }

  Future<void> _toggleMasterStatus(MamMasterAccount master) async {
    final mamId = master.login.trim();
    if (mamId.isEmpty || _mamStatusUpdating.contains(mamId)) return;

    final enableTrading = master.status != 'Active';
    setState(() => _mamStatusUpdating.add(mamId));

    try {
      final response = await AuthApi.instance.setMamTradingEnabled(
        mamId: mamId,
        enabled: enableTrading,
      );
      if (!mounted) return;

      final confirmed = _apiBool(
        response['is_trading_enabled'],
        fallback: _apiBool(response['is_enabled'], fallback: enableTrading),
      );
      setState(() {
        master.status = confirmed ? 'Active' : 'Paused';
      });
      showAppMessage(
        (response['message'] ?? 'MAM trading ${confirmed ? 'resumed' : 'paused'} successfully.')
            .toString(),
      );
    } catch (error) {
      debugPrint('Could not update MAM trading status for $mamId: $error');
      if (mounted) {
        showAppMessage(
          error is AuthApiException
              ? error.message
              : 'Could not ${enableTrading ? 'resume' : 'pause'} this MAM node. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _mamStatusUpdating.remove(mamId));
    }
  }

  void _openMasterDetails(MamMasterAccount master) {
    setState(() {
      _selectedMasterDetail = master;
    });
  }

  Future<void> _loadMamAccounts() async {
    if (mounted) {
      setState(() {
        _isLoadingMamAccounts = true;
        _mamAccountsError = null;
      });
    }

    try {
      final accounts = await AuthApi.instance.getUserMamAccounts();
      final masters = <MamMasterAccount>[];
      const chunkSize = 3;
      for (var i = 0; i < accounts.length; i += chunkSize) {
        final chunk = accounts.sublist(
          i,
          i + chunkSize > accounts.length ? accounts.length : i + chunkSize,
        );
        final chunkMasters = await Future.wait(chunk.map((account) async {
          final master = _mamMasterFromApi(account);
          try {
            final investors = await AuthApi.instance.getMamInvestors(master.login);
            master.investorsCount = investors.length;
            final investorCapital = investors.fold<double>(
              0.0,
              (total, investor) => total + _apiDouble(investor['balance']),
            );
            // Managed AUM reflects the master balance plus linked investor capital.
            master.totalAum = master.balance + investorCapital;
          } catch (error) {
            debugPrint('Could not load investors for MAM ${master.login}: $error');
          }
          return master;
        }));
        masters.addAll(chunkMasters);
      }

      if (!mounted) return;
      setState(() {
        _masters = masters;
        _isLoadingMamAccounts = false;
        _mamAccountsError = null;
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load MAM accounts: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _masters = [];
        _isLoadingMamAccounts = false;
        _mamAccountsError = error is AuthApiException
            ? error.message
            : 'Could not load MAM accounts.';
      });
    }
  }

  double _apiDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  MamMasterAccount _mamMasterFromApi(Map<String, dynamic> account) {
    final login = (account['account_id'] ?? '').toString();
    final rawRisk = (account['risk_level'] ?? '').toString().trim();
    final rawPayout = (account['payout_frequency'] ?? '').toString().trim();
    final leverageValue = account['leverage']?.toString() ?? '';
    final balance = _apiDouble(account['balance']);
    final isTradingEnabled = _apiBool(
      account['is_trading_enabled'] ?? account['is_enabled'],
      fallback: (account['status'] ?? '').toString().toLowerCase() == 'active',
    );

    return MamMasterAccount(
      name: (account['account_name'] ?? 'MAM Account $login').toString(),
      login: login,
      profitShare: _apiDouble(account['profit_sharing_percentage']),
      leverage: leverageValue.isEmpty ? '—' : '1:$leverageValue',
      balance: balance,
      status: isTradingEnabled ? 'Active' : 'Paused',
      risk: rawRisk.isEmpty ? 'Unknown' : rawRisk[0].toUpperCase() + rawRisk.substring(1),
      payout: rawPayout.isEmpty ? 'Unknown' : rawPayout[0].toUpperCase() + rawPayout.substring(1),
      allocationMethod: (account['group_name'] ?? 'MT5 Master').toString(),
      investorsCount: 0,
      totalAum: balance,
      monthlyGain: 0.0,
      server: (account['server'] ?? '').toString(),
      tradingPlatform: 'MetaTrader 5 (MT5)',
      algoTrading: _apiBool(account['is_algo_enabled']) ? 'Enabled' : 'Disabled',
      pendingRelease: _apiDouble(account['pending_release']),
      releasedPayout: _apiDouble(account['released_payout']),
      pendingWallet: _apiDouble(account['pending_wallet']),
      totalSettled: _apiDouble(account['total_settled']),
      tradesProcessed: _apiDouble(account['trades_processed']).toInt(),
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
                  '\$${_investorAccounts.fold<double>(0, (sum, account) => sum + account.balance).toStringAsFixed(2)}',
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
                  '\$${_investorAccounts.fold<double>(0, (sum, account) => sum + account.totalProfit).toStringAsFixed(2)}',
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

    return RepaintBoundary(
      child: InkWell(
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
    ));
  }

  void _openInvestorAccountDetails(String accountId) {
    setState(() {
      _selectedInvestorDetail = null;
      _selectedInvestorAccountId = accountId;
    });
  }

  void _depositToMaster(MamMasterAccount master) {
    showFundsActionDialog(
      context,
      withdrawal: false,
      accountId: master.login,
      accountLabel: '${master.name} · Master #${master.login}',
      onCompleted: (_) {
        _loadMamAccounts();
      },
    );
  }

  void _withdrawFromMaster(MamMasterAccount master) {
    showFundsActionDialog(
      context,
      withdrawal: true,
      accountId: master.login,
      accountLabel: '${master.name} · Master #${master.login}',
      onCompleted: (_) {
        _loadMamAccounts();
      },
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
      if (_availableFilter == 'Medium Risk') {
        filterMatch = p.riskScore == 'Medium';
      }
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

    return RepaintBoundary(
      child: InkWell(
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
                          '${pool.performanceFee.toStringAsFixed(0)}% • \$${pool.minDeposit.toStringAsFixed(2)}',
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
    ));
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
  final String _allocationMethod = 'Equity Proportional';
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
  final String _payout = 'Monthly';
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
