import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_haptics.dart';
import 'partnership_theme.dart';

// ============================================================================
// INTERACTIVE COMMISSION EARNINGS CALCULATOR CARD
// ============================================================================

class EarningsCalculatorCard extends StatefulWidget {
  const EarningsCalculatorCard({
    super.key,
    required this.colors,
  });

  final PartnershipColors colors;

  @override
  State<EarningsCalculatorCard> createState() => _EarningsCalculatorCardState();
}

class _EarningsCalculatorCardState extends State<EarningsCalculatorCard> {
  int _calcTraders = 25;
  int _calcLotsPerTrader = 10;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final directLots = _calcTraders * _calcLotsPerTrader;
    final l1Monthly = directLots * 4.0;
    final l2Lots = (directLots * 0.4).round();
    final l2Monthly = l2Lots * 1.6;
    final l3Lots = (directLots * 0.25).round();
    final l3Monthly = l3Lots * 0.8;
    final totalMonthly = l1Monthly + l2Monthly + l3Monthly;
    final totalAnnual = totalMonthly * 12;

    return PartnershipGlassPanel(
      colors: colors,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.calculator, color: colors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Revenue Calculator',
                      style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Simulate potential earnings across 3 tiers',
                      style: TextStyle(color: colors.muted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Slider 1: Active Traders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Direct Traders', style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_calcTraders Traders', style: TextStyle(color: colors.blue, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.blue,
              thumbColor: colors.blue,
              inactiveTrackColor: colors.border,
              trackHeight: 4,
            ),
            child: Slider(
              value: _calcTraders.toDouble(),
              min: 1,
              max: 150,
              divisions: 149,
              onChanged: (val) {
                final next = val.round();
                if (next != _calcTraders) {
                  AppHaptics.selectionClick();
                  setState(() => _calcTraders = next);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          // Slider 2: Lots per Trader
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Avg Lots / Trader / Month', style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_calcLotsPerTrader Lots', style: TextStyle(color: colors.gold, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.gold,
              thumbColor: colors.gold,
              inactiveTrackColor: colors.border,
              trackHeight: 4,
            ),
            child: Slider(
              value: _calcLotsPerTrader.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: (val) {
                final next = val.round();
                if (next != _calcLotsPerTrader) {
                  AppHaptics.selectionClick();
                  setState(() => _calcLotsPerTrader = next);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          // KPI Results Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.isDark
                    ? const [Color(0xFF0F275A), Color(0xFF0A1C40)]
                    : const [Color(0xFFE8F0FE), Color(0xFFD6E4FC)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Direct Monthly Volume', style: TextStyle(color: colors.muted, fontSize: 12)),
                    Text('$directLots Lots', style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Projected Monthly Revenue', style: TextStyle(color: colors.muted, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${totalMonthly.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Projected Annual', style: TextStyle(color: colors.muted, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${totalAnnual.toStringAsFixed(0)} / yr',
                          style: TextStyle(
                            color: colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tier breakdown chips
          Row(
            children: [
              _calcTierChip(colors, 'L1 Direct (50%)', '\$${l1Monthly.toStringAsFixed(0)}', colors.blue),
              const SizedBox(width: 8),
              _calcTierChip(colors, 'L2 Sub-IB (20%)', '\$${l2Monthly.toStringAsFixed(0)}', colors.gold),
              const SizedBox(width: 8),
              _calcTierChip(colors, 'L3 Extended (10%)', '\$${l3Monthly.toStringAsFixed(0)}', colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcTierChip(PartnershipColors colors, String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.subCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.subBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: colors.muted, fontSize: 9.5, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
