import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

export 'package:crm_app/pages/pamm/widgets/pamm_detail_components.dart';
export 'package:crm_app/pages/pamm/widgets/pamm_top_bar.dart';

/// Theme-aware skeleton shimmer wrapper tuned to [PammColors].
class PammSkeletonizer extends StatelessWidget {
  const PammSkeletonizer({
    super.key,
    required this.enabled,
    required this.child,
  });

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final effect = dark
        ? const ShimmerEffect(
            baseColor: Color(0xFF0F1B33),
            highlightColor: Color(0xFF1B2D52),
          )
        : const ShimmerEffect(
            baseColor: Color(0xFFE2E8F0),
            highlightColor: Color(0xFFF8FAFC),
          );
    return Skeletonizer(
      enabled: enabled,
      effect: effect,
      enableSwitchAnimation: true,
      child: child,
    );
  }
}

class PammSnapshotCard extends StatelessWidget {
  const PammSnapshotCard({
    super.key,
    required this.isManagedTab,
    required this.managedCount,
    this.totalEquity,
    this.totalPnl,
  });

  final bool isManagedTab;
  final int managedCount;
  final double? totalEquity;
  final double? totalPnl;

  @override
  Widget build(BuildContext context) {
    final equityText = formatPammMoney(totalEquity ?? 0);
    final pnlValue = totalPnl ?? 0;
    final pnlPrefix = pnlValue >= 0 ? '+' : '-';
    final pnlText = '$pnlPrefix\$${pnlValue.abs().toStringAsFixed(2)}';
    return PammMetricGrid(
      cards: [
        PammMetricCard(
          label: isManagedTab ? 'POOL EQUITY' : 'INVESTED EQUITY',
          value: equityText,
          subtext: 'Combined capital',
          icon: LucideIcons.wallet,
          accent: PammColors.blue,
        ),
        PammMetricCard(
          label: isManagedTab ? 'MANAGED POOLS' : 'NET PROFIT / LOSS',
          value: isManagedTab ? '$managedCount' : pnlText,
          subtext: isManagedTab ? 'Accepting deposits' : 'Active allocations',
          icon: LucideIcons.trendingUp,
          accent: !isManagedTab && pnlValue < 0
              ? PammColors.negative(context)
              : PammColors.positive(context),
        ),
        const PammMetricCard(
          label: 'ALLOCATION',
          value: 'Proportional',
          subtext: 'Execution MT5',
          icon: LucideIcons.activity,
          accent: PammColors.gold,
        ),
      ],
    );
  }
}

class PammMetricGrid extends StatelessWidget {
  const PammMetricGrid({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 510 ? 3 : 2;
          const gap = 8.0;
          final regularWidth =
              (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var index = 0; index < cards.length; index++)
                SizedBox(
                  width: columns == 2 &&
                          cards.length.isOdd &&
                          index == cards.length - 1
                      ? constraints.maxWidth
                      : regularWidth,
                  child: cards[index],
                ),
            ],
          );
        },
      );
}

class PammFeatureBanner extends StatelessWidget {
  const PammFeatureBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String tag;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            PammColors.navy,
            Color(0xFF122C63),
            PammColors.deepBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: dark
              ? PammColors.blue.withValues(alpha: 0.45)
              : PammColors.navy.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: PammColors.navy.withValues(alpha: dark ? 0.45 : 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            Positioned(
              right: -36,
              top: -42,
              child: IgnorePointer(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        PammColors.blue.withValues(alpha: 0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: PammType.heading(
                                    context,
                                    size: 16,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        PammColors.gold.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: PammColors.gold
                                          .withValues(alpha: 0.45),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: PammType.label(
                                      context,
                                      size: 10,
                                      weight: FontWeight.w700,
                                      color: const Color(0xFFFDE68A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: PammType.body(
                                context,
                                size: 12.5,
                                weight: FontWeight.w400,
                                color: const Color(0xFFCBD5E1),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: () {
                        AppHaptics.lightImpact();
                        onAction();
                      },
                      icon: const Icon(LucideIcons.arrowRight, size: 16),
                      label: Text(
                        actionLabel,
                        style: PammType.body(
                          context,
                          size: 13.5,
                          weight: FontWeight.w700,
                          color: PammColors.navy,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: PammColors.navy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PammMetricCard extends StatelessWidget {
  const PammMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: PammDecorations.card(context, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PammType.label(
                    context,
                    size: 10.5,
                    weight: FontWeight.w700,
                    color: muted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: dark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accent.withValues(alpha: dark ? 0.30 : 0.20),
                  ),
                ),
                child: Icon(icon, color: accent, size: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: PammType.figure(
                context,
                size: 18,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PammType.body(
              context,
              size: 11.5,
              weight: FontWeight.w500,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

class PammSearchAndFilters extends StatelessWidget {
  const PammSearchAndFilters({
    super.key,
    required this.controller,
    required this.query,
    required this.hint,
    required this.filters,
    required this.selectedFilter,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onSelectFilter,
  });

  final TextEditingController controller;
  final String query;
  final String hint;
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String> onSelectFilter;

  @override
  Widget build(BuildContext context) {
    final card = PammColors.card(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          style: PammType.body(context, size: 13, color: text),
          decoration: PammDecorations.input(
            context,
            hint: hint,
            prefixIcon: Icon(LucideIcons.search, color: muted, size: 17),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(LucideIcons.x, color: muted, size: 16),
                    onPressed: () {
                      AppHaptics.selectionClick();
                      onClearQuery();
                    },
                  )
                : null,
          ),
        ),
        if (filters.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = filters[i];
                final isSelected = selectedFilter == f;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      AppHaptics.selectionClick();
                      onSelectFilter(f);
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? PammColors.blue : card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected ? PammColors.blue : border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: PammType.body(
                          context,
                          size: 12,
                          weight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : muted,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class PammSectionHeader extends StatelessWidget {
  const PammSectionHeader({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: PammDecorations.card(context, radius: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PammColors.blue, PammColors.deepBlue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PammType.heading(
                context,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: PammType.figure(
                context,
                size: 11.5,
                weight: FontWeight.w600,
                color: muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PammEmptyState extends StatelessWidget {
  const PammEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final muted = PammColors.muted(context);
    final buttonAccent = dark ? const Color(0xFF60A5FA) : PammColors.deepBlue;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
      decoration: PammDecorations.card(context, radius: 16),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: PammColors.subtle(context),
              shape: BoxShape.circle,
              border: Border.all(color: PammColors.border(context)),
            ),
            child: Icon(LucideIcons.searchX, color: muted, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PammType.heading(
              context,
              size: 15,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: PammType.body(
              context,
              size: 12.5,
              weight: FontWeight.w400,
              color: muted,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                AppHaptics.selectionClick();
                onAction!();
              },
              icon: const Icon(LucideIcons.rotateCcw, size: 15),
              label: Text(
                actionLabel!,
                style: PammType.body(
                  context,
                  size: 12.5,
                  weight: FontWeight.w600,
                  color: buttonAccent,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: buttonAccent,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: BorderSide(
                  color: buttonAccent.withValues(alpha: 0.45),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PammErrorState extends StatelessWidget {
  const PammErrorState({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final negative = PammColors.negative(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: PammDecorations.card(
        context,
        radius: 16,
        borderColor: negative.withValues(alpha: 0.35),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: negative.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: negative.withValues(alpha: 0.3)),
            ),
            child: Icon(LucideIcons.circleAlert, color: negative, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PammType.heading(
              context,
              size: 15,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: PammType.body(
              context,
              size: 12.5,
              weight: FontWeight.w400,
              color: muted,
              height: 1.4,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                AppHaptics.lightImpact();
                onRetry!();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                retryLabel,
                style: PammType.body(
                  context,
                  size: 12.5,
                  weight: FontWeight.w600,
                  color: negative,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: negative,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: BorderSide(color: negative.withValues(alpha: 0.45)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PammStatusPill extends StatelessWidget {
  const PammStatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final active = status != 'Closed';
    final color =
        active ? PammColors.positive(context) : PammColors.negative(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        status,
        style: PammType.label(
          context,
          size: 11,
          weight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class PammShareBadge extends StatelessWidget {
  const PammShareBadge({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2B210B) : const Color(0xFFFFF7DF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: dark ? const Color(0xFF785A1A) : const Color(0xFFF5D77F),
        ),
      ),
      child: Text(
        '${value.toStringAsFixed(2)}%',
        style: PammType.figure(
          context,
          size: 11.5,
          weight: FontWeight.w700,
          color: dark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
        ),
      ),
    );
  }
}
