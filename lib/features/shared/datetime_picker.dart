import "package:flutter/cupertino.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/features/shared/cupertino_date_sheet.dart";

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String? helpText,
}) {
  final first = firstDate ?? DateTime(2020);
  final last = lastDate ?? today();
  return showCupertinoDateSheet(
    context: context,
    initialDateTime: clampDate(initialDate, first: first, last: last),
    mode: CupertinoDatePickerMode.date,
    minimumDate: first,
    maximumDate: last,
    title: helpText ?? S.expenseDate,
  );
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final first = firstDate ?? DateTime(2020);
  final last = lastDate ?? DateTime.now();
  return showCupertinoDateSheet(
    context: context,
    initialDateTime: clampDate(initialDateTime, first: first, last: last),
    mode: CupertinoDatePickerMode.dateAndTime,
    minimumDate: first,
    maximumDate: last,
    title: S.selectRecordedAt,
  );
}
