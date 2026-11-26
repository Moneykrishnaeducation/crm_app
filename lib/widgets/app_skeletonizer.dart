import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// App-wide theme-aware progressive skeleton shimmer wrapper.
///
/// Wraps structured placeholder layouts while data is loading asynchronously,
/// preventing Cumulative Layout Shift (CLS) and replacing jarring full-page spinners.
class AppSkeletonizer extends StatelessWidget {
  const AppSkeletonizer({
    super.key,
    required this.enabled,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  /// Whether shimmer skeleton placeholders should be active.
  final bool enabled;

  /// The child layout, containing either mock placeholders or live data.
  final Widget child;

  /// Duration of one shimmer sweep cycle.
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effect = isDark
        ? ShimmerEffect(
            baseColor: const Color(0xFF142442),
            highlightColor: const Color(0xFF233B6C),
            duration: duration,
          )
        : ShimmerEffect(
            baseColor: const Color(0xFFE2EBF6),
            highlightColor: const Color(0xFFF4F8FD),
            duration: duration,
          );

    return Skeletonizer(
      enabled: enabled,
      effect: effect,
      enableSwitchAnimation: true,
      child: child,
    );
  }
}
