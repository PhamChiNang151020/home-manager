import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

abstract final class AppFonts {
  static const nunito = "Nunito";
}

abstract final class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required AppAccent accent,
    bool glass = false,
  }) {
    final colors =
        brightness == Brightness.dark
            ? AppColorScheme.dark(accent.color, glass: glass)
            : AppColorScheme.light(accent.colorOnLight, glass: glass);
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
      // Prevent M3 elevation overlays from tinting sheets/dialogs.
      surfaceTint: Colors.transparent,
    );

    final material = ThemeData(brightness: brightness, useMaterial3: true);
    final textTheme = material.textTheme.apply(
      fontFamily: AppFonts.nunito,
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    final surfaceColor = glass ? colors.glassFill : colors.bgSurface;
    final barColor = glass ? Colors.transparent : colors.bgBase;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: AppFonts.nunito,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: glass ? Colors.transparent : colors.bgBase,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: barColor,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: glass ? 0 : null,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        // Line the title up with MobileViewport instead of Material's 16.
        titleSpacing: AppSpacing.screenHorizontal,
      ),
      cardTheme: CardTheme(
        // Material defaults to 4 on every side, which pushes cards 4 further
        // in than plain Material surfaces and leaves the two misaligned.
        // Vertical only: keeps the gap between stacked cards, drops the
        // horizontal offset.
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        color: surfaceColor,
        elevation: glass ? 0 : (brightness == Brightness.dark ? 1 : 2),
        shadowColor:
            brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: glass ? colors.glassBorder : colors.border),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: glass ? colors.glassBorder : colors.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: glass ? Colors.transparent : colors.bgSurface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: colors.border,
        dragHandleSize: const Size(40, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.cardRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: colors.accentMuted(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? colors.accent : colors.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
        fillColor: surfaceColor,
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
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        helperStyle: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: onPrimary,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          // Finite width — Size.fromHeight(∞) stacks AlertDialog actions.
          minimumSize: const Size(64, AppSpacing.touchMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          side: BorderSide(color: colors.border),
          minimumSize: const Size(64, AppSpacing.touchMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          // Finite width — Size.fromHeight(∞) breaks TextButton inside Row.
          minimumSize: const Size(0, AppSpacing.touchMin),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
        minVerticalPadding: AppSpacing.sm,
      ),
    );
  }

  @Deprecated("Use AppTheme.build with ThemeController")
  static ThemeData dark() =>
      build(brightness: Brightness.dark, accent: AppAccent.amber);
}
