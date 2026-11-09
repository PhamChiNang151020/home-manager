import "package:flutter/material.dart";
import "package:home_manager/core/domain/month_clamp.dart";
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
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/electricity/reminder_banner.dart";
import "package:home_manager/features/expenses/expense_category_chart.dart";
import "package:home_manager/features/income/income_page.dart";
import "package:home_manager/features/overview/overview_income_spend_chart.dart";
import "package:home_manager/features/shared/animated_entrance.dart";
import "package:home_manager/features/shared/animated_money_text.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_refresh_indicator.dart";
import "package:home_manager/features/shared/error_view.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/skeleton.dart";
import "package:home_manager/features/shell/quick_add_picker_sheet.dart";
import "package:home_manager/features/water/water_page.dart";

class OverviewPage extends StatefulWidget {
  const OverviewPage({
    super.key,
    required this.home,
    required this.services,
    required this.currentUserId,
    this.onOpenAssets,
    this.onOpenExpenses,
    this.loadOverview,
  });

  final Home home;
  final AppServices services;
  final String currentUserId;
  final VoidCallback? onOpenAssets;
  final VoidCallback? onOpenExpenses;

  /// Test seam: when set, skips [OverviewService] and uses this loader.
  final Future<OverviewSnapshot> Function(String homeId)? loadOverview;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  OverviewSnapshot? _snapshot;
  bool _loading = true;
  bool _failed = false;

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

  Future<void> _refresh() => _load(showOverlay: false);

  Future<void> _load({bool showOverlay = true}) async {
    if (showOverlay) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }
    try {
      final loader = widget.loadOverview;
      final snapshot =
          loader != null
              ? await loader(home.id)
              : await OverviewService(services).load(home.id);
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
        _failed = false;
      });
    } catch (e, st) {
      AppLog.e("Failed to load overview", error: e, stackTrace: st);
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _snapshot == null) {
      return ListView(
        padding: AppSpacing.shellListPadding,
        children: const [
          SkeletonBox(width: double.infinity, height: 98, borderRadius: 16),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(width: double.infinity, height: 79, borderRadius: 16),
          SizedBox(height: AppSpacing.lg),
          SkeletonBox(width: 200, height: 24, borderRadius: 8),
          SizedBox(height: AppSpacing.sm),
          SkeletonBox(width: double.infinity, height: 204, borderRadius: 16),
        ],
      );
    }

    if (_failed && _snapshot == null) {
      return ListView(
        padding: AppSpacing.shellListPadding,
        children: [
          ErrorView(message: S.loadFailedTitle, onRetry: _load),
        ],
      );
    }

    final snap = _snapshot;
    if (snap == null) return const SizedBox.shrink();

    final colors = context.appColors;
    final month = currentMonth().month;
    final netPositive = snap.netWorth >= 0;
    final heroStyle = TextStyle(
      color: netPositive ? colors.success : colors.error,
      fontWeight: FontWeight.w800,
      fontSize: 32,
      height: 40 / 32,
      fontFamily: "Nunito",
    );

    return AppRefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: AppSpacing.shellListPadding,
        children: [
          ReminderBanner(
            home: home,
            onAction:
                () => showQuickAddPickerSheet(
                  context: context,
                  home: home,
                  services: services,
                  currentUserId: widget.currentUserId,
                  onSaved: _load,
                ),
          ),
          AnimatedEntrance(
            index: 0,
            // Spec hero y 123–221 (98): label 12/16 + gap 4 + amount 32/40,
            // padding top/bottom 17 incl. 1px border -> layout padding 19.
            child: SizedBox(
              height: 98,
              child: AppCard(
                key: const ValueKey("overview-net-worth"),
                onTap: widget.onOpenAssets,
                padding: const EdgeInsets.fromLTRB(16, 19, 16, 19),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.netWorthHomeLabel(home.name),
                            style: TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                              fontFamily: "Nunito",
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedMoneyText(
                            amount: snap.netWorth,
                            large: true,
                            style: heroStyle,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 24, color: colors.textMuted),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedEntrance(
            index: 1,
            child: AppCard(
              key: const ValueKey("overview-month"),
              padding: EdgeInsets.zero,
              child: SizedBox(
                height: 79,
                child: Row(
                  children: [
                    Expanded(
                      child: _MonthHalf(
                        icon: AppIcons.expenses,
                        label: S.monthSpentLabel(month),
                        amount: snap.monthExpenses,
                        onTap: widget.onOpenExpenses,
                      ),
                    ),
                    Container(width: 1, color: colors.border),
                    Expanded(
                      child: _MonthHalf(
                        icon: AppIcons.income,
                        label: S.monthIncomeLabel(month),
                        amount: snap.monthIncome,
                        onTap: () => _pushIncome(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedEntrance(
            index: 2,
            child: OverviewIncomeSpendChart(
              points: snap.incomeSpendHistory,
            ),
          ),
          if (snap.categorySpend.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            AnimatedEntrance(
              index: 3,
              child: ExpenseCategoryChart(spend: snap.categorySpend),
            ),
          ],
        ],
      ),
    );
  }

  void _pushIncome(BuildContext context) {
    Navigator.push<void>(
      context,
      AppPageRoute<void>(page: IncomeRoutePage(home: home, services: services)),
    );
  }
}

class _MonthHalf extends StatelessWidget {
  const _MonthHalf({
    required this.icon,
    required this.label,
    required this.amount,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final double amount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accent.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, size: 14, color: colors.accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: colors.textSecondary,
                      fontFamily: "Nunito",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              VndFormat.format(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                fontFamily: "Nunito",
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
