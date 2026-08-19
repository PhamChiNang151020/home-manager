import "package:flutter_test/flutter_test.dart";
import "package:home_manager/app.dart";
import "package:home_manager/core/domain/meter_math.dart";
import "package:home_manager/core/l10n/strings.dart";

void main() {
  test("meter math uses delta times rate", () {
    final used = MeterMath.consumption(previousKwh: 100, newKwh: 120);
    expect(used, 20);
    expect(MeterMath.amountVnd(consumptionKwh: used, kwhRate: 3500), 70000);
  });

  test("day of month clamps 31 in February", () {
    expect(DayOfMonth.clampToMonth(31, DateTime(2026, 2, 1)), 28);
    expect(DayOfMonth.isToday(31, DateTime(2026, 1, 31)), isTrue);
  });

  testWidgets("missing config screen", (tester) async {
    await tester.pumpWidget(const MissingConfigApp());
    expect(find.text(S.missingConfig), findsOneWidget);
  });
}
