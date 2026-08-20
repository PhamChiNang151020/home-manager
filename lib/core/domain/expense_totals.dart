import "package:home_manager/core/models/expense.dart";

class CategorySpend {
  const CategorySpend({required this.category, required this.amountVnd});

  final ExpenseCategory category;
  final double amountVnd;
}

List<CategorySpend> spendByCategory(List<Expense> expenses) {
  final totals = <String, double>{};
  final categories = <String, ExpenseCategory>{};
  for (final expense in expenses) {
    totals[expense.categoryId] =
        (totals[expense.categoryId] ?? 0) + expense.amountVnd;
    final category = expense.category;
    if (category != null) {
      categories[expense.categoryId] = category;
    }
  }
  final result =
      totals.entries.map((entry) {
        final category =
            categories[entry.key] ??
            ExpenseCategory(
              id: entry.key,
              homeId: "",
              name: entry.key,
              iconKey: "more_horiz",
              colorKey: "other",
              isDefault: false,
            );
        return CategorySpend(category: category, amountVnd: entry.value);
      }).toList();
  result.sort((a, b) => b.amountVnd.compareTo(a.amountVnd));
  return result;
}

double totalAmount(List<Expense> expenses) {
  return expenses.fold<double>(0, (sum, item) => sum + item.amountVnd);
}
