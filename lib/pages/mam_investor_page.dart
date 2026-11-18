import 'package:flutter/material.dart';
import 'package:flutter_notch_toast/flutter_notch_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

// -----------------------------------------------------------------------------
// DYNAMIC THEME COLORS HELPER
// -----------------------------------------------------------------------------
class _InvestorColors {
  const _InvestorColors({
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

  factory _InvestorColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _InvestorColors(
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
// DATA MODEL: MAM INVESTMENT SUBSCRIPTION
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

  double get returnPercentage =>
      initialCapital == 0 ? 0 : ((currentEquity - initialCapital) / initialCapital) * 100;
}

// -----------------------------------------------------------------------------
// MAM INVESTOR PAGE
// -----------------------------------------------------------------------------
class MamInvestorPage extends StatefulWidget {
  const MamInvestorPage({
    super.key,
    this.onBack,
    this.onExploreAvailable,
    this.showBackButton = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onExploreAvailable;
  final bool showBackButton;

  @override
  State<MamInvestorPage> createState() => _MamInvestorPageState();
}

class _MamInvestorPageState extends State<MamInvestorPage> {
  late List<MamInvestmentSubscription> _investments;

  @override
  void initState() {
    super.initState();
    _investments = [
      MamInvestmentSubscription(
        id: 'INV-1092',
        poolName: 'Alpha Quant Alpha-1',
        managerLogin: '8849102',
        initialCapital: 10000.00,
        currentEquity: 11480.50,
        unrealizedPnl: 1480.50,
        allocationMethod: 'Equity Proportional',
        feePercentage: 20.0,
        joinedDate: 'Oct 12, 2024',
        isMirroringActive: true,
        riskLevel: 'Moderate',
      ),
      MamInvestmentSubscription(
        id: 'INV-1099',
        poolName: 'Prime Trend Rider',
        managerLogin: '8850231',
        initialCapital: 5000.00,
        currentEquity: 5560.00,
        unrealizedPnl: 560.00,
        allocationMethod: 'Lot Proportional',
        feePercentage: 25.0,
        joinedDate: 'Nov 02, 2024',
        isMirroringActive: true,
        riskLevel: 'Low-Risk',
      ),
    ];
  }

  _InvestorColors get _c => _InvestorColors.of(context);

  double get _totalCapital => _investments.fold(0.0, (acc, i) => acc + i.initialCapital);
  double get _totalEquity => _investments.fold(0.0, (acc, i) => acc + i.currentEquity);
  double get _totalPnl => _investments.fold(0.0, (acc, i) => acc + i.unrealizedPnl);
  double get _totalReturnPercentage =>
      _totalCapital == 0 ? 0.0 : ((_totalEquity - _totalCapital) / _totalCapital) * 100;

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
                      _buildPortfolioMetrics(),
                      const SizedBox(height: 14),
                      _buildExploreCtaCard(),
                      const SizedBox(height: 14),
                      _buildInvestmentsSection(),
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
                  'MAM Investor',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Managed Investment Portfolio & Active Pools',
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
          if (widget.onExploreAvailable != null)
            SizedBox(
              height: 38,
              child: FilledButton.icon(
                onPressed: widget.onExploreAvailable,
                icon: const Icon(LucideIcons.compass, size: 14),
                label: const Text('Explore', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: _c.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.usersRound, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Investor Allocation Hub',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track your subscribed MAM master pools, live floating returns, and risk detach controls.',
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
  // PORTFOLIO METRICS
  // ---------------------------------------------------------------------------
  Widget _buildPortfolioMetrics() {
    final isPos = _totalPnl >= 0;

    return Row(
      children: [
        Expanded(
          child: _metricCard(
            label: 'Total Equity',
            value: '\$${_totalEquity.toStringAsFixed(0)}',
            accent: _c.blue,
            icon: LucideIcons.wallet,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'Net PnL',
            value: '${isPos ? '+' : ''}\$${_totalPnl.toStringAsFixed(0)}',
            subValue: '${isPos ? '+' : ''}${_totalReturnPercentage.toStringAsFixed(1)}%',
            accent: isPos ? _c.green : _c.red,
            icon: isPos ? LucideIcons.trendingUp : LucideIcons.trendingDown,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            label: 'Active Pools',
            value: '${_investments.length}',
            accent: _c.gold,
            icon: LucideIcons.layers,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    String? subValue,
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
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue,
              style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EXPLORE CTA CARD
  // ---------------------------------------------------------------------------
  Widget _buildExploreCtaCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _c.blueBorder),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.sparkles, size: 18, color: _c.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover More Master Pools',
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Browse verified strategy managers & allocate capital.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _c.muted, fontSize: 10.5),
                ),
              ],
            ),
          ),
          if (widget.onExploreAvailable != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: widget.onExploreAvailable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Browse',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INVESTMENTS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildInvestmentsSection() {
    if (_investments.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: _c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.border),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.wallet, size: 36, color: _c.muted),
            const SizedBox(height: 10),
            Text(
              'No Active Subscriptions',
              style: GoogleFonts.inter(color: _c.text, fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Text(
              'You currently have no funds allocated to MAM pools.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _c.muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            if (widget.onExploreAvailable != null)
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: widget.onExploreAvailable,
                  icon: const Icon(LucideIcons.compass, size: 16),
                  label: const Text('Explore Available Pools'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _c.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Pool Subscriptions (${_investments.length})',
              style: GoogleFonts.inter(color: _c.text, fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _investments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final inv = _investments[index];
            return _buildInvestmentCard(inv);
          },
        ),
      ],
    );
  }

  Widget _buildInvestmentCard(MamInvestmentSubscription inv) {
    final isPos = inv.unrealizedPnl >= 0;

    return Container(
      padding: const EdgeInsets.all(13),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon, Name & Status
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: inv.isMirroringActive ? _c.greenLight : _c.subCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: inv.isMirroringActive
                        ? _c.green.withValues(alpha: 0.4)
                        : _c.border,
                  ),
                ),
                child: Icon(
                  inv.isMirroringActive ? LucideIcons.radio : LucideIcons.pause,
                  size: 18,
                  color: inv.isMirroringActive ? _c.green : _c.muted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inv.poolName,
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
                      'Master #${inv.managerLogin} • ${inv.allocationMethod}',
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
                  color: inv.isMirroringActive ? _c.greenLight : _c.redLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: inv.isMirroringActive
                        ? _c.green.withValues(alpha: 0.3)
                        : _c.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  inv.isMirroringActive ? 'Active' : 'Paused',
                  style: TextStyle(
                    color: inv.isMirroringActive ? _c.green : _c.red,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          // 2x2 Grid for Mobile Card Stats
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
                        'Allocated',
                        '\$${inv.initialCapital.toStringAsFixed(0)}',
                        icon: LucideIcons.dollarSign,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Current Equity',
                        '\$${inv.currentEquity.toStringAsFixed(2)}',
                        icon: LucideIcons.wallet,
                        valueColor: isPos ? _c.green : _c.red,
                      ),
                    ),
                  ],
                ),
                Divider(height: 12, thickness: 1, color: _c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _microStat(
                        'Net Profit/Loss',
                        '${isPos ? '+' : ''}\$${inv.unrealizedPnl.toStringAsFixed(2)} (${isPos ? '+' : ''}${inv.returnPercentage.toStringAsFixed(1)}%)',
                        icon: isPos ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                        valueColor: isPos ? _c.green : _c.red,
                      ),
                    ),
                    Container(width: 1, height: 28, color: _c.subBorder),
                    Expanded(
                      child: _microStat(
                        'Fee Rate',
                        '${inv.feePercentage.toStringAsFixed(0)}% Perf Fee',
                        icon: LucideIcons.percent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),

          // Interactive Buttons (min height 44px)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleMirroring(inv),
                    icon: Icon(
                      inv.isMirroringActive ? LucideIcons.pause : LucideIcons.play,
                      size: 14,
                      color: _c.text,
                    ),
                    label: Text(
                      inv.isMirroringActive ? 'Pause' : 'Resume',
                      style: TextStyle(color: _c.text, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _c.border),
                      minimumSize: const Size.fromHeight(44),
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
                    onPressed: () => _confirmDetach(inv),
                    icon: Icon(LucideIcons.logOut, size: 14, color: _c.red),
                    label: Text(
                      'Stop / Detach',
                      style: TextStyle(color: _c.red, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _c.red,
                      side: BorderSide(color: _c.red.withValues(alpha: 0.35)),
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

  void _toggleMirroring(MamInvestmentSubscription inv) {
    setState(() {
      inv.isMirroringActive = !inv.isMirroringActive;
    });
    toast.info(inv.isMirroringActive
        ? 'Trade copying resumed for ${inv.poolName}'
        : 'Trade copying paused for ${inv.poolName}');
  }

  void _confirmDetach(MamInvestmentSubscription inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Detach from ${inv.poolName}?',
          style: GoogleFonts.inter(color: _c.text, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Detaching stops mirroring and returns remaining equity (\$${inv.currentEquity.toStringAsFixed(2)}) to your wallet.',
          style: TextStyle(color: _c.muted, fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 44),
            ),
            child: Text('Cancel', style: TextStyle(color: _c.muted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _investments.removeWhere((item) => item.id == inv.id);
              });
              toast.success('Successfully detached from ${inv.poolName}');
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
}
