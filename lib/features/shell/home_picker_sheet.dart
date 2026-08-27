import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_sheet.dart";

Future<void> showHomePickerSheet({
  required BuildContext context,
  required List<Home> homes,
  required Home? selected,
  required ValueChanged<Home> onSelected,
  required VoidCallback onAddHome,
}) {
  return showAppSheet<void>(
    context: context,
    isScrollControlled: false,
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
              Text(S.switchHome, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              HomePickerList(
                homes: homes,
                selected: selected,
                onSelected: (home) {
                  Navigator.pop(context);
                  onSelected(home);
                },
                onAddHome: () {
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

class HomePickerList extends StatelessWidget {
  const HomePickerList({
    super.key,
    required this.homes,
    required this.selected,
    required this.onSelected,
    required this.onAddHome,
  });

  final List<Home> homes;
  final Home? selected;
  final ValueChanged<Home> onSelected;
  final VoidCallback onAddHome;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final home in homes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              home.id == selected?.id
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: home.id == selected?.id ? colors.accent : colors.textMuted,
            ),
            title: Text(home.name),
            onTap: () => onSelected(home),
          ),
        if (homes.isNotEmpty) const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.add_home_outlined, color: colors.accent),
          title: const Text(S.addHome),
          onTap: onAddHome,
        ),
      ],
    );
  }
}
