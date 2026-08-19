import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/meter_math.dart";

void main() {
  test("meter math uses delta times rate", () {
    final used = MeterMath.consumption(previousKwh: 100, newKwh: 120);
    expect(used, 20);
    expect(MeterMath.amountVnd(consumptionKwh: used, kwhRate: 3500), 70000);
  });

  test("zero consumption yields zero amount", () {
    expect(MeterMath.amountVnd(consumptionKwh: 0, kwhRate: 3500), 0);
  });
}
