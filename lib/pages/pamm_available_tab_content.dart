part of 'pamm_page.dart';

List<Widget> _buildPammAvailableTabContent(_PammPageState state) {
  final query = state._query.toLowerCase();
  final rows = state._available
      .where(
        (pool) =>
            pool.name.toLowerCase().contains(query) ||
            pool.login.contains(query),
      )
      .toList();
  final totalEquity = state._available.fold<double>(
    0,
    (value, pool) => value + pool.equity,
  );
  final averageProfitShare = state._available.isEmpty
      ? '0%'
      : '${(state._available.fold<double>(0, (value, pool) => value + pool.share) / state._available.length).toStringAsFixed(1)}%';

  return [
    const SizedBox(height: 12),
    state._metricGrid([
      state._metricCard(
        'AVAILABLE POOLS',
        '${state._available.length}',
        'Open for investment',
        LucideIcons.layers,
        _PammPageState._blue,
      ),
      state._metricCard(
        'TOTAL POOL EQUITY',
        state._money(totalEquity),
        'Across listed pools',
        LucideIcons.wallet,
        _PammPageState._green,
      ),
      state._metricCard(
        'AVG. PROFIT SHARE',
        averageProfitShare,
        'Pool allocation',
        LucideIcons.chartNoAxesCombined,
        _PammPageState._gold,
      ),
    ]),
    const SizedBox(height: 14),
    state._buildSearchAndFilters(
      'Search available pools by name or MT5 login...',
      ['All Pools', 'Profit Share'],
    ),
    const SizedBox(height: 12),
    state._sectionHeader('Explore Investment Pools', rows.length),
    const SizedBox(height: 10),
    if (rows.isEmpty)
      state._emptyState(
        'No Investment Pools Found',
        'Try another search to discover available pools.',
      )
    else
      for (final pool in rows) ...[
        state._buildPoolCard(pool, managed: false),
        const SizedBox(height: 10),
      ],
  ];
}
