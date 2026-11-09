import "package:flutter/material.dart";
import "package:intl/intl.dart";

bool isSamePeriodMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

T? findPeriodForMonth<T>({
  required List<T> periods,
  required DateTime month,
  required DateTime Function(T) getPeriodMonth,
  required String Function(T) getId,
  String? excludeId,
}) {
  for (final period in periods) {
    if (excludeId != null && getId(period) == excludeId) continue;
    if (isSamePeriodMonth(getPeriodMonth(period), month)) return period;
  }
  return null;
}

Future<bool> confirmDuplicatePeriodMonth(
  BuildContext context,
  DateTime month, {
  required String title,
  required String confirmMessage,
  required String cancelLabel,
  required String overwriteLabel,
}) async {
  final monthLabel = DateFormat("MM/yyyy").format(month);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text("$monthLabel — $confirmMessage"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(overwriteLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
