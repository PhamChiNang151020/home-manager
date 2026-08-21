import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/income.dart";
import "package:home_manager/core/models/water_period.dart";
import "package:home_manager/core/services/overview_service.dart";

void main() {
  test("buildIncomeSpendHistory sums income vs combined spend", () {
    final end = DateTime(2026, 8);
    final points = buildIncomeSpendHistory(
      endMonth: end,
      incomes: [
        Income(
          id: "i1",
          homeId: "h1",
          userId: "u1",
          amountVnd: 10000000,
          incomeMonth: DateTime(2026, 8),
          createdAt: DateTime(2026, 8),
        ),
      ],
      expenses: [
        Expense(
          id: "e1",
          homeId: "h1",
          categoryId: "c1",
          paidBy: "u1",
          amountVnd: 500000,
          expenseDate: DateTime(2026, 8, 5),
          createdAt: DateTime(2026, 8),
        ),
      ],
      electricity: [
        ElectricityPeriod(
          id: "el1",
          homeId: "h1",
          periodMonth: DateTime(2026, 8),
          amountVnd: 300000,
          recordedAt: DateTime(2026, 8),
        ),
      ],
      water: [
        WaterPeriod(
          id: "w1",
          homeId: "h1",
          periodMonth: DateTime(2026, 8),
          amountVnd: 100000,
          recordedAt: DateTime(2026, 8),
        ),
      ],
      bankPeriods: [
        BankAccountPeriod(
          id: "bp1",
          bankAccountId: "b1",
          periodMonth: DateTime(2026, 8),
          balanceUsed: 0,
          paymentDue: 0,
          paymentMade: 200000,
          isPaid: true,
          recordedAt: DateTime(2026, 8),
        ),
      ],
      count: 1,
    );
    expect(points, hasLength(1));
    expect(points.single.income, 10000000);
    expect(points.single.spend, 1100000);
  });
}
