import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PammTopBar extends StatelessWidget {
  const PammTopBar({
    super.key,
    required this.tab,
    required this.managedCount,
    required this.availableCount,
    required this.investmentsCount,
    required this.loading,
    required this.error,
    required this.onSelectTab,
    required this.onRetry,
  });

  final int tab;
  final int managedCount;
  final int availableCount;
  final int investmentsCount;
  final bool loading;
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

    final labels = ['Managed', 'Available', 'Investments'];
    final counts = [managedCount, availableCount, investmentsCount];
    final icons = [
      LucideIcons.briefcaseBusiness,
      LucideIcons.layers,
      LucideIcons.usersRound,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A3A8C), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: PammColors.blue.withValues(alpha: 0.3),
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
                      style: GoogleFonts.poppins(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Percentage Allocation Management Module',
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
              ),
              if (MediaQuery.sizeOf(context).width >= 420)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: PammColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PammColors.blue.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.layers,
                        color: PammColors.blue,
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'PAMM CENTER',
                        style: GoogleFonts.poppins(
                          color: PammColors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
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
                          label:
                              '${labels[i]}, ${counts[i]} ${counts[i] == 1 ? 'item' : 'items'}',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onSelectTab(i),
                              borderRadius: BorderRadius.circular(11),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOutCubic,
                                constraints: BoxConstraints(
                                  minHeight: compact ? 68 : 48,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact ? 2 : 8,
                                  vertical: compact ? 7 : 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: tab == i
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF2563EB),
                                            Color(0xFF1D4ED8),
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
                                                .withValues(alpha: 0.3),
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
                                            color:
                                                tab == i ? Colors.white : muted,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            labels[i],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: tab == i
                                                  ? Colors.white
                                                  : text,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${counts[i]} ${counts[i] == 1 ? 'item' : 'items'}',
                                            style: GoogleFonts.poppins(
                                              color: tab == i
                                                  ? Colors.white
                                                      .withValues(alpha: 0.82)
                                                  : muted,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
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
                                            size: 14,
                                            color:
                                                tab == i ? Colors.white : muted,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              labels[i],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                color: tab == i
                                                    ? Colors.white
                                                    : text,
                                                fontSize: 12.5,
                                                fontWeight: tab == i
                                                    ? FontWeight.w900
                                                    : FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: tab == i
                                                  ? Colors.white
                                                      .withValues(alpha: 0.22)
                                                  : border
                                                      .withValues(alpha: 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${counts[i]}',
                                              style: GoogleFonts.poppins(
                                                color: tab == i
                                                    ? Colors.white
                                                    : muted,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
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
          if (loading) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 2),
          ],
          if (error != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(color: muted, fontSize: 11.5),
                  ),
                ),
                TextButton.icon(
                  onPressed: loading ? null : onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
