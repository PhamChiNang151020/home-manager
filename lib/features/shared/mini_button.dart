import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// Visual 32×height, 48 touch target. Accent outline, 14 w700.
class MiniButton extends StatelessWidget {
  const MiniButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 67,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      width: width,
      height: 48,
      child: Center(
        child: SizedBox(
          width: width,
          height: 32,
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.accent,
              side: BorderSide(color: colors.accent),
              padding: EdgeInsets.zero,
              minimumSize: Size(width, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
