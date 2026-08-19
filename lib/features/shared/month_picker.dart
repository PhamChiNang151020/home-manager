import "package:flutter/material.dart";
import "package:home_manager/core/l10n/app_locale.dart";
import "package:home_manager/core/l10n/strings.dart";

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDatePicker(
    context: context,
    locale: AppLocale.locale,
    initialDate: initialDate,
    firstDate: firstDate ?? DateTime(2020),
    lastDate: lastDate ?? DateTime(2100),
    helpText: S.selectMonth,
    cancelText: S.cancel,
    confirmText: S.ok,
  );
}
