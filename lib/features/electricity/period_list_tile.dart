import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/electricity_period.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/electricity/bill_photo_viewer.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/money_text.dart";
import "package:home_manager/features/shared/status_badge.dart";
import "package:intl/intl.dart";

String _fmtKwh(double? kwh) {
  if (kwh == null) return '–';
  final rounded = kwh.round();
  return kwh == rounded.toDouble()
      ? rounded.toString()
      : kwh.toStringAsFixed(1);
}

class PeriodListTile extends StatelessWidget {
  const PeriodListTile({
    super.key,
    required this.period,
    required this.home,
    required this.photos,
    required this.onTap,
  });

  final ElectricityPeriod period;
  final Home home;
  final BillPhotoService photos;
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
                "${_fmtKwh(period.previousKwh)} → "
                "${_fmtKwh(period.newKwh)} kWh"
                "${period.consumptionKwh != null ? ' · ${_fmtKwh(period.consumptionKwh!)} kWh' : ''}",
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
                if (home.trackingMode == TrackingMode.meter &&
                    period.consumptionKwh != null)
                  StatusBadge(
                    label: "${_fmtKwh(period.consumptionKwh!)} kWh",
                    variant: StatusBadgeVariant.accent,
                  ),
                GestureDetector(
                  onTap:
                      hasPhoto
                          ? () => showBillPhotoViewer(
                            context: context,
                            photoPath: period.photoPath!,
                            photos: photos,
                          )
                          : null,
                  child: StatusBadge(
                    label: hasPhoto ? S.hasPhoto : S.noPhoto,
                    variant:
                        hasPhoto
                            ? StatusBadgeVariant.success
                            : StatusBadgeVariant.neutral,
                  ),
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
