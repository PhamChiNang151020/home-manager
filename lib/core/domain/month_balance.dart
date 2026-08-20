import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/income.dart";
import "package:home_manager/core/models/water_period.dart";

class MonthBalance {
  const MonthBalance({
    required this.income,
    required this.electricity,
    required this.water,
    required this.expenses,
  });

  final double income;
  final double electricity;
  final double water;
  final double expenses;

  double get totalOut => electricity + water + expenses;

  double get net => income - totalOut;
}

class MonthBalancePoint {
  const MonthBalancePoint({required this.month, required this.balance});

  final DateTime month;
  final MonthBalance balance;
}

MonthBalance computeMonthBalance({
  required double income,
  required double electricity,
  required double water,
  required double expenses,
}) {
  return MonthBalance(
    income: income,
    electricity: electricity,
    water: water,
    expenses: expenses,
  );
}

List<MonthBalancePoint> balancesForMonths({
  required DateTime endMonth,
  required List<Income> incomes,
  required List<ElectricityPeriod> electricity,
  required List<WaterPeriod> water,
  required List<Expense> expenses,
  int count = 6,
}) {
  final end = monthStart(endMonth);
  return List.generate(count, (index) {
    final month = DateTime(end.year, end.month - (count - 1 - index));
    return MonthBalancePoint(
      month: month,
      balance: _balanceForMonth(
        month,
        incomes: incomes,
        electricity: electricity,
        water: water,
        expenses: expenses,
      ),
    );
  });
}

MonthBalance _balanceForMonth(
  DateTime month, {
  required List<Income> incomes,
  required List<ElectricityPeriod> electricity,
  required List<WaterPeriod> water,
  required List<Expense> expenses,
}) {
  return computeMonthBalance(
    income: incomes
        .where((item) => sameMonth(item.incomeMonth, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd),
    electricity: electricity
        .where((item) => sameMonth(item.periodMonth, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd),
    water: water
        .where((item) => sameMonth(item.periodMonth, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd),
    expenses: expenses
        .where((item) => sameMonth(item.expenseDate, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd),
  );
}

double? monthOverMonthPercent(double current, double previous) {
  if (previous == 0) return null;
  return (current - previous) / previous * 100;
}
