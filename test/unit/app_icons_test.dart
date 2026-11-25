import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_icons.dart";

void main() {
  test("maps seeded expense icon_key to icons", () {
    expect(AppIcons.expenseCategory("restaurant"), Icons.restaurant);
    expect(AppIcons.expenseCategory("shopping_cart"), Icons.shopping_cart);
    expect(AppIcons.expenseCategory("health_and_safety"), Icons.health_and_safety);
    expect(AppIcons.expenseCategory("school"), Icons.school);
    expect(AppIcons.expenseCategory("more_horiz"), Icons.more_horiz);
    expect(AppIcons.expenseCategory("unknown"), Icons.more_horiz);
    expect(AppIcons.expenseCategory("payments"), Icons.more_horiz);
  });
}
