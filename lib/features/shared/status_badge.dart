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
    final (bg, fg) = switch (variant) {
      StatusBadgeVariant.success => (
        colors.success.withValues(alpha: 0.15),
        colors.success,
      ),
      StatusBadgeVariant.warning => (colors.warningMuted(), colors.warning),
      StatusBadgeVariant.accent => (colors.accentMuted(), colors.accent),
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
