import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/services/pwa_runtime.dart";

/// Keeps Flutter [MediaQuery] in sync with the iOS home-screen host box.
///
/// Flutter is embedded in `#flutter-host` (see [web/index.html]). On that
/// shell, bottom safe-area insets from the engine are often wrong and shift
/// painted controls away from hit targets — zero the bottom inset only.
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
