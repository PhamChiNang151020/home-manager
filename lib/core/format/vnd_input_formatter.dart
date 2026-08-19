import "package:flutter/services.dart";
import "package:home_manager/core/format/vnd_format.dart";

class VndInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r"[^\d]"), "");
    if (digits.isEmpty) {
      return const TextEditingValue(text: "");
    }
    final number = int.tryParse(digits);
    if (number == null) return oldValue;
    final formatted = VndFormat.input(number.toDouble());
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
