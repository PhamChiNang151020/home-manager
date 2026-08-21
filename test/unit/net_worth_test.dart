import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/net_worth.dart";

void main() {
  test("computeNetWorth assets minus liabilities", () {
    expect(
      computeNetWorth(
        savingsTotal: 1000000,
        owedToMeTotal: 200000,
        bankUsedTotal: 300000,
        iOweTotal: 100000,
      ),
      800000,
    );
  });

  test("sumAmounts folds values", () {
    expect(sumAmounts([1, 2, 3.5]), 6.5);
    expect(sumAmounts([]), 0);
  });
}
