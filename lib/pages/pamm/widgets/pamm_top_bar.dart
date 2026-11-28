import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PammTopBar extends StatelessWidget {
  const PammTopBar({
    super.key,
    required this.tab,
    required this.managedCount,
    required this.availableCount,
    required this.investmentsCount,
    required this.loading,
    this.shimmerTabs,
    required this.error,
    required this.onSelectTab,
    required this.onRetry,
  });

  final int tab;
  final int managedCount;
  final int availableCount;
  final int investmentsCount;
  final bool loading;
  final bool? shimmerTabs;
  final String? error;
  final ValueChanged<int> onSelectTab;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final card = PammColors.card(context);
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final pillAccent = dark ? const Color(0xFF60A5FA) : PammColors.deepBlue;

    const labels = ['Managed', 'Available', 'Investments'];
    const icons = [
      LucideIcons.briefcaseBusiness,
      LucideIcons.layers,
      LucideIcons.usersRound,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      padding: const EdgeInsets.all(14),
      decoration: PammDecorations.card(
        context,
        radius: 20,
        color: surface,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PammColors.navy, PammColors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: PammColors.blue.withValues(alpha: dark ? 0.35 : 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.activity,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAMM Portfolio',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.heading(
                        context,
                        size: 18,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Percentage Allocation Management Module',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.body(
                        context,
                        size: 12,
                        weight: FontWeight.w500,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width >= 420) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: PammColors.blue.withValues(alpha: dark ? 0.16 : 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PammColors.blue.withValues(alpha: dark ? 0.32 : 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.layers,
                        color: pillAccent,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'PAMM CENTER',
                        style: PammType.label(
                          context,
                          size: 10,
                          weight: FontWeight.w700,
                          color: pillAccent,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          PammSkeletonizer(
            enabled: shimmerTabs ?? loading,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 420;
                  return Row(
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: tab == i,
                            label: labels[i],
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  AppHaptics.selectionClick();
                                  onSelectTab(i);
                                },
                                borderRadius: BorderRadius.circular(11),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeInOutCubic,
                                  constraints: const BoxConstraints(
                                    minHeight: 46,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 4 : 10,
                                    vertical: compact ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: tab == i
                                        ? const LinearGradient(
                                            colors: [
                                              PammColors.blue,
                                              PammColors.deepBlue,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(11),
                                    boxShadow: tab == i
                                        ? [
                                            BoxShadow(
                                              color: PammColors.blue
                                                  .withValues(alpha: 0.28),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: compact
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              icons[i],
                                              size: 16,
                                              color: tab == i
                                                  ? Colors.white
                                                  : muted,
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              labels[i],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: PammType.body(
                                                context,
                                                size: 11.5,
                                                weight: tab == i
                                                    ? FontWeight.w700
                                                    : FontWeight.w600,
                                                color: tab == i
                                                    ? Colors.white
                                                    : text,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              icons[i],
                                              size: 15,
                                              color: tab == i
                                                  ? Colors.white
                                                  : muted,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                labels[i],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: PammType.body(
                                                  context,
                                                  size: 13,
                                                  weight: tab == i
                                                      ? FontWeight.w700
                                                      : FontWeight.w600,
                                                  color: tab == i
                                                      ? Colors.white
                                                      : text,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: PammColors.negative(context).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: PammColors.negative(context).withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: 15,
                    color: PammColors.negative(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error!,
                      style: PammType.body(
                        context,
                        size: 12,
                        color: text,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: loading
                        ? null
                        : () {
                            AppHaptics.lightImpact();
                            onRetry();
                          },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: pillAccent,
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
