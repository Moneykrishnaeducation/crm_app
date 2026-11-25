import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

export 'package:crm_app/pages/pamm/widgets/pamm_detail_components.dart';
export 'package:crm_app/pages/pamm/widgets/pamm_top_bar.dart';

class PammSnapshotCard extends StatelessWidget {
  const PammSnapshotCard({
    super.key,
    required this.isManagedTab,
    required this.managedCount,
  });

  final bool isManagedTab;
  final int managedCount;

  @override
  Widget build(BuildContext context) {
    return PammMetricGrid(
      cards: [
        PammMetricCard(
          label: isManagedTab ? 'POOL EQUITY' : 'INVESTED EQUITY',
          value: r'$0.00',
          subtext: 'Combined capital',
          icon: LucideIcons.wallet,
          accent: PammColors.blue,
        ),
        PammMetricCard(
          label: isManagedTab ? 'MANAGED POOLS' : 'NET PROFIT / LOSS',
          value: isManagedTab ? '$managedCount' : '+\$0.00',
          subtext: isManagedTab ? 'Accepting deposits' : 'Active allocations',
          icon: LucideIcons.trendingUp,
          accent: PammColors.green,
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
    final card = PammColors.card(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            PammColors.gold.withValues(alpha: dark ? .5 : .65),
            PammColors.blue.withValues(alpha: dark ? .6 : .75),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(17),
          gradient: LinearGradient(
            colors: [
              card,
              dark ? const Color(0xFF0C1D3E) : const Color(0xFFF8FAFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                    gradient: const LinearGradient(
                      colors: [PammColors.blue, PammColors.deepBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: PammColors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: text,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: PammColors.gold.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: PammColors.gold.withValues(alpha: .3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.poppins(
                                color: PammColors.gold,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: muted,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
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
                onPressed: onAction,
                icon: const Icon(LucideIcons.arrowRight, size: 15),
                label: Text(
                  actionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: PammColors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
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
    final card = PammColors.card(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  style: GoogleFonts.poppins(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: accent, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 7),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: TextField(
            controller: controller,
            onChanged: onQueryChanged,
            style: GoogleFonts.poppins(color: text, fontSize: 12.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: muted, fontSize: 11.5),
              prefixIcon: Icon(LucideIcons.search, color: muted, size: 17),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(LucideIcons.x, color: muted, size: 16),
                      onPressed: onClearQuery,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
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
                return InkWell(
                  onTap: () => onSelectFilter(f),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? PammColors.blue : card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? PammColors.blue : border,
                      ),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
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
    final card = PammColors.card(context);
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: GoogleFonts.poppins(
                color: muted,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
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
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final card = PammColors.card(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.searchX, color: muted, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 11),
          ),
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
    final color = active ? PammColors.green : PammColors.closedRose;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PammShareBadge extends StatelessWidget {
  const PammShareBadge({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7DF),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFF5D77F)),
        ),
        child: Text(
          '${value.toStringAsFixed(2)}%',
          style: const TextStyle(
            color: Color(0xFF99620A),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
