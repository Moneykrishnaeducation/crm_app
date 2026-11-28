import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
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
    final isOpen = pool.status == 'Open';

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
                value: isOpen ? 'Accepting deposits' : 'Closed',
                valueColor: isOpen
                    ? PammColors.positive(context)
                    : PammColors.negative(context),
              ),
            ],
          ),
        );

        final toggleColor =
            isOpen ? PammColors.closedRose : PammColors.positive(context);

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
                  icon: const Icon(Icons.people_outline, size: 18),
                  label: const Text('Connected investor list'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PammColors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: PammType.body(
                      context,
                      size: 13,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
                      : const Icon(Icons.show_chart, size: 18),
                  label: Text(
                    togglingPammId == pool.id
                        ? 'Updating pool…'
                        : isOpen
                            ? 'Close investment pool'
                            : 'Open investment pool',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: toggleColor,
                    side: BorderSide(
                      color: toggleColor.withValues(alpha: 0.45),
                    ),
                    minimumSize: const Size(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: PammType.body(
                      context,
                      size: 13,
                      weight: FontWeight.w700,
                      color: toggleColor,
                    ),
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
              padding: const EdgeInsets.fromLTRB(8, 4, 14, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      onBack();
                    },
                    tooltip: 'Back to managed pools',
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: Icon(Icons.arrow_back, color: text),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Managed pool details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.heading(
                        context,
                        size: 15.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
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
                        const SizedBox(width: 10),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Profit share',
                            value: '${pool.share.toStringAsFixed(2)}%',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Leverage',
                            value: pool.leverage,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PammDetailMetric(
                            title: 'Pool status',
                            value: pool.status,
                            valueColor: isOpen
                                ? PammColors.positive(context)
                                : PammColors.negative(context),
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
                            valueColor: isOpen
                                ? PammColors.positive(context)
                                : PammColors.negative(context),
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
                  'PAMM manager',
                  style: PammType.label(
                    context,
                    size: 11,
                    weight: FontWeight.w700,
                    color: PammColors.blue,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              PammStatusPill(status: pool.status),
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
                      pool.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.heading(
                        context,
                        size: 22,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Manage your pool, review equity and monitor investor activity.',
                      style: PammType.body(
                        context,
                        size: 12.5,
                        weight: FontWeight.w400,
                        color: muted,
                        height: 1.4,
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
                    'Manager balance',
                    style: PammType.label(
                      context,
                      size: 11,
                      weight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatPammMoney(pool.managerBalance),
                    style: PammType.figure(
                      context,
                      size: 22,
                      weight: FontWeight.w700,
                      color: text,
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
              FilledButton.icon(
                onPressed: pool.status == 'Open'
                    ? () {
                        AppHaptics.lightImpact();
                        onDeposit();
                      }
                    : null,
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
                    : const Icon(Icons.sync, size: 17),
                label: Text(syncing ? 'Syncing…' : 'Sync MT5'),
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
          ),
        ],
      ),
    );
  }
}
