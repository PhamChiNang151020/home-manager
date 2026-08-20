import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/water_period.dart";
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

String _fmtM3(double? kwh) {
  if (kwh == null) return "–";
  final rounded = kwh.round();
  return kwh == rounded.toDouble()
      ? rounded.toString()
      : kwh.toStringAsFixed(1);
}

class WaterPeriodListTile extends StatelessWidget {
  const WaterPeriodListTile({
    super.key,
    required this.period,
    required this.home,
    required this.photos,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePaid,
    this.previousPeriod,
  });

  final WaterPeriod period;
  final WaterPeriod? previousPeriod;
  final Home home;
  final BillPhotoService photos;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePaid;

  _TrendData? _trend() {
    final prev = previousPeriod;
    if (prev == null || prev.amountVnd == 0) return null;
    final delta = period.amountVnd - prev.amountVnd;
    final pct = (delta / prev.amountVnd * 100).roundToDouble();
    return _TrendData(pct: pct, up: delta > 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final monthLabel = DateFormat("MM/yyyy").format(period.periodMonth);
    final hasPhoto = period.photoPath != null && period.photoPath!.isNotEmpty;
    final hasNote = period.note != null && period.note!.isNotEmpty;
    final recordedLabel = DateFormat(
      "dd/MM/yyyy HH:mm",
    ).format(period.recordedAt.toLocal());
    final trend = _trend();
    final isMeter = home.trackingMode == TrackingMode.meter;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Row 1: tháng (trái) + kebab (phải) ──────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _KebabMenu(
                  isPaid: period.isPaid,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onTogglePaid: onTogglePaid,
                ),
              ],
            ),
            const SizedBox(height: 2),
            // ── Row 2: tiền + trend (trái) | trạng thái paid (phải) ──────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      MoneyText(amount: period.amountVnd, large: true),
                      if (trend != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        _TrendChip(trend: trend, colors: colors),
                      ],
                    ],
                  ),
                ),
                StatusBadge(
                  label: period.isPaid ? S.paid : S.unpaid,
                  variant:
                      period.isPaid
                          ? StatusBadgeVariant.success
                          : StatusBadgeVariant.neutral,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // ── Row 3: m³ (trái) | ảnh (phải) ─────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // cột trái: m³ + ghi chú
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMeter)
                        Text(
                          "${_fmtM3(period.previousM3)} → "
                          "${_fmtM3(period.newM3)} m³",
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      if (isMeter && period.consumptionM3 != null) ...[
                        const SizedBox(height: 2),
                        StatusBadge(
                          label: "${_fmtM3(period.consumptionM3!)} m³",
                          variant: StatusBadgeVariant.accent,
                        ),
                      ],
                      if (hasNote) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          period.note!,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // cột phải: ảnh + ngày ghi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                    const SizedBox(height: 4),
                    Text(
                      recordedLabel,
                      style: TextStyle(color: colors.textMuted, fontSize: 11),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trend chip ──────────────────────────────────────────────────────────────

class _TrendData {
  const _TrendData({required this.pct, required this.up});
  final double pct;
  final bool up;
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.trend, required this.colors});
  final _TrendData trend;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final isZero = trend.pct == 0;
    final color =
        isZero
            ? colors.textMuted
            : trend.up
            ? colors.error
            : colors.success;
    final icon =
        isZero
            ? Icons.remove
            : trend.up
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;
    final label =
        isZero
            ? "0%"
            : "${trend.up ? "+" : ""}${trend.pct.abs().toStringAsFixed(0)}%";

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kebab menu ──────────────────────────────────────────────────────────────

class _KebabMenu extends StatelessWidget {
  const _KebabMenu({
    required this.isPaid,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePaid,
  });

  final bool isPaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePaid;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PopupMenuButton<_MenuAction>(
      icon: Icon(Icons.more_vert, size: 20, color: colors.textMuted),
      iconSize: 20,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _MenuAction.edit:
            onEdit();
          case _MenuAction.delete:
            onDelete();
          case _MenuAction.togglePaid:
            onTogglePaid();
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: _MenuAction.edit,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined, size: 18),
                title: const Text(S.edit),
              ),
            ),
            PopupMenuItem(
              value: _MenuAction.togglePaid,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isPaid
                      ? Icons.unpublished_outlined
                      : Icons.check_circle_outline,
                  size: 18,
                ),
                title: Text(isPaid ? S.markUnpaid : S.markPaid),
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _MenuAction.delete,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: colors.error,
                ),
                title: Text(S.delete, style: TextStyle(color: colors.error)),
              ),
            ),
          ],
    );
  }
}

enum _MenuAction { edit, delete, togglePaid }
