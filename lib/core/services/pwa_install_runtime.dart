import "package:home_manager/core/domain/pwa_install.dart";
import "package:home_manager/core/domain/pwa_viewport.dart";
import "package:home_manager/core/services/pwa_runtime.dart";

PwaInstallSurface currentPwaInstallSurface() {
  return PwaInstall.surface(
    userAgent: pwaUserAgent(),
    displayStandalone: pwaDisplayStandalone(),
    iosNavigatorStandalone: pwaIosNavigatorStandalone(),
  );
}

String currentPwaShareUrl() => PwaInstall.shareUrlFrom(Uri.base);

String currentIosWebClipProfileUrl() =>
    PwaInstall.iosWebClipProfileUrlFrom(Uri.base);

double currentPwaStandaloneTouchGap() {
  if (!pwaIsStandaloneWebApp()) return 0;
  return PwaViewport.standaloneTouchGap(
    screenMaxDimension: pwaScreenMaxDimension(),
    innerHeight: pwaInnerHeight(),
  );
}
