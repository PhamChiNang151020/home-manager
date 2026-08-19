import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/period_history_filter.dart";
import "package:home_manager/core/models/electricity_period.dart";

ElectricityPeriod _period({required DateTime month}) {
  return ElectricityPeriod(
    id: "p-${month.year}-${month.month}",
    homeId: "h1",
    periodMonth: month,
    amountVnd: 70000,
    recordedAt: DateTime(2026, 1, 15),
  );
}

void main() {
  test("distinctPeriodYears returns unique years descending", () {
    final years = distinctPeriodYears([
      _period(month: DateTime(2024, 3)),
      _period(month: DateTime(2026, 1)),
      _period(month: DateTime(2026, 5)),
    ]);
    expect(years, [2026, 2024]);
  });

  test("filterPeriodHistory filters by year and month", () {
    final periods = [
      _period(month: DateTime(2026, 1)),
      _period(month: DateTime(2026, 2)),
      _period(month: DateTime(2025, 12)),
    ];

    expect(
      filterPeriodHistory(periods, year: 2026).map((p) => p.periodMonth.month),
      [2, 1],
    );
    expect(
      filterPeriodHistory(
        periods,
        year: 2026,
        month: 2,
      ).single.periodMonth.month,
      2,
    );
  });

  test("filterPeriodHistory sorts oldest first", () {
    final periods = [
      _period(month: DateTime(2026, 3)),
      _period(month: DateTime(2026, 1)),
    ];

    final sorted = filterPeriodHistory(
      periods,
      sortOrder: PeriodSortOrder.oldestFirst,
    );
    expect(sorted.map((p) => p.periodMonth.month), [1, 3]);
  });
}
