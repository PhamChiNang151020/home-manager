import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final defaultStyle = large
        ? theme.textTheme.headlineMedium?.copyWith(
            color: colors.accent,
            fontWeight: FontWeight.w700,
          )
        : theme.textTheme.titleMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          );
    return Text(
      VndFormat.format(amount),
      style: style ?? defaultStyle,
    );
  }
}
