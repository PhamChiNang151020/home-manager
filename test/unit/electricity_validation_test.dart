import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/electricity_validation.dart";

void main() {
  group("validateMeterReadings", () {
    test("returns null for valid readings", () {
      expect(ElectricityValidation.validateMeterReadings(100, 120), isNull);
    });

    test("missing previous returns missingReadings", () {
      expect(
        ElectricityValidation.validateMeterReadings(null, 120),
        ElectricitySaveError.missingReadings,
      );
    });

    test("missing new returns missingReadings", () {
      expect(
        ElectricityValidation.validateMeterReadings(100, null),
        ElectricitySaveError.missingReadings,
      );
    });

    test("new less than previous returns invalidReadings", () {
      expect(
        ElectricityValidation.validateMeterReadings(120, 100),
        ElectricitySaveError.invalidReadings,
      );
    });
  });

  group("validateInvoiceAmount", () {
    test("returns null for positive amount", () {
      expect(ElectricityValidation.validateInvoiceAmount(539000), isNull);
    });

    test("null or non-positive returns invalidAmount", () {
      expect(
        ElectricityValidation.validateInvoiceAmount(null),
        ElectricitySaveError.invalidAmount,
      );
      expect(
        ElectricityValidation.validateInvoiceAmount(0),
        ElectricitySaveError.invalidAmount,
      );
      expect(
        ElectricityValidation.validateInvoiceAmount(-100),
        ElectricitySaveError.invalidAmount,
      );
    });
  });

  group("parseKwh", () {
    test("parses decimal comma as dot", () {
      expect(ElectricityValidation.parseKwh("120,5"), 120.5);
    });

    test("empty text returns null", () {
      expect(ElectricityValidation.parseKwh(""), isNull);
    });
  });
}
