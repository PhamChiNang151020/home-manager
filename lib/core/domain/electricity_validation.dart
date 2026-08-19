enum ElectricitySaveError { missingReadings, invalidReadings, invalidAmount }

abstract final class ElectricityValidation {
  static ElectricitySaveError? validateMeterReadings(
    double? previousKwh,
    double? newKwh,
  ) {
    if (previousKwh == null || newKwh == null) {
      return ElectricitySaveError.missingReadings;
    }
    if (newKwh < previousKwh) {
      return ElectricitySaveError.invalidReadings;
    }
    return null;
  }

  static ElectricitySaveError? validateInvoiceAmount(double? amountVnd) {
    if (amountVnd == null || amountVnd <= 0) {
      return ElectricitySaveError.invalidAmount;
    }
    return null;
  }

  static double? parseKwh(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return double.tryParse(trimmed.replaceAll(",", "."));
  }
}
