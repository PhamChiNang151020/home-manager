import "package:flutter/cupertino.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/features/shared/cupertino_date_sheet.dart";

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final first = firstDate ?? DateTime(2020);
  final last = lastDate ?? lastSelectableMonthEnd();
  final picked = await showCupertinoDateSheet(
    context: context,
    initialDateTime: clampDate(initialDate, first: first, last: last),
    mode: CupertinoDatePickerMode.monthYear,
    minimumDate: first,
    maximumDate: last,
    title: S.selectMonth,
  );
  if (picked == null) return null;
  return monthStart(picked);
}
