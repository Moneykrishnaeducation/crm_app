import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_haptics.dart';
import '../../../services/auth_api.dart';
import 'earnings_calculator_card.dart';
import 'ib_faq_section.dart';
import 'partnership_modals.dart';
import 'partnership_theme.dart';

export 'earnings_calculator_card.dart';
export 'ib_faq_section.dart';

// ============================================================================
// PARTNERSHIP APPLICATION & PROGRAM VIEW (NON-IB STATE)
// ============================================================================

class PartnershipApplicationView extends StatefulWidget {
  const PartnershipApplicationView({
    super.key,
    required this.ibStatus,
    this.onBack,
    required this.onRefresh,
    required this.onEnterDemoMode,
    required this.onApplicationSubmitted,
  });

  final String ibStatus;
  final VoidCallback? onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onEnterDemoMode;
  final VoidCallback onApplicationSubmitted;

  @override
  State<PartnershipApplicationView> createState() => _PartnershipApplicationViewState();
}

class _PartnershipApplicationViewState extends State<PartnershipApplicationView> {
  bool _submittingApplication = false;
  bool _agreedToTerms = true;

  Future<void> _submitIbApplication() async {
    AppHaptics.mediumImpact();
    setState(() => _submittingApplication = true);
    try {
      await AuthApi.instance.submitIbApplication();
      if (mounted) {
        setState(() => _submittingApplication = false);
        widget.onApplicationSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: const [
                Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'IB Application submitted! Compliance review is in progress.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submittingApplication = false);
        final msg = e is AuthApiException ? e.message : 'Failed to submit IB application.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(msg, style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  void _openTermsModal() {
    AppHaptics.selectionClick();
    showIbTermsModal(
      context,
      initialAgreed: _agreedToTerms,
      onAgreedChanged: (agreed) {
        if (mounted) setState(() => _agreedToTerms = agreed);
      },
      onSubmit: _submitIbApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final isPending = widget.ibStatus == 'pending';

    return Scaffold(
      backgroundColor: colors.canvas,
      body: PartnershipBackdrop(
        colors: colors,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            color: colors.blue,
            backgroundColor: colors.card,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
              children: [
                _buildIbAppTopBar(context, colors, isPending),
                const SizedBox(height: 14),
                _buildIbStatusAlert(colors, isPending),
                const SizedBox(height: 16),
                _buildIbHeroDeck(colors),
                const SizedBox(height: 18),
                EarningsCalculatorCard(colors: colors),
                const SizedBox(height: 18),
                _buildTierBreakdownSection(colors),
                const SizedBox(height: 18),
                _buildCoreBenefitsSection(colors),
                const SizedBox(height: 18),
                IbFaqSection(colors: colors),
                const SizedBox(height: 22),
                _buildApplyFooterCta(colors, isPending),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIbAppTopBar(
    BuildContext context,
    PartnershipColors colors,
    bool isPending,
  ) {
    return Row(
      children: [
        if (widget.onBack != null || Navigator.canPop(context))
          IconButton(
            onPressed: widget.onBack ?? () => Navigator.pop(context),
            icon: Icon(LucideIcons.arrowLeft, color: colors.text),
          )
        else
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.blue, const Color(0xFF1E3A8A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.network, color: Colors.white, size: 20),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Introducing Broker (IB)',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Multi-Tier Partnership Program',
                style: TextStyle(
                  color: colors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPending
                ? const Color(0xFFD97706).withValues(alpha: 0.15)
                : colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPending
                  ? const Color(0xFFD97706).withValues(alpha: 0.4)
                  : colors.blue.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPending ? LucideIcons.clock : LucideIcons.sparkles,
                size: 11,
                color: isPending ? const Color(0xFFF59E0B) : colors.blue,
              ),
              const SizedBox(width: 5),
              Text(
                isPending ? 'Under Review' : 'Enrolling',
                style: TextStyle(
                  color: isPending ? const Color(0xFFF59E0B) : colors.blue,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () {
            AppHaptics.lightImpact();
            widget.onRefresh();
          },
          tooltip: 'Refresh Status',
          icon: Icon(LucideIcons.refreshCw, color: colors.muted, size: 18),
        ),
      ],
    );
  }

  Widget _buildIbStatusAlert(PartnershipColors colors, bool isPending) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: colors.isDark
                ? const [Color(0xFF382305), Color(0xFF1E1404)]
                : const [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
          ),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.clock, color: Color(0xFFD97706), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Pending Review',
                        style: TextStyle(
                          color: colors.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Compliance review is actively in progress',
                        style: TextStyle(
                          color: colors.isDark ? const Color(0xFFD97706) : const Color(0xFFB45309),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your Introducing Broker application has been received and is awaiting compliance verification. We typically complete reviews within 2 to 24 business hours. Once approved, your commission wallet and referral links will be unlocked automatically.',
              style: TextStyle(
                color: colors.isDark
                    ? const Color(0xFFFCD34D).withValues(alpha: 0.85)
                    : const Color(0xFF78350F),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    AppHaptics.lightImpact();
                    widget.onRefresh();
                  },
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: const Text('Check Approval Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 0,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    AppHaptics.lightImpact();
                    widget.onEnterDemoMode();
                  },
                  icon: const Icon(LucideIcons.sparkles, size: 14),
                  label: const Text('Preview Command Center'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    side: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: colors.isDark
              ? const [Color(0xFF0C246E), Color(0xFF071426)]
              : const [Color(0xFFE8EEF9), Color(0xFFF8FAFC)],
        ),
        border: Border.all(color: colors.blue.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colors.blue.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.shieldCheck, color: colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Become a Certified VT-Index Partner',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Earn up to \$8.00 per standard lot across 3 tiers',
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Enroll as an Introducing Broker to start generating lifetime automated daily commissions on all trading volume generated by your clients and subordinate Sub-IB networks.',
            style: TextStyle(
              color: colors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _openTermsModal,
                icon: const Icon(LucideIcons.send, size: 14),
                label: const Text('Apply for IB Partnership'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  AppHaptics.lightImpact();
                  widget.onEnterDemoMode();
                },
                icon: const Icon(LucideIcons.sparkles, size: 14),
                label: const Text('Preview Command Center'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIbHeroDeck(PartnershipColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.isDark
              ? const [Color(0xFF071A57), Color(0xFF0A2675), Color(0xFF0D338E)]
              : const [Color(0xFF0A255E), Color(0xFF103D88), Color(0xFF1652B0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'INSTITUTIONAL TIER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(LucideIcons.zap, size: 14, color: Color(0xFFF5C438)),
              const SizedBox(width: 4),
              const Text(
                'Instant Daily Rebate',
                style: TextStyle(color: Color(0xFFF5C438), fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Accelerate Your Trading Revenue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Partner with VT-Index to unlock multi-tiered override rebates on FX, Metals, Indices, and Crypto.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroStatCell('Base Rebate Pool', '\$8.00 / lot'),
              _heroStatCell('Level 1 Direct', '50% (\$4.00)'),
              _heroStatCell('Sub-IB Tiers', '20% + 10%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatCell(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierBreakdownSection(PartnershipColors colors) {
    final tiers = [
      {
        'level': 'Level 1',
        'title': 'Direct Client Network',
        'rate': '50% Pool Share (\$4.00/lot)',
        'desc': 'Earn direct commission on every closed position traded by clients you introduce.',
        'color': colors.blue,
        'icon': LucideIcons.user,
      },
      {
        'level': 'Level 2',
        'title': 'Sub-IB Network',
        'rate': '20% Pool Share (\$1.60/lot)',
        'desc': 'Receive automated sub-tier overrides on all volume generated by clients introduced by your Sub-IBs.',
        'color': colors.gold,
        'icon': LucideIcons.users,
      },
      {
        'level': 'Level 3',
        'title': 'Extended Ecosystem',
        'rate': '10% Pool Share (\$0.80/lot)',
        'desc': 'Compound continuous override revenue from third-generation clients referred across your downline network.',
        'color': colors.green,
        'icon': LucideIcons.globe,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3-TIER REBATE ARCHITECTURE',
          style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
        ...tiers.map((t) {
          final color = t['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PartnershipGlassPanel(
              colors: colors,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(t['icon'] as IconData, color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t['title'] as String,
                              style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t['level'] as String,
                                style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(t['rate'] as String, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(t['desc'] as String, style: TextStyle(color: colors.muted, fontSize: 11.5, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCoreBenefitsSection(PartnershipColors colors) {
    final benefits = [
      {'title': '\$8.00/Lot Pool', 'desc': 'Transparent multi-tier model across the complete rebate structure.', 'icon': LucideIcons.badgePercent},
      {'title': '3-Tier Sub-IB Tree', 'desc': 'Automated multi-level overrides on direct and subordinate networks.', 'icon': LucideIcons.network},
      {'title': 'Daily Settlements', 'desc': 'Instant commission credits with zero payout or transfer fees.', 'icon': LucideIcons.wallet},
      {'title': 'Partner CRM', 'desc': 'Real-time MT5 trading telemetry, conversion stats, and client drilldowns.', 'icon': LucideIcons.barChart3},
      {'title': 'QR & Link Studio', 'desc': 'Pre-built landing pages, campaign profiles, and dynamic QR generators.', 'icon': LucideIcons.qrCode},
      {'title': 'Dedicated Manager', 'desc': '1-on-1 strategic growth advice, custom profiles, and priority desk.', 'icon': LucideIcons.headphones},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTNER ADVANTAGES',
          style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, idx) {
            final b = benefits[idx];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(b['icon'] as IconData, size: 20, color: colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    b['title'] as String,
                    style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b['desc'] as String,
                    style: TextStyle(color: colors.muted, fontSize: 10.5, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildApplyFooterCta(PartnershipColors colors, bool isPending) {
    if (isPending) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFD97706).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.clock, size: 16, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text(
              'Application Submitted • Awaiting Compliance Approval',
              style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submittingApplication ? null : _openTermsModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: colors.blue.withValues(alpha: 0.4),
        ),
        child: _submittingApplication
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.send, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Join VT-Index Partnership Program',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
      ),
    );
  }
}
