part of '../main.dart';

class BrokerMorePage extends StatelessWidget {
  const BrokerMorePage({super.key, required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  static const _ink = Color(0xFF10264B);
  static const _muted = Color(0xFF71809A);
  static const _line = Color(0xFFE7ECF4);
  static const _surface = Colors.white;

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR ACCOUNT', style: TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      SizedBox(height: 5),
                      Text('More', style: TextStyle(color: _ink, fontSize: 27, fontWeight: FontWeight.w800, height: 1.1)),
                      SizedBox(height: 4),
                      Text('Manage your profile, preferences and services', style: TextStyle(color: _muted, fontSize: 11)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xFFEAF7F0), borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.circle, color: Color(0xFF22A06B), size: 7),
                    SizedBox(width: 6),
                    Text('Online', style: TextStyle(color: Color(0xFF18794E), fontSize: 10, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _MoreProfileCard(onTap: () => onSelectPage('Profile')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF182D52), Color(0xFF24558B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x1F18345D), blurRadius: 16, offset: Offset(0, 7))],
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('TRADE WITH CONFIDENCE', style: TextStyle(color: Color(0xFFFFD98A), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  const Text('Your trading tools,\nin one place.', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 5),
                  Text('Explore platform resources and account services', style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 10, height: 1.35)),
                ])),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: .18))),
                  child: const Icon(LucideIcons.chartNoAxesCombined, color: Color(0xFFFFD27A), size: 25),
                ),
              ]),
            ),
            const SizedBox(height: 22),
            const _MoreSectionLabel('ACCOUNT & PARTNERSHIP', subtitle: 'Your account and trading services'),
            _MoreMenuGroup(children: [
              _MoreMenuRow(icon: LucideIcons.userRound, title: 'Profile', subtitle: 'Personal details and account information', onTap: () => onSelectPage('Profile')),
              _MoreMenuRow(icon: LucideIcons.shieldCheck, title: 'Security Center', subtitle: 'Account protection and security', onTap: () => onSelectPage('Security Center')),
              _MoreMenuRow(icon: LucideIcons.network, title: 'Partnership', subtitle: 'IB overview, referrals and commissions', accent: _brokerGold, onTap: () => onSelectPage('Partnership')),
              _MoreMenuRow(icon: LucideIcons.layers, title: 'PAMM', subtitle: 'Managed investment accounts', onTap: () => onSelectPage('PAMM Account')),
            ]),
            const SizedBox(height: 20),
            const _MoreSectionLabel('COPY TRADING', subtitle: 'Tools and services for copy trading'),
            _MoreMenuGroup(children: [
              _MoreMenuRow(icon: LucideIcons.briefcaseBusiness, title: 'MAM Manager', subtitle: 'Manage your managed accounts', onTap: () => onSelectPage('Transactions')),
              _MoreMenuRow(icon: LucideIcons.usersRound, title: 'MAM Investor', subtitle: 'Explore managed investment accounts', onTap: () => onSelectPage('Partnership')),
              _MoreMenuRow(icon: LucideIcons.wallet, title: 'Available MAM', subtitle: 'View available managed accounts', onTap: () => onSelectPage('Transactions'), showDivider: false),
            ]),
            const SizedBox(height: 20),
            const _MoreSectionLabel('PREFERENCES & SUPPORT', subtitle: 'Personalise your app experience'),
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
            const Center(child: Text('VTINDEX MT5  •  LOCAL TIME UTC+5:30', style: TextStyle(color: Color(0xFFA0AABD), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: .55))),
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
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text('INR-DEVOP B', overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFF10264B), fontSize: 13, fontWeight: FontWeight.w800))),
                  SizedBox(width: 5),
                  Icon(LucideIcons.badgeCheck, color: _brokerGold, size: 15),
                ]),
                SizedBox(height: 4),
                Text('iyyanar@vtindex.com', style: TextStyle(color: Color(0xFF71809A), fontSize: 10)),
                SizedBox(height: 6),
                Text('View profile', style: TextStyle(color: Color(0xFF24558B), fontSize: 10, fontWeight: FontWeight.w700)),
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
          Text(label, style: const TextStyle(color: Color(0xFF344766), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8)),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: const TextStyle(color: Color(0xFF8793A7), fontSize: 10)),
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
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: Theme.of(context).dividerColor), boxShadow: const [BoxShadow(color: Color(0x060F2748), blurRadius: 12, offset: Offset(0, 4))]),
        child: Column(children: children),
      );
}

class _MoreMenuRow extends StatelessWidget {
  const _MoreMenuRow({required this.icon, required this.title, required this.onTap, this.subtitle, this.trailing, this.accent = const Color(0xFF4775A8), this.showDivider = true});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final String? trailing;
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(color: accent.withValues(alpha: .09), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Icon(icon, color: accent, size: 17)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: Color(0xFF1B2F50), fontSize: 12, fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: const TextStyle(color: Color(0xFF8290A6), fontSize: 9, height: 1.25)),
                  ],
                ])),
                if (trailing != null) ...[
                  Text(trailing!, style: const TextStyle(color: Color(0xFF71809A), fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 7),
                ],
                const Icon(LucideIcons.chevronRight, color: Color(0xFFA1ACBC), size: 17),
              ]),
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, thickness: 1, indent: 49, color: Color(0xFFF0F2F6)),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5EAF2)),
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
            const Text('Log Out', style: TextStyle(color: Color(0xFF10264B), fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Are you sure you want to log out of your account? You will need to enter your credentials to sign back in.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF71809A), fontSize: 12, height: 1.45)),
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
