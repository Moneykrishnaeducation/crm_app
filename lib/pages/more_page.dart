part of '../main.dart';

class BrokerMorePage extends StatelessWidget {
  const BrokerMorePage({super.key, required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
      children: [
        _MoreProfileCard(onTap: () => onSelectPage('Profile')),
        const SizedBox(height: 24),
        const _MoreSectionLabel(
          'INVESTMENT MANAGEMENT & PARTNERSHIPS',
          subtitle: 'Portfolio management, investor accounts, fund allocations and partner referrals',
        ),

        _MoreMenuGroup(
          children: [
            _MoreMenuRow(
              icon: LucideIcons.layers,
              title: 'PAMM',
              subtitle: 'Managed pools, available pools and my investments',
              accent: const Color(0xFF365CEB),
              onTap: () => onSelectPage('PAMM Account'),
            ),
            _MoreMenuRow(
              icon: LucideIcons.briefcaseBusiness,
              title: 'MAM',
              subtitle: 'MAM Manager, MAM Investor and MAM Available',
              onTap: () => onSelectPage('MAM Account'),
            ),
            _MoreMenuRow(
              icon: LucideIcons.network,
              title: 'Partnership',
              subtitle: 'IB overview, referrals and commissions',
              accent: _brokerGold,
              onTap: () => onSelectPage('Partnership'),
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _MoreSectionLabel(
          'PREFERENCES',
          subtitle: 'Personalise your app experience',
        ),
        _MoreMenuGroup(
          children: [
            _MoreMenuRow(
              icon: LucideIcons.download,
              title: 'Download Center',
              subtitle: 'Access platform downloads',
              onTap: () => onSelectPage('Platform'),
            ),
            _MoreMenuRow(
              icon: LucideIcons.shieldCheck,
              title: 'Security Center',
              subtitle: 'Account protection and security',
              onTap: () => onSelectPage('Security Center'),
              showDivider: false,
            ),
            _MoreMenuRow(
              icon: LucideIcons.settings,
              title: 'Settings',
              subtitle: 'Application preferences',
              onTap: () => onSelectPage('Settings'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _MoreSectionLabel(
          'SUPPORT',
          subtitle: 'Get help and manage your requests',
        ),
        _MoreMenuGroup(
          children: [
            _MoreMenuRow(
              icon: LucideIcons.messageSquare,
              title: 'Tickets',
              subtitle: 'View and manage support tickets',
              onTap: () => onSelectPage('Tickets'),
              showDivider: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

class _MoreProfileCard extends StatelessWidget {
  const _MoreProfileCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final border = theme.dividerColor;

    // High-end fintech palette adaptive to theme
    final cardBgStart = isDark ? const Color(0xFF14243B) : Colors.white;
    final cardBgEnd = isDark ? const Color(0xFF0F1A2C) : const Color(0xFFF8FAFC);
    final cardBorder = isDark ? const Color(0xFF23364E) : const Color(0xFFE2E8F0);

    final badgeVerifiedBg = const Color(0xFF10B981).withValues(alpha: isDark ? 0.16 : 0.10);
    final badgeVerifiedBorder = const Color(0xFF10B981).withValues(alpha: isDark ? 0.35 : 0.25);
    final badgeVerifiedText = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

    final badgeTierBg = _brokerGold.withValues(alpha: isDark ? 0.16 : 0.10);
    final badgeTierBorder = _brokerGold.withValues(alpha: isDark ? 0.38 : 0.28);
    final badgeTierText = isDark ? const Color(0xFFF6C84D) : const Color(0xFF9A6E0C);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          if (!isDark) ...[
            const BoxShadow(
              color: Color(0x0C0F2748),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
            const BoxShadow(
              color: Color(0x040F2748),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardBgStart, cardBgEnd],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cardBorder, width: 1.2),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(22),
            splashColor: _brokerGold.withValues(alpha: 0.08),
            highlightColor: cs.primary.withValues(alpha: 0.04),
            child: Stack(
              children: [
                // Subtle decorative radial accent glow at top-right
                Positioned(
                  top: -24,
                  right: -24,
                  child: IgnorePointer(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            (isDark ? _brokerGold : const Color(0xFF3B82F6))
                                .withValues(alpha: isDark ? 0.08 : 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Avatar + User Info + Chevron
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Enhanced Avatar with Gold & Blue Gradient Ring
                          _buildAvatar(isDark),
                          const SizedBox(width: 14),
                          // Identity Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'INR-DEVOP B',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: cs.onSurface,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      LucideIcons.badgeCheck,
                                      color: _brokerGold,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'iyyanar@vtindex.com',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Client ID Chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E2D44)
                                        : const Color(0xFFEEF2F8),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF283B55)
                                          : const Color(0xFFDFE6F1),
                                      width: 0.9,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.idCard,
                                        size: 11,
                                        color: isDark
                                            ? const Color(0xFF90A3BF)
                                            : const Color(0xFF5A6E88),
                                      ),
                                      const SizedBox(width: 4.5),
                                      Flexible(
                                        child: Text(
                                          'Client ID: #331589',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFFBAC7D9)
                                                : const Color(0xFF384961),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Circular action chevron button
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF1A2A42)
                                  : const Color(0xFFF1F5F9),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF263A58)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                LucideIcons.chevronRight,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Sleek Divider line
                      Container(
                        height: 1,
                        color: border.withValues(alpha: isDark ? 0.4 : 0.6),
                      ),
                      const SizedBox(height: 12),
                      // Bottom Row: Status Badges & Quick Action Link
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // KYC Status Pill
                                _buildStatusPill(
                                  icon: LucideIcons.shieldCheck,
                                  label: 'Verified',
                                  bgColor: badgeVerifiedBg,
                                  borderColor: badgeVerifiedBorder,
                                  textColor: badgeVerifiedText,
                                ),
                                // Account Tier Pill
                                _buildStatusPill(
                                  icon: LucideIcons.crown,
                                  label: 'Live MT5 Trader',
                                  bgColor: badgeTierBg,
                                  borderColor: badgeTierBorder,
                                  textColor: badgeTierText,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // View profile link with subtle arrow
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View profile',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                LucideIcons.chevronRight,
                                size: 13,
                                color: cs.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildAvatar(bool isDark) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer gradient ring container
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(2.2), // Ring thickness
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE5B842), // Gold
                Color(0xFF38BDF8), // Sky Blue
                Color(0xFF1D4ED8), // Deep Blue
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF0F1A2C) : Colors.white,
            ),
            padding: const EdgeInsets.all(1.8), // Inner separation
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF16325C), // Navy
                    Color(0xFF254B85), // Broker Blue
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  'IB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Active status indicator dot
        Positioned(
          bottom: 1,
          right: 1,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981),
              border: Border.all(
                color: isDark ? const Color(0xFF14243B) : Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.5, color: textColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreSectionLabel extends StatelessWidget {
  const _MoreSectionLabel(this.label, {this.subtitle});
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ],
    ),
  );
}

class _MoreMenuGroup extends StatelessWidget {
  const _MoreMenuGroup({required this.children});
  final List<_MoreMenuRow> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor),
      boxShadow: [
        if (Theme.of(context).brightness == Brightness.light)
          const BoxShadow(
            color: Color(0x060F2748),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
      ],
    ),
    child: Column(children: children),
  );
}

class _MoreMenuRow extends StatelessWidget {
  const _MoreMenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.accent = const Color(0xFF4775A8),
    this.showDivider = true,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final Color accent;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Center(child: Icon(icon, color: accent, size: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 9,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: Color(0xFFA1ACBC),
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ),
      if (showDivider)
        Divider(
          height: 1,
          thickness: 1,
          indent: 49,
          color: Theme.of(context).dividerColor,
        ),
    ],
  );
}

class LogoutBottomSheet extends StatefulWidget {
  const LogoutBottomSheet({super.key, required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  State<LogoutBottomSheet> createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<LogoutBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final border = theme.dividerColor;
    final muted = cs.onSurfaceVariant;

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FadeTransition(
              opacity: _animCtrl,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.18),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animCtrl,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      18 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 38,
                            height: 4,
                            decoration: BoxDecoration(
                              color: muted.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEF4444).withValues(alpha: dark ? 0.16 : 0.10),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: dark ? 0.35 : 0.22),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEF4444).withValues(alpha: dark ? 0.22 : 0.14),
                              ),
                              child: const Center(
                                child: Icon(
                                  LucideIcons.logOut,
                                  color: Color(0xFFEF4444),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Are you sure you want to log out of your account? You will need to enter your credentials to sign back in.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: muted,
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: cs.onSurface,
                                  side: BorderSide(color: border),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: widget.onConfirm,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(LucideIcons.logOut, size: 16),
                                label: const Text(
                                  'Log Out',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
