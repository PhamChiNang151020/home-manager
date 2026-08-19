import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_colors.dart";
import "package:intl/intl.dart";

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.amount,
    this.style,
    this.large = false,
  });

  final double amount;
  final TextStyle? style;
  final bool large;

  static final _vnd = NumberFormat.decimalPattern("vi_VN");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = large
        ? theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          )
        : theme.textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          );
    return Text(
      "${_vnd.format(amount)} đ",
      style: style ?? defaultStyle,
    );
  }
}
