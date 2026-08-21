/// Parses a VND amount from OCR receipt text.
double? parseReceiptAmount(String rawText) {
  if (rawText.trim().isEmpty) return null;

  final amounts = _findAmounts(rawText);
  if (amounts.isEmpty) return null;

  final keywordAmount = _amountNearKeyword(rawText, amounts);
  if (keywordAmount != null) return keywordAmount;

  return amounts.map((a) => a.value).reduce((a, b) => a > b ? a : b);
}

final _amountPattern = RegExp(
  r"(?<!\d)(\d{1,3}(?:[.,]\d{3})+|\d{4,})(?!\d)",
);

final _keywordPattern = RegExp(
  r"(tổng\s*cộng|thành\s*tiền|tổng|total)",
  caseSensitive: false,
);

class _AmountMatch {
  const _AmountMatch({required this.value, required this.start, required this.end});

  final double value;
  final int start;
  final int end;
}

List<_AmountMatch> _findAmounts(String text) {
  final results = <_AmountMatch>[];
  for (final match in _amountPattern.allMatches(text)) {
    final raw = match.group(1);
    if (raw == null) continue;
    final value = _parseAmountToken(raw);
    if (value == null || value <= 0) continue;
    // Ignore tiny numbers that are likely dates / qty / VAT %.
    if (value < 1000) continue;
    results.add(
      _AmountMatch(value: value, start: match.start, end: match.end),
    );
  }
  return results;
}

double? _parseAmountToken(String raw) {
  final cleaned = raw.replaceAll(RegExp(r"[^\d]"), "");
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

double? _amountNearKeyword(String text, List<_AmountMatch> amounts) {
  double? best;
  var bestDistance = 1 << 30;

  for (final keyword in _keywordPattern.allMatches(text)) {
    for (final amount in amounts) {
      // Prefer amounts that appear after the keyword on the same line-ish window.
      final after = amount.start >= keyword.end;
      final distance =
          after
              ? amount.start - keyword.end
              : keyword.start - amount.end;
      if (distance < 0 || distance > 80) continue;
      final score = after ? distance : distance + 40;
      if (score < bestDistance) {
        bestDistance = score;
        best = amount.value;
      }
    }
  }
  return best;
}
