enum PwaInstallSurface {
  hidden,
  iosSafari,
  iosInApp,
  androidChrome,
  androidInApp,
}

abstract final class PwaInstall {
  static const productionAppUrl =
      "https://phamchinang151020.github.io/home-manager/";

  static const iosWebClipProfileFile = "to-am.mobileconfig";

  static const productionIosWebClipProfileUrl =
      "$productionAppUrl$iosWebClipProfileFile";

  static const bannerDismissedKey = "pwa_install_banner_dismissed";

  static PwaInstallSurface surface({
    required String userAgent,
    required bool displayStandalone,
    required bool iosNavigatorStandalone,
  }) {
    if (displayStandalone || iosNavigatorStandalone) {
      return PwaInstallSurface.hidden;
    }
    final ua = userAgent.toLowerCase();
    final ios =
        ua.contains("iphone") || ua.contains("ipad") || ua.contains("ipod");
    final android = ua.contains("android");
    if (!ios && !android) {
      return PwaInstallSurface.hidden;
    }
    if (ios) {
      return _iosInAppBrowser(ua)
          ? PwaInstallSurface.iosInApp
          : PwaInstallSurface.iosSafari;
    }
    return _androidInAppBrowser(ua)
        ? PwaInstallSurface.androidInApp
        : PwaInstallSurface.androidChrome;
  }

  static String shareUrlFrom(Uri pageUri) {
    final host = pageUri.host.toLowerCase();
    if (host == "localhost" || host == "127.0.0.1") {
      return productionAppUrl;
    }
    var path = pageUri.path;
    if (path.endsWith("index.html")) {
      path = path.substring(0, path.length - "index.html".length);
    }
    if (path.isEmpty) {
      path = "/";
    } else if (!path.endsWith("/")) {
      path = "$path/";
    }
    return Uri(
      scheme: pageUri.scheme.isEmpty ? "https" : pageUri.scheme,
      host: pageUri.host,
      port: pageUri.hasPort ? pageUri.port : null,
      path: path,
    ).toString();
  }

  static String iosWebClipProfileUrlFrom(Uri pageUri) {
    return "${shareUrlFrom(pageUri)}$iosWebClipProfileFile";
  }

  static bool isIosSurface(PwaInstallSurface surface) {
    return switch (surface) {
      PwaInstallSurface.iosSafari || PwaInstallSurface.iosInApp => true,
      _ => false,
    };
  }

  static bool _iosInAppBrowser(String ua) {
    if (_sharedInAppMarkers(ua)) return true;
    if (ua.contains("crios") || ua.contains("fxios") || ua.contains("edgios")) {
      return true;
    }
    return false;
  }

  static bool _androidInAppBrowser(String ua) {
    if (_sharedInAppMarkers(ua)) return true;
    return ua.contains("; wv");
  }

  static bool _sharedInAppMarkers(String ua) {
    const markers = [
      "fbav",
      "fban",
      "fb_iab",
      "instagram",
      "zalo",
      "line/",
      "micromessenger",
      "twitter",
    ];
    return markers.any(ua.contains);
  }
}
