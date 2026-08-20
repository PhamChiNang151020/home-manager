import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/app_locale.dart";
import "package:home_manager/core/l10n/strings.dart";

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String? helpText,
}) {
  final first = firstDate ?? DateTime(2020);
  final last = lastDate ?? today();
  return showDatePicker(
    context: context,
    locale: AppLocale.locale,
    initialDate: clampDate(initialDate, first: first, last: last),
    firstDate: first,
    lastDate: last,
    helpText: helpText,
    cancelText: S.cancel,
    confirmText: S.ok,
  );
}

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  required DateTime initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final date = await showAppDatePicker(
    context: context,
    initialDate: initialDateTime,
    firstDate: firstDate,
    lastDate: lastDate,
    helpText: S.selectRecordedAt,
  );
  if (date == null || !context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDateTime),
    cancelText: S.cancel,
    confirmText: S.ok,
  );
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
