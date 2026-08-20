import "package:home_manager/core/domain/pwa_install.dart";
import "package:home_manager/core/services/pwa_runtime.dart";

PwaInstallSurface currentPwaInstallSurface() {
  return PwaInstall.surface(
    userAgent: pwaUserAgent(),
    displayStandalone: pwaDisplayStandalone(),
    iosNavigatorStandalone: pwaIosNavigatorStandalone(),
  );
}

String currentPwaShareUrl() => PwaInstall.shareUrlFrom(Uri.base);
