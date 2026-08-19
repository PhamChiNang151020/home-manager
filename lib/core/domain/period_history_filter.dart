import "package:home_manager/core/models/electricity_period.dart";

enum PeriodSortOrder { newestFirst, oldestFirst }

List<int> distinctPeriodYears(List<ElectricityPeriod> periods) {
  final years = periods.map((p) => p.periodMonth.year).toSet().toList();
  years.sort((a, b) => b.compareTo(a));
  return years;
}

List<ElectricityPeriod> filterPeriodHistory(
  List<ElectricityPeriod> periods, {
  int? year,
  int? month,
  PeriodSortOrder sortOrder = PeriodSortOrder.newestFirst,
}) {
  var result =
      periods.where((period) {
        if (year != null && period.periodMonth.year != year) {
          return false;
        }
        if (month != null && period.periodMonth.month != month) {
          return false;
        }
        return true;
      }).toList();

  result.sort((a, b) {
    final byMonth = a.periodMonth.compareTo(b.periodMonth);
    return sortOrder == PeriodSortOrder.newestFirst ? -byMonth : byMonth;
  });
  return result;
}
