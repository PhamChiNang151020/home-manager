class ExpensePreset {
  const ExpensePreset({
    required this.categoryId,
    required this.categoryName,
    required this.roundedAmount,
    required this.occurrenceCount,
  });

  final String categoryId;
  final String categoryName;
  final double roundedAmount;
  final int occurrenceCount;

  factory ExpensePreset.fromJson(Map<String, dynamic> json) {
    return ExpensePreset(
      categoryId: json["category_id"] as String,
      categoryName: json["category_name"] as String,
      roundedAmount: (json["rounded_amount"] as num).toDouble(),
      occurrenceCount: (json["occurrence_count"] as num).toInt(),
    );
  }
}
