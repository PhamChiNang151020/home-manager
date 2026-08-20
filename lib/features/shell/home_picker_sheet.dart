import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

Future<void> showHomePickerSheet({
  required BuildContext context,
  required List<Home> homes,
  required Home? selected,
  required ValueChanged<Home> onSelected,
  required VoidCallback onAddHome,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.appColors.bgSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.cardRadius),
      ),
    ),
    builder: (context) {
      final colors = context.appColors;
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
              Text(S.switchHome, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              for (final home in homes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    home.id == selected?.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                        home.id == selected?.id
                            ? colors.accent
                            : colors.textMuted,
                  ),
                  title: Text(home.name),
                  onTap: () {
                    Navigator.pop(context);
                    onSelected(home);
                  },
                ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.add_home_outlined, color: colors.accent),
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
