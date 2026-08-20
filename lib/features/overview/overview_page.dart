import "package:flutter/material.dart";
import "package:home_manager/core/domain/expense_totals.dart";
import "package:home_manager/core/domain/month_balance.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/water_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/electricity/reminder_banner.dart";
import "package:home_manager/features/expenses/expense_category_chart.dart";
import "package:home_manager/features/income/income_page.dart";
import "package:home_manager/features/overview/overview_summary_card.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";
import "package:home_manager/features/shared/month_picker.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/water/water_page.dart";
import "package:intl/intl.dart";

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key, required this.home, required this.services});

  final Home home;
  final AppServices services;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late DateTime _month;
  MonthBalance? _balance;
  List<CategorySpend> _spend = [];
  bool _loading = true;

  Home get home => widget.home;
  AppServices get services => widget.services;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
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
      final incomes = await services.incomes.list(home.id, month: _month);
      final electricity = await services.electricity.list(home.id);
      final water = await services.water.list(home.id);
      final expenses = await services.expenses.list(home.id, month: _month);
      final elecMonth = electricity
          .where(
            (p) =>
                p.periodMonth.year == _month.year &&
                p.periodMonth.month == _month.month,
          )
          .fold<double>(0, (sum, p) => sum + p.amountVnd);
      final waterMonth = water
          .where(
            (p) =>
                p.periodMonth.year == _month.year &&
                p.periodMonth.month == _month.month,
          )
          .fold<double>(0, (sum, p) => sum + p.amountVnd);
      if (!mounted) return;
      setState(() {
        _balance = computeMonthBalance(
          income: incomes.fold<double>(0, (sum, i) => sum + i.amountVnd),
          electricity: elecMonth,
          water: waterMonth,
          expenses: expenses.fold<double>(0, (sum, e) => sum + e.amountVnd),
        );
        _spend = spendByCategory(expenses);
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load overview", error: e, stackTrace: st);
      if (mounted) setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return LoadingOverlay(
      loading: _loading,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            AnimatedEntrance(index: 0, child: ReminderBanner(home: home)),
            LabeledPickerField(
              label: S.month,
              value: DateFormat("MM/yyyy").format(_month),
              onTap: () async {
                final picked = await showMonthPicker(
                  context: context,
                  initialDate: _month,
                );
                if (picked != null) {
                  setState(() => _month = DateTime(picked.year, picked.month));
                  _load();
                }
              },
            ),
            if (_balance != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AnimatedEntrance(
                index: 1,
                child: OverviewSummaryCard(balance: _balance!),
              ),
            ],
            if (_spend.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              AnimatedEntrance(
                index: 2,
                child: ExpenseCategoryChart(spend: _spend),
              ),
            ],
            const AnimatedEntrance(
              index: 3,
              child: SectionHeader(title: S.overview),
            ),
            AnimatedEntrance(
              index: 4,
              child: AppCard(
                onTap: () => _openElectricity(context),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const AppAssetIcon(AppIcons.electricity, size: 32),
                  title: const Text(S.electricity),
                  trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AnimatedEntrance(
              index: 5,
              child: AppCard(
                onTap: () => _openWater(context),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const AppAssetIcon(AppIcons.water, size: 32),
                  title: const Text(S.water),
                  trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AnimatedEntrance(
              index: 6,
              child: AppCard(
                onTap: () => _openIncome(context),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const AppAssetIcon(AppIcons.income, size: 32),
                  title: const Text(S.income),
                  trailing: Icon(Icons.chevron_right, color: colors.textMuted),
                ),
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
