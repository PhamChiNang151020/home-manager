class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.homeId,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.isDefault,
  });

  final String id;
  final String homeId;
  final String name;
  final String iconKey;
  final String colorKey;
  final bool isDefault;

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      name: json["name"] as String,
      iconKey: json["icon_key"] as String,
      colorKey: json["color_key"] as String,
      isDefault: json["is_default"] as bool? ?? false,
    );
  }
}

class Expense {
  const Expense({
    required this.id,
    required this.homeId,
    required this.categoryId,
    required this.paidBy,
    required this.amountVnd,
    required this.expenseDate,
    required this.createdAt,
    this.note,
    this.receiptPhotoPath,
    this.category,
    this.paidByName,
  });

  final String id;
  final String homeId;
  final String categoryId;
  final String paidBy;
  final double amountVnd;
  final DateTime expenseDate;
  final DateTime createdAt;
  final String? note;
  final String? receiptPhotoPath;
  final ExpenseCategory? category;
  final String? paidByName;

  factory Expense.fromJson(Map<String, dynamic> json) {
    final categoryJson = json["expense_categories"];
    final profileJson = json["profiles"];
    return Expense(
      id: json["id"] as String,
      homeId: json["home_id"] as String,
      categoryId: json["category_id"] as String,
      paidBy: json["paid_by"] as String,
      amountVnd: (json["amount_vnd"] as num).toDouble(),
      expenseDate: DateTime.parse(json["expense_date"] as String),
      createdAt: DateTime.parse(
        json["created_at"] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      ),
      note: json["note"] as String?,
      receiptPhotoPath: json["receipt_photo_path"] as String?,
      category:
          categoryJson is Map
              ? ExpenseCategory.fromJson(
                Map<String, dynamic>.from(categoryJson),
              )
              : null,
      paidByName:
          profileJson is Map
              ? (profileJson["display_name"] as String? ??
                  profileJson["email"] as String?)
              : null,
    );
  }
}
