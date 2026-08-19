import "package:intl/intl.dart";

abstract final class VndFormat {
  static final NumberFormat _number = NumberFormat.decimalPattern("vi_VN");

  /// Display text with đ suffix, e.g. `539.000 đ`.
  static String format(double amount) => "${_number.format(amount)} đ";

  /// Short axis label, e.g. `539k`, `1,2 tr`.
  static String compact(double amount) {
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      return "${_number.format(millions)} tr";
    }
    if (amount >= 1000) {
      final thousands = amount / 1000;
      return "${_number.format(thousands)} k";
    }
    return _number.format(amount);
  }

  /// Input / field value without suffix, e.g. `539.000`.
  static String input(double amount) {
    if (amount == 0) return "";
    return _number.format(amount.round());
  }

  static double? parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    var cleaned = trimmed.replaceAll(RegExp(r"[đ\s]"), "");
    cleaned = cleaned.replaceAll(".", "").replaceAll(",", ".");
    return double.tryParse(cleaned);
  }
}
