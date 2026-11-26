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
  });

  final List<Widget> children;
  final String storageKey;

  @override
  Widget build(BuildContext context) => ListView.builder(
        key: PageStorageKey<String>(storageKey),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
}

class PammManagedTabPage extends _PammTabPage {
  const PammManagedTabPage({super.key, required super.children})
      : super(storageKey: 'pamm-managed-tab');
}

class PammAvailableTabPage extends _PammTabPage {
  const PammAvailableTabPage({super.key, required super.children})
      : super(storageKey: 'pamm-available-tab');
}

class PammInvestmentsTabPage extends _PammTabPage {
  const PammInvestmentsTabPage({super.key, required super.children})
      : super(storageKey: 'pamm-investments-tab');
}

class PammManagedTabView extends StatelessWidget {
  const PammManagedTabView({
    super.key,
    required this.managed,
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
    final normalizedQuery = query.toLowerCase();
    final pools = managed
        .where(
          (pool) =>
              pool.name.toLowerCase().contains(normalizedQuery) ||
              pool.login.contains(normalizedQuery),
        )
        .toList();

    return PammManagedTabPage(
      children: [
        PammFeatureBanner(
          icon: LucideIcons.layers,
          title: 'Create PAMM Pool',
          tag: 'PAMM MANAGER',
          subtitle:
              'Set allocation rules, configure profit share and accept investor capital.',
          actionLabel: 'Create PAMM Pool',
          onAction: onCreatePool,
        ),
        const SizedBox(height: 12),
        PammMetricGrid(
          cards: [
            PammMetricCard(
              label: 'MANAGED EQUITY',
              value: formatPammMoney(
                managed.fold<double>(0, (total, pool) => total + pool.equity),
              ),
              subtext: 'Combined pool equity',
              icon: LucideIcons.wallet,
              accent: PammColors.blue,
            ),
            PammMetricCard(
              label: 'MANAGED POOLS',
              value: '${managed.length}',
              subtext: 'Your active pools',
              icon: LucideIcons.layers,
              accent: PammColors.green,
            ),
            PammMetricCard(
              label: 'PROFIT / LOSS',
              value: formatPammMoney(
                managed.fold<double>(0, (total, pool) => total + pool.pnl),
              ),
              subtext: 'Pool performance',
              icon: LucideIcons.trendingUp,
              accent: PammColors.gold,
            ),
          ],
        ),
        const SizedBox(height: 14),
        PammSearchAndFilters(
          controller: searchController,
          query: query,
          hint: 'Search managed pools by name or MT5 login...',
          filters: const ['All Pools'],
          selectedFilter: selectedFilter,
          onQueryChanged: onQueryChanged,
          onClearQuery: onClearQuery,
          onSelectFilter: onSelectFilter,
        ),
        const SizedBox(height: 12),
        PammSectionHeader(title: 'Managed PAMM Pools', count: pools.length),
        const SizedBox(height: 10),
        if (pools.isEmpty)
          const PammEmptyState(
            title: 'No Managed Pools Found',
            message: 'Try changing your search or create a new PAMM pool.',
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
    required this.query,
    required this.selectedFilter,
    required this.searchController,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onSelectFilter,
    required this.onInvest,
  });

  final List<PammPool> available;
  final String query;
  final String selectedFilter;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String> onSelectFilter;
  final ValueChanged<PammPool> onInvest;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.toLowerCase();
    final rows = available
        .where(
          (pool) =>
              pool.name.toLowerCase().contains(normalizedQuery) ||
              pool.login.contains(normalizedQuery),
        )
        .toList();
    final totalEquity = available.fold<double>(
      0,
      (value, pool) => value + pool.equity,
    );
    final averageProfitShare = available.isEmpty
        ? '0%'
        : '${(available.fold<double>(0, (value, pool) => value + pool.share) / available.length).toStringAsFixed(1)}%';

    return PammAvailableTabPage(
      children: [
        const SizedBox(height: 12),
        PammMetricGrid(
          cards: [
            PammMetricCard(
              label: 'AVAILABLE POOLS',
              value: '${available.length}',
              subtext: 'Open for investment',
              icon: LucideIcons.layers,
              accent: PammColors.blue,
            ),
            PammMetricCard(
              label: 'TOTAL POOL EQUITY',
              value: formatPammMoney(totalEquity),
              subtext: 'Across listed pools',
              icon: LucideIcons.wallet,
              accent: PammColors.green,
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
        const SizedBox(height: 14),
        PammSearchAndFilters(
          controller: searchController,
          query: query,
          hint: 'Search available pools by name or MT5 login...',
          filters: const ['All Pools', 'Profit Share'],
          selectedFilter: selectedFilter,
          onQueryChanged: onQueryChanged,
          onClearQuery: onClearQuery,
          onSelectFilter: onSelectFilter,
        ),
        const SizedBox(height: 12),
        PammSectionHeader(title: 'Explore Investment Pools', count: rows.length),
        const SizedBox(height: 10),
        if (rows.isEmpty)
          const PammEmptyState(
            title: 'No Investment Pools Found',
            message: 'Try another search to discover available pools.',
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
    required this.managedCount,
    required this.isManagedTab,
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
  final int managedCount;
  final bool isManagedTab;
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
    final normalizedQuery = query.toLowerCase();
    final rows = investments
        .where(
          (investment) =>
              investment.name.toLowerCase().contains(normalizedQuery) ||
              investment.login.contains(normalizedQuery) ||
              investment.manager.toLowerCase().contains(normalizedQuery),
        )
        .toList();
    final invested = investments.fold<double>(
      0,
      (total, investment) => total + investment.deposit,
    );
    final value = investments.fold<double>(
      0,
      (total, investment) => total + investment.value,
    );
    final pnl = investments.fold<double>(
      0,
      (total, investment) => total + investment.pnl,
    );

    return PammInvestmentsTabPage(
      children: [
        PammSnapshotCard(
          isManagedTab: isManagedTab,
          managedCount: managedCount,
        ),
        const SizedBox(height: 12),
        PammMetricGrid(
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
              accent: PammColors.green,
            ),
            PammMetricCard(
              label: 'NET PROFIT / LOSS',
              value: formatPammMoney(pnl),
              subtext: 'Unrealized result',
              icon: LucideIcons.trendingUp,
              accent: PammColors.gold,
            ),
          ],
        ),
        const SizedBox(height: 14),
        PammSearchAndFilters(
          controller: searchController,
          query: query,
          hint: 'Search investments by pool, manager or login...',
          filters: const ['All Investments'],
          selectedFilter: selectedFilter,
          onQueryChanged: onQueryChanged,
          onClearQuery: onClearQuery,
          onSelectFilter: onSelectFilter,
        ),
        const SizedBox(height: 12),
        PammSectionHeader(
          title: 'My Portfolio Investments',
          count: rows.length,
        ),
        const SizedBox(height: 10),
        if (rows.isEmpty)
          const PammEmptyState(
            title: 'No Investments Found',
            message: 'Your PAMM investments will appear here.',
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
