import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/features/electricity/period_month_conflict.dart";

ElectricityPeriod _period({required String id, required DateTime month}) {
  return ElectricityPeriod(
    id: id,
    homeId: "h1",
    periodMonth: month,
    amountVnd: 70000,
  );
}

void main() {
  test("isSamePeriodMonth compares year and month only", () {
    expect(
      isSamePeriodMonth(DateTime(2026, 3, 1), DateTime(2026, 3, 31)),
      isTrue,
    );
    expect(
      isSamePeriodMonth(DateTime(2026, 3, 1), DateTime(2026, 4, 1)),
      isFalse,
    );
  });

  test("findPeriodForMonth returns duplicate", () {
    final periods = [
      _period(id: "p1", month: DateTime(2026, 1)),
      _period(id: "p2", month: DateTime(2026, 2)),
    ];
    final found = findPeriodForMonth(periods, DateTime(2026, 2, 10));
    expect(found?.id, "p2");
  });

  test("findPeriodForMonth excludeId skips editing period", () {
    final periods = [_period(id: "p1", month: DateTime(2026, 2))];
    final found = findPeriodForMonth(
      periods,
      DateTime(2026, 2),
      excludeId: "p1",
    );
    expect(found, isNull);
  });
}
