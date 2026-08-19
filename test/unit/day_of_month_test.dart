import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/meter_math.dart";

void main() {
  test("day of month clamps 31 in February", () {
    expect(DayOfMonth.clampToMonth(31, DateTime(2026, 2, 1)), 28);
    expect(DayOfMonth.isToday(31, DateTime(2026, 1, 31)), isTrue);
  });

  test("isToday false when day does not match", () {
    expect(DayOfMonth.isToday(15, DateTime(2026, 3, 20)), isFalse);
  });

  test("isToday false when day is null", () {
    expect(DayOfMonth.isToday(null, DateTime(2026, 3, 15)), isFalse);
  });
}
