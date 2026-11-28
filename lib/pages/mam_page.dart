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
    this.riskLevel = '',
    this.leverage = '',
  });

  final String accountId;
  final String alias;
  final String masterAccountId;
  final double balance;
  final double totalProfit;
  final double profitShare;
  final bool isCopying;
  final String riskLevel;
  final String leverage;
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
    this.managerName = '',
    this.leverage = '',
    this.balance = 0,
    this.equity = 0,
    this.accountAge = '',
    this.totalProfit = 0,
    this.totalDeposits = 0,
    this.totalWithdrawals = 0,
    this.profitSharingPercentage = 0,
    this.historicalGrowth = '0.00%',
    this.isEnabled = true,
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
  final String managerName;
  final String leverage;
  final double balance;
  final double equity;
  final String accountAge;
  final double totalProfit;
  final double totalDeposits;
  final double totalWithdrawals;
  final double profitSharingPercentage;
  final String historicalGrowth;
  final bool isEnabled;
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
  static final List<MamMasterAccount> _skeletonMasters = List.generate(
    2,
    (i) => MamMasterAccount(
      name: 'Alpha Quant Yield Fund ${i + 1}',
      login: '1000${i + 1}',
      profitShare: 20.0,
      leverage: '1:500',
      balance: 50000.0 * (i + 1),
      status: 'Active',
      risk: 'Medium',
      payout: 'Bi-Weekly',
      allocationMethod: 'Lot Proportional',
      investorsCount: 14 + (i * 8),
      totalAum: 125000.0 * (i + 1),
      monthlyGain: 14.8,
      server: 'VTIndex-Live',
    ),
  );

  static final List<AvailableMamPool> _skeletonAvailablePools = List.generate(
    3,
    (i) => AvailableMamPool(
      id: 'POOL_${i + 1}',
      name: 'Global FX Growth Pool ${i + 1}',
      traderHandle: '@pro_manager_${i + 1}',
      winRate: 78.5,
      monthlyRoi: 16.4,
      maxDrawdown: 5.2,
      copiersCount: 120 + (i * 45),
      totalAum: 450000.0,
      riskScore: '3',
      performanceFee: 15.0,
      minDeposit: 500.0,
      pairs: const ['EURUSD', 'GBPUSD', 'XAUUSD'],
      isVerified: true,
      managerName: 'Alex Vance',
      leverage: '1:500',
    ),
  );

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
  bool _availableLoading = false;
  int _availableRequestId = 0;
  String? _availableError;
  int _availableTotal = 0;
  int _availablePage = 1;
  static const int _availablePageSize = 10;
  final Set<String> _mamStatusUpdating = <String>{};
  final Set<String> _investingManagerIds = <String>{};
  bool _investorAccountsLoading = false;
  String? _investorAccountsError;
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

    _investments = [];
    _investorAccounts = [];

    _availablePools = [];

    _loadMamAccounts();
    _loadMamInvestments();
    if (_tab == 2) _loadAvailableManagers();
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
          setState(() {
            _availableSearchQuery = _availableSearchController.text.trim();
            _availablePage = 1;
          });
          if (_tab == 2) _loadAvailableManagers();
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

  // Tab 2 metric derived from backend-provided profit-share values.
  double get _avgProfitShare => _availablePools.isEmpty
      ? 0.0
      : _availablePools.fold(0.0, (acc, p) => acc + p.profitSharingPercentage) /
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
              initialAccountId: _selectedInvestorAccountId,
              initialAccountDetails: _investorAccounts.any(
                (account) => account.accountId == _selectedInvestorAccountId,
              )
                  ? (() {
                      final account = _investorAccounts.firstWhere(
                        (account) => account.accountId == _selectedInvestorAccountId,
                      );
                      return <String, dynamic>{
                        'account_id': account.accountId,
                        'master_account_id': account.masterAccountId,
                        'name': account.alias,
                        'balance': account.balance,
                        'profit': account.totalProfit,
                        'profit_share': account.profitShare,
                        'risk_level': account.riskLevel,
                        'leverage': account.leverage,
                        'status': account.isCopying ? 'Copying' : 'Paused',
                      };
                    })()
                  : null,
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
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(() => _tab = i);
                    if (i == 2) _loadAvailableManagers();
                  },
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
        AppSkeletonizer(
          enabled: true,
          child: Column(
            children: [
              for (final master in _skeletonMasters) ...[
                _buildMasterNodeCard(master),
                const SizedBox(height: 10),
              ],
            ],
          ),
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
                      onPressed: () { AppHaptics.lightImpact(); _managerSearchController.clear(); },
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
                onTap: () { AppHaptics.selectionClick(); setState(() => _managerStatusFilter = f); },
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
        onTap: () { AppHaptics.lightImpact(); _openMasterDetails(master); },
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
                              'MT5 Account: ${master.login} • ${master.allocationMethod}',
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
                              onPressed: () { AppHaptics.mediumImpact(); _depositToMaster(master); },
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
                              onPressed: () { AppHaptics.mediumImpact(); _withdrawFromMaster(master); },
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
                                  : () { AppHaptics.mediumImpact(); _toggleMasterStatus(master); },
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
                              onPressed: () { AppHaptics.lightImpact(); _openMasterDetails(master); },
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
      AppHaptics.heavyImpact();

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
      AppHaptics.vibrate();
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
      risk: rawRisk.isEmpty ? '' : rawRisk[0].toUpperCase() + rawRisk.substring(1),
      payout: rawPayout.isEmpty ? '' : rawPayout[0].toUpperCase() + rawPayout.substring(1),
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
      if (_investorAccountsLoading && _investorAccounts.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 36),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (_investorAccountsError != null && _investorAccounts.isEmpty)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _c.border),
          ),
          child: Column(
            children: [
              Text(
                _investorAccountsError!,
                textAlign: TextAlign.center,
                style: TextStyle(color: _c.muted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _investorAccountsLoading ? null : _loadMamInvestments,
                icon: const Icon(LucideIcons.refreshCw, size: 15),
                label: const Text('Retry'),
              ),
            ],
          ),
        )
      else if (_investorAccounts.isEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _c.border),
          ),
          child: Column(
            children: [
              Icon(LucideIcons.wallet, color: _c.muted, size: 32),
              const SizedBox(height: 10),
              Text(
                'No MAM investments yet',
                style: GoogleFonts.inter(
                  color: _c.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Explore available managers and create your first investment account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _c.muted, fontSize: 11.5),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() => _tab = 2),
                child: const Text('Explore MAM managers'),
              ),
            ],
          ),
        )
      else ...[
        Row(
          children: [
            Expanded(
              child: _metricCard(
                label: 'INVESTMENT ACCOUNTS',
                value: '${_investorAccounts.length}',
                subtext: 'Live from backend',
                icon: LucideIcons.wallet,
                accent: _c.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metricCard(
                label: 'CURRENT BALANCE',
                value: '\$${_investorAccounts.fold<double>(
                  0,
                  (sum, account) => sum + account.balance,
                ).toStringAsFixed(2)}',
                subtext: 'Across MAM accounts',
                icon: Icons.show_chart,
                accent: _c.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final account in _investorAccounts) ...[
          _buildInvestorAccountCard(account),
          const SizedBox(height: 10),
        ],
      ],
      if (_investorAccountsLoading && _investorAccounts.isNotEmpty)
        const Padding(
          padding: EdgeInsets.all(8),
          child: Center(child: LinearProgressIndicator()),
        ),
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
        onTap: () { AppHaptics.lightImpact(); _openInvestorAccountDetails(account.accountId); },
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
                        'Account ${account.accountId} • Master ${account.masterAccountId}',
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
      accountLabel: '${master.name} · Master ${master.login}',
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
      accountLabel: '${master.name} · Master ${master.login}',
      onCompleted: (_) {
        _loadMamAccounts();
      },
    );
  }


  double _availableNumber(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.-]'), '');
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  String _availableText(dynamic value) => value?.toString().trim() ?? '';

  String _investmentDisplayName(String name) => name.replaceAll(
        RegExp(r'\bInvestment\s+#\s*', caseSensitive: false),
        'Investment ',
      );

  Future<void> _loadAvailableManagers() async {
    final requestId = ++_availableRequestId;
    setState(() {
      _availableLoading = true;
      _availableError = null;
    });
    try {
      final response = await AuthApi.instance.getAvailableMamManagers(
        page: _availablePage,
        pageSize: _availablePageSize,
        search: _availableSearchQuery,
      );
      final raw = response['results'] is List
          ? response['results'] as List
          : response['data'] is List ? response['data'] as List : <dynamic>[];
      final managers = raw.whereType<Map>().map((entry) {
        final item = entry.cast<String, dynamic>();
        final id = _availableText(item['accountId'] ?? item['mam_account_id'] ?? item['id']);
        final riskValue = _availableText(item['risk_level'] ?? item['riskLevel']);
        final risk = riskValue.isEmpty ? '' :
            riskValue[0].toUpperCase() + riskValue.substring(1).toLowerCase();
        final leverageValue = _availableText(item['leverage'] ?? item['package_leverage']);
        final profitShare = _availableNumber(item['profit_sharing_percentage'] ?? item['profit_sharing'] ?? item['profitShare']);
        return AvailableMamPool(
          id: id,
          name: _availableText(item['name'] ?? item['account_name']),
          traderHandle: _availableText(item['manager_name']),
          winRate: 0,
          monthlyRoi: 0,
          maxDrawdown: 0,
          copiersCount: 0,
          totalAum: _availableNumber(item['current_equity'] ?? item['equity']),
          riskScore: risk,
          performanceFee: profitShare,
          minDeposit: 0,
          pairs: const [],
          isVerified: false,
          managerName: _availableText(item['manager_name']),
          leverage: leverageValue.isEmpty ? '' : (leverageValue.startsWith('1:') ? leverageValue : '1:$leverageValue'),
          balance: _availableNumber(item['current_balance'] ?? item['balance']),
          equity: _availableNumber(item['current_equity'] ?? item['equity']),
          accountAge: _availableText(item['account_age'] ?? item['accountAge']),
          totalProfit: _availableNumber(item['total_profit']),
          totalDeposits: _availableNumber(item['total_deposits']),
          totalWithdrawals: _availableNumber(item['total_withdrawals']),
          profitSharingPercentage: profitShare,
          historicalGrowth: _availableText(item['growth'] ?? item['growth_percentage'] ?? '0.00%'),
          isEnabled: _apiBool(item['status'] ?? item['is_enabled'], fallback: true),
        );
      }).where((manager) => manager.id.isNotEmpty).toList();

      if (!mounted || requestId != _availableRequestId) return;
      setState(() {
        _availablePools = managers;
        _availableTotal = _availableNumber(response['count']).toInt();
      });
    } catch (error) {
      if (!mounted || requestId != _availableRequestId) return;
      setState(() {
        _availableError = error is AuthApiException ? error.message :
            'Could not load available MAM managers. Please try again.';
        _availablePools = [];
        _availableTotal = 0;
      });
    } finally {
      if (mounted && requestId == _availableRequestId) {
        setState(() => _availableLoading = false);
      }
    }
  }

  /// Load the signed-in client's MAM investor accounts from UserInvestmentsView.
  Future<void> _loadMamInvestments() async {
    if (mounted) {
      setState(() {
        _investorAccountsLoading = true;
        _investorAccountsError = null;
      });
    }
    try {
      final response = await AuthApi.instance.getUserMamInvestments();
      final raw = response['results'] is List
          ? response['results'] as List
          : response['data'] is List
              ? response['data'] as List
              : <dynamic>[];
      final accounts = <MamInvestorAccount>[];
      final subscriptions = <MamInvestmentSubscription>[];
      for (final entry in raw.whereType<Map>()) {
        final item = entry.cast<String, dynamic>();
        final accountId = _availableText(
          item['accountId'] ?? item['trading_account_id'] ?? item['account_id'] ?? item['id'],
        );
        if (accountId.isEmpty) continue;
        final masterId = _availableText(item['master_account_id']);
        final balance = _availableNumber(item['current_balance'] ?? item['balance']);
        final equity = _availableNumber(item['current_equity'] ?? item['equity']);
        final profit = _availableNumber(item['profit'] ?? item['total_profit']);
        final share = _availableNumber(
          item['profit_sharing_percentage'] ?? item['profit_sharing'] ?? item['profitShare'],
        );
        final status = _availableText(item['status']).toLowerCase();
        final copying = status == 'copying' || status == 'running' ||
            _apiBool(item['is_enabled'], fallback: false);
        final alias = _investmentDisplayName(
          _availableText(item['name'] ?? item['mam_account_name']),
        );
        accounts.add(MamInvestorAccount(
          accountId: accountId,
          alias: alias.isEmpty ? 'MAM Investment $accountId' : alias,
          masterAccountId: masterId,
          balance: balance,
          totalProfit: profit,
          profitShare: share,
          isCopying: copying,
          riskLevel: _availableText(item['risk_level'] ?? item['riskLevel']),
          leverage: _availableText(item['leverage'] ?? item['package_leverage']),
        ));
        final createdAt = _availableText(item['created_at']);
        subscriptions.add(MamInvestmentSubscription(
          id: accountId,
          poolName: alias.isEmpty ? 'MAM Investment $accountId' : alias,
          managerLogin: masterId,
          initialCapital: _availableNumber(item['amount_invested']),
          currentEquity: equity,
          unrealizedPnl: _availableNumber(item['open_profit']),
          allocationMethod: '—',
          feePercentage: share,
          joinedDate: createdAt.isEmpty ? '—' : createdAt.split('T').first,
          isMirroringActive: copying,
          riskLevel: _availableText(item['risk_level']).isEmpty
              ? '—'
              : _availableText(item['risk_level']),
        ));
      }
      if (!mounted) return;
      setState(() {
        _investorAccounts = accounts;
        _investments = subscriptions;
        _investorAccountsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _investorAccounts = [];
        _investments = [];
        _investorAccountsLoading = false;
        _investorAccountsError = error is AuthApiException
            ? error.message
            : 'Could not load your MAM investment accounts.';
      });
    }
  }

  Future<void> _investInManager(AvailableMamPool manager) async {
    final managerId = manager.id.trim();
    if (managerId.isEmpty || _investingManagerIds.contains(managerId)) return;

    final password = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (_) => _InvestMamPasswordSheet(pool: manager, colors: _c),
    );
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _investingManagerIds.add(managerId));
    try {
      final response = await AuthApi.instance.createMamInvestment(
        managerId: managerId,
        investorPassword: password,
      );
      AppHaptics.heavyImpact();

      // The create endpoint returns the newly provisioned MT5 investor login.
      // Refresh the investor list first so the new account can be selected.
      final createdAccountId = _availableText(
        response['account_id'] ??
            response['accountId'] ??
            response['trading_account_id'] ??
            response['id'],
      );

      await _loadMamInvestments();
      if (!mounted) return;

      // Some deployments cache UserInvestmentsView briefly. If the newly
      // created account is not in that response yet, seed the selected session
      // from the create response instead of opening an empty workspace.
      final responseAccount = response['account'] is Map
          ? (response['account'] as Map).cast<String, dynamic>()
          : response['trading_account'] is Map
              ? (response['trading_account'] as Map).cast<String, dynamic>()
              : response['data'] is Map
                  ? (response['data'] as Map).cast<String, dynamic>()
                  : response;

      final responseAccountId = _availableText(
        responseAccount['account_id'] ??
            responseAccount['accountId'] ??
            responseAccount['login'] ??
            responseAccount['id'] ??
            createdAccountId,
      );
      final refreshedAccountId = createdAccountId.isNotEmpty
          ? createdAccountId
          : responseAccountId.isNotEmpty
              ? responseAccountId
              : (_investorAccounts.isNotEmpty
                    ? _investorAccounts.last.accountId
                    : '');

      if (refreshedAccountId.isNotEmpty &&
          !_investorAccounts.any((account) => account.accountId == refreshedAccountId)) {
        final responseAlias = _investmentDisplayName(
          _availableText(
            responseAccount['name'] ??
                responseAccount['account_name'] ??
                responseAccount['mam_account_name'],
          ),
        );
        final responseMasterId = _availableText(
          responseAccount['master_account_id'] ??
              responseAccount['mam_master_id'] ??
              manager.id,
        );
        final responseBalance = _availableNumber(
          responseAccount['current_balance'] ??
              responseAccount['balance'] ??
              responseAccount['initial_balance'],
        );
        final responseProfit = _availableNumber(
          responseAccount['profit'] ?? responseAccount['total_profit'],
        );
        final responseShare = _availableNumber(
          responseAccount['profit_sharing_percentage'] ??
              responseAccount['profit_share'] ??
              responseAccount['profitShare'] ??
              manager.profitSharingPercentage ??
              manager.performanceFee,
        );
        setState(() {
          _investorAccounts = [
            ..._investorAccounts,
            MamInvestorAccount(
              accountId: refreshedAccountId,
              alias: responseAlias.isEmpty
                  ? '${manager.name} Investment'
                  : responseAlias,
              masterAccountId: responseMasterId,
              balance: responseBalance,
              totalProfit: responseProfit,
              profitShare: responseShare,
              isCopying: true,
              riskLevel: _availableText(
                responseAccount['risk_level'] ?? responseAccount['riskLevel'],
              ),
              leverage: _availableText(
                responseAccount['leverage'] ?? responseAccount['package_leverage'],
              ),
            ),
          ];
        });
      }

      if (refreshedAccountId.isEmpty) {
        setState(() => _tab = 1);
        showAppMessage(
          'Investment account created, but its account ID was not returned. Open Investor Accounts to view it.',
        );
        return;
      }

      setState(() {
        _tab = 1;
        _selectedInvestorDetail = null;
        _selectedInvestorAccountId = refreshedAccountId;
      });

      showAppMessage(
        _availableText(response['message']).isNotEmpty
            ? _availableText(response['message'])
            : 'Investment account created. Opening your investor session.',
      );
    } catch (error) {
      AppHaptics.vibrate();
      if (mounted) {
        showAppMessage(
          error is AuthApiException
              ? error.message
              : 'Could not create the MAM investment account. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _investingManagerIds.remove(managerId));
    }
  }

  void _viewAvailableManager(AvailableMamPool manager) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .58),
      builder: (sheetContext) {
        Widget metric(String label, String value, IconData icon) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
              decoration: BoxDecoration(
                color: _c.subCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _c.subBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: _c.blue),
                  const SizedBox(height: 8),
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: _c.muted,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Widget detail(String label, String value, IconData icon) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 15, color: _c.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      color: _c.muted,
                      fontSize: 11.5,
                    ),
                  ),
                ),
                Text(
                  value.isEmpty ? '—' : value,
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        }

        final risk = manager.riskScore.trim();

        return Container(
          padding: EdgeInsets.fromLTRB(
            18,
            12,
            18,
            18 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
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
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _c.muted.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _c.card,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _c.card,
                        _c.isDark
                            ? const Color(0xFF142138)
                            : const Color(0xFFF1F6FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _c.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _c.blueLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _c.blueBorder),
                        ),
                        child: Icon(
                          LucideIcons.userRound,
                          color: _c.blue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manager.name.isEmpty ? 'MAM Manager' : manager.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: _c.text,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Manager ID  ·  ${manager.id}',
                              style: GoogleFonts.inter(
                                color: _c.muted,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(Icons.close, color: _c.muted),
                        constraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 38,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    metric(
                      'Balance',
                      _formatCurrency(manager.balance),
                      LucideIcons.wallet,
                    ),
                    const SizedBox(width: 9),
                    metric(
                      'Equity',
                      _formatCurrency(manager.equity),
                      LucideIcons.activity,
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: _c.subCard,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _c.subBorder),
                  ),
                  child: Column(
                    children: [
                      detail('Manager', manager.managerName, LucideIcons.user),
                      Divider(height: 1, color: _c.subBorder),
                      detail(
                        'Performance fee',
                        '${manager.profitSharingPercentage.toStringAsFixed(2)}%',
                        LucideIcons.percent,
                      ),
                      Divider(height: 1, color: _c.subBorder),
                      detail(
                        'Risk profile',
                        risk.isEmpty ? '—' : risk,
                        LucideIcons.shield,
                      ),
                      Divider(height: 1, color: _c.subBorder),
                      detail('Leverage', manager.leverage, LucideIcons.scale),
                      Divider(height: 1, color: _c.subBorder),
                      detail(
                        'Account age',
                        manager.accountAge,
                        LucideIcons.calendarDays,
                      ),
                      Divider(height: 1, color: _c.subBorder),
                      detail(
                        'Historical growth',
                        manager.historicalGrowth,
                        LucideIcons.trendingUp,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: manager.isEnabled
                        ? () {
                            Navigator.pop(sheetContext);
                            _investInManager(manager);
                          }
                        : null,
                    icon: const Icon(LucideIcons.arrowRight, size: 17),
                    label: const Text('Invest in this MAM'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brandBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _c.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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

  // ---------------------------------------------------------------------------
  // TAB 2: MAM AVAILABLE
  // ---------------------------------------------------------------------------
  List<Widget> _buildAvailableTab() {
    final filtered = _availablePools.where((pool) {
      if (_availableFilter == 'Low Risk') return pool.riskScore.toLowerCase() == 'low';
      if (_availableFilter == 'Medium Risk') return pool.riskScore.toLowerCase() == 'medium';
      if (_availableFilter == 'High Risk') return pool.riskScore.toLowerCase() == 'high';
      return true;
    }).toList();
    return [
      _buildAvailableSummaryMetrics(),
      const SizedBox(height: 14),
      _buildAvailableSearchAndFilters(),
      const SizedBox(height: 12),
      if (_availableLoading && _availablePools.isEmpty)
        AppSkeletonizer(
          enabled: true,
          child: Column(
            children: [
              for (final manager in _skeletonAvailablePools) ...[
                _buildAvailablePoolCard(manager),
                const SizedBox(height: 10),
              ],
            ],
          ),
        )
      else if (_availableError != null)
        _buildAvailableError()
      else if (filtered.isEmpty)
        _buildEmptyAvailableSearch()
      else
        for (final manager in filtered) ...[
          _buildAvailablePoolCard(manager),
          const SizedBox(height: 10),
        ],
      if (_availableTotal > _availablePageSize) _buildAvailablePagination(),
    ];
  }

  Widget _buildAvailableSummaryMetrics() {
    return Row(children: [
      Expanded(child: _metricCard(
        label: 'AVAILABLE MANAGERS', value: '$_availableTotal',
        subtext: 'Active MAM accounts', icon: LucideIcons.users, accent: _c.blue)),
      const SizedBox(width: 8),
      Expanded(child: _metricCard(
        label: 'PAGE AVG SHARE', value: '${_avgProfitShare.toStringAsFixed(1)}%',
        subtext: 'Returned by backend', icon: LucideIcons.percent, accent: _c.green)),
    ]);
  }

  Widget _buildAvailableError() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: _c.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: _c.border)),
    child: Column(children: [
      Icon(LucideIcons.wifiOff, color: _c.red, size: 28),
      const SizedBox(height: 8),
      Text(_availableError!, textAlign: TextAlign.center, style: TextStyle(color: _c.text, fontSize: 12)),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: _availableLoading ? null : _loadAvailableManagers,
        icon: const Icon(LucideIcons.refreshCw, size: 15), label: const Text('Retry')),
    ]),
  );

  Widget _buildAvailablePagination() {
    final pages = (_availableTotal / _availablePageSize).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Page $_availablePage of $pages', style: TextStyle(color: _c.muted, fontSize: 11)),
        Row(children: [
          IconButton(onPressed: _availablePage > 1 && !_availableLoading ? () {
            setState(() => _availablePage--); _loadAvailableManagers();
          } : null, icon: const Icon(LucideIcons.chevronLeft)),
          IconButton(onPressed: _availablePage < pages && !_availableLoading ? () {
            setState(() => _availablePage++); _loadAvailableManagers();
          } : null, icon: const Icon(LucideIcons.chevronRight)),
        ]),
      ]),
    );
  }

  Widget _buildAvailableSearchAndFilters() {
    final filters = [
      'All Pools',
      'Low Risk',
      'Medium Risk',
      'High Risk',
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
              hintText: 'Search manager, account name or login ID...',
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
                onTap: () { AppHaptics.selectionClick(); setState(() => _availableFilter = f); },
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

  Widget _buildAvailablePoolCard(AvailableMamPool manager) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return _buildAvailablePoolCardMobile(manager);
        }
        return _buildAvailablePoolCardDesktop(manager);
      },
    );
  }

  Widget _buildAvailablePoolCardMobile(AvailableMamPool manager) {
    final risk = manager.riskScore.trim();
    final riskColor = risk.toLowerCase() == 'low'
        ? _c.green
        : risk.toLowerCase() == 'high'
            ? _c.red
            : _c.gold;
    final isInvesting = _investingManagerIds.contains(manager.id);
    final managerTitle = manager.name.trim().isEmpty
        ? 'MAM Manager'
        : manager.name.trim();

    Widget detailRow(String label, String value, {Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: _c.muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value.isEmpty ? '—' : value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: valueColor ?? _c.text,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? .12 : .025),
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
                  managerTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ID: ${manager.id}',
                style: GoogleFonts.inter(
                  color: _c.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: manager.isEnabled ? _c.green : _c.muted,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          if (manager.managerName.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              manager.managerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _c.muted,
                fontSize: 10.5,
              ),
            ),
          ],
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MANAGER BALANCE',
                      style: GoogleFonts.inter(
                        color: _c.muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .45,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _formatCurrency(manager.balance),
                        style: GoogleFonts.inter(
                          color: _c.text,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PROFIT SHARE',
                    style: GoogleFonts.inter(
                      color: _c.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${manager.profitSharingPercentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      color: _c.blue,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: _c.border),
          detailRow(
            'Historical growth',
            manager.historicalGrowth,
            valueColor: _c.green,
          ),
          Divider(height: 1, color: _c.border),
          detailRow(
            'Risk profile',
            risk.isEmpty ? '—' : risk,
            valueColor: risk.isEmpty ? _c.muted : riskColor,
          ),
          Divider(height: 1, color: _c.border),
          detailRow('Account age', manager.accountAge),
          if (manager.leverage.isNotEmpty) ...[
            Divider(height: 1, color: _c.border),
            detailRow('Leverage', manager.leverage),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      _viewAvailableManager(manager);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _c.text,
                      side: BorderSide(color: _c.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('View details'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: !manager.isEnabled || isInvesting
                        ? null
                        : () {
                            AppHaptics.mediumImpact();
                            _investInManager(manager);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: _c.blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _c.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      textStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: isInvesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            manager.isEnabled ? 'Invest now' : 'Unavailable',
                            maxLines: 1,
                            softWrap: false,
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

  Widget _buildAvailablePoolCardDesktop(AvailableMamPool manager) {
    final risk = manager.riskScore;
    final riskColor = risk.toLowerCase() == 'low'
        ? _c.green
        : risk.toLowerCase() == 'high'
            ? _c.red
            : _c.gold;
    final initial = manager.name.isEmpty
        ? 'M'
        : manager.name.substring(0, 1).toUpperCase();

    Widget metric(String label, String value, {Color? color}) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: _c.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '—' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: color ?? _c.text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? .12 : .025),
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
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _c.blueBorder),
                ),
                child: Text(
                  initial,
                  style: GoogleFonts.inter(
                    color: _c.blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manager.name.isEmpty ? 'MAM Manager' : manager.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        if (manager.managerName.isNotEmpty) manager.managerName,
                        'ID ${manager.id}',
                      ].join('  •  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _c.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: manager.isEnabled ? _c.greenLight : _c.subCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: manager.isEnabled ? _c.greenBorder : _c.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: manager.isEnabled ? _c.green : _c.muted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      manager.isEnabled ? 'ACTIVE MAM' : 'DISABLED',
                      style: TextStyle(
                        color: manager.isEnabled ? _c.green : _c.muted,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    metric('Balance', _formatCurrency(manager.balance)),
                    const SizedBox(width: 8),
                    metric(
                      'Profit Share',
                      '${manager.profitSharingPercentage.toStringAsFixed(0)}%',
                      color: _c.blue,
                    ),
                    const SizedBox(width: 8),
                    metric('Account Age', manager.accountAge),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: _c.subBorder),
                const SizedBox(height: 10),
                Row(
                  children: [
                    metric('Historical Growth', manager.historicalGrowth, color: _c.green),
                    const SizedBox(width: 8),
                    metric('Risk Profile', risk.isEmpty ? '—' : risk, color: risk.isEmpty ? _c.muted : riskColor),
                    const SizedBox(width: 8),
                    metric('Leverage', manager.leverage),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      _viewAvailableManager(manager);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _c.blue,
                      side: BorderSide(color: _c.blueBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('View'),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: FilledButton(
                    onPressed: !manager.isEnabled || _investingManagerIds.contains(manager.id)
                        ? null
                        : () {
                            AppHaptics.mediumImpact();
                            _investInManager(manager);
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: _brandGold,
                      foregroundColor: const Color(0xFF10264A),
                      disabledBackgroundColor: _c.border,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _investingManagerIds.contains(manager.id)
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Invest',
                            style: TextStyle(fontWeight: FontWeight.w800),
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

}

// -----------------------------------------------------------------------------
// INVEST IN MAM MODAL
// -----------------------------------------------------------------------------
/// Password confirmation sheet for the create-investment endpoint.
/// The backend creates the MT5 investor account and does not take a deposit
/// amount, source account, allocation method, or drawdown guard in this call.
class _InvestMamPasswordSheet extends StatefulWidget {
  const _InvestMamPasswordSheet({
    required this.pool,
    required this.colors,
  });

  final AvailableMamPool pool;
  final _MamColors colors;

  @override
  State<_InvestMamPasswordSheet> createState() =>
      _InvestMamPasswordSheetState();
}

class _InvestMamPasswordSheetState extends State<_InvestMamPasswordSheet> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  String? _validationError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _passwordDecoration({
    required String hint,
    required bool hidden,
    required VoidCallback onToggle,
  }) {
    final c = widget.colors;
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.robotoMono(
        color: c.muted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(Icons.key_outlined, color: c.blue, size: 18),
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: c.muted,
          size: 18,
        ),
      ),
      filled: true,
      fillColor: c.subCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: c.blue, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: c.red),
      ),
    );
  }

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      value.toUpperCase(),
      style: GoogleFonts.inter(
        color: widget.colors.text,
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: .35,
      ),
    ),
  );

  Widget _summaryMetric(String label, String value, {Color? valueColor}) {
    final c = widget.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.muted,
                fontSize: 8.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: valueColor ?? c.text,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final password = _passwordController.text;
    final confirmation = _confirmPasswordController.text;
    if (password.isEmpty || confirmation.isEmpty) {
      setState(() => _validationError = 'Enter and confirm your investor password.');
      return;
    }
    if (password != confirmation) {
      setState(() => _validationError = 'Investor passwords do not match.');
      return;
    }
    AppHaptics.mediumImpact();
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final pool = widget.pool;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(17, 13, 17, 18 + bottomInset),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: c.border),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: c.muted.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Invest in ${pool.id}',
                    style: GoogleFonts.inter(
                      color: c.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: c.muted),
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: c.blueLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.blueBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.blue.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.person_outline, color: c.blue, size: 20),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pool.name.isEmpty ? 'MAM Manager' : pool.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: c.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'ID: ${pool.id}',
                              style: GoogleFonts.robotoMono(
                                color: c.muted,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.green.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: c.greenBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: c.green, size: 6),
                            const SizedBox(width: 5),
                            Text(
                              'ACTIVE MAM',
                              style: TextStyle(
                                color: c.green,
                                fontSize: 8.3,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _summaryMetric(
                        'Performance Fee',
                        '${pool.profitSharingPercentage.toStringAsFixed(0)}%',
                        valueColor: c.blue,
                      ),
                      const SizedBox(width: 7),
                      _summaryMetric(
                        'Risk Profile',
                        pool.riskScore,
                        valueColor: c.gold,
                      ),
                      const SizedBox(width: 7),
                      _summaryMetric(
                        'Leverage',
                        pool.leverage,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),
            _label('Investor Terminal Password *'),
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              autocorrect: false,
              enableSuggestions: false,
              style: GoogleFonts.robotoMono(
                color: c.text,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: _passwordDecoration(
                hint: 'Set investment terminal password',
                hidden: _hidePassword,
                onToggle: () => setState(() => _hidePassword = !_hidePassword),
              ),
            ),
            const SizedBox(height: 14),
            _label('Confirm Investor Password *'),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _hideConfirmPassword,
              autocorrect: false,
              enableSuggestions: false,
              style: GoogleFonts.robotoMono(
                color: c.text,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: _passwordDecoration(
                hint: 'Re-enter investment password',
                hidden: _hideConfirmPassword,
                onToggle: () => setState(
                  () => _hideConfirmPassword = !_hideConfirmPassword,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_validationError != null) ...[
              const SizedBox(height: 9),
              Text(
                _validationError!,
                style: TextStyle(color: c.red, fontSize: 11),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.blueLight,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: c.blueBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: c.blue, size: 18),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Your investment trading account will be created under this MAM manager. Keep your terminal password secure.',
                      style: GoogleFonts.inter(
                        color: c.text,
                        fontSize: 10.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 17),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.arrow_forward, size: 17),
                label: const Text('CONFIRM & CREATE'),
                style: FilledButton.styleFrom(
                  backgroundColor: c.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: c.muted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              onChanged: (val) { AppHaptics.selectionClick(); setState(() => _profitShare = val); },
            ),
            const SizedBox(height: 14),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: () {
                  final name = _nameController.text.trim().isEmpty
                      ? 'Custom MAM Pool $_selectedLogin'
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
