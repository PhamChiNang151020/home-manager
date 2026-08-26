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

  /// Seeded `expense_categories.icon_key` → icon. Unknown keys return null.
  static IconData? expenseCategory(String iconKey) {
    return switch (iconKey) {
      "restaurant" => food,
      "payments" => loan,
      "health_and_safety" => health,
      "school" => tuition,
      "more_horiz" => expenses,
      _ => null,
    };
  }
}
