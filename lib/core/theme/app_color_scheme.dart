import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_accent.dart";

@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.bgBase,
    required this.bgSurface,
    required this.bgElevated,
    required this.border,
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

  final Color bgBase;
  final Color bgSurface;
  final Color bgElevated;
  final Color border;
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

  static AppColorScheme dark(Color accent) {
    return AppColorScheme(
      bgBase: const Color(0xFF0B0D10),
      bgSurface: const Color(0xFF151A21),
      bgElevated: const Color(0xFF1A1E24),
      border: const Color(0xFF273140),
      textPrimary: const Color(0xFFE9EEF5),
      textSecondary: const Color(0xFF94A3B8),
      textMuted: const Color(0xFF64748B),
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

  static AppColorScheme light(Color accent) {
    return AppColorScheme(
      bgBase: const Color(0xFFF5F6F8),
      bgSurface: const Color(0xFFFFFFFF),
      bgElevated: const Color(0xFFEEF1F5),
      border: const Color(0xFFD1D9E6),
      textPrimary: const Color(0xFF0F172A),
      textSecondary: const Color(0xFF64748B),
      textMuted: const Color(0xFF94A3B8),
      accent: accent,
      success: const Color(0xFF16A34A),
      warning: const Color(0xFFD97706),
      error: const Color(0xFFDC2626),
      catFood: const Color(0xFFEA580C),
      catLoan: const Color(0xFF0284C7),
      catHealth: const Color(0xFF059669),
      catTuition: const Color(0xFF7C3AED),
      catOther: const Color(0xFF64748B),
    );
  }

  @override
  AppColorScheme copyWith({
    Color? bgBase,
    Color? bgSurface,
    Color? bgElevated,
    Color? border,
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
      bgBase: bgBase ?? this.bgBase,
      bgSurface: bgSurface ?? this.bgSurface,
      bgElevated: bgElevated ?? this.bgElevated,
      border: border ?? this.border,
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
      bgBase: Color.lerp(bgBase, other.bgBase, t) ?? bgBase,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t) ?? bgSurface,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t) ?? bgElevated,
      border: Color.lerp(border, other.border, t) ?? border,
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
