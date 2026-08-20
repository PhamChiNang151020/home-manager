/// Raster icons in `assets/`. Paths must match files on disk.
abstract final class AppIcons {
  static const brand = "assets/brand/logo.png";
  static const electricity = "assets/electricity.png";
  static const water = "assets/water.png";
  static const income = "assets/income.png";
  static const food = "assets/food.png";
  static const loan = "assets/loan.png";
  static const health = "assets/insurance.png";
  static const tuition = "assets/tuition.png";
  static const dashboard = "assets/dashboard.png";
  static const expenses = "assets/expense.png";
  static const settings = "assets/settings.png";
  static const reminder = "assets/reminder.png";

  static String accentPreview(String accentName) =>
      "assets/brand/appearance_preview/icon-accent-$accentName.png";

  /// Seeded `expense_categories.icon_key` → PNG. Unknown keys have no asset.
  static String? expenseCategory(String iconKey) {
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
