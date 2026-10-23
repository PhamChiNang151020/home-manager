import 'package:flutter/material.dart';

/// Auth-scoped button theme: 48px height, transparent hover/focus overlay
ButtonStyle authButtonStyle(BuildContext context) {
  final theme = Theme.of(context);
  return theme.filledButtonTheme.style!.copyWith(
    visualDensity: VisualDensity.standard,
    minimumSize: WidgetStateProperty.all(const Size.fromHeight(48)),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return null;
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return Colors.transparent;
      }
      return null;
    }),
  );
}
