import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/month_balance.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/income.dart";
import "package:home_manager/core/models/water_period.dart";

void main() {
  test("computeMonthBalance nets income minus all outflows", () {
    final balance = computeMonthBalance(
      income: 20000000,
      electricity: 700000,
      water: 150000,
      expenses: 4000000,
    );
    expect(balance.totalOut, 4850000);
    expect(balance.net, 15150000);
  });

  test("negative net when spend exceeds income", () {
    final balance = computeMonthBalance(
      income: 1000,
      electricity: 800,
      water: 400,
      expenses: 0,
    );
    expect(balance.net, -200);
  });

  test("Income.fromJson parses nested profile name", () {
    final income = Income.fromJson({
      "id": "i1",
      "home_id": "h1",
      "user_id": "u1",
      "amount_vnd": 15000000,
      "income_month": "2026-08-01",
      "source": "Lương",
      "note": null,
      "created_at": "2026-08-01T00:00:00.000Z",
      "profiles": {"display_name": "An", "email": "an@x.com"},
    });
    expect(income.displayName, "An");
    expect(income.amountVnd, 15000000);
  });

  test("monthOverMonthPercent is null when previous is zero", () {
    expect(monthOverMonthPercent(100, 0), isNull);
    expect(monthOverMonthPercent(150, 100), 50);
    expect(monthOverMonthPercent(80, 100), -20);
  });

  test("balancesForMonths folds six months ending at selected", () {
    final points = balancesForMonths(
      endMonth: DateTime(2026, 8),
      count: 3,
      incomes: [
        Income(
          id: "i1",
          homeId: "h1",
          userId: "u1",
          amountVnd: 1000,
          incomeMonth: DateTime(2026, 8),
          createdAt: DateTime(2026, 8, 1),
        ),
      ],
      electricity: [
        ElectricityPeriod(
          id: "e1",
          homeId: "h1",
          periodMonth: DateTime(2026, 7),
          amountVnd: 200,
          recordedAt: DateTime(2026, 7, 1),
        ),
        ElectricityPeriod(
          id: "e2",
          homeId: "h1",
          periodMonth: DateTime(2026, 8),
          amountVnd: 300,
          recordedAt: DateTime(2026, 8, 1),
        ),
      ],
      water: [
        WaterPeriod(
          id: "w1",
          homeId: "h1",
          periodMonth: DateTime(2026, 8),
          amountVnd: 50,
          recordedAt: DateTime(2026, 8, 1),
        ),
      ],
      expenses: [
        Expense(
          id: "x1",
          homeId: "h1",
          categoryId: "c1",
          paidBy: "u1",
          amountVnd: 400,
          expenseDate: DateTime(2026, 6, 10),
          createdAt: DateTime(2026, 6, 10),
        ),
      ],
    );

    expect(points.map((p) => p.month.month), [6, 7, 8]);
    expect(points[0].balance.totalOut, 400);
    expect(points[1].balance.electricity, 200);
    expect(points[2].balance.income, 1000);
    expect(points[2].balance.totalOut, 350);
  });
}
