import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

enum AppToastKind { success, destructive, info }

/// Floating toast via the nearest [ScaffoldMessenger].
void showAppToast(
  BuildContext context,
  String message, {
  AppToastKind kind = AppToastKind.success,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  _showOn(messenger, context.appColors, message, kind);
}

/// Pop the current route, then show a toast on the parent messenger.
///
/// Captures [ScaffoldMessenger] and colors before pop so the toast still works
/// when the route being closed is a modal bottom sheet.
void popWithAppToast(
  BuildContext context,
  String message, {
  VoidCallback? then,
  Object? result,
  AppToastKind kind = AppToastKind.success,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final colors = context.appColors;
  Navigator.pop(context, result);
  then?.call();
  if (messenger == null) return;
  _showOn(messenger, colors, message, kind);
}

void _showOn(
  ScaffoldMessengerState messenger,
  AppColorScheme colors,
  String message,
  AppToastKind kind,
) {
  final (accent, icon) = switch (kind) {
    AppToastKind.success => (colors.success, Icons.check_circle_rounded),
    AppToastKind.destructive => (colors.error, Icons.delete_outline_rounded),
    AppToastKind.info => (colors.accent, Icons.info_outline_rounded),
  };

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        duration: const Duration(milliseconds: 2600),
        backgroundColor: Color.alphaBlend(
          accent.withValues(alpha: 0.16),
          colors.bgElevated,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          side: BorderSide(color: accent.withValues(alpha: 0.55), width: 1.5),
        ),
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
      ),
    );
}
