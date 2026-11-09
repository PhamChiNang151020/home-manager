import "package:flutter/material.dart";

/// Vector UI icons. Brand mark stays on [brand] as a raster asset.
abstract final class AppIcons {
  static const brand = "assets/brand/logo.png";

  static const IconData electricity = Icons.bolt_rounded;
  static const IconData water = Icons.water_drop_rounded;
  static const IconData income = Icons.payments_rounded;
  static const IconData food = Icons.restaurant_rounded;
  static const IconData loan = Icons.credit_card_rounded;
  static const IconData health = Icons.health_and_safety_rounded;
  static const IconData tuition = Icons.school_rounded;
  static const IconData dashboard = Icons.dashboard_rounded;
  static const IconData expenses = Icons.receipt_long_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData reminder = Icons.notifications_rounded;

  /// Seeded `expense_categories.icon_key` → icon. Unknown keys → more_horiz.
  static IconData expenseCategory(String iconKey) {
    return switch (iconKey) {
      "restaurant" => Icons.restaurant,
      "shopping_cart" => Icons.shopping_cart,
      "home" => Icons.home,
      "directions_car" => Icons.directions_car,
      "school" => Icons.school,
      "health_and_safety" => Icons.health_and_safety,
      "child_care" => Icons.child_care,
      "celebration" => Icons.celebration,
      "checkroom" => Icons.checkroom,
      "phone_iphone" => Icons.phone_iphone,
      "pets" => Icons.pets,
      "more_horiz" => Icons.more_horiz,
      _ => Icons.more_horiz,
    };
  }

  static const expenseCategoryKeys = <String>[
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
  ];
}
