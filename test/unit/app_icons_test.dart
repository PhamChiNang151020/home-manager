import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_icons.dart";

void main() {
  test("maps seeded expense icon_key to assets", () {
    expect(AppIcons.expenseCategory("restaurant"), AppIcons.food);
    expect(AppIcons.expenseCategory("payments"), AppIcons.loan);
    expect(AppIcons.expenseCategory("health_and_safety"), AppIcons.health);
    expect(AppIcons.expenseCategory("school"), AppIcons.tuition);
    expect(AppIcons.expenseCategory("more_horiz"), AppIcons.expenses);
    expect(AppIcons.expenseCategory("unknown"), isNull);
  });

  test("accent preview paths match files", () {
    expect(
      AppIcons.accentPreview("amber"),
      "assets/brand/appearance_preview/icon-accent-amber.png",
    );
    expect(
      AppAccent.blue.previewAsset,
      "assets/brand/appearance_preview/icon-accent-blue.png",
    );
  });
}
