import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_detail_components.dart';
import 'package:flutter/material.dart';

class PammConnectedPortfolioView extends StatelessWidget {
  const PammConnectedPortfolioView({
    super.key,
    required this.pool,
    required this.investors,
    required this.loading,
    required this.error,
    required this.onClose,
    required this.onRetry,
  });

  final PammPool pool;
  final List<PammInvestment> investors;
  final bool loading;
  final String? error;
  final VoidCallback onClose;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final card = PammColors.card(context);
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    final capital = investors.fold<double>(
      0,
      (sum, investment) => sum + investment.deposit,
    );
    final value = investors.fold<double>(
      0,
      (sum, investment) => sum + investment.value,
    );
    final pnl = investors.fold<double>(
      0,
      (sum, investment) => sum + investment.pnl,
    );
    final fees = investors.fold<double>(
      0,
      (sum, investment) => sum + investment.managerProfitShare,
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: border)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: PammColors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Connected investor portfolio',
                  style: TextStyle(
                    color: text,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close portfolio',
                onPressed: onClose,
                icon: Icon(Icons.close, color: muted, size: 19),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: PammColors.blue.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.people_outline,
                            color: PammColors.blue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PAMM MANAGER',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: .8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pool.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: text,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Account ID: ${pool.login} · Investor allocation overview',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        PammPortfolioBadge(
                          label: '${investors.length} investors',
                          color: PammColors.green,
                        ),
                        PammPortfolioBadge(
                          label:
                              '${pool.share.toStringAsFixed(2)}% performance fee',
                          color: PammColors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 4 : 2;
                  const gap = 8.0;
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  final items = [
                    (
                      'Net capital invested',
                      formatPammMoney(capital),
                      Icons.account_balance_wallet_outlined,
                    ),
                    (
                      'Current investor value',
                      formatPammMoney(value),
                      Icons.credit_card_outlined,
                    ),
                    (
                      'Net investor P/L',
                      formatPammMoney(pnl),
                      Icons.trending_up,
                    ),
                    (
                      'Manager fees accrued',
                      formatPammMoney(fees),
                      Icons.verified_user_outlined,
                    ),
                  ];
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: items
                        .map(
                          (item) => SizedBox(
                            width: width,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: border),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.$1,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.$2,
                                          style: TextStyle(
                                            color: text,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(item.$3, size: 16, color: PammColors.blue),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Investor accounts',
                          style: TextStyle(
                            color: text,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Individual balances, allocation, performance and fee breakdown',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Total units: ${investors.length}',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (investors.isEmpty)
                Container(
                  constraints: const BoxConstraints(minHeight: 155),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: PammColors.blue.withValues(alpha: .06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          color: PammColors.blue,
                          size: 21,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No connected investors yet',
                        style: TextStyle(
                          color: text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Investor accounts and their portfolio details will appear here once they join this pool.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: muted,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: investors.length,
                  itemBuilder: (context, index) {
                    final investment = investors[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                investment.name,
                                style: TextStyle(
                                  color: text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Investor account · MT5 ${investment.login}',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 22,
                            runSpacing: 8,
                            children: [
                              PammPoolValue(
                                label: 'Capital invested',
                                value: formatPammMoney(investment.deposit),
                              ),
                              PammPoolValue(
                                label: 'Current value',
                                value: formatPammMoney(investment.value),
                              ),
                              PammPoolValue(
                                label: 'Investor P/L',
                                value: formatPammMoney(investment.pnl),
                              ),
                              PammPoolValue(
                                label: 'Manager fee',
                                value:
                                    formatPammMoney(investment.managerProfitShare),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 9, 16, 10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Values are loaded from the connected investor accounts.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onClose,
                child: const Text('Close portfolio'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
