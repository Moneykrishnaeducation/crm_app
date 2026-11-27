import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/partnership_models.dart';

// ============================================================================
// CUSTOM VISUAL CHART PAINTERS
// ============================================================================

class CommissionTrajectoryPainter extends CustomPainter {
  CommissionTrajectoryPainter({
    required this.monthsData,
    required this.lineColor,
    required this.isDark,
    this.selectedIndex,
  });

  static final Map<String, TextPainter> _cachedPainters = {};

  final List<Map<String, dynamic>> monthsData;
  final Color lineColor;
  final bool isDark;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (monthsData.isEmpty) return;

    const paddingBottom = 24.0;
    const paddingTop = 14.0;
    final chartHeight = size.height - paddingBottom - paddingTop;
    final chartWidth = size.width;

    double maxVal = 0.0;
    for (final item in monthsData) {
      final val = parseDouble(item['total']);
      if (val > maxVal) maxVal = val;
    }
    if (maxVal <= 0) maxVal = 100.0;
    maxVal *= 1.15; // Give 15% breathing room at the top

    // Grid lines
    final gridPaint = Paint()
      ..color = isDark ? const Color(0x1AFFFFFF) : const Color(0x12000000)
      ..strokeWidth = 1.0;

    const gridSteps = 4;
    for (int i = 0; i <= gridSteps; i++) {
      final y = paddingTop + (chartHeight / gridSteps) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // Points calculation
    final stepX = monthsData.length > 1
        ? chartWidth / (monthsData.length - 1)
        : chartWidth;
    final points = <Offset>[];
    for (int i = 0; i < monthsData.length; i++) {
      final val = parseDouble(monthsData[i]['total']);
      final x = i * stepX;
      final y = paddingTop + chartHeight - ((val / maxVal) * chartHeight);
      points.add(Offset(x, y));
    }

    // Build smooth cubic bezier curve
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Fill gradient under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height - paddingBottom)
      ..lineTo(points.first.dx, size.height - paddingBottom)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, paddingTop),
        Offset(0, size.height - paddingBottom),
        [
          lineColor.withValues(alpha: isDark ? 0.38 : 0.25),
          lineColor.withValues(alpha: 0.01),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw month label texts and dots
    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF88A4C8) : const Color(0xFF64748B),
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
    );

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = selectedIndex == i;

      // Draw dot
      final dotBgPaint = Paint()
        ..color = isDark ? const Color(0xFF071426) : Colors.white;
      final dotPaint = Paint()
        ..color = isSelected ? const Color(0xFFF5C438) : lineColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p, isSelected ? 6.0 : 3.5, dotPaint);
      canvas.drawCircle(p, isSelected ? 3.0 : 1.8, dotBgPaint);

      // Draw label (skip alternate months on very small widths if crowded)
      if (size.width > 340 || i % 2 == 0 || i == points.length - 1) {
        final monthName = monthsData[i]['month']?.toString() ?? '';
        final cacheKey = '$monthName-$isDark';
        final tp = _cachedPainters.putIfAbsent(cacheKey, () {
          return TextPainter(
            text: TextSpan(text: monthName, style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();
        });
        tp.paint(
          canvas,
          Offset(p.dx - tp.width / 2, size.height - paddingBottom + 6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CommissionTrajectoryPainter oldDelegate) =>
      oldDelegate.monthsData != monthsData ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.isDark != isDark ||
      oldDelegate.selectedIndex != selectedIndex;
}
