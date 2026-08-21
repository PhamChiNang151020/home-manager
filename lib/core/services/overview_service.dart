import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/domain/net_worth.dart";
import "package:home_manager/core/models/bank_account.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/income.dart";
import "package:home_manager/core/models/water_period.dart";
import "package:home_manager/core/services/app_services.dart";

class IncomeSpendPoint {
  const IncomeSpendPoint({
    required this.month,
    required this.income,
    required this.spend,
  });

  final DateTime month;
  final double income;
  final double spend;
}

class OverviewSnapshot {
  const OverviewSnapshot({
    required this.netWorth,
    required this.latestElectricity,
    required this.latestWater,
    required this.monthExpenses,
    required this.monthIncome,
    required this.bankUsed,
    required this.bankLimit,
    required this.debtNet,
    required this.savingsTotal,
    required this.incomeSpendHistory,
    required this.categorySpend,
  });

  final double netWorth;
  final ElectricityPeriod? latestElectricity;
  final WaterPeriod? latestWater;
  final double monthExpenses;
  final double monthIncome;
  final double bankUsed;
  final double bankLimit;
  final double debtNet;
  final double savingsTotal;
  final List<IncomeSpendPoint> incomeSpendHistory;
  final List<CategorySpend> categorySpend;
}

List<IncomeSpendPoint> buildIncomeSpendHistory({
  required DateTime endMonth,
  required List<Income> incomes,
  required List<Expense> expenses,
  required List<ElectricityPeriod> electricity,
  required List<WaterPeriod> water,
  required List<BankAccountPeriod> bankPeriods,
  int count = 6,
}) {
  final end = monthStart(endMonth);
  return List.generate(count, (index) {
    final month = DateTime(end.year, end.month - (count - 1 - index));
    final income = incomes
        .where((item) => sameMonth(item.incomeMonth, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd);
    final expenseTotal = expenses
        .where((item) => sameMonth(item.expenseDate, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd);
    final elec = electricity
        .where((item) => sameMonth(item.periodMonth, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd);
    final wat = water
        .where((item) => sameMonth(item.periodMonth, month))
        .fold<double>(0, (sum, item) => sum + item.amountVnd);
    final bankPaid = bankPeriods
        .where((item) => sameMonth(item.periodMonth, month))
        .fold<double>(0, (sum, item) => sum + item.paymentMade);
    return IncomeSpendPoint(
      month: month,
      income: income,
      spend: expenseTotal + elec + wat + bankPaid,
    );
  });
}

class OverviewService {
  OverviewService(this._services);

  final AppServices _services;

  Future<OverviewSnapshot> load(String homeId, {DateTime? month}) async {
    final m = month ?? currentMonth();
    final electricityLatest = await _services.electricity.latest(homeId);
    final waterLatest = await _services.water.latest(homeId);
    final allElectricity = await _services.electricity.list(homeId);
    final allWater = await _services.water.list(homeId);
    final allExpenses = await _services.expenses.list(homeId);
    final allIncomes = await _services.incomes.list(homeId);
    final monthExpenses = allExpenses
        .where((e) => sameMonth(e.expenseDate, m))
        .toList();
    final monthIncomes = allIncomes
        .where((i) => sameMonth(i.incomeMonth, m))
        .toList();
    final accounts = await _services.bankAccounts.listAccounts(homeId);
    final debts = await _services.personalDebts.list(homeId);
    final savingsList = await _services.savings.list(homeId);

    var bankUsed = 0.0;
    var bankLimit = 0.0;
    final allBankPeriods = <BankAccountPeriod>[];
    for (final account in accounts) {
      bankLimit += account.creditLimit;
      final period = await _services.bankAccounts.latestPeriod(account.id);
      bankUsed += period?.balanceUsed ?? 0;
      final periods = await _services.bankAccounts.listPeriods(account.id);
      allBankPeriods.addAll(periods);
    }

    final owedToMe = sumAmounts(
      debts.where((d) => !d.iOwe && !d.isSettled).map((d) => d.remainingAmount),
    );
    final iOwe = sumAmounts(
      debts.where((d) => d.iOwe && !d.isSettled).map((d) => d.remainingAmount),
    );
    final savingsTotal = sumAmounts(savingsList.map((s) => s.currentAmount));
    final monthIncome = sumAmounts(monthIncomes.map((i) => i.amountVnd));

    return OverviewSnapshot(
      netWorth: computeNetWorth(
        savingsTotal: savingsTotal,
        owedToMeTotal: owedToMe,
        bankUsedTotal: bankUsed,
        iOweTotal: iOwe,
      ),
      latestElectricity: electricityLatest,
      latestWater: waterLatest,
      monthExpenses: totalAmount(monthExpenses),
      monthIncome: monthIncome,
      bankUsed: bankUsed,
      bankLimit: bankLimit,
      debtNet: owedToMe - iOwe,
      savingsTotal: savingsTotal,
      incomeSpendHistory: buildIncomeSpendHistory(
        endMonth: m,
        incomes: allIncomes,
        expenses: allExpenses,
        electricity: allElectricity,
        water: allWater,
        bankPeriods: allBankPeriods,
      ),
      categorySpend: spendByCategory(monthExpenses),
    );
  }
}
