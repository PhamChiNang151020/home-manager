import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/safe_bottom_padding.dart";
import "package:home_manager/features/shared/app_glass_surface.dart";

class StickyPrimaryBar extends StatelessWidget {
  const StickyPrimaryBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottom = safeBottomPaddingOf(context);
    final bar = Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
        AppSpacing.screenHorizontal,
        AppSpacing.sm + bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
        ),
      ),
    );

    if (colors.glass) {
      return AppGlassSurface.blurred(
        borderRadius: BorderRadius.zero,
        child: bar,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: bar,
    );
  }
}
