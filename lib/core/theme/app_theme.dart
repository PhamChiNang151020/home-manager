import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

abstract final class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required AppAccent accent,
  }) {
    final colors =
        brightness == Brightness.dark
            ? AppColorScheme.dark(accent.color)
            : AppColorScheme.light(accent.color);
    final onPrimary =
        brightness == Brightness.dark ? colors.bgBase : Colors.white;

    final scheme = ColorScheme(
      brightness: brightness,
      surface: colors.bgBase,
      onSurface: colors.textPrimary,
      primary: colors.accent,
      onPrimary: onPrimary,
      secondary: colors.bgElevated,
      onSecondary: colors.textPrimary,
      error: colors.error,
      onError: onPrimary,
      outline: colors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.bgBase,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgBase,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: colors.bgSurface,
        elevation: brightness == Brightness.dark ? 1 : 2,
        shadowColor:
            brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: colors.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.bgSurface,
        indicatorColor: colors.accentMuted(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? colors.accent : colors.textSecondary,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.accent : colors.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: colors.textMuted),
        helperStyle: TextStyle(color: colors.textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(AppSpacing.touchMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          minimumSize: const Size.fromHeight(AppSpacing.touchMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          minimumSize: const Size.fromHeight(AppSpacing.touchMin),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        minVerticalPadding: AppSpacing.sm,
      ),
    );
  }

  @Deprecated("Use AppTheme.build with ThemeController")
  static ThemeData dark() =>
      build(brightness: Brightness.dark, accent: AppAccent.amber);
}
