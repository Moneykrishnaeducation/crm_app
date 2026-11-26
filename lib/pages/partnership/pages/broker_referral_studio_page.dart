import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_notifications.dart';
import '../../../services/auth_api.dart';
import '../models/partnership_models.dart';
import '../widgets/partnership_modals.dart';
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
      var parsed = IbReferralLink.listFromResponse(res);
      if (parsed.isEmpty) {
        final statsRes = await AuthApi.instance.getIbStats().catchError(
          (_) => <String, dynamic>{},
        );
        parsed = IbReferralLink.listFromResponse(res, statsResponse: statsRes);
      }
      if (mounted) {
        setState(() {
          _links = parsed;
          if (_selectedIndex >= _links.length) _selectedIndex = 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _launchShareUri(Uri uri) async {
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        showAppMessage('Could not open messenger app.', type: AppFeedbackType.error);
      }
    } catch (_) {
      showAppMessage('Could not open messenger app.', type: AppFeedbackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final isEmptyState = !_loading && _links.isEmpty;

    final link = _links.isNotEmpty && _selectedIndex < _links.length
        ? _links[_selectedIndex]
        : IbReferralLink(
            profileName: 'Standard Partner Profile',
            referralLink: 'https://client.vtindex.com/?ref=VT-PARTNER',
            referralCode: _loading ? 'VT-PARTNER' : '',
          );
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
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    AppHaptics.lightImpact();
                    _loadLinks();
                  },
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: PartnershipBackdrop(
        colors: colors,
        child: RefreshIndicator(
          color: colors.blue,
          backgroundColor: colors.card,
          onRefresh: _loadLinks,
          child: isEmptyState
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    AppHaptics.lightImpact();
                                    _loadLinks();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colors.border),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: Icon(LucideIcons.refreshCw, size: 15, color: colors.text),
                                  label: Text(
                                    'Refresh Status',
                                    style: TextStyle(color: colors.text, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
                  children: [
                    PartnershipSkeletonizer(
                      colors: colors,
                      enabled: _loading,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                value: _links.isEmpty ? 0 : _selectedIndex,
                                isExpanded: true,
                                dropdownColor: colors.card,
                                iconEnabledColor: colors.blue,
                                style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800),
                                items: _links.isEmpty
                                    ? [
                                        DropdownMenuItem(
                                          value: 0,
                                          child: Text('${link.profileName} (${link.referralCode})'),
                                        ),
                                      ]
                                    : List.generate(_links.length, (i) {
                                        return DropdownMenuItem(
                                          value: i,
                                          child: Text('${_links[i].profileName} (${_links[i].referralCode})'),
                                        );
                                      }),
                                onChanged: (val) {
                                  if (val != null) {
                                    AppHaptics.selectionClick();
                                    setState(() => _selectedIndex = val);
                                  }
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
                              child: _loading
                                  ? const Bone.square(size: 210)
                                  : VtIndexQrView(
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
                                    AppHaptics.lightImpact();
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
                                  onPressed: link.referralCode.isEmpty
                                      ? null
                                      : () {
                                          AppHaptics.lightImpact();
                                          Clipboard.setData(ClipboardData(text: link.referralCode));
                                          showAppMessage('Referral code copied!', type: AppFeedbackType.success);
                                        },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colors.border),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(LucideIcons.code, size: 14),
                                  label: Text(
                                    'Copy Code',
                                    style: TextStyle(
                                      color: link.referralCode.isEmpty ? colors.muted : colors.text,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: Builder(
                              builder: (shareContext) => FilledButton.icon(
                                onPressed: _loading
                                    ? null
                                    : () => shareReferralLink(
                                          shareContext,
                                          url: url,
                                          profileName: link.profileName,
                                        ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.blue,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(LucideIcons.share2, size: 15),
                                label: const Text(
                                  'Share Link',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Social & System Share
                          Text(
                            'SHARE VIA',
                            style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _socialBtn('WhatsApp', LucideIcons.messageCircle, const Color(0xFF25D366), () {
                                final uri = Uri.parse(
                                  'https://wa.me/?text=${Uri.encodeComponent('Join my VT Index partner network: $url')}',
                                );
                                _launchShareUri(uri);
                              }),
                              _socialBtn('Telegram', LucideIcons.send, const Color(0xFF229ED9), () {
                                final uri = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(url)}');
                                _launchShareUri(uri);
                              }),
                              _socialBtn('Email', LucideIcons.mail, colors.blue, () {
                                final uri = Uri(scheme: 'mailto', queryParameters: {'subject': 'Join VT Index', 'body': url});
                                _launchShareUri(uri);
                              }),
                              Builder(
                                builder: (moreContext) => _socialBtn(
                                  'More',
                                  LucideIcons.share2,
                                  colors.gold,
                                  () => shareReferralLink(
                                    moreContext,
                                    url: url,
                                    profileName: link.profileName,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'ALL REFERRAL LINKS (${_loading ? 2 : _links.length})',
                            style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(_loading ? 2 : _links.length, (i) {
                            final item = _loading
                                ? IbReferralLink.demoList()[i]
                                : _links[i];
                            final selected = !_loading && i == _selectedIndex;
                            final itemUrl = item.effectiveUrl;
                            return InkWell(
                              onTap: _loading
                                  ? null
                                  : () {
                                      AppHaptics.selectionClick();
                                      setState(() => _selectedIndex = i);
                                    },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? colors.blue.withValues(alpha: 0.08)
                                      : colors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: selected ? colors.blue : colors.border,
                                    width: selected ? 1.4 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: item.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  item.profileName,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: colors.text,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              if (item.isPrimary) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: colors.blue.withValues(alpha: 0.14),
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    'PRIMARY',
                                                    style: TextStyle(
                                                      color: colors.blue,
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            itemUrl,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: colors.muted, fontSize: 11),
                                          ),
                                          if (item.referralCode.isNotEmpty || item.clientsCount > 0)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                [
                                                  if (item.referralCode.isNotEmpty) 'Code: ${item.referralCode}',
                                                  if (item.clientsCount > 0) '${item.clientsCount} clients',
                                                ].join(' · '),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: colors.blue,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Builder(
                                          builder: (itemShareContext) => IconButton(
                                            tooltip: 'Share',
                                            onPressed: _loading
                                                ? null
                                                : () => shareReferralLink(
                                                      itemShareContext,
                                                      url: itemUrl,
                                                      profileName: item.profileName,
                                                    ),
                                            padding: const EdgeInsets.all(6),
                                            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                            style: IconButton.styleFrom(
                                              backgroundColor: colors.card,
                                              side: BorderSide(color: colors.border),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: Icon(LucideIcons.share2, size: 12, color: colors.text),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            AppHaptics.lightImpact();
                                            Clipboard.setData(ClipboardData(text: itemUrl));
                                            showAppMessage('Referral link copied!', type: AppFeedbackType.success);
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            side: BorderSide(color: colors.border),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          icon: const Icon(LucideIcons.copy, size: 11),
                                          label: Text('Copy', style: TextStyle(fontSize: 10.5, color: colors.text)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _socialBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        AppHaptics.lightImpact();
        onTap();
      },
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
