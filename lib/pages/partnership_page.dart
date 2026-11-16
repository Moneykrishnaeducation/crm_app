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
        const _PartnershipShortcut(icon: LucideIcons.usersRound, label: 'Client list'),
        const SizedBox(height: 8),
        const _PartnershipShortcut(icon: LucideIcons.layers, label: 'Commission history'),
        const SizedBox(height: 8),
        _PartnershipShortcut(icon: LucideIcons.qrCode, label: 'Referral & QR studio', onTap: _showReferralQr),
        const SizedBox(height: 8),
        const _PartnershipShortcut(icon: LucideIcons.network, label: 'IB tree / org chart'),
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
