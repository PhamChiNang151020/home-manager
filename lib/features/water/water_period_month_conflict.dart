import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/water_period.dart";
import "package:intl/intl.dart";

bool isSamePeriodMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

WaterPeriod? findWaterPeriodForMonth(
  List<WaterPeriod> periods,
  DateTime month, {
  String? excludeId,
}) {
  for (final period in periods) {
    if (excludeId != null && period.id == excludeId) continue;
    if (isSamePeriodMonth(period.periodMonth, month)) return period;
  }
  return null;
}

Future<bool> confirmDuplicateWaterPeriodMonth(
  BuildContext context,
  DateTime month,
) async {
  final monthLabel = DateFormat("MM/yyyy").format(month);
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text(S.duplicateWaterPeriodTitle),
          content: Text("$monthLabel — ${S.duplicateWaterPeriodConfirm}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(S.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(S.overwrite),
            ),
          ],
        ),
  );
  return confirmed ?? false;
}
