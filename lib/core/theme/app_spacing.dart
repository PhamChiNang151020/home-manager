import "package:flutter/material.dart";

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;

  /// Gutter from the screen edge to a card edge. Card padding adds another
  /// [md] on top, so text lands 32 from the edge.
  static const screenHorizontal = 16.0;
  static const formFieldGap = 16.0;
  static const lg = 24.0;
  static const touchMin = 48.0;
  static const cardRadius = 16.0;
  static const inputRadius = 12.0;
  static const maxContentWidth = 480.0;

  /// Carries no horizontal inset — the page must sit inside a
  /// [MobileViewport] (directly, or via `FeaturePageScaffold` / the shell),
  /// otherwise its cards run to the screen edge.
  static const shellListPadding = EdgeInsets.fromLTRB(0, sm, 0, lg);
}
