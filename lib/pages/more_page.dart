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
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080F2748),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 49,
              height: 49,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF244D80), Color(0xFF4979A9)],
                ),
              ),
              child: const Center(
                child: Text(
                  'I',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
                        child: Text(
                          'INR-DEVOP B',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        LucideIcons.badgeCheck,
                        color: _brokerGold,
                        size: 15,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'iyyanar@vtindex.com',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'View profile',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Color(0xFF8290A6),
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
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
