import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/water_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/animated_money_text.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:intl/intl.dart";

class WaterSummaryCard extends StatelessWidget {
  const WaterSummaryCard({
    super.key,
    required this.home,
    required this.periods,
  });

  final Home home;
  final List<WaterPeriod> periods;

  static String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  static String _formatM3(double kwh) {
    final rounded = kwh.round();
    return kwh == rounded.toDouble()
        ? rounded.toString()
        : kwh.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (periods.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.appColors;
    final latest = periods.first;
    final recent = periods.take(6).toList();
    final avg =
        (recent.fold<double>(0, (sum, p) => sum + p.amountVnd) / recent.length)
            .roundToDouble();

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.lastPeriod,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            _capitalizeFirst(
              DateFormat("MMMM yyyy", "vi").format(latest.periodMonth),
            ),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedMoneyText(amount: latest.amountVnd, large: true),
          if (home.trackingMode == TrackingMode.meter &&
              latest.consumptionM3 != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              "${S.consumption}: ${_formatM3(latest.consumptionM3!)} m³",
              style: TextStyle(color: colors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
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
