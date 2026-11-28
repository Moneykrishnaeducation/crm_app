import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:flutter/material.dart';

class PammDetailCard extends StatelessWidget {
  const PammDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final border = PammColors.border(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PammDecorations.card(context, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: PammColors.blue.withValues(alpha: dark ? 0.16 : 0.09),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: PammColors.blue.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(icon, color: PammColors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PammType.heading(
                        context,
                        size: 15,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: PammType.body(
                        context,
                        size: 12,
                        weight: FontWeight.w400,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: border.withValues(alpha: 0.75)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class PammDetailRow extends StatelessWidget {
  const PammDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.copyValue,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? copyValue;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: border.withValues(alpha: 0.55)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: PammType.body(
                context,
                size: 12.5,
                weight: FontWeight.w500,
                color: muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: PammType.figure(
                context,
                size: 13,
                weight: FontWeight.w600,
                color: valueColor ?? text,
              ),
            ),
          ),
          if (copyValue != null) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: 'Copy $label',
              child: InkWell(
                onTap: () {
                  AppHaptics.lightImpact();
                  copyPammValue(context, copyValue!);
                },
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.copy_outlined,
                      size: 15,
                      color: PammColors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PammDetailAction extends StatelessWidget {
  const PammDetailAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    final subtle = PammColors.subtle(context);
    final border = PammColors.border(context);
    final muted = PammColors.muted(context);

    return Material(
      color: subtle,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          AppHaptics.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PammColors.blue.withValues(alpha: dark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: PammColors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: PammType.body(
                        context,
                        size: 13.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: PammType.body(
                        context,
                        size: 11.5,
                        weight: FontWeight.w400,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class PammDetailMetric extends StatelessWidget {
  const PammDetailMetric({
    super.key,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final text = PammColors.text(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: PammDecorations.card(context, radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PammType.label(
              context,
              size: 10.5,
              weight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PammType.figure(
              context,
              size: 16,
              weight: FontWeight.w700,
              color: valueColor ?? text,
            ),
          ),
        ],
      ),
    );
  }
}

class PammPoolValue extends StatelessWidget {
  const PammPoolValue({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final text = PammColors.text(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PammType.label(
            context,
            size: 10.5,
            weight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: PammType.figure(
            context,
            size: 13,
            weight: FontWeight.w700,
            color: valueColor ?? text,
          ),
        ),
      ],
    );
  }
}

class PammPortfolioBadge extends StatelessWidget {
  const PammPortfolioBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = PammColors.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: PammType.label(
          context,
          size: 11,
          weight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
