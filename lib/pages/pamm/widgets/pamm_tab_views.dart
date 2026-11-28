import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_pool_cards.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

abstract class _PammTabPage extends StatelessWidget {
  const _PammTabPage({
    super.key,
    required this.children,
    required this.storageKey,
    this.onRefresh,
  });

  final List<Widget> children;
  final String storageKey;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final listView = ListView.builder(
      key: PageStorageKey<String>(storageKey),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
    if (onRefresh == null) return listView;
    return RefreshIndicator(
      color: PammColors.blue,
      onRefresh: () {
        AppHaptics.selectionClick();
        return onRefresh!();
      },
      child: listView,
    );
  }
}

class PammManagedTabPage extends _PammTabPage {
  const PammManagedTabPage({
    super.key,
    required super.children,
    super.onRefresh,
  }) : super(storageKey: 'pamm-managed-tab');
}

class PammAvailableTabPage extends _PammTabPage {
  const PammAvailableTabPage({
    super.key,
    required super.children,
    super.onRefresh,
  }) : super(storageKey: 'pamm-available-tab');
}

class PammInvestmentsTabPage extends _PammTabPage {
  const PammInvestmentsTabPage({
    super.key,
    required super.children,
    super.onRefresh,
  }) : super(storageKey: 'pamm-investments-tab');
}

class PammManagedTabView extends StatelessWidget {
  const PammManagedTabView({
    super.key,
    required this.managed,
    this.loading = false,
    this.onRefresh,
    required this.query,
    required this.selectedFilter,
    required this.searchController,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onSelectFilter,
    required this.onCreatePool,
    required this.onOpenDetails,
    required this.onDeposit,
  });

  final List<PammPool> managed;
  final bool loading;
  final Future<void> Function()? onRefresh;
  final String query;
  final String selectedFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String> onSelectFilter;
  final VoidCallback onCreatePool;
  final ValueChanged<PammPool> onOpenDetails;
  final ValueChanged<PammPool> onDeposit;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final pools = managed
        .where(
          (pool) =>
              pool.name.toLowerCase().contains(normalizedQuery) ||
              pool.login.toLowerCase().contains(normalizedQuery),
        )
        .toList();
    final showSkeleton = loading && managed.isEmpty;
    final skeletonPools = PammPool.skeletonSamples();
    final metricSource = showSkeleton ? skeletonPools : managed;
    final totalPnl = metricSource.fold<double>(
      0,
      (total, pool) => total + pool.pnl,
    );
    final hasActiveFilters = query.trim().isNotEmpty ||
        (selectedFilter.isNotEmpty && selectedFilter != 'All Pools');

    return PammManagedTabPage(
      onRefresh: onRefresh,
      children: [
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammFeatureBanner(
            icon: LucideIcons.layers,
            title: 'Create PAMM Pool',
            tag: 'PAMM MANAGER',
            subtitle:
                'Set allocation rules, configure profit share and accept investor capital.',
            actionLabel: 'Create PAMM Pool',
            onAction: onCreatePool,
          ),
        ),
        const SizedBox(height: 12),
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammMetricGrid(
            cards: [
              PammMetricCard(
                label: 'MANAGED EQUITY',
                value: formatPammMoney(
                  metricSource.fold<double>(
                    0,
                    (total, pool) => total + pool.equity,
                  ),
                ),
                subtext: 'Combined pool equity',
                icon: LucideIcons.wallet,
                accent: PammColors.blue,
              ),
              PammMetricCard(
                label: 'MANAGED POOLS',
                value: '${metricSource.length}',
                subtext: 'Your active pools',
                icon: LucideIcons.layers,
                accent: PammColors.positive(context),
              ),
              PammMetricCard(
                label: 'PROFIT / LOSS',
                value: formatPammMoney(totalPnl),
                subtext: 'Pool performance',
                icon: LucideIcons.trendingUp,
                accent: totalPnl < 0
                    ? PammColors.negative(context)
                    : PammColors.gold,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammSearchAndFilters(
            controller: searchController,
            query: query,
            hint: 'Search managed pools by name or MT5 login...',
            filters: const ['All Pools'],
            selectedFilter: selectedFilter,
            onQueryChanged: onQueryChanged,
            onClearQuery: onClearQuery,
            onSelectFilter: onSelectFilter,
          ),
        ),
        const SizedBox(height: 12),
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammSectionHeader(
            title: 'Managed PAMM Pools',
            count: showSkeleton ? skeletonPools.length : pools.length,
          ),
        ),
        const SizedBox(height: 10),
        if (showSkeleton)
          IgnorePointer(
            child: PammSkeletonizer(
              enabled: true,
              child: Column(
                children: [
                  for (final pool in skeletonPools) ...[
                    PammPoolCard(
                      pool: pool,
                      managed: true,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          )
        else if (pools.isEmpty)
          PammEmptyState(
            title: 'No Managed Pools Found',
            message: managed.isNotEmpty || hasActiveFilters
                ? 'No managed pools match your current search or filters.'
                : 'Try changing your search or create a new PAMM pool.',
            actionLabel:
                managed.isNotEmpty || hasActiveFilters ? 'Reset filters' : null,
            onAction: managed.isNotEmpty || hasActiveFilters
                ? () {
                    onClearQuery();
                    onSelectFilter('All Pools');
                  }
                : null,
          )
        else
          for (final pool in pools) ...[
            PammPoolCard(
              pool: pool,
              managed: true,
              onDetails: () => onOpenDetails(pool),
              onDeposit: () => onDeposit(pool),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class PammAvailableTabView extends StatelessWidget {
  const PammAvailableTabView({
    super.key,
    required this.available,
    this.loading = false,
    this.onRefresh,
    required this.query,
    required this.selectedFilter,
    required this.searchController,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onSelectFilter,
    required this.onInvest,
  });

  final List<PammPool> available;
  final bool loading;
  final Future<void> Function()? onRefresh;
  final String query;
  final String selectedFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String> onSelectFilter;
  final ValueChanged<PammPool> onInvest;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    var rows = available
        .where(
          (pool) =>
              pool.name.toLowerCase().contains(normalizedQuery) ||
              pool.login.toLowerCase().contains(normalizedQuery),
        )
        .toList();
    // Filter to pools with profit share configured and sort lowest fee first.
    if (selectedFilter == 'Profit Share') {
      rows = rows.where((pool) => pool.share > 0).toList()
        ..sort((a, b) => a.share.compareTo(b.share));
    }

    final showSkeleton = loading && available.isEmpty;
    final skeletonPools = PammPool.skeletonSamples();
    final metricSource = showSkeleton ? skeletonPools : available;
    final totalEquity = metricSource.fold<double>(
      0,
      (value, pool) => value + pool.equity,
    );
    final averageProfitShare = metricSource.isEmpty
        ? '0%'
        : '${(metricSource.fold<double>(0, (value, pool) => value + pool.share) / metricSource.length).toStringAsFixed(1)}%';
    final hasActiveFilters = query.trim().isNotEmpty ||
        (selectedFilter.isNotEmpty && selectedFilter != 'All Pools');

    return PammAvailableTabPage(
      onRefresh: onRefresh,
      children: [
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammMetricGrid(
            cards: [
              PammMetricCard(
                label: 'AVAILABLE POOLS',
                value: '${metricSource.length}',
                subtext: 'Open for investment',
                icon: LucideIcons.layers,
                accent: PammColors.blue,
              ),
              PammMetricCard(
                label: 'TOTAL POOL EQUITY',
                value: formatPammMoney(totalEquity),
                subtext: 'Across listed pools',
                icon: LucideIcons.wallet,
                accent: PammColors.positive(context),
              ),
              PammMetricCard(
                label: 'AVG. PROFIT SHARE',
                value: averageProfitShare,
                subtext: 'Pool allocation',
                icon: LucideIcons.chartNoAxesCombined,
                accent: PammColors.gold,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammSearchAndFilters(
            controller: searchController,
            query: query,
            hint: 'Search available pools by name or MT5 login...',
            filters: const ['All Pools', 'Profit Share'],
            selectedFilter: selectedFilter,
            onQueryChanged: onQueryChanged,
            onClearQuery: onClearQuery,
            onSelectFilter: onSelectFilter,
          ),
        ),
        const SizedBox(height: 12),
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammSectionHeader(
            title: 'Explore Investment Pools',
            count: showSkeleton ? skeletonPools.length : rows.length,
          ),
        ),
        const SizedBox(height: 10),
        if (showSkeleton)
          IgnorePointer(
            child: PammSkeletonizer(
              enabled: true,
              child: Column(
                children: [
                  for (final pool in skeletonPools) ...[
                    PammPoolCard(
                      pool: pool,
                      managed: false,
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          )
        else if (rows.isEmpty)
          PammEmptyState(
            title: 'No Investment Pools Found',
            message: available.isNotEmpty || hasActiveFilters
                ? 'No available pools match your current search or filters.'
                : 'Try another search to discover available pools.',
            actionLabel: available.isNotEmpty || hasActiveFilters
                ? 'Reset filters'
                : null,
            onAction: available.isNotEmpty || hasActiveFilters
                ? () {
                    onClearQuery();
                    onSelectFilter('All Pools');
                  }
                : null,
          )
        else
          for (final pool in rows) ...[
            PammPoolCard(
              pool: pool,
              managed: false,
              onInvest: () => onInvest(pool),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class PammInvestmentsTabView extends StatelessWidget {
  const PammInvestmentsTabView({
    super.key,
    required this.investments,
    this.loading = false,
    this.onRefresh,
    required this.query,
    required this.selectedFilter,
    required this.searchController,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onSelectFilter,
    required this.onOpenDetails,
    required this.onDeposit,
  });

  final List<PammInvestment> investments;
  final bool loading;
  final Future<void> Function()? onRefresh;
  final String query;
  final String selectedFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String> onSelectFilter;
  final ValueChanged<PammInvestment> onOpenDetails;
  final ValueChanged<PammInvestment> onDeposit;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final rows = investments
        .where(
          (investment) =>
              investment.name.toLowerCase().contains(normalizedQuery) ||
              investment.login.toLowerCase().contains(normalizedQuery) ||
              investment.manager.toLowerCase().contains(normalizedQuery),
        )
        .toList();
    final showSkeleton = loading && investments.isEmpty;
    final skeletonInvestments = PammInvestment.skeletonSamples();
    final metricSource = showSkeleton ? skeletonInvestments : investments;

    final invested = metricSource.fold<double>(
      0,
      (total, investment) => total + investment.deposit,
    );
    final value = metricSource.fold<double>(
      0,
      (total, investment) => total + investment.value,
    );
    final pnl = metricSource.fold<double>(
      0,
      (total, investment) => total + investment.pnl,
    );
    final hasActiveFilters = query.trim().isNotEmpty ||
        (selectedFilter.isNotEmpty &&
            selectedFilter != 'All Investments' &&
            selectedFilter != 'All Pools');

    return PammInvestmentsTabPage(
      onRefresh: onRefresh,
      children: [
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammMetricGrid(
            cards: [
              PammMetricCard(
                label: 'INVESTED CAPITAL',
                value: formatPammMoney(invested),
                subtext: 'Initial deposits',
                icon: LucideIcons.wallet,
                accent: PammColors.blue,
              ),
              PammMetricCard(
                label: 'CURRENT VALUE',
                value: formatPammMoney(value),
                subtext: 'Portfolio value',
                icon: LucideIcons.chartNoAxesCombined,
                accent: PammColors.positive(context),
              ),
              PammMetricCard(
                label: 'NET PROFIT / LOSS',
                value: formatPammMoney(pnl),
                subtext: 'Unrealized result',
                icon: LucideIcons.trendingUp,
                accent: pnl < 0
                    ? PammColors.negative(context)
                    : PammColors.gold,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammSearchAndFilters(
            controller: searchController,
            query: query,
            hint: 'Search investments by pool, manager or login...',
            filters: const ['All Investments'],
            selectedFilter: selectedFilter,
            onQueryChanged: onQueryChanged,
            onClearQuery: onClearQuery,
            onSelectFilter: onSelectFilter,
          ),
        ),
        const SizedBox(height: 12),
        PammSkeletonizer(
          enabled: showSkeleton,
          child: PammSectionHeader(
            title: 'My Portfolio Investments',
            count: showSkeleton ? skeletonInvestments.length : rows.length,
          ),
        ),
        const SizedBox(height: 10),
        if (showSkeleton)
          IgnorePointer(
            child: PammSkeletonizer(
              enabled: true,
              child: Column(
                children: [
                  for (final investment in skeletonInvestments) ...[
                    PammInvestmentCard(
                      item: investment,
                      onDetails: () {},
                      onDeposit: () {},
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          )
        else if (rows.isEmpty)
          PammEmptyState(
            title: 'No Investments Found',
            message: investments.isNotEmpty || hasActiveFilters
                ? 'No investments match your current search or filters.'
                : 'Your PAMM investments will appear here.',
            actionLabel: investments.isNotEmpty || hasActiveFilters
                ? 'Reset filters'
                : null,
            onAction: investments.isNotEmpty || hasActiveFilters
                ? () {
                    onClearQuery();
                    onSelectFilter('All Investments');
                  }
                : null,
          )
        else
          for (final investment in rows) ...[
            PammInvestmentCard(
              item: investment,
              onDetails: () => onOpenDetails(investment),
              onDeposit: () => onDeposit(investment),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}
