import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:intl/intl.dart";

class ElectricitySummaryCard extends StatelessWidget {
  const ElectricitySummaryCard({
    super.key,
    required this.home,
    required this.periods,
  });

  final Home home;
  final List<ElectricityPeriod> periods;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (periods.isEmpty) {
      return AppCard(
        child: Text(
          S.noPeriods,
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    final latest = periods.first;
    final recent = periods.take(6).toList();
    final avg = recent.fold<double>(0, (sum, p) => sum + p.amountVnd) /
        recent.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.lastPeriod,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat("MMMM yyyy", "vi").format(latest.periodMonth),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          MoneyText(amount: latest.amountVnd, large: true),
          if (home.trackingMode == TrackingMode.meter &&
              latest.consumptionKwh != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              "${S.consumption}: ${latest.consumptionKwh!.toStringAsFixed(1)} kWh",
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.avgSixMonths,
                style: TextStyle(color: colors.textSecondary),
              ),
              MoneyText(amount: avg),
            ],
          ),
        ],
      ),
    );
  }
}
