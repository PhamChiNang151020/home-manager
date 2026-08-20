import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";

class SettingsAppearancePage extends StatelessWidget {
  const SettingsAppearancePage({super.key, required this.theme});

  final ThemeController theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: theme,
      builder: (context, _) {
        final colors = context.appColors;
        return Scaffold(
          appBar: AppBar(title: const Text(S.settingsAppearance)),
          body: MobileViewport(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              Text(
                S.themeModeLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(S.themeModeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(S.themeModeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(S.themeModeDark),
                  ),
                ],
                selected: {theme.mode},
                onSelectionChanged: (selection) {
                  theme.setMode(selection.first);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                S.themeAccent,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final accent in AppAccent.values)
                    _AccentChip(
                      accent: accent,
                      selected: theme.accent == accent,
                      onTap: () => theme.setAccent(accent),
                    ),
                ],
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}

class _AccentChip extends StatelessWidget {
  const _AccentChip({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AppAccent accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      selected: selected,
      label: accent.name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: accent.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
          child:
              selected
                  ? const Icon(Icons.check, color: Colors.white, size: 24)
                  : null,
        ),
      ),
    );
  }
}
