import "package:intl/intl.dart";

abstract final class ElectricityPeriodEdit {
  static String monthKey(DateTime month) =>
      DateFormat("yyyy-MM-01").format(DateTime(month.year, month.month));

  static bool shouldDeleteOriginalPeriod({
    required String? editingId,
    required DateTime? editingOriginalMonth,
    required DateTime periodMonth,
  }) {
    if (editingId == null || editingOriginalMonth == null) {
      return false;
    }
    return monthKey(editingOriginalMonth) != monthKey(periodMonth);
  }
}
