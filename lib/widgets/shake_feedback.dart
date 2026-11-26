import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../app_haptics.dart';

/// Controller for triggering shake animations and tactile error alerts.
class ShakeController extends ChangeNotifier {
  bool _isError = false;

  /// Whether the controller is currently in an error state.
  bool get isError => _isError;

  /// Triggers a shake animation on attached [ShakeFeedbackWidget]s
  /// and automatically triggers [AppHaptics.heavyImpact].
  void shake({bool triggerHaptics = true}) {
    _isError = true;
    notifyListeners();
    if (triggerHaptics) {
      AppHaptics.heavyImpact();
    }
  }

  /// Clears the error state (e.g. when the user edits the input text).
  void clearError() {
    if (_isError) {
      _isError = false;
      notifyListeners();
    }
  }
}

/// A widget that horizontally shakes its child on invalid form inputs or errors.
///
/// Features:
/// - Smooth 3-cycle damped sine-wave oscillation over 350ms.
/// - Integrated tactile error alert via [AppHaptics.heavyImpact].
/// - Seamless drop-in wrapping for input fields, cards, and modal forms.
class ShakeFeedbackWidget extends StatefulWidget {
  const ShakeFeedbackWidget({
    super.key,
    required this.controller,
    required this.child,
    this.shakeDistance = 7.0,
    this.duration = const Duration(milliseconds: 350),
  });

  /// The controller used to trigger shake animations.
  final ShakeController controller;

  /// The child widget to shake (e.g. input container or card).
  final Widget child;

  /// Maximum horizontal translation distance in pixels.
  final double shakeDistance;

  /// Duration of the complete shake animation.
  final Duration duration;

  @override
  State<ShakeFeedbackWidget> createState() => _ShakeFeedbackWidgetState();
}

class _ShakeFeedbackWidgetState extends State<ShakeFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _offsetAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    widget.controller.addListener(_handleController);
  }

  @override
  void didUpdateWidget(covariant ShakeFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleController);
      widget.controller.addListener(_handleController);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleController);
    _animController.dispose();
    super.dispose();
  }

  void _handleController() {
    if (widget.controller.isError) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        final progress = _offsetAnimation.value;
        // 3-cycle damped sine wave: sin(progress * 6 * pi) * (1 - progress)
        final offset = math.sin(progress * 6.0 * math.pi) * (1.0 - progress) * widget.shakeDistance;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
