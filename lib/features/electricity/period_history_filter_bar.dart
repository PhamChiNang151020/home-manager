import "package:flutter/material.dart";
import "package:home_manager/core/domain/period_history_filter.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

class PeriodHistoryFilterBar extends StatelessWidget {
  const PeriodHistoryFilterBar({
    super.key,
    required this.years,
    required this.filterYear,
    required this.filterMonth,
    required this.sortOrder,
    required this.onYearChanged,
    required this.onMonthChanged,
    required this.onSortChanged,
  });

  final List<int> years;
  final int? filterYear;
  final int? filterMonth;
  final PeriodSortOrder sortOrder;
  final ValueChanged<int?> onYearChanged;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<PeriodSortOrder> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
      borderSide: BorderSide(color: colors.border),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: _CompactDropdown<int?>(
              label: S.filterYear,
              value: filterYear,
              border: inputBorder,
              items: [
                const DropdownMenuItem(value: null, child: Text(S.filterAll)),
                for (final year in years)
                  DropdownMenuItem(value: year, child: Text("$year")),
              ],
              onChanged: onYearChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CompactDropdown<int?>(
              label: S.filterMonth,
              value: filterMonth,
              border: inputBorder,
              items: [
                const DropdownMenuItem(value: null, child: Text(S.filterAll)),
                for (var month = 1; month <= 12; month++)
                  DropdownMenuItem(
                    value: month,
                    child: Text(month.toString().padLeft(2, "0")),
                  ),
              ],
              onChanged: onMonthChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CompactDropdown<PeriodSortOrder>(
              label: S.sortLabel,
              value: sortOrder,
              border: inputBorder,
              items: const [
                DropdownMenuItem(
                  value: PeriodSortOrder.newestFirst,
                  child: Text(S.sortNewest),
                ),
                DropdownMenuItem(
                  value: PeriodSortOrder.oldestFirst,
                  child: Text(S.sortOldest),
                ),
              ],
              onChanged: (value) {
                if (value != null) onSortChanged(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactDropdown<T> extends StatelessWidget {
  const _CompactDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.border,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final InputBorder border;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: colors.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
