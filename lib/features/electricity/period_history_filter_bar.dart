import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/domain/period_history_filter.dart";
import "package:home_manager/core/l10n/app_locale.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:intl/intl.dart";

class PeriodHistoryFilterButton extends StatelessWidget {
  const PeriodHistoryFilterButton({
    super.key,
    required this.filterMonth,
    required this.sortOrder,
    required this.onMonthChanged,
    required this.onSortChanged,
  });

  final DateTime? filterMonth;
  final PeriodSortOrder sortOrder;
  final ValueChanged<DateTime?> onMonthChanged;
  final ValueChanged<PeriodSortOrder> onSortChanged;

  bool get _hasActiveFilter =>
      filterMonth != null || sortOrder != PeriodSortOrder.newestFirst;

  Future<void> _openSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
      ),
      builder: (sheetContext) {
        return _PeriodHistoryFilterSheet(
          filterMonth: filterMonth,
          sortOrder: sortOrder,
          onMonthChanged: onMonthChanged,
          onSortChanged: onSortChanged,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      tooltip: S.filterHistory,
      onPressed: () => _openSheet(context),
      icon: Icon(
        _hasActiveFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
        color: _hasActiveFilter ? colors.accent : colors.textSecondary,
      ),
    );
  }
}

class _PeriodHistoryFilterSheet extends StatefulWidget {
  const _PeriodHistoryFilterSheet({
    required this.filterMonth,
    required this.sortOrder,
    required this.onMonthChanged,
    required this.onSortChanged,
  });

  final DateTime? filterMonth;
  final PeriodSortOrder sortOrder;
  final ValueChanged<DateTime?> onMonthChanged;
  final ValueChanged<PeriodSortOrder> onSortChanged;

  @override
  State<_PeriodHistoryFilterSheet> createState() =>
      _PeriodHistoryFilterSheetState();
}

class _PeriodHistoryFilterSheetState extends State<_PeriodHistoryFilterSheet> {
  late bool _allMonths = widget.filterMonth == null;
  late DateTime _selectedMonth = monthStart(
    widget.filterMonth ?? currentMonth(),
  );
  late PeriodSortOrder _sort = widget.sortOrder;

  static final DateTime _firstMonth = DateTime(2020);
  DateTime get _lastMonth => lastSelectableMonthEnd();

  void _applyAndClose() {
    widget.onMonthChanged(_allMonths ? null : monthStart(_selectedMonth));
    widget.onSortChanged(_sort);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppSpacing.touchMin),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(S.cancel),
                  ),
                  Expanded(
                    child: Text(
                      S.filterHistory,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, AppSpacing.touchMin),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _applyAndClose,
                    child: const Text(S.done),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _allMonths
                          ? S.filterAll
                          : DateFormat("MM/yyyy").format(_selectedMonth),
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!_allMonths)
                    TextButton(
                      onPressed: () {
                        setState(() => _allMonths = true);
                      },
                      child: const Text(S.filterAll),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 216,
              child: Localizations.override(
                context: context,
                locale: AppLocale.locale,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    primaryColor: colors.accent,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: textTheme.bodyLarge?.copyWith(
                        color: colors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.monthYear,
                    initialDateTime: clampDate(
                      _selectedMonth,
                      first: _firstMonth,
                      last: _lastMonth,
                    ),
                    minimumDate: _firstMonth,
                    maximumDate: _lastMonth,
                    use24hFormat: true,
                    onDateTimeChanged: (value) {
                      setState(() {
                        _allMonths = false;
                        _selectedMonth = monthStart(value);
                      });
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: LabeledDropdownField<PeriodSortOrder>(
                label: S.sortLabel,
                value: _sort,
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
                  if (value != null) setState(() => _sort = value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
