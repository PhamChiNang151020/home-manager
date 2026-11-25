import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";

Expense _expense({
  required String id,
  required String paidBy,
  required double amount,
  String? paidByName,
}) {
  return Expense(
    id: id,
    homeId: "h1",
    categoryId: "c1",
    paidBy: paidBy,
    amountVnd: amount,
    expenseDate: DateTime(2026, 11, 9),
    createdAt: DateTime(2026, 11, 9),
    paidByName: paidByName,
  );
}

void main() {
  test("whoSpentRows sorts desc, zeros for non-spenders, keeps former", () {
    final rows = whoSpentRows(
      members: const [
        HomeMember(userId: "u1", role: "owner", displayName: "An"),
        HomeMember(userId: "u2", role: "member", displayName: "Bình"),
        HomeMember(userId: "u3", role: "member", email: "c@x.com"),
      ],
      expenses: [
        _expense(id: "e1", paidBy: "u1", amount: 100000, paidByName: "An"),
        _expense(id: "e2", paidBy: "u1", amount: 50000, paidByName: "An"),
        _expense(id: "e3", paidBy: "left", amount: 20000, paidByName: "Cũ"),
      ],
    );

    expect(rows.map((r) => r.userId).toList(), ["u1", "left", "u2", "u3"]);
    expect(rows[0].amountVnd, 150000);
    expect(rows[1].name, "Cũ");
    expect(rows[2].amountVnd, 0);
    expect(rows[3].name, "c@x.com");
  });

  test("totalAmount of whoSpentRows matches month total", () {
    final expenses = [
      _expense(id: "e1", paidBy: "u1", amount: 100000),
      _expense(id: "e2", paidBy: "u2", amount: 40000),
    ];
    final rows = whoSpentRows(
      members: const [
        HomeMember(userId: "u1", role: "owner", displayName: "An"),
        HomeMember(userId: "u2", role: "member", displayName: "Bình"),
      ],
      expenses: expenses,
    );
    expect(
      rows.fold<double>(0, (s, r) => s + r.amountVnd),
      totalAmount(expenses),
    );
  });
}
