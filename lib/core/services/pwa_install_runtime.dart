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
  if (!_isIosUserAgent(pwaUserAgent())) return 0;
  return PwaViewport.standaloneTouchGap(
    screenMaxDimension: pwaScreenMaxDimension(),
    innerHeight: pwaInnerHeight(),
  );
}

bool _isIosUserAgent(String userAgent) {
  final ua = userAgent.toLowerCase();
  return ua.contains("iphone") || ua.contains("ipad") || ua.contains("ipod");
}
