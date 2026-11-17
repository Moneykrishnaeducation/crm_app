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
        _PartnershipShortcut(
          icon: LucideIcons.layers,
          label: 'Commission history',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const BrokerCommissionHistoryPage(),
            ),
          ),
        ),
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


/// Commission history contains the two views shown in the supplied references.
class BrokerCommissionHistoryPage extends StatefulWidget {
  const BrokerCommissionHistoryPage({super.key});

  @override
  State<BrokerCommissionHistoryPage> createState() => _BrokerCommissionHistoryPageState();
}

class _BrokerCommissionHistoryPageState extends State<BrokerCommissionHistoryPage> {
  int _selectedTab = 0;
  int _ledgerRows = 15;
  String _ledgerSearch = '';
  String _symbolFilter = 'All Symbols (7)';
  String _sort = 'Close Time (Newest First)';
  String _withdrawFilter = 'Pending';

  static const _ledger = <_CommissionLedgerEntry>[
    _CommissionLedgerEntry(name: 'TEST CRN', email: 'crmsupportpro@gmail.com', initials: 'TC', deal: '20922385', order: '678898116', account: '3384', symbol: 'XAUUSD', lots: '0.01', pnl: -96.87, commission: 0.06, close: '5 Nov 2026, 07:08 am'),
    _CommissionLedgerEntry(name: 'TEST CRN', email: 'crmsupportpro@gmail.com', initials: 'TC', deal: '20776912', order: '678886341', account: '3384', symbol: 'EURUSD', lots: '0.01', pnl: -0.35, commission: 0.06, close: '27 Oct 2026, 06:54 pm'),
    _CommissionLedgerEntry(name: 'Lakshminarayanan A', email: 'nanianandane@gmail.com', initials: 'LA', deal: '18338543', order: '227958624', account: '2141717622', symbol: 'XAUUSD.r', lots: '0.01', pnl: 1.65, commission: 0.03, close: '2 Jun 2026, 08:06 pm'),
    _CommissionLedgerEntry(name: 'Lakshminarayanan A', email: 'nanianandane@gmail.com', initials: 'LA', deal: '18338199', order: '226590488', account: '2141717622', symbol: 'XAUUSD.r', lots: '0.01', pnl: 20.88, commission: 0.03, close: '2 Jun 2026, 07:52 pm'),
    _CommissionLedgerEntry(name: 'Lakshminarayanan A', email: 'nanianandane@gmail.com', initials: 'LA', deal: '18338200', order: '227142739', account: '2141717622', symbol: 'XAUUSD.r', lots: '0.01', pnl: 37.90, commission: 0.03, close: '2 Jun 2026, 07:52 pm'),
    _CommissionLedgerEntry(name: 'Lakshminarayanan A', email: 'nanianandane@gmail.com', initials: 'LA', deal: '18331796', order: '227088303', account: '2141717622', symbol: 'XAUUSD.r', lots: '0.01', pnl: 2.30, commission: 0.03, close: '2 Jun 2026, 02:16 pm'),
    _CommissionLedgerEntry(name: 'Lakshminarayanan A', email: 'nanianandane@gmail.com', initials: 'LA', deal: '18331476', order: '226962801', account: '2141717622', symbol: 'XAUUSD.r', lots: '0.01', pnl: 2.48, commission: 0.03, close: '2 Jun 2026, 01:52 pm'),
  ];

  List<_CommissionLedgerEntry> get _filteredLedger {
    final q = _ledgerSearch.trim().toLowerCase();
    return _ledger.where((e) {
      final matchesSearch = q.isEmpty || <String>[e.name, e.email, e.deal, e.order, e.account, e.symbol].any((v) => v.toLowerCase().contains(q));
      final matchesSymbol = _symbolFilter == 'All Symbols (7)' || e.symbol == _symbolFilter;
      return matchesSearch && matchesSymbol;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _partnershipCanvas,
      appBar: AppBar(
        title: const Text('Commission History'),
        leading: IconButton(onPressed: () => Navigator.of(context).maybePop(), icon: const Icon(LucideIcons.arrowLeft)),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return ListView(
          padding: EdgeInsets.fromLTRB(wide ? 24 : 14, 14, wide ? 24 : 14, 28),
          children: [
            _commissionHeader(),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: _partnershipBorder), borderRadius: BorderRadius.circular(13)),
              child: Row(children: [
                Expanded(child: _CommissionTab(label: 'Withdrawal History', selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0))),
                Expanded(child: _CommissionTab(label: 'Commission Ledger', selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1))),
              ]),
            ),
            const SizedBox(height: 12),
            if (_selectedTab == 0) _withdrawalContent(wide) else _ledgerContent(wide),
          ],
        );
      }),
    );
  }

  Widget _commissionHeader() => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: _partnershipBorder), boxShadow: const [BoxShadow(color: Color(0x080B1D35), blurRadius: 14, offset: Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('IB PAYOUTS', style: TextStyle(color: _partnershipGold, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      const SizedBox(height: 6),
      const Text('Commission History', style: TextStyle(color: _partnershipNavy, fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      const Text('Review your commission withdrawal requests and trading commission activity.', style: TextStyle(color: _partnershipMuted, fontSize: 11)),
    ]),
  );

  Widget _withdrawalContent(bool wide) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: _partnershipBorder), boxShadow: const [BoxShadow(color: Color(0x080B1D35), blurRadius: 14, offset: Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 13),
        child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Withdrawal History', style: TextStyle(color: _partnershipNavy, fontSize: 15, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Your recent payout requests and their current status.', style: TextStyle(color: _partnershipMuted, fontSize: 11)),
          ])),
          _CommissionFilterChip(label: 'Pending', selected: _withdrawFilter == 'Pending', onTap: () => setState(() => _withdrawFilter = 'Pending')),
          const SizedBox(width: 5),
          _CommissionFilterChip(label: 'All requests', selected: _withdrawFilter == 'All requests', onTap: () => setState(() => _withdrawFilter = 'All requests')),
        ]),
      ),
      const Divider(height: 1, color: _partnershipBorder),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF7F9FC)),
          headingRowHeight: 39,
          dataRowMinHeight: 46,
          dataRowMaxHeight: 52,
          horizontalMargin: 15,
          columnSpacing: wide ? 34 : 22,
          columns: const [
            DataColumn(label: _CommissionTableHeading('DATE')),
            DataColumn(label: _CommissionTableHeading('ACCOUNT')),
            DataColumn(label: _CommissionTableHeading('REQUEST TYPE')),
            DataColumn(label: _CommissionTableHeading('AMOUNT')),
            DataColumn(label: _CommissionTableHeading('STATUS')),
            DataColumn(label: _CommissionTableHeading('NOTES')),
          ],
          rows: _withdrawFilter == 'Pending' || _withdrawFilter == 'All requests' ? [
            DataRow(cells: [
              const DataCell(_CommissionCell('30/1/2026, 10:30:34 am')),
              const DataCell(_CommissionCell('2141715119', bold: true)),
              DataCell(_CommissionPill('Commission withdrawal', color: _partnershipBlue)),
              const DataCell(_CommissionCell('\$0.01', bold: true)),
              DataCell(_CommissionPill('PENDING', color: const Color(0xFFE8A900), background: const Color(0xFFFFF5D9))),
              const DataCell(_CommissionCell('Commission Withdrawal Request')),
            ]),
          ] : [],
        ),
      ),
      const Divider(height: 1, color: _partnershipBorder),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(children: [
          const Text('ROWS:', style: TextStyle(color: _partnershipMuted, fontSize: 9, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          const _CommissionCell('10'),
          const SizedBox(width: 9),
          const Text('Showing 1–1 of 1', style: TextStyle(color: _partnershipMuted, fontSize: 10)),
          const Spacer(),
          const Text('PAGE 1 OF 1', style: TextStyle(color: _partnershipNavy, fontSize: 9, fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronLeft, color: Color(0xFFB7C1CF), size: 17),
          const SizedBox(width: 8),
          const Icon(LucideIcons.chevronRight, color: _partnershipGold, size: 17),
        ]),
      ),
    ]),
  );

  Widget _ledgerContent(bool wide) {
    final entries = _filteredLedger;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GridView.count(
        crossAxisCount: wide ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: wide ? 2.05 : 1.8,
        children: const [
          _CommissionMetric(label: 'TOTAL EARNINGS', value: '\$197.39', subtitle: 'Calculated IB commission payouts', icon: LucideIcons.trendingUp, accent: Color(0xFF16B98B)),
          _CommissionMetric(label: 'VOLUME TRADED', value: '0.02 L', subtitle: 'Executed standard lots', icon: LucideIcons.activity, accent: Color(0xFF5C9EEB)),
          _CommissionMetric(label: 'LEDGER RECORDS', value: '47', subtitle: 'Closed commission deals', icon: LucideIcons.layers, accent: Color(0xFFB56CE2)),
          _CommissionMetric(label: 'FILTERED SUM', value: '\$1.95', subtitle: '47 matching transactions', icon: LucideIcons.award, accent: Color(0xFFE8AD22)),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _partnershipBorder)),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(13),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              SizedBox(width: wide ? 390 : double.infinity, child: TextField(
                onChanged: (v) => setState(() => _ledgerSearch = v),
                style: const TextStyle(color: _partnershipNavy, fontSize: 11),
                decoration: InputDecoration(
                  hintText: 'Search clients, emails, accounts, deal tickets, or symbols...',
                  hintStyle: const TextStyle(color: Color(0xFF9AA9BC), fontSize: 10),
                  prefixIcon: const Icon(LucideIcons.search, color: _partnershipBlue, size: 17),
                  filled: true, fillColor: const Color(0xFFF7F9FC),
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _partnershipBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _partnershipBorder)),
                ),
              )),
              _CommissionDropdown(value: _symbolFilter, values: const ['All Symbols (7)', 'XAUUSD', 'EURUSD', 'XAUUSD.r'], onChanged: (v) => setState(() => _symbolFilter = v)),
              _CommissionDropdown(value: _sort, values: const ['Close Time (Newest First)', 'Close Time (Oldest First)'], onChanged: (v) => setState(() => _sort = v)),
              _CommissionDropdown(value: 'Show: $_ledgerRows rows', values: const ['Show: 15 rows', 'Show: 25 rows', 'Show: 50 rows'], onChanged: (v) => setState(() => _ledgerRows = int.parse(v.split(' ')[1]))),
            ]),
          ),
          const Divider(height: 1, color: _partnershipBorder),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F4FA)),
              headingRowHeight: 40,
              dataRowMinHeight: 55,
              dataRowMaxHeight: 60,
              horizontalMargin: 14,
              columnSpacing: 23,
              columns: const [
                DataColumn(label: _CommissionTableHeading('CLIENT PROFILE')),
                DataColumn(label: _CommissionTableHeading('DEAL TICKET')),
                DataColumn(label: _CommissionTableHeading('ORDER TICKET')),
                DataColumn(label: _CommissionTableHeading('TRADING ACCOUNT')),
                DataColumn(label: _CommissionTableHeading('SYMBOL')),
                DataColumn(label: _CommissionTableHeading('VOLUME (LOTS)')),
                DataColumn(label: _CommissionTableHeading('CLIENT P/L')),
                DataColumn(label: _CommissionTableHeading('IB COMMISSION')),
                DataColumn(label: _CommissionTableHeading('CLOSE TIME')),
              ],
              rows: [
                for (final e in entries.take(_ledgerRows))
                  DataRow(cells: [
                    DataCell(SizedBox(width: 175, child: Row(children: [
                      Container(width: 31, height: 31, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFDCEAFF), borderRadius: BorderRadius.circular(10)), child: Text(e.initials, style: const TextStyle(color: _partnershipBlue, fontSize: 9, fontWeight: FontWeight.w800))),
                      const SizedBox(width: 8),
                      Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _partnershipNavy, fontSize: 10, fontWeight: FontWeight.w800)),
                        Text(e.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _partnershipMuted, fontSize: 9)),
                      ])),
                    ]))),
                    DataCell(_CommissionCell(e.deal, bold: true)),
                    DataCell(_CommissionCell(e.order, color: const Color(0xFF9AA8BB))),
                    DataCell(_CommissionPill(e.account, color: const Color(0xFF5596DF), background: const Color(0xFFEAF3FF))),
                    DataCell(_CommissionPill(e.symbol, color: _partnershipNavy, background: Colors.white, outlined: true)),
                    DataCell(_CommissionCell('${e.lots} Lots', bold: true)),
                    DataCell(_CommissionCell('${e.pnl < 0 ? '↓' : '↑'} ${e.pnl < 0 ? '-' : ''}\$${e.pnl.abs().toStringAsFixed(2)}', color: e.pnl < 0 ? const Color(0xFFE66C83) : const Color(0xFF16B98B), bold: true)),
                    DataCell(_CommissionCell('+\$${e.commission.toStringAsFixed(2)}', color: const Color(0xFF16B98B), bold: true)),
                    DataCell(_CommissionCell(e.close)),
                  ]),
              ],
            ),
          ),
          const Divider(height: 1, color: _partnershipBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(children: [
              Text('Showing 1–${entries.length} of 47', style: const TextStyle(color: _partnershipMuted, fontSize: 10)),
              const Spacer(),
              const Text('PAGE 1 OF 4', style: TextStyle(color: _partnershipNavy, fontSize: 9, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronLeft, color: Color(0xFFB7C1CF), size: 18),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight, color: _partnershipGold, size: 18),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

class _CommissionLedgerEntry {
  const _CommissionLedgerEntry({required this.name, required this.email, required this.initials, required this.deal, required this.order, required this.account, required this.symbol, required this.lots, required this.pnl, required this.commission, required this.close});
  final String name, email, initials, deal, order, account, symbol, lots, close;
  final double pnl, commission;
}

class _CommissionTab extends StatelessWidget {
  const _CommissionTab({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFF1E4FE0) : Colors.transparent,
    borderRadius: BorderRadius.circular(9),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(9), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Center(child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : _partnershipMuted, fontSize: 11, fontWeight: FontWeight.w800))),
    )),
  );
}

class _CommissionTableHeading extends StatelessWidget {
  const _CommissionTableHeading(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(color: _partnershipMuted, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .2));
}

class _CommissionCell extends StatelessWidget {
  const _CommissionCell(this.value, {this.bold = false, this.color = _partnershipNavy});
  final String value;
  final bool bold;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: bold ? FontWeight.w800 : FontWeight.w500));
}

class _CommissionPill extends StatelessWidget {
  const _CommissionPill(this.label, {required this.color, this.background, this.outlined = false});
  final String label;
  final Color color;
  final Color? background;
  final bool outlined;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: background ?? color.withValues(alpha: .09), borderRadius: BorderRadius.circular(8), border: outlined ? Border.all(color: const Color(0xFF7B8798)) : null),
    child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
  );
}

class _CommissionMetric extends StatelessWidget {
  const _CommissionMetric({required this.label, required this.value, required this.subtitle, required this.icon, required this.accent});
  final String label, value, subtitle;
  final IconData icon, accent;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _partnershipBorder)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(label, style: const TextStyle(color: _partnershipMuted, fontSize: 8, fontWeight: FontWeight.w800))), Icon(icon, color: accent, size: 16)]),
      const Spacer(),
      Text(value, style: TextStyle(color: accent, fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _partnershipMuted, fontSize: 8)),
    ]),
  );
}

class _CommissionFilterChip extends StatelessWidget {
  const _CommissionFilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
    decoration: BoxDecoration(color: selected ? const Color(0xFF1E4FE0) : Colors.white, border: Border.all(color: selected ? const Color(0xFF1E4FE0) : _partnershipBorder), borderRadius: BorderRadius.circular(8)),
    child: Text(label.toUpperCase(), style: TextStyle(color: selected ? Colors.white : _partnershipMuted, fontSize: 8, fontWeight: FontWeight.w800)),
  ));
}

class _CommissionDropdown extends StatelessWidget {
  const _CommissionDropdown({required this.value, required this.values, required this.onChanged});
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: const Color(0xFFF7F9FC), border: Border.all(color: _partnershipBorder), borderRadius: BorderRadius.circular(10)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, isDense: true, icon: const Icon(LucideIcons.chevronDown, size: 14, color: _partnershipMuted),
      style: const TextStyle(color: _partnershipNavy, fontSize: 9, fontWeight: FontWeight.w700),
      items: [for (final item in values) DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))],
      onChanged: (v) { if (v != null) onChanged(v); },
    )),
  );
}
