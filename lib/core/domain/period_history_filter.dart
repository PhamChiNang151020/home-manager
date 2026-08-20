import "package:home_manager/core/models/electricity_period.dart";

enum PeriodSortOrder { newestFirst, oldestFirst }

List<int> distinctYearsFromMonths(Iterable<DateTime> months) {
  final years = months.map((month) => month.year).toSet().toList();
  years.sort((a, b) => b.compareTo(a));
  return years;
}

List<T> filterByPeriodMonth<T>(
  List<T> items, {
  required DateTime Function(T) monthOf,
  int? year,
  int? month,
  PeriodSortOrder sortOrder = PeriodSortOrder.newestFirst,
}) {
  var result =
      items.where((item) {
        final periodMonth = monthOf(item);
        if (year != null && periodMonth.year != year) {
          return false;
        }
        if (month != null && periodMonth.month != month) {
          return false;
        }
        return true;
      }).toList();

  result.sort((a, b) {
    final byMonth = monthOf(a).compareTo(monthOf(b));
    return sortOrder == PeriodSortOrder.newestFirst ? -byMonth : byMonth;
  });
  return result;
}

List<int> distinctPeriodYears(List<ElectricityPeriod> periods) {
  return distinctYearsFromMonths(periods.map((p) => p.periodMonth));
}

List<ElectricityPeriod> filterPeriodHistory(
  List<ElectricityPeriod> periods, {
  int? year,
  int? month,
  PeriodSortOrder sortOrder = PeriodSortOrder.newestFirst,
}) {
  return filterByPeriodMonth(
    periods,
    monthOf: (period) => period.periodMonth,
    year: year,
    month: month,
    sortOrder: sortOrder,
  );
}
