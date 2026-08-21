import "package:flutter/material.dart";

abstract final class AppColors {
  static const bgBase = Color(0xFF0B0D10);
  static const bgSurface = Color(0xFF151A21);
  static const bgElevated = Color(0xFF1A1E24);
  static const border = Color(0xFF273140);
  static const textPrimary = Color(0xFFE9EEF5);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
  static const accent = Color(0xFFF5A623);
  static const accentGlow = Color(0xFFFFD180);
  static const success = Color(0xFF4ADE80);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);

  static Color accentMuted([double opacity = 0.18]) =>
      accent.withValues(alpha: opacity);

  static Color warningMuted([double opacity = 0.15]) =>
      warning.withValues(alpha: opacity);
}
