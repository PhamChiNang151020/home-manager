import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// Avatar 36 with 48 touch. Accent tint .12 + first letter 16 w700.
class AvatarButton extends StatelessWidget {
  const AvatarButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = 36,
  });

  final String label;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final letter = label.trim().isEmpty ? "?" : label.trim()[0].toUpperCase();
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.accent.withValues(alpha: 0.12),
          ),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.accent,
            ),
          ),
        ),
      ),
    );
  }
}
