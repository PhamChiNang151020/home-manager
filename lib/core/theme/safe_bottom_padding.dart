import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";
import "package:home_manager/core/domain/safe_bottom_inset.dart";
import "package:home_manager/core/services/pwa_runtime.dart";

/// Bottom inset from the window, not from ancestor [MediaQuery] overrides.
///
/// [Scaffold] applies `removeTop: true` to [Scaffold.bottomNavigationBar],
/// which zeros both `padding.top` and `viewPadding.top`. The iOS fallback in
/// [safeBottomInset] then never runs. [MediaQueryData.fromView] reads the
/// engine insets instead.
double safeBottomPaddingOf(BuildContext context) {
  if (kIsWeb && pwaIosHomeScreenShell()) return 0;
  final mq = MediaQueryData.fromView(View.of(context));
  return safeBottomInset(
    paddingBottom: mq.padding.bottom,
    viewPaddingBottom: mq.viewPadding.bottom,
    paddingTop: mq.padding.top,
    isCupertino: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS,
  );
}
