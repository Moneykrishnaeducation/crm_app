part of 'pamm_page.dart';

List<Widget> _buildPammManagedTabContent(_PammPageState state) {
  final query = state._query.toLowerCase();
  final pools = state._managed
      .where(
        (pool) =>
            pool.name.toLowerCase().contains(query) ||
            pool.login.contains(query),
      )
      .toList();

  return [
    state._buildCreatePammBanner(),
    const SizedBox(height: 12),
    Row(
      children: [
        Expanded(
          child: state._metricCard(
            'MANAGED EQUITY',
            state._money(
              state._managed.fold<double>(
                0,
                (total, pool) => total + pool.equity,
              ),
            ),
            'Combined pool equity',
            LucideIcons.wallet,
            _PammPageState._blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: state._metricCard(
            'MANAGED POOLS',
            '${state._managed.length}',
            'Your active pools',
            LucideIcons.layers,
            _PammPageState._green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: state._metricCard(
            'PROFIT / LOSS',
            state._money(
              state._managed.fold<double>(0, (total, pool) => total + pool.pnl),
            ),
            'Pool performance',
            LucideIcons.trendingUp,
            _PammPageState._gold,
          ),
        ),
      ],
    ),
    const SizedBox(height: 14),
    state._buildSearchAndFilters(
      'Search managed pools by name or MT5 login...',
      ['All Pools'],
    ),
    const SizedBox(height: 12),
    state._sectionHeader('Managed PAMM Pools', pools.length),
    const SizedBox(height: 10),
    if (pools.isEmpty)
      state._emptyState(
        'No Managed Pools Found',
        'Try changing your search or create a new PAMM pool.',
      )
    else
      for (final pool in pools) ...[
        state._buildPoolCard(pool, managed: true),
        const SizedBox(height: 10),
      ],
  ];
}
