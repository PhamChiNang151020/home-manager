import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/models/expense.dart";

Expense _expense({
  required String id,
  required String categoryId,
  required double amount,
  String colorKey = "food",
  String name = "Ăn uống/Chợ",
}) {
  return Expense(
    id: id,
    homeId: "h1",
    categoryId: categoryId,
    paidBy: "u1",
    amountVnd: amount,
    expenseDate: DateTime(2026, 8, 1),
    createdAt: DateTime(2026, 8, 1),
    category: ExpenseCategory(
      id: categoryId,
      homeId: "h1",
      name: name,
      iconKey: "restaurant",
      colorKey: colorKey,
      isDefault: true,
    ),
  );
}

void main() {
  test("totalAmount sums expenses", () {
    expect(
      totalAmount([
        _expense(id: "1", categoryId: "c1", amount: 10000),
        _expense(id: "2", categoryId: "c1", amount: 25000),
      ]),
      35000,
    );
  });

  test("spendByCategory groups and sorts descending", () {
    final spend = spendByCategory([
      _expense(id: "1", categoryId: "food", amount: 10000, name: "Ăn"),
      _expense(
        id: "2",
        categoryId: "loan",
        amount: 40000,
        name: "Vay",
        colorKey: "loan",
      ),
      _expense(id: "3", categoryId: "food", amount: 5000, name: "Ăn"),
    ]);
    expect(spend.first.category.name, "Vay");
    expect(spend.first.amountVnd, 40000);
    expect(spend.last.amountVnd, 15000);
  });

  test("Expense.fromJson parses nested category", () {
    final expense = Expense.fromJson({
      "id": "e1",
      "home_id": "h1",
      "category_id": "c1",
      "paid_by": "u1",
      "amount_vnd": 12000,
      "expense_date": "2026-08-01",
      "created_at": "2026-08-01T00:00:00.000Z",
      "note": "chợ",
      "receipt_photo_path": null,
      "expense_categories": {
        "id": "c1",
        "home_id": "h1",
        "name": "Ăn uống/Chợ",
        "icon_key": "restaurant",
        "color_key": "food",
        "is_default": true,
      },
      "profiles": {"display_name": "An", "email": "an@x.com"},
    });
    expect(expense.category?.name, "Ăn uống/Chợ");
    expect(expense.paidByName, "An");
  });
}
