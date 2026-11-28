import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PammCardStat extends StatelessWidget {
  const PammCardStat({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PammType.label(
            context,
            size: 10,
            weight: FontWeight.w700,
            color: muted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: PammType.figure(
            context,
            size: 13.5,
            weight: FontWeight.w700,
            color: color ?? text,
          ),
        ),
      ],
    );
  }
}

class PammPoolCard extends StatelessWidget {
  const PammPoolCard({
    super.key,
    required this.pool,
    required this.managed,
    this.onDetails,
    this.onDeposit,
    this.onInvest,
  });

  final PammPool pool;
  final bool managed;
  final VoidCallback? onDetails;
  final VoidCallback? onDeposit;
  final VoidCallback? onInvest;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final subtle = PammColors.subtle(context);
    final isOpen = pool.status != 'Closed';
    final statusColor = isOpen
        ? PammColors.positive(context)
        : (dark ? const Color(0xFFFB7185) : PammColors.closedRose);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PammDecorations.card(context, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: managed
                        ? const [PammColors.navy, PammColors.blue]
                        : const [Color(0xFFB45309), PammColors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: (managed ? PammColors.blue : PammColors.gold)
                          .withValues(alpha: dark ? 0.30 : 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    pool.name.isEmpty ? 'P' : pool.name[0].toUpperCase(),
                    style: PammType.heading(
                      context,
                      size: 17,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pool.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.heading(
                        context,
                        size: 15.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          flex: managed ? 1 : 0,
                          child: Text(
                            'MT5 ${pool.login}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PammType.figure(
                              context,
                              size: 12,
                              weight: FontWeight.w600,
                              color: muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => copyPammValue(context, pool.login),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Icon(
                              Icons.copy_outlined,
                              size: 13,
                              color: muted,
                            ),
                          ),
                        ),
                        if (!managed)
                          Expanded(
                            child: Text(
                              ' • ${pool.manager}',
                              style: PammType.body(
                                context,
                                size: 12,
                                weight: FontWeight.w500,
                                color: muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.32),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOpen ? 'OPEN' : 'CLOSED',
                      style: PammType.label(
                        context,
                        size: 10.5,
                        weight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: subtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PammCardStat(label: 'LEVERAGE', value: pool.leverage),
                ),
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: border,
                ),
                Expanded(
                  child: PammCardStat(
                    label: managed ? 'MANAGER BALANCE' : 'POOL EQUITY',
                    value: formatPammMoney(
                      managed ? pool.managerBalance : pool.equity,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: border,
                ),
                Expanded(
                  child: PammCardStat(
                    label: managed ? 'POOL VALUE' : 'PROFIT SHARE',
                    value: managed
                        ? formatPammMoney(pool.equity)
                        : '${pool.share.toStringAsFixed(2)}%',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  managed
                      ? (isOpen
                          ? 'Managed PAMM Pool'
                          : 'Pool Closed for Deposits')
                      : (isOpen
                          ? 'Open for Investor Allocation'
                          : 'Closed for New Investors'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PammType.body(
                    context,
                    size: 11.5,
                    weight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ),
              if (managed) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDetails == null
                      ? null
                      : () {
                          AppHaptics.lightImpact();
                          onDetails!();
                        },
                  icon: const Icon(LucideIcons.chevronRight, size: 14),
                  label: Text(
                    'Details',
                    style: PammType.body(
                      context,
                      size: 12,
                      weight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: text,
                    side: BorderSide(color: border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 44),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: !isOpen || onDeposit == null
                      ? null
                      : () {
                          AppHaptics.lightImpact();
                          onDeposit!();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text(
                    'Deposit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ] else ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: !isOpen || onInvest == null
                      ? null
                      : () {
                          AppHaptics.lightImpact();
                          onInvest!();
                        },
                  icon: const Icon(LucideIcons.trendingUp, size: 15),
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  label: const Text(
                    'Invest Now',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class PammInvestmentCard extends StatelessWidget {
  const PammInvestmentCard({
    super.key,
    required this.item,
    required this.onDetails,
    required this.onDeposit,
  });

  final PammInvestment item;
  final VoidCallback onDetails;
  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final subtle = PammColors.subtle(context);
    final pnlColor = item.pnl >= 0
        ? PammColors.positive(context)
        : PammColors.negative(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PammDecorations.card(context, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: PammColors.green
                          .withValues(alpha: dark ? 0.30 : 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.walletCards,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.heading(
                        context,
                        size: 15.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MT5 ${item.login}  •  Manager: ${item.manager}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.body(
                        context,
                        size: 12,
                        weight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PammShareBadge(value: item.share),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: subtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: PammCardStat(
                    label: 'CURRENT VALUE',
                    value: formatPammMoney(item.value),
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: border,
                ),
                Expanded(
                  child: PammCardStat(
                    label: 'PROFIT / LOSS',
                    value: formatPammMoney(item.pnl),
                    color: pnlColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: border,
                ),
                Expanded(
                  child: PammCardStat(
                    label: 'INITIAL DEPOSIT',
                    value: formatPammMoney(item.deposit),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Active PAMM Allocation',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PammType.body(
                    context,
                    size: 11.5,
                    weight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  AppHaptics.lightImpact();
                  onDetails();
                },
                icon: const Icon(LucideIcons.chevronRight, size: 14),
                label: Text(
                  'Details',
                  style: PammType.body(
                    context,
                    size: 12,
                    weight: FontWeight.w700,
                    color: text,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: text,
                  side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  AppHaptics.lightImpact();
                  onDeposit();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: PammColors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: const Text(
                  'Deposit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
