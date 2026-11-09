import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";

enum AppToastKind { success, destructive, info }

/// Gap above the scaffold bottom chrome when a bottom nav is present.
/// Floating [SnackBar] already clears the nav; only this extra gap is needed.
/// From Đợt 1 (nav top 754): toast y 698–746. Without nav: y 754–802.
const _toastGapAboveNav = AppSpacing.sm; // 8

/// Bottom inset when there is no bottom nav (Members, etc.): y 754–802.
const _toastBottomWithoutNav = 50.0;

bool _scaffoldHasBottomNav(BuildContext context) {
  // Descendant contexts (body buttons, etc.).
  final fromOf = Scaffold.maybeOf(context);
  if (fromOf != null) {
    return fromOf.widget.bottomNavigationBar != null;
  }

  // Ancestor Scaffold widget (rare).
  final ancestor = context.findAncestorWidgetOfExactType<Scaffold>();
  if (ancestor?.bottomNavigationBar != null) return true;

  // State.context of a widget that *builds* a Scaffold (e.g. AppShell): the
  // Scaffold is a descendant, not an ancestor — walk the element tree.
  var hasNav = false;
  void visitor(Element el) {
    if (hasNav) return;
    final widget = el.widget;
    if (widget is Scaffold && widget.bottomNavigationBar != null) {
      hasNav = true;
      return;
    }
    el.visitChildren(visitor);
  }

  (context as Element).visitChildren(visitor);
  return hasNav;
}

double _toastBottomMargin(BuildContext context) {
  return _scaffoldHasBottomNav(context)
      ? _toastGapAboveNav
      : _toastBottomWithoutNav;
}

/// Floating toast via the nearest [ScaffoldMessenger].
///
/// Dark inverse bar (361×48, #0F172A). Optional action keeps the toast 5s.
void showAppToast(
  BuildContext context,
  String message, {
  AppToastKind kind = AppToastKind.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  _showOn(
    messenger,
    context.appColors,
    message,
    kind,
    bottomMargin: _toastBottomMargin(context),
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

/// Pop the current route, then show a toast on the parent messenger.
void popWithAppToast(
  BuildContext context,
  String message, {
  VoidCallback? then,
  Object? result,
  AppToastKind kind = AppToastKind.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final colors = context.appColors;
  final bottomMargin = _toastBottomMargin(context);
  Navigator.pop(context, result);
  then?.call();
  if (messenger == null) return;
  _showOn(
    messenger,
    colors,
    message,
    kind,
    bottomMargin: bottomMargin,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

void _showOn(
  ScaffoldMessengerState messenger,
  AppColorScheme colors,
  String message,
  AppToastKind kind, {
  required double bottomMargin,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final icon = switch (kind) {
    AppToastKind.success => Icons.check_circle,
    AppToastKind.destructive => Icons.delete_outline_rounded,
    AppToastKind.info => Icons.info_outline_rounded,
  };
  final iconColor = switch (kind) {
    AppToastKind.success => const Color(0xFF7DD3A0),
    AppToastKind.destructive => const Color(0xFFFCA5A5),
    AppToastKind.info => const Color(0xFFFDBA74),
  };
  final hasAction = actionLabel != null && onAction != null;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: SizedBox(
          height: 48,
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ),
              if (hasAction)
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      onAction();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFDBA74),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        duration: Duration(milliseconds: hasAction ? 5000 : 2600),
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        ),
        margin: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          bottomMargin,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
}
