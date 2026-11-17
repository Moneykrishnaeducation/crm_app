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
            const _MoreSectionLabel('ACCOUNT', subtitle: 'Profile, security and partnership services'),

            _MoreMenuGroup(children: [
              _MoreMenuRow(icon: LucideIcons.userRound, title: 'Profile', subtitle: 'Personal details and account information', onTap: () => onSelectPage('Profile')),
              _MoreMenuRow(icon: LucideIcons.shieldCheck, title: 'Security Center', subtitle: 'Account protection and security', onTap: () => onSelectPage('Security Center')),
              _MoreMenuRow(icon: LucideIcons.network, title: 'Partnership', subtitle: 'IB overview, referrals and commissions', accent: _brokerGold, onTap: () => onSelectPage('Partnership')),
              _MoreMenuRow(icon: LucideIcons.layers, title: 'PAMM', subtitle: 'Managed investment accounts', onTap: () => onSelectPage('PAMM Account')),
            ]),
            const SizedBox(height: 20),

            const _MoreSectionLabel('COPY TRADING & MAM', subtitle: 'Social trading and managed accounts'),
            const _MoreSectionLabel('TRADING SERVICES', subtitle: 'Managed account and copy trading tools'),

            _MoreMenuGroup(children: [
              _MoreMenuRow(icon: LucideIcons.briefcaseBusiness, title: 'MAM Manager', subtitle: 'Manage master nodes & allocation rules', onTap: () => onSelectPage('MAM Manager')),
              _MoreMenuRow(icon: LucideIcons.usersRound, title: 'MAM Investor', subtitle: 'View subscribed pools & net returns', onTap: () => onSelectPage('MAM Investor')),
              _MoreMenuRow(icon: LucideIcons.wallet, title: 'MAM Available', subtitle: 'Discover & invest in verified master pools', onTap: () => onSelectPage('Available MAM'), showDivider: false),
            ]),
            const SizedBox(height: 20),
            const _MoreSectionLabel('PREFERENCES', subtitle: 'Personalise your app experience'),
            _MoreMenuGroup(children: [
              _MoreMenuRow(icon: LucideIcons.download, title: 'Download Center', subtitle: 'Access platform downloads', onTap: () => onSelectPage('Platform')),
              _MoreMenuRow(icon: LucideIcons.settings, title: 'Settings', subtitle: 'Application preferences', onTap: () => onSelectPage('Settings'), showDivider: false),
            ]),
            const SizedBox(height: 16),
            Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _showLogoutSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF2DADB))),
                  child: const Row(children: [
                    Icon(LucideIcons.logOut, color: Color(0xFFD64545), size: 18),
                    SizedBox(width: 12),
                    Expanded(child: Text('Log out', style: TextStyle(color: Color(0xFFD64545), fontSize: 12, fontWeight: FontWeight.w700))),
                    Icon(LucideIcons.chevronRight, color: Color(0xFFC77C7C), size: 17),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(child: Text('VTINDEX MT5  •  LOCAL TIME UTC+5:30', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: .55))),
          ],
        ),
      );

  void _showLogoutSheet(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetContext) => LogoutBottomSheet(
          onConfirm: () {
            Navigator.of(sheetContext).pop();
            onSelectPage('Logout');
          },
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor), boxShadow: const [BoxShadow(color: Color(0x080F2748), blurRadius: 14, offset: Offset(0, 5))]),
            child: Row(children: [
              Container(
                width: 49,
                height: 49,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF244D80), Color(0xFF4979A9)])),
                child: const Center(child: Text('I', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text('INR-DEVOP B', overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w800))),
                  const SizedBox(width: 5),
                  const Icon(LucideIcons.badgeCheck, color: _brokerGold, size: 15),
                ]),
                const SizedBox(height: 4),
                Text('iyyanar@vtindex.com', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                const SizedBox(height: 6),
                Text('View profile', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w700)),
              ])),
              const Icon(LucideIcons.chevronRight, color: Color(0xFF8290A6), size: 20),
            ]),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
          ],
        ]),
      );
}

class _MoreMenuGroup extends StatelessWidget {
  const _MoreMenuGroup({required this.children});
  final List<_MoreMenuRow> children;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor), boxShadow: [if (Theme.of(context).brightness == Brightness.light) const BoxShadow(color: Color(0x060F2748), blurRadius: 10, offset: Offset(0, 3))]),
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
  Widget build(BuildContext context) => Column(children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(color: accent.withValues(alpha: .09), borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Icon(icon, color: accent, size: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, height: 1.25)),
                  ],
                ])),
                const Icon(LucideIcons.chevronRight, color: Color(0xFFA1ACBC), size: 17),
              ]),
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, indent: 49, color: Theme.of(context).dividerColor),
      ]);
}

class LogoutBottomSheet extends StatelessWidget {
  const LogoutBottomSheet({super.key, required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: const [BoxShadow(color: Color(0x33000817), blurRadius: 24, offset: Offset(0, 8))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: const Color(0xFFD5DCE7), borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 20),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF5867).withValues(alpha: .09)),
              child: const Center(child: Icon(LucideIcons.logOut, color: Color(0xFFD64545), size: 25)),
            ),
            const SizedBox(height: 16),
            Text('Log Out', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Are you sure you want to log out of your account? You will need to enter your credentials to sign back in.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, height: 1.45)),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF344766), side: const BorderSide(color: Color(0xFFDCE3ED)), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.icon(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD64545), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(LucideIcons.logOut, size: 15),
                label: const Text('Log Out', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              )),
            ]),
          ]),
        ),
      );
}
