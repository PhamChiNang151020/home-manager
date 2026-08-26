import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_accent.dart";

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.glass,
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.border,
    required this.glassFill,
    required this.glassBorder,
    required this.ambientTop,
    required this.ambientBottom,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.catFood,
    required this.catLoan,
    required this.catHealth,
    required this.catTuition,
    required this.catOther,
  });

  /// Frosted surfaces + ambient gradient when true.
  final bool glass;

  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color border;
  final Color glassFill;
  final Color glassBorder;
  final Color ambientTop;
  final Color ambientBottom;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color success;
  final Color warning;
  final Color error;
  final Color catFood;
  final Color catLoan;
  final Color catHealth;
  final Color catTuition;
  final Color catOther;

  Color accentMuted([double opacity = 0.18]) =>
      accent.withValues(alpha: opacity);

  Color warningMuted([double opacity = 0.15]) =>
      warning.withValues(alpha: opacity);

  Color categoryColor(String colorKey) {
    return switch (colorKey) {
      "food" => catFood,
      "loan" => catLoan,
      "health" => catHealth,
      "tuition" => catTuition,
      _ => catOther,
    };
  }

  static AppColorScheme dark(Color accent, {bool glass = false}) {
    const base = Color(0xFF0B0D10);
    const surface = Color(0xFF151A21);
    return AppColorScheme(
      glass: glass,
      bgBase: base,
      bgSurface: surface,
      bgElevated: const Color(0xFF1A1E24),
      border: const Color(0xFF273140),
      glassFill: glass ? surface.withValues(alpha: 0.55) : surface,
      glassBorder:
          glass
              ? Colors.white.withValues(alpha: 0.14)
              : const Color(0xFF273140),
      ambientTop: Color.lerp(base, accent, 0.22)!,
      ambientBottom: base,
      textPrimary: const Color(0xFFE9EEF5),
      textSecondary: const Color(0xFF94A3B8),
      textMuted: const Color(0xFF7A8799),
      accent: accent,
      success: const Color(0xFF4ADE80),
      warning: const Color(0xFFFBBF24),
      error: const Color(0xFFF87171),
      catFood: const Color(0xFFF97316),
      catLoan: const Color(0xFF38BDF8),
      catHealth: const Color(0xFF34D399),
      catTuition: const Color(0xFFA78BFA),
      catOther: const Color(0xFF94A3B8),
    );
  }

  /// Pass [AppAccent.colorOnLight], not [AppAccent.color] — the bright brand
  /// tone is not legible on these backgrounds.
  static AppColorScheme light(Color accent, {bool glass = false}) {
    const base = Color(0xFFF5F6F8);
    const surface = Color(0xFFFFFFFF);
    return AppColorScheme(
      glass: glass,
      bgBase: base,
      bgSurface: surface,
      bgElevated: const Color(0xFFEEF1F5),
      border: const Color(0xFFD1D9E6),
      glassFill: glass ? surface.withValues(alpha: 0.72) : surface,
      glassBorder:
          glass
              ? Colors.white.withValues(alpha: 0.55)
              : const Color(0xFFD1D9E6),
      ambientTop: Color.lerp(base, accent, 0.12)!,
      ambientBottom: base,
      textPrimary: const Color(0xFF0F172A),
      textSecondary: const Color(0xFF475569),
      textMuted: const Color(0xFF5B6B7F),
      accent: accent,
      success: const Color(0xFF147038),
      warning: const Color(0xFF8F5606),
      error: const Color(0xFFC81E1E),
      catFood: const Color(0xFFEA580C),
      catLoan: const Color(0xFF0284C7),
      catHealth: const Color(0xFF059669),
      catTuition: const Color(0xFF7C3AED),
      catOther: const Color(0xFF64748B),
    );
  }

  @override
  AppColorScheme copyWith({
    bool? glass,
    Color? bgBase,
    Color? bgSurface,
    Color? bgElevated,
    Color? border,
    Color? glassFill,
    Color? glassBorder,
    Color? ambientTop,
    Color? ambientBottom,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? catFood,
    Color? catLoan,
    Color? catHealth,
    Color? catTuition,
    Color? catOther,
  }) {
    return AppColorScheme(
      glass: glass ?? this.glass,
      bgBase: bgBase ?? this.bgBase,
      bgSurface: bgSurface ?? this.bgSurface,
      bgElevated: bgElevated ?? this.bgElevated,
      border: border ?? this.border,
      glassFill: glassFill ?? this.glassFill,
      glassBorder: glassBorder ?? this.glassBorder,
      ambientTop: ambientTop ?? this.ambientTop,
      ambientBottom: ambientBottom ?? this.ambientBottom,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      catFood: catFood ?? this.catFood,
      catLoan: catLoan ?? this.catLoan,
      catHealth: catHealth ?? this.catHealth,
      catTuition: catTuition ?? this.catTuition,
      catOther: catOther ?? this.catOther,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other == null) return this;
    return AppColorScheme(
      glass: t < 0.5 ? glass : other.glass,
      bgBase: Color.lerp(bgBase, other.bgBase, t) ?? bgBase,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t) ?? bgSurface,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t) ?? bgElevated,
      border: Color.lerp(border, other.border, t) ?? border,
      glassFill: Color.lerp(glassFill, other.glassFill, t) ?? glassFill,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t) ?? glassBorder,
      ambientTop: Color.lerp(ambientTop, other.ambientTop, t) ?? ambientTop,
      ambientBottom:
          Color.lerp(ambientBottom, other.ambientBottom, t) ?? ambientBottom,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      catFood: Color.lerp(catFood, other.catFood, t) ?? catFood,
      catLoan: Color.lerp(catLoan, other.catLoan, t) ?? catLoan,
      catHealth: Color.lerp(catHealth, other.catHealth, t) ?? catHealth,
      catTuition: Color.lerp(catTuition, other.catTuition, t) ?? catTuition,
      catOther: Color.lerp(catOther, other.catOther, t) ?? catOther,
    );
  }
}

extension AppColorSchemeContext on BuildContext {
  AppColorScheme get appColors =>
      Theme.of(this).extension<AppColorScheme>() ??
      AppColorScheme.dark(AppAccent.amber.color);
}
