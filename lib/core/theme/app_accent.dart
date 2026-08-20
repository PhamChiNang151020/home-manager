import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_icons.dart";

enum AppAccent {
  amber,
  blue,
  purple,
  green;

  Color get color => switch (this) {
    AppAccent.amber => const Color(0xFFF5A623),
    AppAccent.blue => const Color(0xFF3B82F6),
    AppAccent.purple => const Color(0xFFA855F7),
    AppAccent.green => const Color(0xFF22C55E),
  };

  String get storageKey => name;

  String get previewAsset => AppIcons.accentPreview(name);

  static AppAccent fromStorage(String? value) {
    return AppAccent.values.firstWhere(
      (accent) => accent.name == value,
      orElse: () => AppAccent.amber,
    );
  }
}
