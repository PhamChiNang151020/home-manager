enum WaterSaveError { missingReadings, invalidReadings, invalidAmount }

abstract final class WaterValidation {
  static WaterSaveError? validateMeterReadings(
    double? previousM3,
    double? newM3,
  ) {
    if (previousM3 == null || newM3 == null) {
      return WaterSaveError.missingReadings;
    }
    if (newM3 < previousM3) {
      return WaterSaveError.invalidReadings;
    }
    return null;
  }

  static WaterSaveError? validateInvoiceAmount(double? amountVnd) {
    if (amountVnd == null || amountVnd <= 0) {
      return WaterSaveError.invalidAmount;
    }
    return null;
  }

  static double? parseM3(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed.replaceAll(",", "."));
  }
}
