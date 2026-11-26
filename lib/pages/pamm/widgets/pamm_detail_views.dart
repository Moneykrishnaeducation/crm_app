import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_detail_components.dart';
import 'package:flutter/material.dart';

export 'package:crm_app/pages/pamm/widgets/pamm_available_detail_view.dart';
export 'package:crm_app/pages/pamm/widgets/pamm_connected_portfolio_view.dart';

class PammPoolAnalyticsCard extends StatelessWidget {
  const PammPoolAnalyticsCard({
    super.key,
    required this.pool,
    required this.onOpenPoolTrades,
  });

  final PammPool pool;
  final VoidCallback onOpenPoolTrades;

  @override
  Widget build(BuildContext context) => PammDetailCard(
        title: 'Analytics and activity',
        subtitle: 'Live MT5 positions for this PAMM account',
        icon: Icons.monitor_heart_outlined,
        child: Column(
          children: [
            PammDetailAction(
              title: 'Open positions',
              subtitle: 'View positions for MT5 login ${pool.login}',
              icon: Icons.bar_chart,
              onTap: onOpenPoolTrades,
            ),
          ],
        ),
      );
}

class PammManagedDetailView extends StatelessWidget {
  const PammManagedDetailView({
    super.key,
    required this.pool,
    required this.togglingPammId,
    required this.syncingPammId,
    required this.onBack,
    required this.onLoadConnectedInvestors,
    required this.onTogglePool,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onSyncEquity,
    required this.onOpenPoolTrades,
  });

  final PammPool pool;
  final String? togglingPammId;
  final String? syncingPammId;
  final VoidCallback onBack;
  final VoidCallback onLoadConnectedInvestors;
  final VoidCallback onTogglePool;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onSyncEquity;
  final VoidCallback onOpenPoolTrades;

  @override
  Widget build(BuildContext context) {
    final text = PammColors.text(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
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
                value: pool.status == 'Open' ? 'Accepting deposits' : 'Closed',
              ),
            ],
          ),
        );

        final management = PammDetailCard(
          title: 'Pool management',
          subtitle: 'Investor access and status',
          icon: Icons.tune,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    AppHaptics.lightImpact();
                    onLoadConnectedInvestors();
                  },
                  icon: const Icon(Icons.people_outline, size: 17),
                  label: const Text('Connected investor list'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: togglingPammId == pool.id
                      ? null
                      : () {
                          AppHaptics.mediumImpact();
                          onTogglePool();
                        },
                  icon: togglingPammId == pool.id
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.show_chart, size: 17),
                  label: Text(
                    togglingPammId == pool.id
                        ? 'Updating pool…'
                        : pool.status == 'Open'
                            ? 'Close investment pool'
                            : 'Open investment pool',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PammColors.closedRose,
                    side: const BorderSide(color: Color(0xFFFFC5CF)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
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
              padding: const EdgeInsets.fromLTRB(8, 0, 14, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      onBack();
                    },
                    tooltip: 'Back to managed pools',
                    icon: Icon(Icons.arrow_back, color: text),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                children: [
                  _ManagedHeroCard(
                    pool: pool,
                    syncing: syncingPammId == pool.id,
                    onDeposit: onDeposit,
                    onWithdraw: onWithdraw,
                    onSyncEquity: onSyncEquity,
                  ),
                  const SizedBox(height: 12),
                  if (wide)
                    Row(
                      children: [
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Total pool equity',
                            value: formatPammMoney(pool.equity),
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
                            title: 'Leverage',
                            value: pool.leverage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Pool status',
                            value: pool.status,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Total pool equity',
                            value: formatPammMoney(pool.equity),
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
                            title: 'Leverage',
                            value: pool.leverage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Pool status',
                            value: pool.status,
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

class _ManagedHeroCard extends StatelessWidget {
  const _ManagedHeroCard({
    required this.pool,
    required this.syncing,
    required this.onDeposit,
    required this.onWithdraw,
    required this.onSyncEquity,
  });

  final PammPool pool;
  final bool syncing;
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onSyncEquity;

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
                child: const Text(
                  'PAMM manager',
                  style: TextStyle(
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
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pool.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: text,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your pool, review equity and monitor investor activity.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
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
                    'Manager balance',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formatPammMoney(pool.managerBalance),
                    style: TextStyle(
                      color: text,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              FilledButton.icon(
                onPressed: pool.status == 'Open'
                    ? () {
                        AppHaptics.lightImpact();
                        onDeposit();
                      }
                    : null,
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
              OutlinedButton.icon(
                onPressed: syncing
                    ? null
                    : () {
                        AppHaptics.mediumImpact();
                        onSyncEquity();
                      },
                icon: syncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync, size: 16),
                label: Text(syncing ? 'Syncing…' : 'Sync MT5'),
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
          ),
        ],
      ),
    );
  }
}
