import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
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
  final Future<void> Function() onRetry;

  Widget _buildInvestorCard(BuildContext context, PammInvestment investment) {
    final dark = PammColors.isDark(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final pnlColor = investment.pnl > 0
        ? PammColors.positive(context)
        : investment.pnl < 0
            ? PammColors.negative(context)
            : text;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: PammDecorations.card(context, radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PammColors.blue.withValues(alpha: dark ? 0.16 : 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: PammColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investment.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.heading(
                        context,
                        size: 13.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Investor account · MT5 ${investment.login}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.body(
                        context,
                        size: 11.5,
                        weight: FontWeight.w400,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (investment.share > 0) ...[
                const SizedBox(width: 8),
                PammPortfolioBadge(
                  label: '${investment.share.toStringAsFixed(1)}% share',
                  color: PammColors.blue,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: border.withValues(alpha: 0.65)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 22,
            runSpacing: 10,
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
                valueColor: pnlColor,
              ),
              PammPoolValue(
                label: 'Manager fee',
                value: formatPammMoney(investment.managerProfitShare),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final showSkeleton = loading && investors.isEmpty;

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
    final skeletonInvestors = PammInvestment.skeletonSamples();
    final netPnlColor = (showSkeleton ? 3270.0 : pnl) > 0
        ? PammColors.positive(context)
        : (showSkeleton ? 3270.0 : pnl) < 0
            ? PammColors.negative(context)
            : text;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 10, 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: border)),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: PammColors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Connected investor portfolio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PammType.heading(
                    context,
                    size: 16,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh investors',
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onPressed: loading
                    ? null
                    : () {
                        AppHaptics.selectionClick();
                        onRetry();
                      },
                icon: Icon(Icons.refresh, color: muted, size: 20),
              ),
              IconButton(
                tooltip: 'Close portfolio',
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                onPressed: () {
                  AppHaptics.lightImpact();
                  onClose();
                },
                icon: Icon(Icons.close, color: muted, size: 20),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: PammColors.blue,
            onRefresh: () {
              AppHaptics.selectionClick();
              return onRetry();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: PammColors.blue.withValues(
                        alpha: dark ? 0.35 : 0.22,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: dark ? 0.25 : 0.04,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: PammColors.blue.withValues(
                                alpha: dark ? 0.18 : 0.10,
                              ),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: PammColors.blue.withValues(alpha: 0.22),
                              ),
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
                                  style: PammType.label(
                                    context,
                                    size: 10.5,
                                    weight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  pool.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PammType.heading(
                                    context,
                                    size: 17,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Account ID: ${pool.login} · Investor allocation overview',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: PammType.body(
                                    context,
                                    size: 11.5,
                                    weight: FontWeight.w400,
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          PammPortfolioBadge(
                            label: '${investors.length} investors',
                            color: PammColors.positive(context),
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
                PammSkeletonizer(
                  enabled: showSkeleton,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 700 ? 4 : 2;
                      const gap = 8.0;
                      final kpiWidth =
                          (constraints.maxWidth - gap * (columns - 1)) /
                              columns;
                      final items = [
                        (
                          'Net capital invested',
                          formatPammMoney(showSkeleton ? 16000.0 : capital),
                          Icons.account_balance_wallet_outlined,
                          text,
                        ),
                        (
                          'Current investor value',
                          formatPammMoney(showSkeleton ? 19270.0 : value),
                          Icons.credit_card_outlined,
                          text,
                        ),
                        (
                          'Net investor P/L',
                          formatPammMoney(showSkeleton ? 3270.0 : pnl),
                          Icons.trending_up,
                          netPnlColor,
                        ),
                        (
                          'Manager fees accrued',
                          formatPammMoney(showSkeleton ? 654.0 : fees),
                          Icons.verified_user_outlined,
                          text,
                        ),
                      ];
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: items
                            .map(
                              (item) => SizedBox(
                                width: kpiWidth,
                                child: Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: PammDecorations.card(
                                    context,
                                    radius: 14,
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
                                              style: PammType.label(
                                                context,
                                                size: 10.5,
                                                weight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            FittedBox(
                                              alignment: Alignment.centerLeft,
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                item.$2,
                                                style: PammType.figure(
                                                  context,
                                                  size: 16.5,
                                                  weight: FontWeight.w700,
                                                  color: item.$4,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: PammColors.blue.withValues(
                                            alpha: dark ? 0.16 : 0.08,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          item.$3,
                                          size: 16,
                                          color: PammColors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
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
                            style: PammType.heading(
                              context,
                              size: 14.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Individual balances, allocation, performance and fee breakdown',
                            style: PammType.body(
                              context,
                              size: 11.5,
                              weight: FontWeight.w400,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total units: ${investors.length}',
                      style: PammType.label(
                        context,
                        size: 11,
                        weight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (showSkeleton)
                  PammSkeletonizer(
                    enabled: true,
                    child: Column(
                      children: [
                        for (final investment in skeletonInvestors)
                          _buildInvestorCard(context, investment),
                      ],
                    ),
                  )
                else if (error != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: PammDecorations.card(context, radius: 14),
                    child: Column(
                      children: [
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: PammType.body(
                            context,
                            size: 12.5,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            AppHaptics.lightImpact();
                            onRetry();
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (investors.isEmpty)
                  Container(
                    constraints: const BoxConstraints(minHeight: 160),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(22),
                    decoration: PammDecorations.card(context, radius: 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: PammColors.blue.withValues(
                              alpha: dark ? 0.16 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.people_outline,
                            color: PammColors.blue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No connected investors yet',
                          style: PammType.heading(
                            context,
                            size: 14,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Investor accounts and their portfolio details will appear here once they join this pool.',
                          textAlign: TextAlign.center,
                          style: PammType.body(
                            context,
                            size: 12,
                            weight: FontWeight.w400,
                            color: muted,
                            height: 1.4,
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
                    itemBuilder: (context, index) =>
                        _buildInvestorCard(context, investors[index]),
                  ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Values are loaded from the connected investor accounts.',
                  style: PammType.body(
                    context,
                    size: 11.5,
                    weight: FontWeight.w400,
                    color: muted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  AppHaptics.lightImpact();
                  onClose();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: text,
                  side: BorderSide(color: border),
                  minimumSize: const Size(0, 44),
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
                child: const Text('Close portfolio'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
