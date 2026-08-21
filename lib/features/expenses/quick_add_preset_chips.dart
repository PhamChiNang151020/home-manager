import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/expense_preset.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/expenses/expense_category_style.dart";

class QuickAddPresetChips extends StatelessWidget {
  const QuickAddPresetChips({
    super.key,
    required this.presets,
    required this.categories,
    required this.onTap,
    this.enabled = true,
  });

  final List<ExpensePreset> presets;
  final List<ExpenseCategory> categories;
  final ValueChanged<ExpensePreset> onTap;
  final bool enabled;

  String _iconKeyFor(ExpensePreset preset) {
    for (final category in categories) {
      if (category.id == preset.categoryId) return category.iconKey;
    }
    return "more_horiz";
  }

  @override
  Widget build(BuildContext context) {
    if (presets.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;
    return SizedBox(
      height: AppSpacing.touchMin,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        itemCount: presets.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final preset = presets[index];
          return Material(
            color: colors.bgElevated,
            borderRadius: BorderRadius.circular(AppSpacing.touchMin / 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.touchMin / 2),
              onTap: enabled ? () => onTap(preset) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExpenseCategoryIcon(
                      iconKey: _iconKeyFor(preset),
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "${VndFormat.input(preset.roundedAmount)}đ",
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
