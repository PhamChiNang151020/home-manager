import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";

class CategorySpend {
  const CategorySpend({required this.category, required this.amountVnd});

  final ExpenseCategory category;
  final double amountVnd;
}

class WhoSpentRow {
  const WhoSpentRow({
    required this.userId,
    required this.name,
    required this.amountVnd,
  });

  final String userId;
  final String name;
  final double amountVnd;
}

/// Current members (0 đ if none) plus former members who spent; amount desc.
List<WhoSpentRow> whoSpentRows({
  required List<HomeMember> members,
  required List<Expense> expenses,
}) {
  final totals = <String, double>{};
  final names = <String, String>{};
  for (final expense in expenses) {
    totals[expense.paidBy] = (totals[expense.paidBy] ?? 0) + expense.amountVnd;
    final label = expense.paidByName;
    if (label != null && label.isNotEmpty) {
      names[expense.paidBy] = label;
    }
  }
  final memberIds = <String>{};
  final rows = <WhoSpentRow>[];
  for (final member in members) {
    memberIds.add(member.userId);
    rows.add(
      WhoSpentRow(
        userId: member.userId,
        name: member.displayName ?? member.email ?? member.userId,
        amountVnd: totals[member.userId] ?? 0,
      ),
    );
  }
  for (final entry in totals.entries) {
    if (memberIds.contains(entry.key)) continue;
    rows.add(
      WhoSpentRow(
        userId: entry.key,
        name: names[entry.key] ?? entry.key,
        amountVnd: entry.value,
      ),
    );
  }
  rows.sort((a, b) => b.amountVnd.compareTo(a.amountVnd));
  return rows;
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
