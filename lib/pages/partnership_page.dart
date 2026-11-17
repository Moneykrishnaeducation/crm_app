import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _partnershipNavy = Color(0xFF102746);
const _partnershipBlue = Color(0xFF2459A6);
const _partnershipGold = Color(0xFFC99A35);
const _partnershipMuted = Color(0xFF738197);
const _partnershipBorder = Color(0xFFE5EAF1);
const _partnershipCanvas = Color(0xFFF6F8FB);

class BrokerPartnershipPage extends StatefulWidget {
  const BrokerPartnershipPage({super.key});

  @override
  State<BrokerPartnershipPage> createState() => _BrokerPartnershipPageState();
}

class _BrokerPartnershipPageState extends State<BrokerPartnershipPage> {
  static const _partners = <_PartnerProfile>[
    _PartnerProfile(name: 'Gold', code: 'X0RCGYVH7A', clients: 0),
    _PartnerProfile(name: 'Gold-80', code: 'UENYAZWK4', clients: 0),
    _PartnerProfile(name: 'Test', code: '4Z7G7TKF4J', clients: 0, primary: true),
    _PartnerProfile(name: 'test', code: 'IQ57TSDY38', clients: 0),
    _PartnerProfile(name: 'crm', code: '9BSFFEGGTL', clients: 0),
    _PartnerProfile(name: 'test3', code: '6F81L1IUK5', clients: 0),
  ];

  int _selectedPartnerIndex = 2;
  _PartnerProfile get _selectedPartner => _partners[_selectedPartnerIndex];

  void _showReferralQr() {
    var modalPartnerIndex = _selectedPartnerIndex;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) {
          final partner = _partners[modalPartnerIndex];
          final referralUrl = 'https://client.vtindex.com/?ref=${partner.code}';
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _partnershipBorder),
                  boxShadow: const [BoxShadow(color: Color(0x220B1D35), blurRadius: 30, offset: Offset(0, 12))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    const Expanded(child: Text('Referral QR code', style: TextStyle(color: _partnershipNavy, fontSize: 18, fontWeight: FontWeight.w700))),
                    IconButton(tooltip: 'Close', onPressed: () => Navigator.of(sheetContext).pop(), icon: const Icon(LucideIcons.x, color: _partnershipMuted)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: _partnershipCanvas, borderRadius: BorderRadius.circular(12), border: Border.all(color: _partnershipBorder)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: modalPartnerIndex,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        iconEnabledColor: _partnershipBlue,
                        style: const TextStyle(color: _partnershipNavy, fontSize: 12),
                        items: [for (var i = 0; i < _partners.length; i++) DropdownMenuItem(value: i, child: Text('${_partners[i].name} · ${_partners[i].code}'))],
                        onChanged: (index) {
                          if (index == null) return;
                          setModalState(() => modalPartnerIndex = index);
                          setState(() => _selectedPartnerIndex = index);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _partnershipBorder)),
                    child: QrImageView(data: referralUrl, version: QrVersions.auto, size: 210, backgroundColor: Colors.white, eyeStyle: const QrEyeStyle(color: Color(0xFF102746)), dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF102746))),
                  ),
                  const SizedBox(height: 14),
                  Text(partner.name, style: const TextStyle(color: _partnershipNavy, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  SelectableText(referralUrl, textAlign: TextAlign.center, style: const TextStyle(color: _partnershipMuted, fontSize: 11)),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        color: _partnershipCanvas,
        child: LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return ListView(
            padding: EdgeInsets.fromLTRB(wide ? 32 : 16, 22, wide ? 32 : 16, 110),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1160),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _partnershipBorder), boxShadow: const [BoxShadow(color: Color(0x080B1D35), blurRadius: 18, offset: Offset(0, 6))]),
                      child: Row(children: [
                        Container(width: 52, height: 52, decoration: BoxDecoration(color: _partnershipGold.withValues(alpha: .14), borderRadius: BorderRadius.circular(16)), child: const Icon(LucideIcons.award, color: _partnershipGold, size: 27)),
                        const SizedBox(width: 16),
                        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Partnership', style: TextStyle(color: _partnershipNavy, fontSize: 21, fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('Track your network and referral performance.', style: TextStyle(color: _partnershipMuted, fontSize: 13))])),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    Row(children: const [Expanded(child: _PartnershipStat(icon: LucideIcons.usersRound, label: 'Total clients', value: '2,458')), SizedBox(width: 12), Expanded(child: _PartnershipStat(icon: LucideIcons.coins, label: 'IB earnings', value: '\$4,820.00', gold: true))]),
                    const SizedBox(height: 16),
                    if (wide)
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 6, child: _buildPartnerColumn()),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: _buildToolsColumn()),
                      ])
                    else ...[
                      _buildToolsColumn(),
                      const SizedBox(height: 18),
                      _buildPartnerColumn(),
                    ],
                  ]),
                ),
              ),
            ],
          );
        }),
      );

  Widget _buildToolsColumn() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _partnershipBorder)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your partner code', style: TextStyle(color: _partnershipNavy, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Share this code to invite new clients.', style: TextStyle(color: _partnershipMuted, fontSize: 12)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: _partnershipCanvas, borderRadius: BorderRadius.circular(12), border: Border.all(color: _partnershipBorder)),
              child: Row(children: [const Icon(LucideIcons.link, color: _partnershipBlue, size: 18), const SizedBox(width: 9), Expanded(child: Text(_selectedPartner.code, style: const TextStyle(color: _partnershipNavy, fontSize: 13, fontWeight: FontWeight.w700))), IconButton(tooltip: 'Show referral QR code', onPressed: _showReferralQr, icon: const Icon(LucideIcons.qrCode, color: _partnershipBlue, size: 20))]),
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _showReferralQr, style: FilledButton.styleFrom(backgroundColor: _partnershipNavy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(LucideIcons.qrCode, size: 17), label: const Text('Show referral QR'))),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('Quick shortcuts', style: TextStyle(color: _partnershipNavy, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _PartnershipShortcut(
          icon: LucideIcons.usersRound,
          label: 'Client list',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BrokerClientTreePage(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const _PartnershipShortcut(icon: LucideIcons.layers, label: 'Commission history'),
        const SizedBox(height: 8),
        _PartnershipShortcut(icon: LucideIcons.qrCode, label: 'Referral & QR studio', onTap: _showReferralQr),
        const SizedBox(height: 8),
        _PartnershipShortcut(
          icon: LucideIcons.network,
          label: 'IB tree / org chart',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BrokerClientTreePage(),
            ),
          ),
        ),
      ]);

  Widget _buildPartnerColumn() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Partner profiles', style: TextStyle(color: _partnershipNavy, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _partnershipBorder)),
          child: Column(children: [for (var i = 0; i < _partners.length; i++) _PartnerProfileTile(profile: _partners[i], selected: i == _selectedPartnerIndex, onTap: () => setState(() => _selectedPartnerIndex = i))]),
        ),
      ]);
}

class _PartnerProfile {
  const _PartnerProfile({required this.name, required this.code, required this.clients, this.primary = false});
  final String name;
  final String code;
  final int clients;
  final bool primary;
}

class _PartnerProfileTile extends StatelessWidget {
  const _PartnerProfileTile({required this.profile, required this.selected, required this.onTap});
  final _PartnerProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? _partnershipBlue.withValues(alpha: .06) : Colors.transparent,
        child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: selected ? _partnershipBlue.withValues(alpha: .1) : _partnershipCanvas, borderRadius: BorderRadius.circular(10)), child: Icon(LucideIcons.userRound, size: 16, color: selected ? _partnershipBlue : _partnershipMuted)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(profile.name, style: const TextStyle(color: _partnershipNavy, fontSize: 12, fontWeight: FontWeight.w700)),
                    if (profile.primary) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: _partnershipGold.withValues(alpha: .2), borderRadius: BorderRadius.circular(5)),
                        child: const Text('Primary', style: TextStyle(color: _partnershipNavy, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(profile.code, style: const TextStyle(color: _partnershipMuted, fontSize: 10, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('\$0', style: TextStyle(color: _partnershipNavy, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text('${profile.clients} clients', style: const TextStyle(color: _partnershipMuted, fontSize: 9)),
            ],
          ),
        ]))),
      );
}

class _PartnershipStat extends StatelessWidget {
  const _PartnershipStat({required this.icon, required this.label, required this.value, this.gold = false});
  final IconData icon;
  final String label;
  final String value;
  final bool gold;

  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _partnershipBorder)), child: Row(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: (gold ? _partnershipGold : _partnershipBlue).withValues(alpha: .12), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: gold ? _partnershipGold : _partnershipBlue, size: 19)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _partnershipMuted, fontSize: 11)), const SizedBox(height: 5), FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(color: _partnershipNavy, fontSize: 17, fontWeight: FontWeight.w700)))]))]));
}

class _PartnershipShortcut extends StatelessWidget {
  const _PartnershipShortcut({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _partnershipBorder)), child: Row(children: [Icon(icon, color: _partnershipBlue, size: 18), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(color: _partnershipNavy, fontSize: 12, fontWeight: FontWeight.w600))), const Icon(LucideIcons.chevronRight, color: _partnershipMuted, size: 18)]))));
}


/// Client hierarchy shown from the partnership quick shortcuts.
///
/// This page is populated from one hierarchy fixture so the headline metrics,
/// parent referral count and child rows cannot drift apart. Replace the
/// fixture with the authenticated IB network API when it is available.
class BrokerClientTreePage extends StatefulWidget {
  const BrokerClientTreePage({super.key});

  @override
  State<BrokerClientTreePage> createState() => _BrokerClientTreePageState();
}

class _BrokerClientTreePageState extends State<BrokerClientTreePage> {
  static const _navy = Color(0xFF102746);
  static const _blue = Color(0xFF2459A6);
  static const _gold = Color(0xFFC99A35);
  static const _muted = Color(0xFF738197);
  static const _border = Color(0xFFDCE5F1);
  static const _canvas = Color(0xFFF5F7FB);
  static const _ib = _ClientTreeMember(
    initials: 'IB',
    name: 'INR-DEVOP B',
    email: 'iyyanar@vtindex.com',
    phone: '7894561235',
    joined: '2026-01-20',
    referralCode: 'X0RCGYVH7A',
    level: 1,
    accountCount: 9,
    isPartner: true,
    children: [
      _ClientTreeMember(
        initials: 'SK',
        name: 'SHRAVAN KUMAR MADDKUNTA',
        email: 'elegantgrouplands@gmail.com',
        joined: '2026-10-23',
        level: 2,
        accountCount: 1,
      ),
      _ClientTreeMember(
        initials: 'TC',
        name: 'TEST CRN',
        email: 'crmsupportpro@gmail.com',
        phone: '7417417410',
        joined: '2026-07-25',
        referralCode: '8SEBSRFT',
        level: 2,
        accountCount: 4,
      ),
    ],
  );

  final _searchController = TextEditingController();
  String _query = '';
  bool _expanded = true;
  bool _showAllReferralLinks = true;

  int get _networkCount => _ib.children.length + 1;
  int get _directCount => _ib.children.where((member) => member.level == 2).length;
  int get _downstreamCount => _ib.children.where((member) => member.level > 1).length;
  int get _depth => _ib.children.fold<int>(1, (max, member) => member.level > max ? member.level : max);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visibleChildren = _ib.children.where((member) {
      if (query.isEmpty) return true;
      return <String>[
        member.name,
        member.email,
        member.phone ?? '',
        member.referralCode ?? '',
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();
    final rootMatches = query.isEmpty ||
        <String>[_ib.name, _ib.email, _ib.phone ?? '', _ib.referralCode ?? '']
            .any((value) => value.toLowerCase().contains(query));
    final dark = Theme.of(context).brightness == Brightness.dark;
    final page = dark ? const Color(0xFF0B1424) : _canvas;

    return Scaffold(
      backgroundColor: page,
      appBar: AppBar(
        title: const Text('Client list'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final horizontal = wide ? 28.0 : 14.0;
          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 30),
            children: [
              _treeHeader(dark),
              const SizedBox(height: 14),
              _treeSearch(dark),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: wide ? 2.25 : 2.05,
                children: [
                  _TreeStat(label: 'TOTAL NETWORK', value: '$_networkCount', subtitle: 'All downline clients', icon: LucideIcons.users, accent: _gold, dark: dark),
                  _TreeStat(label: 'DIRECT (L1)', value: '$_directCount', subtitle: 'Direct referrals', icon: LucideIcons.userRound, accent: _gold, dark: dark),
                  _TreeStat(label: 'SUB-TIER (L2+)', value: '$_downstreamCount', subtitle: 'Downstream clients', icon: LucideIcons.network, accent: const Color(0xFF20A8E8), dark: dark),
                  _TreeStat(label: 'NETWORK DEPTH', value: 'L$_depth', subtitle: 'Maximum depth', icon: LucideIcons.gitBranch, accent: const Color(0xFF13B981), dark: dark),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: dark ? const Color(0xFF2A3A53) : _border, height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('CLIENT HIERARCHY', style: TextStyle(color: dark ? Colors.white : _navy, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .45)),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _expanded = true),
                    icon: const Icon(LucideIcons.maximize2, size: 13),
                    label: const Text('Expand all'),
                    style: _treeSmallButton(dark),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _expanded = false),
                    icon: const Icon(LucideIcons.minimize2, size: 13),
                    label: const Text('Collapse all'),
                    style: _treeSmallButton(dark),
                  ),
                  if (wide) const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _showAllReferralLinks = !_showAllReferralLinks),
                    icon: const Icon(LucideIcons.network, size: 13),
                    label: const Text('Org chart'),
                    style: _treeSmallButton(dark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (rootMatches)
                _TreeMemberCard(
                  member: _ib,
                  dark: dark,
                  root: true,
                  expanded: _expanded,
                  onToggle: () => setState(() => _expanded = !_expanded),
                  showReferralLink: _showAllReferralLinks,
                ),
              if (_expanded && visibleChildren.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: dark ? const Color(0xFF36506F) : const Color(0xFFCAD8E8), width: 1.2)),
                    ),
                    child: Column(
                      children: [
                        for (final member in visibleChildren)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: _TreeMemberCard(
                              member: member,
                              dark: dark,
                              root: false,
                              showReferralLink: _showAllReferralLinks,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              if (!rootMatches && visibleChildren.isEmpty)
                _treeEmpty(dark),
              if (rootMatches && visibleChildren.isEmpty && query.isNotEmpty)
                _treeEmpty(dark),
              const SizedBox(height: 12),
              Divider(color: dark ? const Color(0xFF2A3A53) : _border, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('CLIENTS PER PAGE', style: TextStyle(color: dark ? const Color(0xFFA9B9CE) : _muted, fontSize: 9, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(
                    'Showing ${visibleChildren.length + (rootMatches ? 1 : 0)} of $_networkCount',
                    style: TextStyle(color: dark ? const Color(0xFFA9B9CE) : _muted, fontSize: 10),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _treeHeader(bool dark) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF17243A) : Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: dark ? const Color(0xFF29415F) : _border),
      boxShadow: const [BoxShadow(color: Color(0x080B1D35), blurRadius: 14, offset: Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('IB NETWORK', style: TextStyle(color: _blue, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      const SizedBox(height: 6),
      Text('Client Tree', style: TextStyle(color: dark ? Colors.white : _navy, fontSize: 21, fontWeight: FontWeight.w800, height: 1.1)),
      const SizedBox(height: 5),
      Text('Explore your referral network and client trading accounts.', style: TextStyle(color: dark ? const Color(0xFFA9B9CE) : _muted, fontSize: 11)),
    ]),
  );

  Widget _treeSearch(bool dark) => Container(
    decoration: BoxDecoration(
      color: dark ? const Color(0xFF17243A) : Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: dark ? const Color(0xFF29415F) : _border),
    ),
    child: TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style: TextStyle(color: dark ? Colors.white : _navy, fontSize: 11),
      decoration: InputDecoration(
        hintText: 'Search name, email, referral code, profile or account...',
        hintStyle: TextStyle(color: dark ? const Color(0xFF8FA1BA) : const Color(0xFF9AA9BC), fontSize: 10),
        prefixIcon: const Icon(LucideIcons.search, color: _blue, size: 17),
        suffixIcon: _query.isEmpty ? null : IconButton(
          tooltip: 'Clear search',
          onPressed: () { _searchController.clear(); setState(() => _query = ''); },
          icon: const Icon(LucideIcons.x, size: 16),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    ),
  );

  Widget _treeEmpty(bool dark) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: dark ? const Color(0xFF17243A) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: dark ? const Color(0xFF29415F) : _border)),
    child: Column(children: [
      Icon(LucideIcons.users, color: dark ? const Color(0xFFA9B9CE) : _muted, size: 24),
      const SizedBox(height: 8),
      Text('No matching clients', style: TextStyle(color: dark ? Colors.white : _navy, fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text('Try a different name, email or referral code.', style: TextStyle(color: dark ? const Color(0xFFA9B9CE) : _muted, fontSize: 10)),
    ]),
  );

  ButtonStyle _treeSmallButton(bool dark) => OutlinedButton.styleFrom(
    foregroundColor: dark ? const Color(0xFFE4ECF7) : _navy,
    side: BorderSide(color: dark ? const Color(0xFF36506F) : _border),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    visualDensity: VisualDensity.compact,
  );
}

class _ClientTreeMember {
  const _ClientTreeMember({
    required this.initials,
    required this.name,
    required this.email,
    required this.level,
    required this.accountCount,
    this.phone,
    this.joined,
    this.referralCode,
    this.isPartner = false,
    this.children = const [],
  });

  final String initials;
  final String name;
  final String email;
  final String? phone;
  final String? joined;
  final String? referralCode;
  final int level;
  final int accountCount;
  final bool isPartner;
  final List<_ClientTreeMember> children;
}

class _TreeStat extends StatelessWidget {
  const _TreeStat({required this.label, required this.value, required this.subtitle, required this.icon, required this.accent, required this.dark});
  final String label, value, subtitle;
  final IconData icon;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: dark ? const Color(0xFF17243A) : Colors.white, borderRadius: BorderRadius.circular(13), border: Border.all(color: dark ? const Color(0xFF29415F) : _border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .35))), Icon(icon, color: accent, size: 13)]),
      const Spacer(),
      Text(value, style: TextStyle(color: dark ? Colors.white : _navy, fontSize: 19, fontWeight: FontWeight.w800, height: 1)),
      const SizedBox(height: 5),
      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 8)),
    ]),
  );
}

class _TreeMemberCard extends StatelessWidget {
  const _TreeMemberCard({required this.member, required this.dark, required this.root, required this.showReferralLink, this.expanded = false, this.onToggle});
  final _ClientTreeMember member;
  final bool dark;
  final bool root;
  final bool showReferralLink;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : _navy;
    final muted = dark ? const Color(0xFFA9B9CE) : _muted;
    final border = dark ? const Color(0xFF29415F) : _border;
    final surface = dark ? const Color(0xFF17243A) : Colors.white;
    final accent = root ? const Color(0xFF387BFF) : const Color(0xFF00BFA5);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: root && !dark ? const Color(0xFFEEF4FF) : surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: root ? const Color(0xFF5A8EFF) : border, width: root ? 1.2 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: accent.withValues(alpha: .10), borderRadius: BorderRadius.circular(9), border: Border.all(color: accent.withValues(alpha: .28))), child: Text(member.initials, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w800))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 5, runSpacing: 3, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text(member.name, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
              _TreePill(label: 'L${member.level}', color: root ? const Color(0xFF3B82F6) : const Color(0xFF00A991), dark: dark),
              if (member.isPartner) _TreePill(label: 'Gold', color: _gold, dark: dark),
            ]),
            const SizedBox(height: 4),
            Text(member.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: muted, fontSize: 9)),
            Wrap(spacing: 9, runSpacing: 3, children: [
              if (member.phone != null) Text(member.phone!, style: TextStyle(color: muted, fontSize: 9)),
              if (member.joined != null) Text('Joined ${member.joined}', style: TextStyle(color: muted, fontSize: 9)),
              if (showReferralLink && member.referralCode != null) Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.link, color: _blue, size: 10),
                const SizedBox(width: 3),
                Text(member.referralCode!, style: const TextStyle(color: _blue, fontSize: 8, fontWeight: FontWeight.w700)),
              ]),
            ]),
          ])),
          if (root)
            IconButton(
              tooltip: expanded ? 'Hide team' : 'Show team',
              visualDensity: VisualDensity.compact,
              onPressed: onToggle,
              icon: Icon(expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: muted),
            ),
        ]),
        const SizedBox(height: 9),
        Row(children: [
          if (member.isPartner) _TreePill(label: '${member.children.length} referrals', color: _blue, dark: dark),
          const Spacer(),
          if (member.isPartner) _TreePill(label: 'IB Partner', color: const Color(0xFF00A870), dark: dark),
          const SizedBox(width: 6),
          _TreePill(label: '${member.accountCount} Accounts', color: muted, dark: dark),
        ]),
      ]),
    );
  }
}

class _TreePill extends StatelessWidget {
  const _TreePill({required this.label, required this.color, required this.dark});
  final String label;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: .09), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: .22))),
    child: Text(label, style: TextStyle(color: dark && color == _muted ? const Color(0xFFCFD8E7) : color, fontSize: 8, fontWeight: FontWeight.w700)),
  );
}
