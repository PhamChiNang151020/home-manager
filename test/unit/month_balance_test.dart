import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/month_balance.dart";
import "package:home_manager/core/models/income.dart";

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
}
