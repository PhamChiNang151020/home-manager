import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";

void main() {
  test("theme uses bundled Nunito", () {
    final theme = AppTheme.build(
      brightness: Brightness.dark,
      accent: AppAccent.amber,
    );
    expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.nunito);
    expect(theme.textTheme.titleLarge?.fontFamily, AppFonts.nunito);
  });
}
