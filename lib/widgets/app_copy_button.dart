import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../app_notifications.dart';

/// Interactive copy button with animated sensory confirmation.
///
/// Features:
/// - Tactile confirmation using [AppHaptics.lightImpact].
/// - Instant visual transformation: transitions from [defaultIcon] to
///   [LucideIcons.check] in vibrant emerald (`#10B981`) for 1500ms.
/// - Dynamic label change to "Copied!" when rendered as a text/outlined button.
/// - Dynamic tooltip indicating copy status.
/// - Integrated [showAppMessage] success banner notification.
class AppCopyButton extends StatefulWidget {
  const AppCopyButton({
    super.key,
    required this.value,
    this.label = 'Value',
    this.size = 16,
    this.color,
    this.successColor = const Color(0xFF10B981),
    this.padding = const EdgeInsets.all(8),
    this.constraints,
    this.buttonLabel,
    this.defaultIcon = LucideIcons.copy,
    this.isOutlined = false,
    this.buttonStyle,
    this.showMessage = true,
    this.onCopied,
  });

  const AppCopyButton.outlined({
    super.key,
    required this.value,
    this.label = 'Value',
    this.size = 14,
    this.color,
    this.successColor = const Color(0xFF10B981),
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.constraints,
    required this.buttonLabel,
    this.defaultIcon = LucideIcons.copy,
    this.buttonStyle,
    this.showMessage = true,
    this.onCopied,
  }) : isOutlined = true;

  /// The text content to copy to the clipboard.
  final String value;

  /// Human-readable label for tooltip and snackbar (e.g. "Account number").
  final String label;

  /// Size of the copy/check icon.
  final double size;

  /// Default icon color when not copied.
  final Color? color;

  /// Icon and text color when copied. Defaults to emerald `#10B981`.
  final Color successColor;

  /// Hit-test padding around the button.
  final EdgeInsetsGeometry padding;

  /// Optional constraints for the icon button.
  final BoxConstraints? constraints;

  /// Optional text label if rendered as a labeled button (e.g. "Copy all credentials").
  final String? buttonLabel;

  /// The icon to show before being copied. Defaults to [LucideIcons.copy].
  final IconData defaultIcon;

  /// Whether to render as an [OutlinedButton.icon].
  final bool isOutlined;

  /// Optional style override for [TextButton] or [OutlinedButton].
  final ButtonStyle? buttonStyle;

  /// Whether to trigger [showAppMessage] upon successful copy.
  final bool showMessage;

  /// Optional callback invoked when copy succeeds.
  final VoidCallback? onCopied;

  @override
  State<AppCopyButton> createState() => _AppCopyButtonState();
}

class _AppCopyButtonState extends State<AppCopyButton> with SingleTickerProviderStateMixin {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCopy() async {
    if (!mounted || widget.value.isEmpty) return;
    unawaited(AppHaptics.lightImpact());
    await Clipboard.setData(ClipboardData(text: widget.value));

    if (widget.showMessage) {
      showAppMessage('${widget.label} copied to clipboard.', type: AppFeedbackType.success);
    }

    widget.onCopied?.call();

    if (mounted) {
      setState(() => _copied = true);
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final defaultColor = widget.color ?? cs.primary;
    final iconColor = _copied ? widget.successColor : defaultColor;

    final iconWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Icon(
        _copied ? LucideIcons.check : widget.defaultIcon,
        key: ValueKey<bool>(_copied),
        color: iconColor,
        size: widget.size,
      ),
    );

    if (widget.buttonLabel != null) {
      final labelWidget = AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: iconColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        child: Text(_copied ? 'Copied!' : widget.buttonLabel!),
      );

      if (widget.isOutlined) {
        return OutlinedButton.icon(
          onPressed: widget.value.isEmpty ? null : _handleCopy,
          style: widget.buttonStyle,
          icon: iconWidget,
          label: labelWidget,
        );
      }

      return TextButton.icon(
        onPressed: widget.value.isEmpty ? null : _handleCopy,
        style: widget.buttonStyle,
        icon: iconWidget,
        label: labelWidget,
      );
    }

    return IconButton(
      tooltip: _copied ? 'Copied!' : 'Copy ${widget.label}',
      constraints: widget.constraints,
      padding: widget.padding,
      iconSize: widget.size,
      onPressed: widget.value.isEmpty ? null : _handleCopy,
      icon: iconWidget,
    );
  }
}
