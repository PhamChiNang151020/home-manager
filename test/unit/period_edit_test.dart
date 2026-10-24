import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/period_edit.dart";

void main() {
  test("monthKey formats as yyyy-MM-01", () {
    expect(PeriodEdit.monthKey(DateTime(2026, 3, 15)), "2026-03-01");
  });

  group("shouldDeleteOriginalPeriod", () {
    test("true when edit changes month", () {
      expect(
        PeriodEdit.shouldDeleteOriginalPeriod(
          editingId: "p1",
          editingOriginalMonth: DateTime(2026, 1),
          periodMonth: DateTime(2026, 2),
        ),
        isTrue,
      );
    });

    test("false when same month", () {
      expect(
        PeriodEdit.shouldDeleteOriginalPeriod(
          editingId: "p1",
          editingOriginalMonth: DateTime(2026, 1, 5),
          periodMonth: DateTime(2026, 1, 20),
        ),
        isFalse,
      );
    });

    test("false when not editing", () {
      expect(
        PeriodEdit.shouldDeleteOriginalPeriod(
          editingId: null,
          editingOriginalMonth: DateTime(2026, 1),
          periodMonth: DateTime(2026, 2),
        ),
        isFalse,
      );
    });
  });
}
