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

    // The tinted background pulls the label toward the surface, so the label
    // has to move the other way to stay above 4.5:1 against that blend.
    Color onTint(Color base) =>
        Color.lerp(
          base,
          isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
          isDark ? 0.12 : 0.25,
        )!;

    final (bg, fg) = switch (variant) {
      StatusBadgeVariant.success => (
        colors.success.withValues(alpha: isDark ? 0.22 : 0.18),
        onTint(colors.success),
      ),
      StatusBadgeVariant.warning => (
        colors.warning.withValues(alpha: isDark ? 0.32 : 0.26),
        onTint(colors.warning),
      ),
      StatusBadgeVariant.accent => (
        colors.accent.withValues(alpha: isDark ? 0.28 : 0.22),
        onTint(colors.accent),
      ),
      StatusBadgeVariant.neutral => (colors.bgElevated, colors.textSecondary),
      StatusBadgeVariant.error => (
        colors.error.withValues(alpha: isDark ? 0.22 : 0.18),
        onTint(colors.error),
      ),
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

enum StatusBadgeVariant { success, warning, accent, neutral, error }
