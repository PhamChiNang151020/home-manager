import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/app_locale.dart";
import "package:home_manager/core/l10n/strings.dart";

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final first = firstDate ?? DateTime(2020);
  final last = lastDate ?? lastSelectableMonthEnd();
  return showDatePicker(
    context: context,
    locale: AppLocale.locale,
    initialDate: clampDate(initialDate, first: first, last: last),
    firstDate: first,
    lastDate: last,
    helpText: S.selectMonth,
    cancelText: S.cancel,
    confirmText: S.ok,
  );
}
