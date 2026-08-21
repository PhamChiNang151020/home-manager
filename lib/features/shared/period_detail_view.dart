import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/status_badge.dart";
import "package:intl/intl.dart";

class PeriodDetailView extends StatelessWidget {
  const PeriodDetailView({
    super.key,
    required this.month,
    required this.amountVnd,
    required this.recordedAt,
    required this.isPaid,
    this.consumptionIcon,
    this.consumptionValue,
    this.photoPath,
    this.onViewPhoto,
    this.note,
  });

  final DateTime month;
  final double amountVnd;
  final DateTime recordedAt;
  final bool isPaid;
  final IconData? consumptionIcon;
  final String? consumptionValue;
  final String? photoPath;
  final VoidCallback? onViewPhoto;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final monthLabel = DateFormat("MM/yyyy").format(month);
    final recordedLabel = DateFormat(
      "dd/MM/yyyy HH:mm",
    ).format(recordedAt.toLocal());
    final hasNote = note != null && note!.isNotEmpty;
    final hasPhoto = photoPath != null && photoPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        PeriodDetailInfoRow(
          icon: Icons.calendar_today_outlined,
          label: S.month,
          value: monthLabel,
        ),
        const Divider(height: AppSpacing.lg),
        PeriodDetailInfoRow(
          icon: Icons.payments_outlined,
          label: S.amount,
          value: VndFormat.format(amountVnd),
          valueColor: colors.accent,
          valueBold: true,
        ),
        if (consumptionValue != null) ...[
          const Divider(height: AppSpacing.lg),
          PeriodDetailInfoRow(
            icon: consumptionIcon ?? Icons.speed_outlined,
            label: S.consumption,
            value: consumptionValue!,
          ),
        ],
        const Divider(height: AppSpacing.lg),
        PeriodDetailInfoRow(
          icon: Icons.schedule_outlined,
          label: S.recordedAt,
          value: recordedLabel,
        ),
        const Divider(height: AppSpacing.lg),
        PeriodDetailInfoRow(
          icon: Icons.image_outlined,
          label: S.photo,
          value: hasPhoto ? S.viewPhoto : S.noPhoto,
          valueColor: hasPhoto ? colors.success : colors.textMuted,
          onTap: onViewPhoto,
        ),
        const Divider(height: AppSpacing.lg),
        PeriodDetailInfoRow(
          icon: Icons.check_circle_outline,
          label: S.paid,
          value: isPaid ? S.paid : S.unpaid,
          valueWidget: StatusBadge(
            label: isPaid ? S.paid : S.unpaid,
            variant:
                isPaid
                    ? StatusBadgeVariant.success
                    : StatusBadgeVariant.warning,
            large: true,
          ),
        ),
        if (hasNote) ...[
          const Divider(height: AppSpacing.lg),
          PeriodDetailInfoRow(
            icon: Icons.notes_outlined,
            label: S.note,
            value: note!,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class PeriodDetailInfoRow extends StatelessWidget {
  const PeriodDetailInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
    this.valueWidget,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  final Widget? valueWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final valueChild =
        valueWidget ??
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: valueColor ?? colors.textPrimary,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 15,
          ),
        );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: colors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child:
                onTap != null
                    ? DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colors.accent.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: valueChild,
                    )
                    : valueChild,
          ),
        ),
      ],
    );

    if (onTap == null) return row;
    return GestureDetector(onTap: onTap, child: row);
  }
}
