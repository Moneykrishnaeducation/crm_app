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
        final status = investment != null
            ? 'Active allocation'
            : pool.status == 'Open'
                ? 'Open for investors'
                : 'Closed';
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
              PammDetailRow(label: 'Status', value: status),
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
                value: investment?.joinedOn ?? 'Not joined',
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
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PAMM overview',
                          style: TextStyle(
                            color: text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Review account details, equity and allocations.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PammDetailMetric(
                    title: 'Pool equity',
                    value: formatPammMoney(pool.equity),
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
                      icon: const Icon(Icons.arrow_back, size: 15),
                      label: const Text('Back to investments'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: text,
                        side: BorderSide(color: border),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pool status  ',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
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
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
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
                            value:
                                formatPammMoney(investment?.pnl ?? pool.pnl),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Profit share',
                            value: '${pool.share.toStringAsFixed(2)}%',
                          ),
                        ),
                        const SizedBox(width: 8),
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
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Realized P/L',
                            value:
                                formatPammMoney(investment?.pnl ?? pool.pnl),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Profit share',
                            value: '${pool.share.toStringAsFixed(2)}%',
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
    final card = PammColors.card(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: PammColors.blue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  investment == null ? 'Available PAMM pool' : 'My investment',
                  style: const TextStyle(
                    color: PammColors.blue,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'MT5 login  ${pool.login}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: 'Copy MT5 login',
                onPressed: () => copyPammValue(context, pool.login),
                icon: Icon(Icons.copy_outlined, size: 14, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 5),
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
                      style: TextStyle(
                        color: text,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manager: ${pool.manager}',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Review your allocation, current value and investment performance.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Net current value',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formatPammMoney(investment?.value ?? pool.equity),
                    style: TextStyle(
                      color: text,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'USD',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (investment == null)
                FilledButton.icon(
                  onPressed: status == 'Closed'
                      ? null
                      : () {
                          AppHaptics.lightImpact();
                          onJoin();
                        },
                  icon: const Icon(Icons.trending_up, size: 16),
                  label: const Text('Invest Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else ...[
                FilledButton.icon(
                  onPressed: status == 'Closed'
                      ? null
                      : () {
                          AppHaptics.lightImpact();
                          onDeposit();
                        },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Deposit funds'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    AppHaptics.lightImpact();
                    onWithdraw();
                  },
                  icon: const Icon(Icons.remove, size: 16),
                  label: const Text('Withdraw funds'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: text,
                    side: BorderSide(color: border),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
