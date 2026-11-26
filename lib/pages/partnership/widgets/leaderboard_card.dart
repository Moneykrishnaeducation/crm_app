import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_notifications.dart';
import '../models/partnership_models.dart';
import 'partnership_modals.dart';
import 'partnership_theme.dart';

// ============================================================================
// RANKED CLIENTS & REFERRAL LINKS LEADERBOARD CARD
// ============================================================================

class LeaderboardCard extends StatefulWidget {
  const LeaderboardCard({
    super.key,
    required this.colors,
    required this.dashboardData,
    required this.referralLinks,
    required this.clientTree,
    required this.onIbChanged,
  });

  final PartnershipColors colors;
  final IbDashboardData dashboardData;
  final List<IbReferralLink> referralLinks;
  final List<IbClient> clientTree;
  final VoidCallback onIbChanged;

  @override
  State<LeaderboardCard> createState() => _LeaderboardCardState();
}

class _LeaderboardCardState extends State<LeaderboardCard> {
  String _leaderboardView = 'Ranked'; // 'Ranked' | 'Links'

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final clients = widget.dashboardData.earningsPerClient;

    return PartnershipGlassPanel(
      colors: colors,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _leaderboardView == 'Ranked' ? 'Top Client Performers' : 'Referral Links Share',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.text, fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.subCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.subBorder),
                ),
                child: Row(
                  children: [
                    _togglePill(colors, 'Ranked', _leaderboardView == 'Ranked', () {
                      setState(() => _leaderboardView = 'Ranked');
                    }),
                    _togglePill(colors, 'Links', _leaderboardView == 'Links', () {
                      setState(() => _leaderboardView = 'Links');
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_leaderboardView == 'Ranked')
            clients.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No client performance records yet',
                        style: TextStyle(color: colors.muted, fontSize: 12),
                      ),
                    ),
                  )
                : Column(
                    children: clients.take(6).map((item) {
                      final rank = clients.indexOf(item) + 1;
                      final name = (item['name'] ?? 'Client').toString();
                      final comm = (item['total_commission'] as num?)?.toDouble() ?? 0.0;
                      final vol = (item['total_volume'] as num?)?.toDouble() ?? 0.0;

                      return InkWell(
                        onTap: () {
                          AppHaptics.selectionClick();
                          final cId = (item['client_id'] ?? '').toString();
                          final matched = widget.clientTree
                              .where((c) => c.id == cId || c.name.toLowerCase() == name.toLowerCase())
                              .firstOrNull;
                          showClientAccountsModal(
                            context,
                            matched ?? IbClient(id: cId, name: name),
                            onIbChanged: widget.onIbChanged,
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.subCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.subBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: rank == 1
                                      ? colors.gold
                                      : (rank == 2
                                          ? const Color(0xFF94A3B8)
                                          : (rank == 3 ? const Color(0xFFB45309) : colors.border)),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '#$rank',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
                                    Text('${vol.toStringAsFixed(2)} Lots', style: TextStyle(color: colors.muted, fontSize: 10.5)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${comm.toStringAsFixed(2)}',
                                    style: TextStyle(color: colors.green, fontSize: 13, fontWeight: FontWeight.w900),
                                  ),
                                  Text('Yield', style: TextStyle(color: colors.muted, fontSize: 9.5)),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Icon(LucideIcons.chevronRight, size: 14, color: colors.muted),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
          else
            widget.referralLinks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No referral links registered',
                        style: TextStyle(color: colors.muted, fontSize: 12),
                      ),
                    ),
                  )
                : Column(
                    children: widget.referralLinks.map((link) {
                      final copyText = link.referralCode.isNotEmpty
                          ? link.referralCode
                          : link.effectiveUrl;
                      final copyLabel = link.referralCode.isNotEmpty
                          ? 'Code ${link.referralCode} copied!'
                          : 'Referral link copied!';
                      return InkWell(
                        onTap: () {
                          AppHaptics.selectionClick();
                          showReferralQrModal(context, link);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.subCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.subBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(color: link.color, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            link.profileName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800),
                                          ),
                                          Text(
                                            link.referralCode.isNotEmpty
                                                ? 'Code: ${link.referralCode}${link.clientsCount > 0 ? ' · ${link.clientsCount} clients' : ''}'
                                                : link.effectiveUrl,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: colors.muted, fontSize: 10.5, fontFamily: 'monospace'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Show QR',
                                    onPressed: () {
                                      AppHaptics.selectionClick();
                                      showReferralQrModal(context, link);
                                    },
                                    padding: const EdgeInsets.all(6),
                                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                    style: IconButton.styleFrom(
                                      backgroundColor: colors.card,
                                      side: BorderSide(color: colors.border),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: Icon(LucideIcons.qrCode, size: 13, color: colors.text),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      AppHaptics.lightImpact();
                                      Clipboard.setData(ClipboardData(text: copyText));
                                      showAppMessage(copyLabel, type: AppFeedbackType.success);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      side: BorderSide(color: colors.border),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(LucideIcons.copy, size: 11),
                                    label: Text(
                                      'Copy',
                                      style: TextStyle(fontSize: 10, color: colors.text),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
        ],
      ),
    );
  }

  Widget _togglePill(PartnershipColors colors, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : colors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
