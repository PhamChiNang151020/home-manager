import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.large = false,
  });

  final String label;
  final StatusBadgeVariant variant;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bg, fg) = switch (variant) {
      StatusBadgeVariant.success => (
        colors.success.withValues(alpha: isDark ? 0.22 : 0.18),
        isDark
            ? colors.success
            : Color.lerp(colors.success, const Color(0xFF000000), 0.18)!,
      ),
      StatusBadgeVariant.warning => (
        colors.warning.withValues(alpha: isDark ? 0.32 : 0.26),
        isDark
            ? Color.lerp(colors.warning, const Color(0xFFFFFFFF), 0.12)!
            : Color.lerp(colors.warning, const Color(0xFF000000), 0.28)!,
      ),
      StatusBadgeVariant.accent => (
        colors.accent.withValues(alpha: isDark ? 0.28 : 0.22),
        isDark
            ? colors.accent
            : Color.lerp(colors.accent, const Color(0xFF000000), 0.22)!,
      ),
      StatusBadgeVariant.neutral => (colors.bgElevated, colors.textSecondary),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSpacing.md : AppSpacing.sm,
        vertical: large ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: large ? 13 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum StatusBadgeVariant { success, warning, accent, neutral }
