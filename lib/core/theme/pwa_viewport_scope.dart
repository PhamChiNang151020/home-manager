import "package:flutter/material.dart";

/// Reserved wrapper for future PWA viewport tweaks.
///
/// iOS touch alignment is handled in [web/index.html] by sizing the page to
/// `window.innerHeight`. Adding Flutter padding on top caused double insets
/// and a growing dead zone at the bottom.
class PwaViewportScope extends StatelessWidget {
  const PwaViewportScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
