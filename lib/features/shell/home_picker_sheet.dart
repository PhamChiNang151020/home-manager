import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_colors.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/status_badge.dart";

Future<void> showHomePickerSheet({
  required BuildContext context,
  required List<Home> homes,
  required Home? selected,
  required ValueChanged<Home> onSelected,
  required VoidCallback onAddHome,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.switchHome,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final home in homes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    home.id == selected?.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: home.id == selected?.id
                        ? AppColors.accent
                        : AppColors.textMuted,
                  ),
                  title: Text(home.name),
                  subtitle: Text(
                    home.trackingMode == TrackingMode.meter
                        ? S.modeMeter
                        : S.modeInvoice,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(home);
                  },
                ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_home_outlined, color: AppColors.accent),
                title: const Text(S.addHome),
                onTap: () {
                  Navigator.pop(context);
                  onAddHome();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget trackingModeChip(TrackingMode mode) {
  return StatusBadge(
    label: mode == TrackingMode.meter ? S.modeMeterShort : S.modeInvoiceShort,
    variant: mode == TrackingMode.meter
        ? StatusBadgeVariant.accent
        : StatusBadgeVariant.neutral,
  );
}
