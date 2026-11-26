import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/partnership_models.dart';
import 'partnership_modals.dart';
import 'partnership_theme.dart';

// ============================================================================
// CLIENT ACCOUNTS BOTTOM SHEET MODAL
// ============================================================================

void showClientAccountsModal(
  BuildContext context,
  IbClient client, {
  VoidCallback? onIbChanged,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colors = PartnershipColors.of(sheetContext);
      final theme = getIbLevelTheme(client.level, colors.isDark);
      return SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
          ),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              // Top drag bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.avatarBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.avatarBorder),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        client.initials,
                        style: TextStyle(
                          color: theme.avatarText,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LEVEL ${client.level}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                theme.roleLabel.toUpperCase(),
                                style: TextStyle(
                                  color: colors.muted,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            client.name,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (client.email.isNotEmpty)
                            Text(
                              client.email,
                              style: TextStyle(color: colors.muted, fontSize: 11.5),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: Icon(LucideIcons.x, color: colors.muted, size: 20),
                    ),
                  ],
                ),
              ),
              // Badges row: Client ID, accounts count, IB status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.subCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.subBorder),
                      ),
                      child: Text(
                        'ID: ${client.id}',
                        style: TextStyle(color: colors.muted, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (client.isIb)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.green.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.shieldCheck, color: colors.green, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'IB Partner',
                              style: TextStyle(color: colors.green, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      )
                    else if (client.ibRequestStatus == 'pending')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.clock, color: colors.gold, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'IB Pending',
                              style: TextStyle(color: colors.gold, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          showConfirmIbModal(context, client, onIbChanged: onIbChanged);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(color: colors.blue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: Icon(LucideIcons.userPlus, size: 12, color: colors.blue),
                        label: Text(
                          'Request IB',
                          style: TextStyle(fontSize: 10, color: colors.blue, fontWeight: FontWeight.w800),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 4-stat Portfolio Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _miniKpi(colors, 'Accounts', '${client.accounts.length}', LucideIcons.layers, colors.blue),
                    const SizedBox(width: 8),
                    _miniKpi(colors, 'Volume', '${client.totalLots.toStringAsFixed(2)} Lots', LucideIcons.activity, colors.green),
                    const SizedBox(width: 8),
                    _miniKpi(colors, 'Commission', '\$${client.totalCommission.toStringAsFixed(2)}', LucideIcons.coins, colors.gold),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: colors.border, height: 1),
              // Accounts list
              Expanded(
                child: client.accounts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.creditCard, size: 36, color: colors.muted),
                            const SizedBox(height: 8),
                            Text(
                              'No trading accounts linked',
                              style: TextStyle(color: colors.muted, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: client.accounts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (itemContext, index) {
                          final acc = client.accounts[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.subCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: colors.subBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.creditCard, size: 16, color: colors.blue),
                                          const SizedBox(width: 8),
                                          Text(
                                            acc.accountId,
                                            style: TextStyle(
                                              color: colors.text,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${acc.accountType} · ${acc.groupAlias}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: colors.muted, fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton.tonalIcon(
                                      onPressed: () => showAccountDetailModal(
                                        sheetContext,
                                        acc,
                                        clientName: client.name,
                                      ),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(LucideIcons.arrowUpRight, size: 12),
                                      label: const Text('Positions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _accountStatPill('Volume', '${acc.totalLots.toStringAsFixed(2)} Lots', colors.muted, colors.text),
                                    _accountStatPill('Deposits', '\$${acc.totalDeposits.toStringAsFixed(2)}', colors.muted, colors.green),
                                    _accountStatPill('Commission', '\$${acc.totalCommission.toStringAsFixed(2)}', colors.muted, colors.gold),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _miniKpi(
  PartnershipColors colors,
  String label,
  String value,
  IconData icon,
  Color accent,
) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: colors.subCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.subBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: accent),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: colors.muted, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
}

Widget _accountStatPill(String label, String value, Color labelColor, Color valColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: labelColor, fontSize: 9.5)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: valColor, fontSize: 11.5, fontWeight: FontWeight.w800)),
    ],
  );
}
