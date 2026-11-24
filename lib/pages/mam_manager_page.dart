import 'package:flutter/material.dart';

import '../app_notifications.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../widgets/mam_master_node_workspace.dart';
import '../services/auth_api.dart';
import '../widgets/mam_modals.dart';
import 'funds_action_dialog.dart';

export '../widgets/mam_master_node_workspace.dart' show MamMasterAccount;

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
// DATA MODEL (MamMasterAccount imported from mam_master_node_workspace.dart)
// -----------------------------------------------------------------------------

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
// MAM MANAGER PAGE
// -----------------------------------------------------------------------------
class MamManagerPage extends StatefulWidget {
  const MamManagerPage({
    super.key,
    this.onBack,
    this.onSelectPage,
    this.showBackButton = false,
  });

  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPage;
  final bool showBackButton;

  @override
  State<MamManagerPage> createState() => _MamManagerPageState();
}

class _MamManagerPageState extends State<MamManagerPage> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All Masters';
  String _searchQuery = '';
  bool _showGuide = false;

  MamMasterAccount? _selectedMasterDetail;
  late List<MamMasterAccount> _masters;

  @override
  void initState() {
    super.initState();
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

    _loadMamAccounts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  _MamColors get _c => _MamColors.of(context);

  int get _activeCount => _masters.where((m) => m.status == 'Active').length;
  double get _totalAum => _masters.fold(0.0, (acc, m) => acc + m.totalAum);
  int get _totalInvestors =>
      _masters.fold(0, (acc, m) => acc + m.investorsCount);

  List<MamMasterAccount> get _filteredMasters => _masters.where((m) {
    final statusMatch =
        _statusFilter == 'All Masters' || m.status == _statusFilter;
    final q = _searchQuery.toLowerCase();
    return statusMatch &&
        (q.isEmpty || m.name.toLowerCase().contains(q) || m.login.contains(q));
  }).toList();

  String _formatCurrency(double val) {
    if (val >= 1000000) return '\$${(val / 1000000).toStringAsFixed(2)}M';
    if (val >= 1000) return '\$${(val / 1000).toStringAsFixed(1)}K';
    return '\$${val.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedMasterDetail != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          setState(() {
            _selectedMasterDetail = null;
          });
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: MamMasterNodeWorkspace(
              master: _selectedMasterDetail!,
              onBack: () {
                setState(() {
                  _selectedMasterDetail = null;
                });
              },
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
                      _buildCreateMasterNodeBanner(),
                      const SizedBox(height: 12),
                      _buildSummaryMetrics(),
                      const SizedBox(height: 14),
                      if (_showGuide) ...[
                        _buildGuideCard(),
                        const SizedBox(height: 14),
                      ],
                      _buildSearchAndFilters(),
                      const SizedBox(height: 12),
                      _buildMastersSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateMasterSheet,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: Text(
          'Create Master Node',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
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
          if (widget.showBackButton &&
              (widget.onBack != null || Navigator.canPop(context)))
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'MAM Manager',
                    style: GoogleFonts.inter(
                      color: _c.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Text(
                  'Master Account Management & Allocations',
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
          IconButton(
            tooltip: 'Deposit to Master Node',
            icon: const Icon(LucideIcons.arrowDownToLine, size: 18),
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            style: IconButton.styleFrom(
              backgroundColor: _c.blueLight,
              foregroundColor: _c.blue,
              padding: const EdgeInsets.all(7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _c.blueBorder),
              ),
            ),
            onPressed: () {
              if (_masters.isNotEmpty) {
                _depositToMaster(_masters.first);
              } else {
                showAppMessage('No active master node found to deposit funds.');
              }
            },
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Withdraw Manager Payout',
            icon: const Icon(LucideIcons.arrowUpFromLine, size: 18),
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            style: IconButton.styleFrom(
              backgroundColor: _c.goldLight,
              foregroundColor: _c.gold,
              padding: const EdgeInsets.all(7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _c.goldBorder),
              ),
            ),
            onPressed: () {
              if (_masters.isNotEmpty) {
                _withdrawFromMaster(_masters.first);
              } else {
                showAppMessage('No active master node found for withdrawal.');
              }
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: _showGuide ? 'Hide Guide' : 'Show Guide',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: Icon(
              _showGuide ? LucideIcons.info : LucideIcons.circleHelp,
              color: _showGuide ? _c.blue : _c.muted,
              size: 20,
            ),
            onPressed: () => setState(() => _showGuide = !_showGuide),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CREATE MASTER NODE BANNER
  // ---------------------------------------------------------------------------
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
            color: const Color(0xFF2563EB)
                .withValues(alpha: _c.isDark ? 0.25 : 0.1),
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
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
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
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
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

  // ---------------------------------------------------------------------------
  // SUMMARY METRICS ROW
  // ---------------------------------------------------------------------------
  Widget _buildSummaryMetrics() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'Total AUM',
            value: _formatCurrency(_totalAum),
            accent: _c.blue,
            icon: LucideIcons.wallet,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'Active Nodes',
            value: '$_activeCount/${_masters.length}',
            accent: _c.green,
            icon: LucideIcons.server,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'Investors',
            value: '$_totalInvestors',
            accent: _c.gold,
            icon: LucideIcons.usersRound,
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
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
              ),
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
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // GUIDE CARD
  // ---------------------------------------------------------------------------
  Widget _buildGuideCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _c.blueBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lightbulb, size: 16, color: _c.blue),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'How MAM Management Works',
                    style: GoogleFonts.inter(
                      color: _c.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'As a MAM Manager, your trading orders executed on the Master Account are automatically apportioned in real-time across connected follower sub-accounts according to your selected allocation rule.',
            style: TextStyle(color: _c.muted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH & FILTERS
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilters() {
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
            controller: _searchController,
            style: TextStyle(color: _c.text, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search master name or login...',
              hintStyle: TextStyle(color: _c.muted, fontSize: 12),
              prefixIcon: Icon(LucideIcons.search, size: 17, color: _c.muted),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, size: 16, color: _c.muted),
                      onPressed: () => _searchController.clear(),
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
              final filter = filters[index];
              final isSelected = _statusFilter == filter;
              return InkWell(
                onTap: () => setState(() => _statusFilter = filter),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  alignment: Alignment.center,
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
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
  // MASTERS LIST SECTION
  // ---------------------------------------------------------------------------
  Widget _buildMastersSection() {
    if (_filteredMasters.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.border),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.briefcaseBusiness, size: 36, color: _c.muted),
            const SizedBox(height: 10),
            Text(
              'No MAM Masters Found',
              style: GoogleFonts.inter(
                color: _c.text,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Create a new MAM master account to begin managing pooled accounts.',
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
      itemCount: _filteredMasters.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final master = _filteredMasters[index];
        return _buildMasterCard(master);
      },
    );
  }

  Widget _buildMasterCard(MamMasterAccount master) {
    final isActive = master.status == 'Active';
    final statusColor = isActive ? _c.green : _c.gold;
    final riskLevel = master.risk.toLowerCase().contains('high')
        ? 3
        : (master.risk.toLowerCase().contains('mod') ? 2 : 1);

    return InkWell(
      onTap: () => _openMasterDetails(master),
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
                    size: 18,
                    color: isActive ? _c.green : _c.gold,
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

            // 2x2 Grid of Node Stats
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
                          'Profit Share',
                          '${master.profitShare.toStringAsFixed(0)}% Fee',
                          icon: LucideIcons.percent,
                        ),
                      ),
                      Container(width: 1, height: 28, color: _c.subBorder),
                      Expanded(
                        child: _microStat(
                          'Leverage / Gain',
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
                                  'Withdraw Payout',
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
                                backgroundColor: _c.blue,
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

  void _toggleMasterStatus(MamMasterAccount master) {
    setState(() {
      master.status = master.status == 'Active' ? 'Paused' : 'Active';
    });
    showAppMessage('Master account ${master.login} marked as ${master.status}');
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

  MamMasterAccount _mamMasterFromApi(Map<String, dynamic> account) {
    final login = (account['account_id'] ?? '').toString();
    final risk = (account['risk_level'] ?? 'medium').toString();
    final payout = (account['payout_frequency'] ?? 'weekly').toString();
    return MamMasterAccount(
      name: (account['account_name'] ?? 'MAM Account $login').toString(),
      login: login,
      profitShare: (account['profit_sharing_percentage'] as num?)?.toDouble() ?? 0,
      leverage: '1:${account['leverage'] ?? 100}',
      balance: (account['balance'] as num?)?.toDouble() ?? 0,
      status: (account['status'] ?? 'Active').toString().toLowerCase() == 'active'
          ? 'Active'
          : 'Paused',
      risk: risk[0].toUpperCase() + risk.substring(1),
      payout: payout[0].toUpperCase() + payout.substring(1),
      allocationMethod: 'Lot Proportional',
      investorsCount: 0,
      totalAum: (account['balance'] as num?)?.toDouble() ?? 0,
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
  final _loginController = TextEditingController(text: '8851490');
  String _allocationMethod = 'Lot Proportional';
  String _leverage = '1:500';
  double _profitShare = 20.0;
  String _riskLevel = 'Moderate';

  @override
  void dispose() {
    _nameController.dispose();
    _loginController.dispose();
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
                      const SizedBox(height: 2),
                      Text(
                        'Configure execution rule & profit share ratio.',
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
            _inputField(
              label: 'Master Pool Name',
              hint: 'e.g., Quantum FX Master Node',
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            _inputField(
              label: 'MT5 Master Account Login',
              hint: 'e.g., 8851490',
              controller: _loginController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Text(
              'Allocation Rule',
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
              items: const [
                DropdownMenuItem(
                  value: 'Lot Proportional',
                  child: Text('Lot Proportional by Balance'),
                ),
                DropdownMenuItem(
                  value: 'Equity Ratio',
                  child: Text('Equity Ratio Allocation'),
                ),
                DropdownMenuItem(
                  value: 'Equal Risk',
                  child: Text('Equal Risk Percentage'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _allocationMethod = val);
              },
            ),
            const SizedBox(height: 12),
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
                        items: const [
                          DropdownMenuItem(
                            value: '1:100',
                            child: Text('1:100'),
                          ),
                          DropdownMenuItem(
                            value: '1:200',
                            child: Text('1:200'),
                          ),
                          DropdownMenuItem(
                            value: '1:500',
                            child: Text('1:500'),
                          ),
                        ],
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
                        initialValue: _riskLevel,
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
                        items: const [
                          DropdownMenuItem(
                            value: 'Low-Risk',
                            child: Text('Low-Risk'),
                          ),
                          DropdownMenuItem(
                            value: 'Moderate',
                            child: Text('Moderate'),
                          ),
                          DropdownMenuItem(
                            value: 'Aggressive',
                            child: Text('Aggressive'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _riskLevel = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Profit Share',
                  style: TextStyle(
                    color: c.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_profitShare.toInt()}%',
                  style: GoogleFonts.inter(
                    color: c.blue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Slider(
              value: _profitShare,
              min: 5,
              max: 50,
              divisions: 9,
              activeColor: c.blue,
              inactiveColor: c.border,
              onChanged: (val) => setState(() => _profitShare = val),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Launch MAM Node',
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

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final c = widget.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: c.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: c.text, fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim().isEmpty
        ? 'Alpha MAM Master'
        : _nameController.text.trim();
    final login = _loginController.text.trim().isEmpty
        ? '8859012'
        : _loginController.text.trim();

    final master = MamMasterAccount(
      name: name,
      login: login,
      profitShare: _profitShare,
      leverage: _leverage,
      balance: 10000.0,
      status: 'Active',
      risk: _riskLevel,
      payout: 'Monthly',
      allocationMethod: _allocationMethod,
      investorsCount: 0,
      totalAum: 10000.0,
      monthlyGain: 0.0,
    );

    widget.onCreated(master);
    Navigator.pop(context);
  }
}

