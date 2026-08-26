import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// Tinted vector icon used across nav, hubs, and category chips.
class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size = 24, this.color});

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color ?? context.appColors.accent);
  }
}
