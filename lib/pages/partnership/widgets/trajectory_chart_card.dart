import 'package:flutter/material.dart';

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
  });

  final PartnershipColors colors;
  final IbDashboardData dashboardData;
  final List<IbReferralLink> referralLinks;

  @override
  State<TrajectoryChartCard> createState() => _TrajectoryChartCardState();
}

class _TrajectoryChartCardState extends State<TrajectoryChartCard> {
  String _chartMode = 'Consolidated'; // 'Consolidated' | 'Multi-Link'
  String _selectedLinkKey = 'all';
  int? _scrubbedMonthIndex;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final months = widget.dashboardData.earningsPerMonth;

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
                      '12-Month Performance Dynamics',
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
                      setState(() => _chartMode = 'Consolidated');
                    }),
                    _togglePill(colors, 'Multi-Link', _chartMode == 'Multi-Link', () {
                      setState(() => _chartMode = 'Multi-Link');
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Painter Canvas
          Builder(
            builder: (chartContext) {
              return GestureDetector(
                onPanUpdate: (details) {
                  final box = chartContext.findRenderObject() as RenderBox?;
                  if (box != null && months.length > 1) {
                    final localX = details.localPosition.dx.clamp(0.0, box.size.width);
                    final step = box.size.width / (months.length - 1);
                    final index = (localX / step).round().clamp(0, months.length - 1);
                    setState(() => _scrubbedMonthIndex = index);
                  }
                },
                onPanEnd: (_) => setState(() => _scrubbedMonthIndex = null),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: CommissionTrajectoryPainter(
                      monthsData: months,
                      lineColor: colors.blue,
                      isDark: colors.isDark,
                      selectedIndex: _scrubbedMonthIndex,
                    ),
                  ),
                ),
              );
            },
          ),
          if (_scrubbedMonthIndex != null && _scrubbedMonthIndex! < months.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${months[_scrubbedMonthIndex!]['month']}: \$${((months[_scrubbedMonthIndex!]['total'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
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
              children: widget.referralLinks.map((link) {
                final isSelected = _selectedLinkKey == link.referralCode;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLinkKey = isSelected ? 'all' : link.referralCode;
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
              }).toList(),
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
