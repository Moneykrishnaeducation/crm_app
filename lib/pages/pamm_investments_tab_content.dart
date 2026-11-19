part of 'pamm_page.dart';

List<Widget> _buildPammInvestmentsTabContent(_PammPageState state) {
  final query = state._query.toLowerCase();
  final rows = state._investments
      .where(
        (investment) =>
            investment.name.toLowerCase().contains(query) ||
            investment.login.contains(query) ||
            investment.manager.toLowerCase().contains(query),
      )
      .toList();
  final invested = state._investments.fold<double>(
    0,
    (total, investment) => total + investment.deposit,
  );
  final value = state._investments.fold<double>(
    0,
    (total, investment) => total + investment.value,
  );
  final pnl = state._investments.fold<double>(
    0,
    (total, investment) => total + investment.pnl,
  );

  return [
    state._snapshot(),
    const SizedBox(height: 12),
    Row(
      children: [
        Expanded(
          child: state._metricCard(
            'INVESTED CAPITAL',
            state._money(invested),
            'Initial deposits',
            LucideIcons.wallet,
            _PammPageState._blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: state._metricCard(
            'CURRENT VALUE',
            state._money(value),
            'Portfolio value',
            LucideIcons.chartNoAxesCombined,
            _PammPageState._green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: state._metricCard(
            'NET PROFIT / LOSS',
            state._money(pnl),
            'Unrealized result',
            LucideIcons.trendingUp,
            _PammPageState._gold,
          ),
        ),
      ],
    ),
    const SizedBox(height: 14),
    state._buildSearchAndFilters(
      'Search investments by pool, manager or login...',
      ['All Investments'],
    ),
    const SizedBox(height: 12),
    state._sectionHeader('My Portfolio Investments', rows.length),
    const SizedBox(height: 10),
    if (rows.isEmpty)
      state._emptyState(
        'No Investments Found',
        'Your PAMM investments will appear here.',
      )
    else
      for (final investment in rows) ...[
        state._buildInvestmentCard(investment),
        const SizedBox(height: 10),
      ],
  ];
}
