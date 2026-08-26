import "package:flutter/material.dart";

/// Single entry point for modal sheets.
///
/// [useSafeArea] is the important part: a tall sheet grows to the full screen
/// height, and without it the sheet's own header slides under the status bar
/// and the Dynamic Island. Background and shape come from `bottomSheetTheme`,
/// the drag handle from `dragHandleColor` / `dragHandleSize`.
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
    builder: builder,
  );
}
