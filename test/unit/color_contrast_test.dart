import "dart:math" as math;
import "dart:ui";

import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) {
    final s = v;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4) as double;
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// WCAG AA: 4.5:1 for body text, 3:1 for large text and graphics.
const _bodyText = 4.5;
const _largeText = 3.0;

void main() {
  for (final brightness in ["dark", "light"]) {
    final isDark = brightness == "dark";

    group("$brightness theme", () {
      for (final accent in AppAccent.values) {
        final colors =
            isDark
                ? AppColorScheme.dark(accent.color)
                : AppColorScheme.light(accent.colorOnLight);
        final surfaces = {
          "bgBase": colors.bgBase,
          "bgSurface": colors.bgSurface,
          "bgElevated": colors.bgElevated,
        };

        test("${accent.name}: text ramp is readable on every surface", () {
          final ramp = {
            "textPrimary": colors.textPrimary,
            "textSecondary": colors.textSecondary,
            "textMuted": colors.textMuted,
          };
          for (final text in ramp.entries) {
            for (final surface in surfaces.entries) {
              expect(
                contrast(text.value, surface.value),
                greaterThanOrEqualTo(_bodyText),
                reason: "${text.key} on ${surface.key}",
              );
            }
          }
        });

        test("${accent.name}: status colours are readable everywhere", () {
          final status = {
            "accent": colors.accent,
            "success": colors.success,
            "warning": colors.warning,
            "error": colors.error,
          };
          for (final c in status.entries) {
            for (final surface in surfaces.entries) {
              expect(
                contrast(c.value, surface.value),
                greaterThanOrEqualTo(_bodyText),
                reason: "${c.key} on ${surface.key}",
              );
            }
          }
        });

        test("${accent.name}: button label is readable on an accent fill", () {
          // Mirrors ColorScheme.onPrimary in AppTheme.build.
          final onAccent = isDark ? colors.bgBase : const Color(0xFFFFFFFF);
          expect(
            contrast(onAccent, colors.accent),
            greaterThanOrEqualTo(_bodyText),
          );
        });
      }
    });
  }

  test("the selected tab label is never fainter than an unselected one", () {
    for (final accent in AppAccent.values) {
      for (final colors in [
        AppColorScheme.dark(accent.color),
        AppColorScheme.light(accent.colorOnLight),
      ]) {
        final selected = contrast(colors.accent, colors.bgSurface);
        final unselected = contrast(colors.textMuted, colors.bgSurface);
        expect(
          selected,
          greaterThanOrEqualTo(unselected),
          reason: "${accent.name}: selected tab must not be the faintest item",
        );
      }
    }
  });

  test("category swatches stay distinguishable as graphics", () {
    for (final colors in [
      AppColorScheme.dark(AppAccent.amber.color),
      AppColorScheme.light(AppAccent.amber.colorOnLight),
    ]) {
      for (final key in ["food", "loan", "health", "tuition", "other"]) {
        expect(
          contrast(colors.categoryColor(key), colors.bgSurface),
          greaterThanOrEqualTo(_largeText),
          reason: key,
        );
      }
    }
  });
}
