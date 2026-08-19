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

  Color accentMuted([double opacity = 0.18]) =>
      accent.withValues(alpha: opacity);

  Color warningMuted([double opacity = 0.15]) =>
      warning.withValues(alpha: opacity);

  static AppColorScheme dark(Color accent) {
    return AppColorScheme(
      bgBase: const Color(0xFF0B0D10),
      bgSurface: const Color(0xFF151A21),
      bgElevated: const Color(0xFF1C2430),
      border: const Color(0xFF273140),
      textPrimary: const Color(0xFFE9EEF5),
      textSecondary: const Color(0xFF94A3B8),
      textMuted: const Color(0xFF64748B),
      accent: accent,
      success: const Color(0xFF4ADE80),
      warning: const Color(0xFFFBBF24),
      error: const Color(0xFFF87171),
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
    );
  }
}

extension AppColorSchemeContext on BuildContext {
  AppColorScheme get appColors =>
      Theme.of(this).extension<AppColorScheme>() ??
      AppColorScheme.dark(AppAccent.amber.color);
}
