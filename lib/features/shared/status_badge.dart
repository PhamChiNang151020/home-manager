import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_colors.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
  });

  final String label;
  final StatusBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      StatusBadgeVariant.success => (AppColors.success.withValues(alpha: 0.15), AppColors.success),
      StatusBadgeVariant.warning => (AppColors.warningMuted(), AppColors.warning),
      StatusBadgeVariant.accent => (AppColors.accentMuted(), AppColors.accent),
      StatusBadgeVariant.neutral => (AppColors.bgElevated, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

enum StatusBadgeVariant { success, warning, accent, neutral }
