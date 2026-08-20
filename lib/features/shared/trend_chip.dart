import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class TrendChip extends StatelessWidget {
  const TrendChip({super.key, required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isZero = percent == 0;
    final up = percent > 0;
    final color =
        isZero
            ? colors.textMuted
            : up
            ? colors.error
            : colors.success;
    final icon =
        isZero
            ? Icons.remove
            : up
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;
    final label =
        isZero ? "0%" : "${up ? "+" : ""}${percent.abs().toStringAsFixed(0)}%";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
