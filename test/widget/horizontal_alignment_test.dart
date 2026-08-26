import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_card.dart";

const _cardKey = Key("card");
const _plainKey = Key("plain");

void main() {
  testWidgets("a card lines up with a plain surface beside it", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: MobileViewport(
            child: ListView(
              padding: AppSpacing.shellListPadding,
              children: const [
                AppCard(key: _cardKey, child: SizedBox(height: 24)),
                SizedBox(key: _plainKey, height: 24, width: double.infinity),
              ],
            ),
          ),
        ),
      ),
    );

    // The visible surface, not the outer box, so a stray horizontal card
    // margin still fails.
    final surface = tester.getRect(
      find
          .descendant(of: find.byKey(_cardKey), matching: find.byType(Material))
          .first,
    );
    final plain = tester.getRect(find.byKey(_plainKey));

    expect(surface.left, plain.left);
    expect(surface.right, plain.right);
  });

  test("the card theme carries no horizontal margin", () {
    for (final brightness in Brightness.values) {
      final margin =
          AppTheme.build(
                brightness: brightness,
                accent: AppAccent.amber,
              ).cardTheme.margin
              as EdgeInsets?;
      expect(margin?.left, 0, reason: brightness.name);
      expect(margin?.right, 0, reason: brightness.name);
    }
  });

  test("the app bar title starts at the same inset as page content", () {
    expect(
      AppTheme.build(
        brightness: Brightness.dark,
        accent: AppAccent.amber,
      ).appBarTheme.titleSpacing,
      AppSpacing.screenHorizontal,
    );
  });
}
