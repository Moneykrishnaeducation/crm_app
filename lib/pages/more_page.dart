part of '../main.dart';

class BrokerMorePage extends StatelessWidget {
  const BrokerMorePage({super.key, required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) => Container(
        color: _brokerNavy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 22),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF0A204A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF174783)),
              ),
              child: const Row(children: [
                Icon(LucideIcons.chartNoAxesCombined, color: Color(0xFF5AB8FF), size: 15),
                SizedBox(width: 6),
                Expanded(child: Text('System: VTIndex MT5', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600))),
                Icon(LucideIcons.circle, color: Color(0xFF38D98B), size: 7),
                SizedBox(width: 5),
                Text('Local | UTC+5:30', style: TextStyle(color: _brokerMuted, fontSize: 8)),
              ]),
            ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(color: _brokerPanel, borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF174783))),
              child: Row(children: [
                const CircleAvatar(radius: 19, backgroundColor: Color(0xFF163B78), child: Icon(LucideIcons.userRound, color: Colors.white, size: 20)),
                const SizedBox(width: 10),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('V Tamizharasan', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  SizedBox(height: 3),
                  Text('vtamizh...@gmail.com', style: TextStyle(color: _brokerMuted, fontSize: 9)),
                ])),
                const Icon(LucideIcons.chevronRight, color: _brokerMuted, size: 20),
              ]),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(colors: [Color(0xFF2413B5), Color(0xFF075EE8), Color(0xFF0C2B70)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                border: Border.all(color: const Color(0xFF2876E8)),
              ),
              child: const Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Trade with Confidence', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Secure. Reliable. Professional.', style: TextStyle(color: Color(0xFFD8E8FF), fontSize: 9)),
                ])),
                Icon(LucideIcons.trendingUp, color: _brokerGold, size: 25),
              ]),
            ),
            const SizedBox(height: 16),
            const _MoreSectionLabel('ACCOUNT & PARTNERSHIP'),
            _MoreMenuRow(icon: LucideIcons.userRound, title: 'Profile', onTap: () => onSelectPage('Profile')),
            _MoreMenuRow(icon: LucideIcons.shield, title: 'Security Center', onTap: () => onSelectPage('Support')),
            _MoreMenuRow(icon: LucideIcons.network, title: 'Partnership', subtitle: 'IB overview, referrals and commissions', accent: _brokerGold, onTap: () => onSelectPage('Partnership')),
            _MoreMenuRow(icon: LucideIcons.layers, title: 'PAMM', onTap: () => onSelectPage('PAMM Account')),
            _MoreMenuRow(icon: LucideIcons.briefcaseBusiness, title: 'Work Order Center', onTap: () => onSelectPage('Transactions')),
            _MoreMenuRow(icon: LucideIcons.gift, title: 'GTC Rewards', onTap: () => onSelectPage('Partnership')),
            _MoreMenuRow(icon: LucideIcons.wallet, title: 'Withdrawal Methods', onTap: () => onSelectPage('Transactions')),
            const SizedBox(height: 14),
            const _MoreSectionLabel('PREFERENCES & SUPPORT'),
            _MoreMenuRow(icon: LucideIcons.globe, title: 'Languages', trailing: 'English', onTap: () => _showLanguageDialog(context)),
            _MoreMenuRow(icon: LucideIcons.languages, title: 'Email Language', trailing: 'English', onTap: () => _showLanguageDialog(context)),
            _MoreMenuRow(icon: LucideIcons.download, title: 'Download Center', onTap: () => onSelectPage('Platform')),
            _MoreMenuRow(icon: LucideIcons.settings, title: 'Settings', onTap: () => onSelectPage('Settings')),
          ],
        ),
      );

  void _showLanguageDialog(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _brokerPanel,
          title: const Text('Language', style: TextStyle(color: Colors.white)),
          content: const Text('English is currently selected.', style: TextStyle(color: _brokerMuted)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
}

class _MoreSectionLabel extends StatelessWidget {
  const _MoreSectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 3, bottom: 5),
        child: Text(label, style: const TextStyle(color: _brokerMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: .7)),
      );
}

class _MoreMenuRow extends StatelessWidget {
  const _MoreMenuRow({required this.icon, required this.title, required this.onTap, this.subtitle, this.trailing, this.accent = const Color(0xFF8FA9D2)});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final String? trailing;
  final Color accent;
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(children: [
              Icon(icon, color: accent, size: 17),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[const SizedBox(height: 3), Text(subtitle!, style: const TextStyle(color: _brokerMuted, fontSize: 8))],
              ])),
              if (trailing != null) Text(trailing!, style: const TextStyle(color: _brokerMuted, fontSize: 8)),
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronRight, color: Color(0xFF7284A3), size: 17),
            ]),
          ),
        ),
      );
}
