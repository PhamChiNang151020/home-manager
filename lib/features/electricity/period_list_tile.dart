import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
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
    final colors = context.appColors;
    final monthLabel = DateFormat("MM/yyyy").format(period.periodMonth);
    final hasPhoto = period.photoPath != null && period.photoPath!.isNotEmpty;
    final hasNote = period.note != null && period.note!.isNotEmpty;
    final recordedLabel = DateFormat(
      "dd/MM/yyyy HH:mm",
    ).format(period.recordedAt.toLocal());

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            MoneyText(amount: period.amountVnd, large: true),
            if (home.trackingMode == TrackingMode.meter) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                "${period.previousKwh?.toStringAsFixed(0) ?? '–'} → "
                "${period.newKwh?.toStringAsFixed(0) ?? '–'} kWh"
                "${period.consumptionKwh != null ? ' · ${period.consumptionKwh!.toStringAsFixed(1)} kWh' : ''}",
                style: TextStyle(color: colors.textSecondary),
              ),
            ],
            if (hasNote) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                period.note!,
                style: TextStyle(color: colors.textMuted, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                StatusBadge(
                  label: hasPhoto ? S.hasPhoto : S.noPhoto,
                  variant:
                      hasPhoto
                          ? StatusBadgeVariant.success
                          : StatusBadgeVariant.warning,
                ),
                if (home.trackingMode == TrackingMode.meter &&
                    period.consumptionKwh != null)
                  StatusBadge(
                    label: "${period.consumptionKwh!.toStringAsFixed(0)} kWh",
                    variant: StatusBadgeVariant.accent,
                  ),
                if (hasNote)
                  const StatusBadge(
                    label: S.hasNote,
                    variant: StatusBadgeVariant.neutral,
                  ),
                StatusBadge(
                  label: recordedLabel,
                  variant: StatusBadgeVariant.neutral,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
