import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/month_clamp.dart";

void main() {
  final now = DateTime(2026, 8, 20);

  test("currentMonth drops the day", () {
    expect(currentMonth(now), DateTime(2026, 8));
  });

  test("clampToCurrentMonth keeps past months and caps future", () {
    expect(
      clampToCurrentMonth(DateTime(2026, 5, 12), now: now),
      DateTime(2026, 5),
    );
    expect(
      clampToCurrentMonth(DateTime(2026, 12, 1), now: now),
      DateTime(2026, 8),
    );
  });

  test("canGoNextMonth false on current month", () {
    expect(canGoNextMonth(DateTime(2026, 8), now: now), isFalse);
    expect(canGoNextMonth(DateTime(2026, 7), now: now), isTrue);
  });

  test("shiftMonth blocks future and allows previous", () {
    expect(shiftMonth(DateTime(2026, 8), 1, now: now), isNull);
    expect(shiftMonth(DateTime(2026, 7), 1, now: now), DateTime(2026, 8));
    expect(shiftMonth(DateTime(2026, 8), -1, now: now), DateTime(2026, 7));
  });

  test("clampDate stays within first and last", () {
    final first = DateTime(2020);
    final last = DateTime(2026, 8, 20);
    expect(clampDate(DateTime(2019, 12, 31), first: first, last: last), first);
    expect(clampDate(DateTime(2026, 9, 1), first: first, last: last), last);
    expect(
      clampDate(DateTime(2026, 3, 10), first: first, last: last),
      DateTime(2026, 3, 10),
    );
  });

  test("lastSelectableMonthEnd is last day of current month", () {
    expect(lastSelectableMonthEnd(now: now), DateTime(2026, 8, 31));
  });
}
