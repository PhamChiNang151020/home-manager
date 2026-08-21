import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/overview_service.dart";
import "package:home_manager/core/services/water_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/bank_credit/bank_credit_page.dart";
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/expenses/expense_category_chart.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/income/income_page.dart";
import "package:home_manager/features/overview/overview_income_spend_chart.dart";
import "package:home_manager/features/personal_debts/personal_debts_page.dart";
import "package:home_manager/features/savings/savings_page.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/animated_money_text.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/loading_view.dart";
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
  OverviewSnapshot? _snapshot;
  bool _loading = true;

  Home get home => widget.home;
  AppServices get services => widget.services;

  @override
  void initState() {
    super.initState();
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
      final snapshot = await OverviewService(services).load(home.id);
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load overview", error: e, stackTrace: st);
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _snapshot == null) {
      return const LoadingView();
    }

    final snap = _snapshot;
    final colors = context.appColors;
    final heroStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: snap != null && snap.netWorth >= 0 ? colors.success : colors.error,
      fontWeight: FontWeight.w800,
      height: 1.05,
    );

    return LoadingOverlay(
      loading: _loading,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppSpacing.shellListPadding,
          children: [
            if (snap != null) ...[
              AnimatedEntrance(
                index: 0,
                child: Material(
                  color: colors.bgElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedMoneyText(
                          amount: snap.netWorth,
                          large: true,
                          style: heroStyle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          S.netWorthHomeLabel(home.name),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AnimatedEntrance(
                index: 1,
                child: OverviewIncomeSpendChart(
                  points: snap.incomeSpendHistory,
                ),
              ),
              if (snap.categorySpend.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AnimatedEntrance(
                  index: 2,
                  child: ExpenseCategoryChart(spend: snap.categorySpend),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AnimatedEntrance(
                index: 3,
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2.2,
                  children: [
                    _QuickCard(
                      iconPath: AppIcons.electricity,
                      title: S.electricity,
                      value:
                          snap.latestElectricity == null
                              ? "—"
                              : VndFormat.compact(
                                snap.latestElectricity!.amountVnd,
                              ),
                      onTap: () => _pushElectricity(context),
                    ),
                    _QuickCard(
                      iconPath: AppIcons.water,
                      title: S.water,
                      value:
                          snap.latestWater == null
                              ? "—"
                              : VndFormat.compact(snap.latestWater!.amountVnd),
                      onTap: () => _pushWater(context),
                    ),
                    _QuickCard(
                      iconPath: AppIcons.expenses,
                      title: S.expenses,
                      value: VndFormat.compact(snap.monthExpenses),
                      onTap: () => _pushExpenses(context),
                    ),
                    _QuickCard(
                      iconPath: AppIcons.income,
                      title: S.income,
                      value: VndFormat.compact(snap.monthIncome),
                      onTap: () => _pushIncome(context),
                    ),
                    _QuickCard(
                      icon: Icons.credit_card_outlined,
                      title: S.bankCredit,
                      value: VndFormat.compact(snap.bankUsed),
                      onTap: () => _pushBank(context),
                    ),
                    _QuickCard(
                      icon: Icons.handshake_outlined,
                      title: S.personalDebts,
                      value: VndFormat.compact(snap.debtNet),
                      onTap: () => _pushDebts(context),
                    ),
                    _QuickCard(
                      icon: Icons.savings_outlined,
                      title: S.savings,
                      value: VndFormat.compact(snap.savingsTotal),
                      onTap: () => _pushSavings(context),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _pushElectricity(BuildContext context) {
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

  void _pushWater(BuildContext context) {
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

  void _pushExpenses(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: FeaturePageScaffold(
          title: S.expenses,
          titleIcon: AppIcons.expenses,
          body: ExpensesPage(
            home: home,
            expenses: services.expenses,
            homesApi: services.homes,
            photos: services.photos,
            currentUserId: widget.currentUserId,
          ),
        ),
      ),
    );
  }

  void _pushIncome(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(page: IncomeRoutePage(home: home, services: services)),
    );
  }

  void _pushBank(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: BankCreditRoutePage(home: home, bank: services.bankAccounts),
      ),
    );
  }

  void _pushDebts(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: PersonalDebtsRoutePage(
          home: home,
          debts: services.personalDebts,
          currentUserId: widget.currentUserId,
        ),
      ),
    );
  }

  void _pushSavings(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(
        page: SavingsRoutePage(home: home, savings: services.savings),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.title,
    required this.value,
    required this.onTap,
    this.iconPath,
    this.icon,
  });

  final String? iconPath;
  final IconData? icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (iconPath != null)
            AppAssetIcon(iconPath!, size: 22)
          else if (icon != null)
            Icon(icon, size: 22, color: colors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.electricity,
      titleIcon: AppIcons.electricity,
      body: ElectricityPage(
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
  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: S.water,
      titleIcon: AppIcons.water,
      body: WaterPage(
        home: widget.home,
        water: widget.water,
        photos: widget.photos,
      ),
    );
  }
}
