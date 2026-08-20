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
