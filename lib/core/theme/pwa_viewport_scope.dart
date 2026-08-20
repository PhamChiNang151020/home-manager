import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/services/pwa_runtime.dart";

/// Aligns Flutter [MediaQuery] with the iOS home-screen touch layer.
///
/// JS in [web/index.html] overrides `clientHeight` and sizes host elements.
/// Flutter web can still apply incorrect bottom safe-area insets in standalone
/// / Web Clip mode, which shifts painted widgets without moving hit targets.
class PwaViewportScope extends StatelessWidget {
  const PwaViewportScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !pwaIosHomeScreenShell()) return child;

    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: 0),
        viewPadding: mq.viewPadding.copyWith(bottom: 0),
      ),
      child: child,
    );
  }
}
