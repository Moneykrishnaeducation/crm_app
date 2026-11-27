import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../app_haptics.dart';
import '../models/partnership_models.dart';
import 'commission_trajectory_painter.dart';
import 'partnership_theme.dart';

// ============================================================================
// INTERACTIVE COMMISSION TRAJECTORY CHART CARD
// ============================================================================

class TrajectoryChartCard extends StatefulWidget {
  const TrajectoryChartCard({
    super.key,
    required this.colors,
    required this.dashboardData,
    required this.referralLinks,
    this.loading = false,
  });

  final PartnershipColors colors;
  final IbDashboardData dashboardData;
  final List<IbReferralLink> referralLinks;
  final bool loading;

  @override
  State<TrajectoryChartCard> createState() => _TrajectoryChartCardState();
}

class _TrajectoryChartCardState extends State<TrajectoryChartCard> {
  static const List<double> _skeletonBarRatios = [
    0.34,
    0.50,
    0.42,
    0.66,
    0.56,
    0.76,
    0.62,
    0.84,
    0.70,
    0.88,
    0.79,
    0.94,
  ];

  String _chartMode = 'Consolidated'; // 'Consolidated' | 'Multi-Link'
  String _selectedLinkKey = 'all';
  int? _scrubbedMonthIndex;

  String _linkKey(IbReferralLink link) =>
      link.referralCode.isNotEmpty ? link.referralCode : link.profileName;

  bool _matchesSelectedLink(Map<String, dynamic> item, IbReferralLink link) {
    final candidates = [
      item['referral_code'],
      item['code'],
      item['link_code'],
      item['profile_name'],
    ].map((v) => (v ?? '').toString().trim().toLowerCase()).where((s) => s.isNotEmpty);

    final code = link.referralCode.trim().toLowerCase();
    final name = link.profileName.trim().toLowerCase();
    return candidates.any(
      (c) => (code.isNotEmpty && c == code) || (name.isNotEmpty && c == name),
    );
  }

  List<Map<String, dynamic>> _deriveMonthsForLink(IbReferralLink link) {
    final monthlyMap = <String, double>{};
    for (final item in widget.dashboardData.monthlyEarningsPerLink) {
      if (!_matchesSelectedLink(item, link)) continue;
      final nested = item['months'] ?? item['earnings_per_month'] ?? item['data'];
      if (nested is List) {
        for (final sub in nested.whereType<Map>()) {
          final mName = normalizePartnershipMonth(sub['month']);
          if (mName != null) {
            final val = parseDouble(
              sub['total'] ?? sub['earnings'] ?? sub['amount'] ?? sub['commission'],
            );
            monthlyMap[mName] = (monthlyMap[mName] ?? 0.0) + val;
          }
        }
      } else {
        final mName = normalizePartnershipMonth(item['month']);
        if (mName != null) {
          final val = parseDouble(
            item['total'] ?? item['earnings'] ?? item['amount'] ?? item['commission'],
          );
          monthlyMap[mName] = (monthlyMap[mName] ?? 0.0) + val;
        }
      }
    }
    return partnershipMonthNames
        .map((m) => {'month': m, 'total': monthlyMap[m] ?? 0.0})
        .toList();
  }

  int _indexForLocalX(double dx, double width, int count) {
    if (count <= 1 || width <= 0) return 0;
    final localX = dx.clamp(0.0, width);
    final step = width / (count - 1);
    return (localX / step).round().clamp(0, count - 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final IbReferralLink? selectedLink =
        (_chartMode == 'Multi-Link' && _selectedLinkKey != 'all')
            ? widget.referralLinks
                .where((l) => _linkKey(l) == _selectedLinkKey)
                .firstOrNull
            : null;
    final months = selectedLink != null
        ? _deriveMonthsForLink(selectedLink)
        : widget.dashboardData.earningsPerMonth;
    final lineColor = selectedLink?.color ?? colors.blue;

    return PartnershipGlassPanel(
      colors: colors,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Trajectory',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.text, fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedLink != null
                          ? '${selectedLink.profileName} · 12-Month Dynamics'
                          : '12-Month Performance Dynamics',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Mode switcher
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.subCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.subBorder),
                ),
                child: Row(
                  children: [
                    _togglePill(colors, 'Consolidated', _chartMode == 'Consolidated', () {
                      setState(() {
                        _chartMode = 'Consolidated';
                        _scrubbedMonthIndex = null;
                      });
                    }),
                    _togglePill(colors, 'Multi-Link', _chartMode == 'Multi-Link', () {
                      setState(() {
                        _chartMode = 'Multi-Link';
                        _scrubbedMonthIndex = null;
                      });
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Painter Canvas or Skeleton Bars
          if (widget.loading)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_skeletonBarRatios.length, (i) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Skeleton.leaf(
                              child: Container(
                                height: 142 * _skeletonBarRatios[i],
                                decoration: BoxDecoration(
                                  color: colors.subCard,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (_) {
                      return Skeleton.leaf(
                        child: Container(
                          width: 24,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.subCard,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            )
          else
            Builder(
              builder: (chartContext) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    final box = chartContext.findRenderObject() as RenderBox?;
                    if (box != null && months.isNotEmpty) {
                      final index = _indexForLocalX(
                        details.localPosition.dx,
                        box.size.width,
                        months.length,
                      );
                      AppHaptics.selectionClick();
                      setState(() {
                        _scrubbedMonthIndex =
                            _scrubbedMonthIndex == index ? null : index;
                      });
                    }
                  },
                  onPanUpdate: (details) {
                    final box = chartContext.findRenderObject() as RenderBox?;
                    if (box != null && months.length > 1) {
                      final index = _indexForLocalX(
                        details.localPosition.dx,
                        box.size.width,
                        months.length,
                      );
                      if (_scrubbedMonthIndex != index) {
                        AppHaptics.selectionClick();
                        setState(() => _scrubbedMonthIndex = index);
                      }
                    }
                  },
                  onPanEnd: (_) => setState(() => _scrubbedMonthIndex = null),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: CommissionTrajectoryPainter(
                          monthsData: months,
                          lineColor: lineColor,
                          isDark: colors.isDark,
                          selectedIndex: _scrubbedMonthIndex,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          if (!widget.loading &&
              _scrubbedMonthIndex != null &&
              _scrubbedMonthIndex! < months.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(() => _scrubbedMonthIndex = null);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${months[_scrubbedMonthIndex!]['month']}: \$${parseDouble(months[_scrubbedMonthIndex!]['total']).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ),
          // Per link badges in Multi-Link mode
          if (_chartMode == 'Multi-Link' && widget.referralLinks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                InkWell(
                  onTap: () {
                    AppHaptics.selectionClick();
                    setState(() {
                      _selectedLinkKey = 'all';
                      _scrubbedMonthIndex = null;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedLinkKey == 'all'
                          ? colors.blue.withValues(alpha: 0.2)
                          : colors.subCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedLinkKey == 'all' ? colors.blue : colors.subBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: colors.blue, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'All Links',
                          style: TextStyle(color: colors.text, fontSize: 10.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                ...widget.referralLinks.map((link) {
                  final key = _linkKey(link);
                  final isSelected = _selectedLinkKey == key;
                  return InkWell(
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() {
                        _selectedLinkKey = isSelected ? 'all' : key;
                        _scrubbedMonthIndex = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? link.color.withValues(alpha: 0.2) : colors.subCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? link.color : colors.subBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: link.color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(link.profileName, style: TextStyle(color: colors.text, fontSize: 10.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _togglePill(PartnershipColors colors, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : colors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
