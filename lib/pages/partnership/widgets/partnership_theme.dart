import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// ============================================================================
// DESIGN TOKENS & STYLING
// ============================================================================

class PartnershipColors {
  const PartnershipColors({
    required this.isDark,
    required this.canvas,
    required this.card,
    required this.subCard,
    required this.border,
    required this.subBorder,
    required this.text,
    required this.muted,
    required this.navy,
    required this.blue,
    required this.gold,
    required this.green,
    required this.red,
    required this.cardShadow,
    required this.inputBg,
    required this.chipBg,
    required this.appBarBg,
  });

  final bool isDark;
  final Color canvas;
  final Color card;
  final Color subCard;
  final Color border;
  final Color subBorder;
  final Color text;
  final Color muted;
  final Color navy;
  final Color blue;
  final Color gold;
  final Color green;
  final Color red;
  final Color cardShadow;
  final Color inputBg;
  final Color chipBg;
  final Color appBarBg;

  factory PartnershipColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PartnershipColors(
      isDark: isDark,
      canvas: Theme.of(context).scaffoldBackgroundColor,
      card: isDark ? const Color(0xFF0F2148) : Colors.white,
      subCard: isDark ? const Color(0xFF0A1838) : const Color(0xFFF6F9FF),
      border: isDark ? const Color(0xFF1E3F8A) : const Color(0xFFDCE5F2),
      subBorder: isDark ? const Color(0xFF193268) : const Color(0xFFE2E8F0),
      text: isDark ? Colors.white : const Color(0xFF091836),
      muted: isDark ? const Color(0xFF90A8CC) : const Color(0xFF576A88),
      navy: isDark ? const Color(0xFF071A57) : const Color(0xFF10264B),
      blue: const Color(0xFF2563EB),
      gold: const Color(0xFFF5C438),
      green: const Color(0xFF10B981),
      red: const Color(0xFFEF4444),
      cardShadow: isDark ? const Color(0x33000000) : const Color(0x0A0B1D35),
      inputBg: isDark ? const Color(0xFF0A1838) : const Color(0xFFF3F6FB),
      chipBg: isDark ? const Color(0xFF102758) : const Color(0xFFEBF2FD),
      appBarBg: isDark ? const Color(0xFF071426) : Colors.white,
    );
  }

  Color get glassFill =>
      isDark ? const Color(0xCC071A57) : const Color(0xEBFFFFFF);
  Color get glassBorder =>
      isDark ? const Color(0x66214FBF) : const Color(0xBBDCE5F2);
  Color get accentGlow =>
      isDark ? const Color(0xFF173B8A) : const Color(0xFFD6E8FF);
}

class PartnershipBackdrop extends StatelessWidget {
  const PartnershipBackdrop({
    super.key,
    required this.colors,
    required this.child,
  });

  final PartnershipColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors.isDark
                      ? const [Color(0xFF040D1E), Color(0xFF071630)]
                      : const [Color(0xFFF7FAFF), Color(0xFFEDF3FD)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -160,
            right: -100,
            child: _ambientOrb(colors.accentGlow),
          ),
          Positioned(
            bottom: 60,
            left: -180,
            child: _ambientOrb(colors.blue.withValues(alpha: .14)),
          ),
          child,
        ],
      );

  Widget _ambientOrb(Color color) => Container(
        width: 380,
        height: 380,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: .5), color.withValues(alpha: 0)],
          ),
        ),
      );
}

class PartnershipGlassPanel extends StatelessWidget {
  const PartnershipGlassPanel({
    super.key,
    required this.colors,
    required this.child,
    this.padding,
    this.radius = 20,
    this.onTap,
  });

  final PartnershipColors colors;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colors.glassFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: colors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }
    return content;
  }
}
