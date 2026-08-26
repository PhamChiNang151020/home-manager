import "package:flutter/material.dart";

/// Bright brand accents for chips / previews. Darker [colorOnLight] lives on
/// [AppAccent] for text and fills on light surfaces.
enum AppAccent {
  amber,
  blue,
  purple,
  green;

  /// Bright brand tone. Only legible against the dark theme's backgrounds.
  Color get color => switch (this) {
    AppAccent.amber => const Color(0xFFF5A623),
    AppAccent.blue => const Color(0xFF60A5FA),
    AppAccent.purple => const Color(0xFFC084FC),
    AppAccent.green => const Color(0xFF22C55E),
  };

  /// Darkened tone for the light theme. The bright tone sits at roughly 2:1
  /// against white, so it fails as text, as an icon and as a button fill.
  /// Each value here clears 4.5:1 on white both as foreground and behind
  /// white label text.
  Color get colorOnLight => switch (this) {
    AppAccent.amber => const Color(0xFF9A4507),
    AppAccent.blue => const Color(0xFF1D4ED8),
    AppAccent.purple => const Color(0xFF6D28D9),
    AppAccent.green => const Color(0xFF166534),
  };

  String get storageKey => name;

  static AppAccent fromStorage(String? value) {
    return AppAccent.values.firstWhere(
      (accent) => accent.name == value,
      orElse: () => AppAccent.amber,
    );
  }
}
