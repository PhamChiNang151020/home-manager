import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/features/shared/app_glass_surface.dart";

/// Single entry point for modal sheets.
///
/// [useSafeArea] keeps tall sheets clear of the status bar. When glass is on,
/// the sheet chrome is frosted via [AppGlassSurface.blurred].
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final child = builder(sheetContext);
      if (!sheetContext.appColors.glass) return child;
      return AppGlassSurface.blurred(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.cardRadius),
        ),
        child: child,
      );
    },
  );
}
