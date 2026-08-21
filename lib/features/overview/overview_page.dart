import "package:flutter/material.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/domain/month_balance.dart";
import "package:home_manager/core/domain/month_clamp.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/water_service.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/electricity/reminder_banner.dart";
import "package:home_manager/features/expenses/expense_category_chart.dart";
import "package:home_manager/features/finance/finance_hub_page.dart";
import "package:home_manager/features/income/income_page.dart";
import "package:home_manager/features/overview/overview_shortcut_grid.dart";
import "package:home_manager/features/overview/overview_spend_trend_chart.dart";
import "package:home_manager/features/overview/overview_summary_card.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/loading_view.dart";
import "package:home_manager/features/shared/month_stepper_field.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/water/water_page.dart";

class OverviewPage extends StatefulWidget {
  const OverviewPage({
    super.key,
    required this.home,
    required this.services,
    required this.currentUserId,
  });

  final Home home;
  final AppServices services;
  final String currentUserId;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late DateTime _month;
  MonthBalance? _balance;
  List<MonthBalancePoint> _history = [];
  double? _spendDeltaPercent;
  List<CategorySpend> _spend = [];
  double _financeAmount = 0;
  bool _loading = true;

  Home get home => widget.home;
  AppServices get services => widget.services;

  @override
  void initState() {
    super.initState();
    _month = currentMonth();
    _load();
  }

  @override
  void didUpdateWidget(covariant OverviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home.id != widget.home.id) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final incomes = await services.incomes.list(home.id);
      final electricity = await services.electricity.list(home.id);
      final water = await services.water.list(home.id);
      final expenses = await services.expenses.list(home.id);
      final financeAmount = await _loadFinanceAmount();
      if (!mounted) return;
      final history = balancesForMonths(
        endMonth: _month,
        incomes: incomes,
        electricity: electricity,
        water: water,
        expenses: expenses,
      );
      final balance = history.last.balance;
      final previous =
          history.length >= 2 ? history[history.length - 2].balance : null;
      setState(() {
        _history = history;
        _balance = balance;
        _spendDeltaPercent =
            previous == null
                ? null
                : monthOverMonthPercent(balance.totalOut, previous.totalOut);
        _spend = spendByCategory(
          expenses
              .where((item) => sameMonth(item.expenseDate, _month))
              .toList(),
        );
        _financeAmount = financeAmount;
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load overview", error: e, stackTrace: st);
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Savings − credit used − (mình nợ) + (người khác nợ mình).
  Future<double> _loadFinanceAmount() async {
    try {
      final accounts = await services.bankAccounts.listAccounts(home.id);
      var creditUsed = 0.0;
      for (final a in accounts) {
        final period = await services.bankAccounts.latestPeriod(a.id);
        creditUsed += period?.balanceUsed ?? 0;
      }
      final debts = await services.personalDebts.list(home.id);
      var iOwe = 0.0;
      var owedToMe = 0.0;
      for (final d in debts) {
        if (d.isSettled) continue;
        if (d.iOwe) {
          iOwe += d.remainingAmount;
        } else {
          owedToMe += d.remainingAmount;
        }
      }
      final savings = await services.savings.list(home.id);
      final savingsTotal = savings.fold<double>(
        0,
        (sum, s) => sum + s.currentAmount,
      );
      return savingsTotal - creditUsed - iOwe + owedToMe;
    } catch (e, st) {
      AppLog.e("Failed to load finance summary", error: e, stackTrace: st);
      return 0;
    }
  }

  void _openElectricity(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: ElectricityRoutePage(
          home: home,
          electricity: services.electricity,
          photos: services.photos,
        ),
      ),
    );
  }

  void _openIncome(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(page: IncomeRoutePage(home: home, services: services)),
    );
  }

  void _openWater(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: WaterRoutePage(
          home: home,
          water: services.water,
          photos: services.photos,
        ),
      ),
    );
  }

  void _openFinance(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: FinanceHubPage(
          home: home,
          services: services,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _balance == null) {
      return const LoadingView();
    }

    return LoadingOverlay(
      loading: _loading,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppSpacing.shellListPadding,
          children: [
            AnimatedEntrance(index: 0, child: ReminderBanner(home: home)),
            MonthStepperField(
              month: _month,
              onChanged: (value) {
                setState(() => _month = value);
                _load();
              },
            ),
            if (_balance != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AnimatedEntrance(
                index: 1,
                child: OverviewSummaryCard(
                  balance: _balance!,
                  spendDeltaPercent: _spendDeltaPercent,
                ),
              ),
            ],
            if (_history.length >= 2) ...[
              const SizedBox(height: AppSpacing.sm),
              AnimatedEntrance(
                index: 2,
                child: OverviewSpendTrendChart(points: _history),
              ),
            ],
            if (_spend.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              AnimatedEntrance(
                index: 3,
                child: ExpenseCategoryChart(spend: _spend),
              ),
            ],
            const AnimatedEntrance(
              index: 4,
              child: SectionHeader(title: S.overview),
            ),
            AnimatedEntrance(
              index: 5,
              child: OverviewShortcutGrid(
                electricityAmount: _balance?.electricity ?? 0,
                waterAmount: _balance?.water ?? 0,
                incomeAmount: _balance?.income ?? 0,
                financeAmount: _financeAmount,
                onElectricity: () => _openElectricity(context),
                onWater: () => _openWater(context),
                onIncome: () => _openIncome(context),
                onFinance: () => _openFinance(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElectricityRoutePage extends StatefulWidget {
  const ElectricityRoutePage({
    super.key,
    required this.home,
    required this.electricity,
    required this.photos,
  });

  final Home home;
  final ElectricityService electricity;
  final BillPhotoService photos;

  @override
  State<ElectricityRoutePage> createState() => _ElectricityRoutePageState();
}

class _ElectricityRoutePageState extends State<ElectricityRoutePage> {
  final _pageKey = GlobalKey<ElectricityPageState>();

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.electricity,
      titleIcon: AppIcons.electricity,
      actionLabel: S.addPeriod,
      onAction: () => _pageKey.currentState?.openAddForm(),
      body: ElectricityPage(
        key: _pageKey,
        home: widget.home,
        electricity: widget.electricity,
        photos: widget.photos,
      ),
    );
  }
}

class WaterRoutePage extends StatefulWidget {
  const WaterRoutePage({
    super.key,
    required this.home,
    required this.water,
    required this.photos,
  });

  final Home home;
  final WaterService water;
  final BillPhotoService photos;

  @override
  State<WaterRoutePage> createState() => _WaterRoutePageState();
}

class _WaterRoutePageState extends State<WaterRoutePage> {
  final _pageKey = GlobalKey<WaterPageState>();

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.water,
      titleIcon: AppIcons.water,
      actionLabel: S.addWaterPeriod,
      onAction: () => _pageKey.currentState?.openAddForm(),
      body: WaterPage(
        key: _pageKey,
        home: widget.home,
        water: widget.water,
        photos: widget.photos,
      ),
    );
  }
}
