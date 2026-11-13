import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

const _partnershipNavy = Color(0xFF06163B);
const _partnershipPanel = Color(0xFF0B2452);
const _partnershipBlue = Color(0xFF0875F5);
const _partnershipGold = Color(0xFFF4C84A);
const _partnershipMuted = Color(0xFFA9B9D5);

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
                  color: _partnershipPanel,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF1455A7)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Referral QR Code', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700))),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(LucideIcons.x, color: _partnershipMuted),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF061A3C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1766C8)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: modalPartnerIndex,
                          isExpanded: true,
                          dropdownColor: _partnershipPanel,
                          iconEnabledColor: _partnershipBlue,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          items: [
                            for (var i = 0; i < _partners.length; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text('${_partners[i].name} - ${_partners[i].code}'),
                              ),
                          ],
                          onChanged: (index) {
                            if (index == null) return;
                            setModalState(() => modalPartnerIndex = index);
                            setState(() => _selectedPartnerIndex = index);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: QrImageView(
                        data: referralUrl,
                        version: QrVersions.auto,
                        size: 210,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(color: Color(0xFF06163B)),
                        dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF06163B)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(partner.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    SelectableText(
                      referralUrl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _partnershipMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        color: _partnershipNavy,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(colors: [Color(0xFF0F3275), Color(0xFF0759C9), Color(0xFF092452)]),
              ),
              child: const Row(children: [Icon(LucideIcons.award, color: _partnershipGold, size: 40), SizedBox(width: 13), Expanded(child: Text('Your Introducing Broker Overview', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)))]),
            ),
            const SizedBox(height: 14),
            const Row(children: [Expanded(child: _PartnershipStat(icon: LucideIcons.usersRound, label: 'Total Clients', value: '2,458', color: Color(0xFF22C6F4))), SizedBox(width: 10), Expanded(child: _PartnershipStat(icon: LucideIcons.coins, label: 'IB Earnings', value: '\$4,820.00', color: _partnershipGold))]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _partnershipPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1455A7))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_selectedPartner.name} - IB Partner Code', style: const TextStyle(color: _partnershipMuted, fontSize: 11)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF061A3C), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1766C8))),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.link, color: Color(0xFF5FCFFF), size: 18),
                        const SizedBox(width: 9),
                        Expanded(child: Text(_selectedPartner.code, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                        IconButton(
                          tooltip: 'Show referral QR code',
                          onPressed: _showReferralQr,
                          icon: const Icon(LucideIcons.qrCode, color: Color(0xFF5FCFFF), size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _showReferralQr, style: FilledButton.styleFrom(backgroundColor: _partnershipGold, foregroundColor: _partnershipNavy), icon: const Icon(LucideIcons.qrCode, size: 17), label: const Text('Show Referral QR'))),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Partner profiles', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(color: _partnershipPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1455A7))),
              child: Column(
                children: [
                  for (var i = 0; i < _partners.length; i++)
                    _PartnerProfileTile(
                      profile: _partners[i],
                      selected: i == _selectedPartnerIndex,
                      onTap: () => setState(() => _selectedPartnerIndex = i),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Quick Shortcuts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const _PartnershipShortcut(icon: LucideIcons.usersRound, label: 'Client List'),
            const SizedBox(height: 8),
            const _PartnershipShortcut(icon: LucideIcons.layers, label: 'Commission History'),
            const SizedBox(height: 8),
            _PartnershipShortcut(icon: LucideIcons.qrCode, label: 'Referral & QR Studio', onTap: _showReferralQr),
            const SizedBox(height: 8),
            const _PartnershipShortcut(icon: LucideIcons.network, label: 'IB Tree / Org Chart'),
          ],
        ),
      );
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
        color: selected ? _partnershipBlue.withValues(alpha: .12) : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Icon(LucideIcons.circle, size: 10, color: selected ? _partnershipBlue : _partnershipMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Text(profile.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)), if (profile.primary) ...[const SizedBox(width: 7), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: _partnershipGold, borderRadius: BorderRadius.circular(4)), child: const Text('Primary', style: TextStyle(color: _partnershipNavy, fontSize: 8, fontWeight: FontWeight.w700)))]]),
                      const SizedBox(height: 3),
                      Text(profile.code, style: const TextStyle(color: _partnershipMuted, fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('\$0', style: TextStyle(color: Color(0xFF00D59A), fontSize: 11, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('${profile.clients} clients', style: const TextStyle(color: _partnershipMuted, fontSize: 9))]),
              ],
            ),
          ),
        ),
      );
}
class _PartnershipStat extends StatelessWidget {
  const _PartnershipStat({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon; final String label, value; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: _partnershipPanel, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF1455A7))), child: Row(children: [Icon(icon, color: color, size: 23), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)), const SizedBox(height: 5), Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))]))]));
}
class _PartnershipShortcut extends StatelessWidget {
  const _PartnershipShortcut({required this.icon, required this.label, this.onTap}); final IconData icon; final String label; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(color: _partnershipPanel, borderRadius: BorderRadius.circular(15), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF1455A7))), child: Row(children: [Icon(icon, color: const Color(0xFF55D5FF)), const SizedBox(width: 12), Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))), const Icon(LucideIcons.chevronRight, color: Colors.white, size: 19)]))));
}

