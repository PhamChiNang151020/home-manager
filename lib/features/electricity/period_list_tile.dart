import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_colors.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/status_badge.dart";
import "package:intl/intl.dart";

class PeriodListTile extends StatelessWidget {
  const PeriodListTile({
    super.key,
    required this.period,
    required this.home,
    required this.onTap,
  });

  final ElectricityPeriod period;
  final Home home;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat("MM/yyyy").format(period.periodMonth);
    final hasPhoto = period.photoPath != null && period.photoPath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                StatusBadge(
                  label: hasPhoto ? S.hasPhoto : S.noPhoto,
                  variant: hasPhoto
                      ? StatusBadgeVariant.success
                      : StatusBadgeVariant.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            MoneyText(amount: period.amountVnd, large: true),
            if (home.trackingMode == TrackingMode.meter) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                "${period.previousKwh?.toStringAsFixed(0) ?? '–'} → "
                "${period.newKwh?.toStringAsFixed(0) ?? '–'} kWh"
                "${period.consumptionKwh != null ? ' · ${period.consumptionKwh!.toStringAsFixed(1)} kWh' : ''}",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
            if (period.note != null && period.note!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                period.note!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
