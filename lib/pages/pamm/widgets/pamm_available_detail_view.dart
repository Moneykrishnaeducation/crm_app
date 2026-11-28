import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_detail_views.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:flutter/material.dart';

class PammAvailableDetailView extends StatelessWidget {
  const PammAvailableDetailView({
    super.key,
    required this.pool,
    required this.investment,
    required this.onBack,
    required this.onJoin,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onOpenPoolTrades,
  });

  final PammPool pool;
  final PammInvestment? investment;
  final VoidCallback onBack;
  final VoidCallback onJoin;
  final ValueChanged<PammInvestment> onDeposit;
  final ValueChanged<PammInvestment> onWithdraw;
  final VoidCallback onOpenPoolTrades;

  @override
  Widget build(BuildContext context) {
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final isPoolClosed = pool.status == 'Closed';
        final status = isPoolClosed
            ? 'Closed'
            : investment != null
                ? 'Active allocation'
                : 'Open for investors';
        final realizedPnl = investment?.pnl ?? pool.pnl;
        final pnlColor = realizedPnl > 0
            ? PammColors.positive(context)
            : realizedPnl < 0
                ? PammColors.negative(context)
                : text;

        final specifications = PammDetailCard(
          title: 'Pool specifications',
          subtitle: 'Account and connection details',
          icon: Icons.dns_outlined,
          child: Column(
            children: [
              PammDetailRow(label: 'Pool display name', value: pool.name),
              PammDetailRow(
                label: 'MT5 login ID',
                value: pool.login,
                copyValue: pool.login,
              ),
              const PammDetailRow(
                label: 'Platform',
                value: 'MetaTrader 5 (MT5)',
              ),
              PammDetailRow(
                label: 'Server',
                value: pool.server,
                copyValue: pool.server,
              ),
              PammDetailRow(label: 'Leverage', value: pool.leverage),
              PammDetailRow(
                label: 'Status',
                value: status,
                valueColor: isPoolClosed
                    ? PammColors.negative(context)
                    : PammColors.positive(context),
              ),
            ],
          ),
        );

        final management = PammDetailCard(
          title: 'Pool management',
          subtitle: 'Manager and allocation details',
          icon: Icons.tune,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PammDetailRow(label: 'Manager', value: pool.manager),
              PammDetailRow(
                label: 'Joined on',
                value: (investment?.joinedOn.trim().isNotEmpty ?? false)
                    ? investment!.joinedOn
                    : 'Not joined',
              ),
              if (investment != null) ...[
                PammDetailRow(
                  label: 'Investor account alias',
                  value: investment!.name,
                ),
                PammDetailRow(
                  label: 'Initial investment',
                  value: formatPammMoney(investment!.deposit),
                ),
              ],
            ],
          ),
        );

        final analytics = PammPoolAnalyticsCard(
          pool: pool,
          onOpenPoolTrades: onOpenPoolTrades,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAMM overview',
                          style: PammType.heading(
                            context,
                            size: 17,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review account details, equity and allocations.',
                          style: PammType.body(
                            context,
                            size: 12,
                            weight: FontWeight.w400,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 118),
                    child: PammDetailMetric(
                      title: 'Pool equity',
                      value: pool.hasPoolDetails
                          ? formatPammMoney(pool.equity)
                          : '—',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        AppHaptics.lightImpact();
                        onBack();
                      },
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Back to investments'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: text,
                        side: BorderSide(color: border),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: PammType.body(
                          context,
                          size: 12.5,
                          weight: FontWeight.w700,
                          color: text,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pool status  ',
                          style: PammType.label(
                            context,
                            size: 11,
                            weight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        PammStatusPill(status: status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                children: [
                  _InvestorHeroCard(
                    pool: pool,
                    investment: investment,
                    status: status,
                    onJoin: onJoin,
                    onDeposit: () {
                      if (investment != null) onDeposit(investment!);
                    },
                    onWithdraw: () {
                      if (investment != null) onWithdraw(investment!);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (wide)
                    Row(
                      children: [
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Realized P/L',
                            value: formatPammMoney(realizedPnl),
                            valueColor: pnlColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Profit share',
                            value: pool.hasPoolDetails
                                ? '${pool.share.toStringAsFixed(2)}%'
                                : '—',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Initial investment',
                            value: formatPammMoney(investment?.deposit ?? 0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Equity share',
                            value:
                                '${(investment?.share ?? 0).toStringAsFixed(2)}%',
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Realized P/L',
                            value: formatPammMoney(realizedPnl),
                            valueColor: pnlColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Profit share',
                            value: pool.hasPoolDetails
                                ? '${pool.share.toStringAsFixed(2)}%'
                                : '—',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Initial investment',
                            value: formatPammMoney(investment?.deposit ?? 0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Equity share',
                            value:
                                '${(investment?.share ?? 0).toStringAsFixed(2)}%',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: specifications),
                        const SizedBox(width: 12),
                        Expanded(child: management),
                        const SizedBox(width: 12),
                        Expanded(child: analytics),
                      ],
                    )
                  else ...[
                    specifications,
                    const SizedBox(height: 10),
                    management,
                    const SizedBox(height: 10),
                    analytics,
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InvestorHeroCard extends StatelessWidget {
  const _InvestorHeroCard({
    required this.pool,
    required this.investment,
    required this.status,
    required this.onJoin,
    required this.onDeposit,
    required this.onWithdraw,
  });

  final PammPool pool;
  final PammInvestment? investment;
  final String status;
  final VoidCallback onJoin;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final subtle = PammColors.subtle(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  PammColors.card(context),
                  const Color(0xFF132242),
                ]
              : [
                  PammColors.card(context),
                  const Color(0xFFF0F6FF),
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: PammColors.blue.withValues(alpha: dark ? 0.35 : 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.28 : 0.04),
            blurRadius: dark ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: PammColors.blue.withValues(alpha: dark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: PammColors.blue.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  investment == null ? 'Available PAMM pool' : 'My investment',
                  style: PammType.label(
                    context,
                    size: 11,
                    weight: FontWeight.w700,
                    color: PammColors.blue,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Tooltip(
                message: 'Copy MT5 login',
                child: Material(
                  color: subtle,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () {
                      AppHaptics.lightImpact();
                      copyPammValue(context, pool.login);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'MT5 ${pool.login}',
                            style: PammType.figure(
                              context,
                              size: 11.5,
                              weight: FontWeight.w600,
                              color: muted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.copy_outlined,
                            size: 13,
                            color: PammColors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investment?.name ?? pool.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.heading(
                        context,
                        size: 21,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Manager: ${pool.manager}',
                      style: PammType.body(
                        context,
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Review your allocation, current value and investment performance.',
                      style: PammType.body(
                        context,
                        size: 12,
                        weight: FontWeight.w400,
                        color: muted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Net current value',
                    style: PammType.label(
                      context,
                      size: 11,
                      weight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatPammMoney(investment?.value ?? pool.equity),
                    style: PammType.figure(
                      context,
                      size: 22,
                      weight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'USD',
                    style: PammType.label(
                      context,
                      size: 10.5,
                      weight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (investment == null)
                FilledButton.icon(
                  onPressed: pool.status == 'Closed'
                      ? null
                      : () {
                          AppHaptics.lightImpact();
                          onJoin();
                        },
                  icon: const Icon(Icons.trending_up, size: 17),
                  label: const Text('Invest Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: PammType.body(
                      context,
                      size: 12.5,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
              else ...[
                FilledButton.icon(
                  onPressed: pool.status == 'Closed'
                      ? null
                      : () {
                          AppHaptics.lightImpact();
                          onDeposit();
                        },
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Deposit funds'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: PammType.body(
                      context,
                      size: 12.5,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    AppHaptics.lightImpact();
                    onWithdraw();
                  },
                  icon: const Icon(Icons.remove, size: 17),
                  label: const Text('Withdraw funds'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: text,
                    side: BorderSide(color: border),
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: PammType.body(
                      context,
                      size: 12.5,
                      weight: FontWeight.w700,
                      color: text,
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
