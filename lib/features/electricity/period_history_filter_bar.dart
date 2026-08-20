import "package:flutter/material.dart";
import "package:home_manager/core/domain/period_history_filter.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: LabeledDropdownField<int?>(
              label: S.filterYear,
              value: filterYear,
              compact: true,
              items: [
                SelectOption(
                  value: null,
                  builder: (_) => const Text(S.filterAll),
                ),
                for (final year in years)
                  SelectOption(value: year, builder: (_) => Text("$year")),
              ],
              onChanged: onYearChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: LabeledDropdownField<int?>(
              label: S.filterMonth,
              value: filterMonth,
              compact: true,
              items: [
                SelectOption(
                  value: null,
                  builder: (_) => const Text(S.filterAll),
                ),
                for (var month = 1; month <= 12; month++)
                  SelectOption(
                    value: month,
                    builder: (_) => Text(month.toString().padLeft(2, "0")),
                  ),
              ],
              onChanged: onMonthChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: LabeledDropdownField<PeriodSortOrder>(
              label: S.sortLabel,
              value: sortOrder,
              compact: true,
              items: [
                SelectOption(
                  value: PeriodSortOrder.newestFirst,
                  builder: (_) => const Text(S.sortNewest),
                ),
                SelectOption(
                  value: PeriodSortOrder.oldestFirst,
                  builder: (_) => const Text(S.sortOldest),
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
