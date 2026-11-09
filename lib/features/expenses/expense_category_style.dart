import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";

class ExpenseCategoryIcon extends StatelessWidget {
  const ExpenseCategoryIcon({
    super.key,
    required this.iconKey,
    this.size = 24,
    this.color,
  });

  final String iconKey;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return AppIcon(
      AppIcons.expenseCategory(iconKey),
      size: size,
      color: color,
    );
  }
}
