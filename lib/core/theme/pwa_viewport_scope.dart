import "dart:math" as math;

import "package:flutter/material.dart";
import "package:home_manager/core/services/pwa_install_runtime.dart";

/// Keeps interactive Flutter layout inside iOS standalone PWA touch bounds.
class PwaViewportScope extends StatefulWidget {
  const PwaViewportScope({super.key, required this.child});

  final Widget child;

  @override
  State<PwaViewportScope> createState() => _PwaViewportScopeState();
}

class _PwaViewportScopeState extends State<PwaViewportScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gap = currentPwaStandaloneTouchGap();
    if (gap <= 0) return widget.child;

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return widget.child;

    final padding = mediaQuery.padding.copyWith(
      bottom: math.max(mediaQuery.padding.bottom, gap),
    );
    final viewPadding = mediaQuery.viewPadding.copyWith(
      bottom: math.max(mediaQuery.viewPadding.bottom, gap),
    );

    return MediaQuery(
      data: mediaQuery.copyWith(padding: padding, viewPadding: viewPadding),
      child: widget.child,
    );
  }
}
