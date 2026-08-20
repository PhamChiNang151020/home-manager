import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";
import "package:home_manager/features/shared/sticky_primary_bar.dart";

/// Full-screen wrapper for a feature pushed from Tổng quan.
class FeaturePageScaffold extends StatelessWidget {
  const FeaturePageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.titleIcon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget body;
  final String? titleIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.bgBase,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: colors.bgBase,
          surfaceTintColor: Colors.transparent,
          title:
              titleIcon == null
                  ? Text(title)
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppAssetIcon(titleIcon!, size: 26),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(child: Text(title)),
                    ],
                  ),
        ),
        body: MobileViewport(child: body),
        bottomNavigationBar:
            actionLabel == null || onAction == null
                ? null
                : StickyPrimaryBar(label: actionLabel!, onPressed: onAction!),
      ),
    );
  }
}
