import "dart:math" as math;

import "package:flutter/material.dart";
import "package:home_manager/core/services/pwa_install_runtime.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";

/// Keeps interactive Flutter layout inside iOS WebKit touch bounds.
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

    final bottomInset = math.max(mediaQuery.padding.bottom, gap);
    final padding = mediaQuery.padding.copyWith(bottom: bottomInset);
    final viewPadding = mediaQuery.viewPadding.copyWith(bottom: bottomInset);
    final height = math.max(0.0, mediaQuery.size.height - gap);
    final size = Size(mediaQuery.size.width, height);
    final colors = Theme.of(context).extension<AppColorScheme>();

    return ColoredBox(
      color: colors?.bgBase ?? Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(bottom: gap),
        child: MediaQuery(
          data: mediaQuery.copyWith(
            padding: padding,
            viewPadding: viewPadding,
            size: size,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
