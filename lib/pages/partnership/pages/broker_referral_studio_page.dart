import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_notifications.dart';
import '../../../services/auth_api.dart';
import '../models/partnership_models.dart';
import '../widgets/partnership_theme.dart';
import '../widgets/vtindex_qr_view.dart';

// ============================================================================
// SUB-PAGE: BROKERREFERRALSTUDIOPAGE (REFERRAL & QR STUDIO)
// ============================================================================

class BrokerReferralStudioPage extends StatefulWidget {
  const BrokerReferralStudioPage({super.key});

  @override
  State<BrokerReferralStudioPage> createState() => _BrokerReferralStudioPageState();
}

class _BrokerReferralStudioPageState extends State<BrokerReferralStudioPage> {
  bool _loading = true;
  List<IbReferralLink> _links = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    setState(() => _loading = true);
    try {
      final res = await AuthApi.instance.getIbReferralLinks();
      final rawList = res['referral_links'] ?? (res['links'] is List ? res['links'] : null);
      final parsed = <IbReferralLink>[];
      if (rawList is List && rawList.isNotEmpty) {
        for (var i = 0; i < rawList.length; i++) {
          if (rawList[i] is Map) {
            parsed.add(IbReferralLink.fromJson(rawList[i].cast<String, dynamic>(), index: i));
          }
        }
      } else {
        final legacy = res['referral_link'] ?? res['link'] ?? res['url'];
        if (legacy != null) {
          parsed.add(IbReferralLink(
            profileName: 'Default Referral',
            referralLink: legacy.toString(),
            referralCode: (res['referral_code'] ?? '').toString(),
            isPrimary: true,
          ));
        }
      }
      if (mounted) {
        setState(() {
          _links = parsed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);

    if (!_loading && _links.isEmpty) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: colors.appBarBg,
          foregroundColor: colors.text,
          elevation: 0,
          title: const Text('Referral & QR Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        body: PartnershipBackdrop(
          colors: colors,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shieldAlert, size: 48, color: colors.gold),
                  const SizedBox(height: 16),
                  Text(
                    'IB Approval Required',
                    style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Multi-profile referral links and custom tracking QR codes are available once your Introducing Broker account is approved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.muted, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final link = _links.isNotEmpty && _selectedIndex < _links.length
        ? _links[_selectedIndex]
        : IbReferralLink(profileName: 'Standard', referralLink: 'https://client.vtindex.com/', referralCode: '');
    final url = link.referralLink.isNotEmpty
        ? link.referralLink
        : 'https://client.vtindex.com/?ref=${link.referralCode}';

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Referral & QR Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: PartnershipBackdrop(
        colors: colors,
        child: _loading
            ? Center(child: CircularProgressIndicator(color: colors.blue))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
                children: [
                  // Profile selector
                  Text(
                    'SELECT PARTNER PROFILE',
                    style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedIndex,
                        isExpanded: true,
                        dropdownColor: colors.card,
                        iconEnabledColor: colors.blue,
                        style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800),
                        items: List.generate(_links.length, (i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Text('${_links[i].profileName} (${_links[i].referralCode})'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedIndex = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // QR Card
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, 8)),
                        ],
                      ),
                      child: VtIndexQrView(
                        data: url,
                        size: 210,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(link.profileName, style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: SelectableText(url, style: TextStyle(color: colors.muted, fontSize: 11)),
                  ),
                  const SizedBox(height: 18),
                  // Copy buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Clipboard.setData(ClipboardData(text: url));
                            showAppMessage('Referral link copied!', type: AppFeedbackType.success);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(LucideIcons.copy, size: 14),
                          label: Text('Copy Link', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Clipboard.setData(ClipboardData(text: link.referralCode));
                            showAppMessage('Referral code copied!', type: AppFeedbackType.success);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(LucideIcons.code, size: 14),
                          label: Text('Copy Code', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Social Share
                  Text(
                    'SHARE VIA MESSENGER',
                    style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _socialBtn('WhatsApp', LucideIcons.messageCircle, const Color(0xFF25D366), () async {
                        final uri = Uri.parse(
                          'https://wa.me/?text=${Uri.encodeComponent('Join my VT Index partner network: $url')}',
                        );
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }),
                      _socialBtn('Telegram', LucideIcons.send, const Color(0xFF229ED9), () async {
                        final uri = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(url)}');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }),
                      _socialBtn('Email', LucideIcons.mail, colors.blue, () async {
                        final uri = Uri(scheme: 'mailto', queryParameters: {'subject': 'Join VT Index', 'body': url});
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _socialBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
