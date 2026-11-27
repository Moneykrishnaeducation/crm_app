import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../app_notifications.dart';
import '../models/partnership_models.dart';
import '../pages/broker_client_tree_page.dart';
import '../pages/broker_commission_ledger_page.dart';
import '../pages/broker_commission_withdrawal_page.dart';
import '../pages/broker_referral_studio_page.dart';
import 'leaderboard_card.dart';
import 'partnership_modals.dart';
import 'partnership_theme.dart';
import 'trajectory_chart_card.dart';

export 'leaderboard_card.dart';
export 'trajectory_chart_card.dart';

// ============================================================================
// APPROVED IB PARTNERSHIP DASHBOARD VIEW
// ============================================================================

class PartnershipDashboardView extends StatelessWidget {
  const PartnershipDashboardView({
    super.key,
    required this.dashboardData,
    required this.referralLinks,
    required this.clientTree,
    required this.commissionTxns,
    required this.loading,
    required this.demoPreviewMode,
    this.errorMessage,
    this.onBack,
    required this.onRefresh,
    required this.onExitDemoMode,
    required this.onIbChanged,
  });

  final IbDashboardData dashboardData;
  final List<IbReferralLink> referralLinks;
  final List<IbClient> clientTree;
  final List<IbCommissionTxn> commissionTxns;
  final bool loading;
  final bool demoPreviewMode;
  final String? errorMessage;
  final VoidCallback? onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onExitDemoMode;
  final VoidCallback onIbChanged;

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final isSkeleton = Skeletonizer.maybeOf(context)?.enabled ?? false;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: PartnershipBackdrop(
        colors: colors,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: colors.blue,
            backgroundColor: colors.card,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
              children: [
                if (demoPreviewMode) _buildDemoPreviewBanner(),
                if (!demoPreviewMode &&
                    errorMessage != null &&
                    errorMessage!.trim().isNotEmpty)
                  _buildErrorRetryBanner(colors, errorMessage!),
                _buildTopBar(colors),
                const SizedBox(height: 14),
                _buildHeroCommandCenter(context),
                const SizedBox(height: 16),
                _buildKpiMatrices(colors),
                const SizedBox(height: 16),
                TrajectoryChartCard(
                  colors: colors,
                  dashboardData: dashboardData,
                  referralLinks: referralLinks,
                  loading: loading && isSkeleton,
                ),
                const SizedBox(height: 16),
                LeaderboardCard(
                  colors: colors,
                  dashboardData: dashboardData,
                  referralLinks: referralLinks,
                  clientTree: clientTree,
                  onIbChanged: onIbChanged,
                ),
                const SizedBox(height: 18),
                _buildShortcutsSection(context, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoPreviewBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: Color(0xFFF59E0B), size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Demo Preview Mode • Real-time metrics will activate once your IB is approved.',
              style: TextStyle(
                color: Color(0xFFF59E0B),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              AppHaptics.lightImpact();
              onExitDemoMode();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Exit Demo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorRetryBanner(PartnershipColors colors, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.red.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.triangleAlert, color: colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.red,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: loading
                ? null
                : () {
                    AppHaptics.lightImpact();
                    onRefresh();
                  },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(PartnershipColors colors) {
    return Row(
      children: [
        if (onBack != null) ...[
          IconButton(
            tooltip: 'Back',
            onPressed: () {
              AppHaptics.selectionClick();
              onBack!();
            },
            icon: Icon(LucideIcons.arrowLeft, color: colors.text),
          ),
          const SizedBox(width: 4),
        ] else ...[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.blue, const Color(0xFF1E3A8A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.network, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Partnership Command Center',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Manage clients, commissions and withdrawals',
                style: TextStyle(color: colors.muted, fontSize: 11.5),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: () {
            AppHaptics.lightImpact();
            onRefresh();
          },
          icon: loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.blue,
                  ),
                )
              : Icon(LucideIcons.refreshCw, color: colors.muted, size: 18),
        ),
      ],
    );
  }

  Widget _buildHeroCommandCenter(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final direct = dashboardData.directClients;
    final total = dashboardData.totalClients;
    final sub = math.max(0, total - direct);
    final velocityRatio = total > 0
        ? math.min(
            1.0,
            (dashboardData.currentMonthVolume /
                math.max(1.0, dashboardData.totalVolume)),
          )
        : 0.5;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.isDark
              ? const [Color(0xFF071A57), Color(0xFF09246F), Color(0xFF0D338E)]
              : const [Color(0xFF0A255E), Color(0xFF103D88), Color(0xFF1652B0)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E040F36),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Actions Row
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    AppHaptics.lightImpact();
                    if (referralLinks.isNotEmpty) {
                      showReferralQrModal(context, referralLinks[0]);
                    } else if (dashboardData.referralLink.isNotEmpty) {
                      final uri = Uri.tryParse(dashboardData.referralLink);
                      final referralCode =
                          uri?.queryParameters['ref'] ??
                          uri?.queryParameters['code'] ??
                          '';
                      showReferralQrModal(
                        context,
                        IbReferralLink(
                          profileName: 'Partner Referral',
                          referralLink: dashboardData.referralLink,
                          referralCode: referralCode,
                          isPrimary: true,
                        ),
                      );
                    } else {
                      showAppMessage(
                        'No active referral link available yet. Pull down to refresh or open Referral Studio.',
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(LucideIcons.qrCode, size: 13),
                  label: const Text(
                    'Instant QR',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    AppHaptics.lightImpact();
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const BrokerCommissionWithdrawalPage(),
                      ),
                    );
                    onIbChanged();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(LucideIcons.wallet, size: 13),
                  label: const Text(
                    'Withdraw',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Available Balance display
          Text(
            'Liquid Available Balance',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${dashboardData.commissionBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'USD',
                style: TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 3-stat summary strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _heroStatCol(
                    'Month Earnings',
                    '\$${dashboardData.currentMonthEarnings.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _heroStatCol(
                    'Total Payouts',
                    '\$${dashboardData.totalWithdrawals.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _heroStatCol(
                    'Network Clients',
                    '${dashboardData.totalClients} ($direct Direct)',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Volume Velocity Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.zap,
                      size: 14,
                      color: Color(0xFFF5C438),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Volume Velocity Meter',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${dashboardData.currentMonthVolume.toStringAsFixed(2)} Lots (30D)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: velocityRatio,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF38BDF8),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'All-Time: ${dashboardData.totalVolume.toStringAsFixed(2)} Lots',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Ratio: $direct Direct / $sub Sub-IB',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiMatrices(PartnershipColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FINANCIAL & VOLUME TELEMETRY',
          style: TextStyle(
            color: colors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.1,
          children: [
            _kpiCard(
              colors,
              'Total Earnings',
              '\$${dashboardData.totalEarnings.toStringAsFixed(2)}',
              LucideIcons.coins,
              colors.gold,
            ),
            _kpiCard(
              colors,
              'Commission Balance',
              '\$${dashboardData.commissionBalance.toStringAsFixed(2)}',
              LucideIcons.wallet,
              colors.blue,
            ),
            _kpiCard(
              colors,
              'Total Clients',
              '${dashboardData.totalClients}',
              LucideIcons.users,
              colors.green,
            ),
            _kpiCard(
              colors,
              'Total Traded Volume',
              '${dashboardData.totalVolume.toStringAsFixed(2)} Lots',
              LucideIcons.activity,
              const Color(0xFF06B6D4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(
    PartnershipColors colors,
    String label,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsSection(
    BuildContext context,
    PartnershipColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTNERSHIP TOOLS & REPORTS',
          style: TextStyle(
            color: colors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.users,
          label: 'Client Network Hierarchy',
          subtitle:
              'View multi-level downline tiers, accounts, and client details',
          onTap: () async {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const BrokerClientTreePage(),
              ),
            );
            onIbChanged();
          },
        ),
        const SizedBox(height: 8),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.creditCard,
          label: 'Commission Ledger & History',
          subtitle:
              '${commissionTxns.isNotEmpty ? '${commissionTxns.length} recorded deals' : 'Complete trade deal records'}, volume, and generated commissions',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BrokerCommissionLedgerPage(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.wallet,
          label: 'Commission Payout & Withdrawal',
          subtitle: 'Instant internal transfer of available commission to live MT5 accounts',
          onTap: () async {
            await Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const BrokerCommissionWithdrawalPage(),
              ),
            );
            onIbChanged();
          },
        ),
        const SizedBox(height: 8),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.qrCode,
          label: 'Referral Link & QR Studio',
          subtitle:
              'Branded referral profiles, marketing links, and social sharing',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BrokerReferralStudioPage(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shortcutItem({
    required PartnershipColors colors,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return PartnershipGlassPanel(
      colors: colors,
      onTap: () {
        AppHaptics.selectionClick();
        onTap();
      },
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 14,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colors.blue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 16, color: colors.muted),
        ],
      ),
    );
  }
}
