import "package:flutter/material.dart";

/// Reserved wrapper for future PWA viewport tweaks.
///
/// iOS touch alignment is handled in [web/index.html]: override
/// `document.documentElement.clientHeight` (what Flutter reads) and sync host
/// elements to `innerHeight` / `visualViewport`. Do not add Flutter padding on
/// top — that caused double insets and a growing dead zone at the bottom.
class PwaViewportScope extends StatelessWidget {
  const PwaViewportScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
