import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_icons.dart";

void main() {
  test("expenseCategory maps all 12 icon_keys", () {
    expect(AppIcons.expenseCategoryKeys, hasLength(12));
    expect(
      AppIcons.expenseCategoryKeys,
      [
        "restaurant",
        "shopping_cart",
        "home",
        "directions_car",
        "school",
        "health_and_safety",
        "child_care",
        "celebration",
        "checkroom",
        "phone_iphone",
        "pets",
        "more_horiz",
      ],
    );
    for (final key in AppIcons.expenseCategoryKeys) {
      expect(AppIcons.expenseCategory(key), isA<IconData>());
    }
  });

  test("expenseCategory unknown key falls back to more_horiz", () {
    expect(AppIcons.expenseCategory("legacy_payments"), Icons.more_horiz);
    expect(AppIcons.expenseCategory(""), Icons.more_horiz);
  });
}
