import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// 6px progress bar, radius 3. Track #EEF1F5; fill accent or success.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.success = false,
  });

  /// 0..1
  final double value;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final clamped = value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colors.bgElevated),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: ColoredBox(
                color: success ? colors.success : colors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
