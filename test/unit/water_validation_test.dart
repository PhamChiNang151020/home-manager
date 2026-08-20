import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/water_validation.dart";

void main() {
  test("validateMeterReadings returns null for valid readings", () {
    expect(WaterValidation.validateMeterReadings(10, 12), isNull);
  });

  test("validateMeterReadings missing previous returns missingReadings", () {
    expect(
      WaterValidation.validateMeterReadings(null, 12),
      WaterSaveError.missingReadings,
    );
  });

  test(
    "validateMeterReadings new less than previous returns invalidReadings",
    () {
      expect(
        WaterValidation.validateMeterReadings(20, 10),
        WaterSaveError.invalidReadings,
      );
    },
  );

  test("validateInvoiceAmount null or non-positive returns invalidAmount", () {
    expect(
      WaterValidation.validateInvoiceAmount(null),
      WaterSaveError.invalidAmount,
    );
    expect(
      WaterValidation.validateInvoiceAmount(0),
      WaterSaveError.invalidAmount,
    );
  });

  test("parseM3 parses decimal comma as dot", () {
    expect(WaterValidation.parseM3("12,5"), 12.5);
  });
}
