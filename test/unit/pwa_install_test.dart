import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/pwa_install.dart";

void main() {
  group("PwaInstall.surface", () {
    test("hides when already standalone", () {
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
          displayStandalone: true,
          iosNavigatorStandalone: false,
        ),
        PwaInstallSurface.hidden,
      );
    });

    test("hides on iOS navigator.standalone", () {
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
          displayStandalone: false,
          iosNavigatorStandalone: true,
        ),
        PwaInstallSurface.hidden,
      );
    });

    test("hides on desktop", () {
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
          displayStandalone: false,
          iosNavigatorStandalone: false,
        ),
        PwaInstallSurface.hidden,
      );
    });

    test("detects iOS Safari", () {
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1",
          displayStandalone: false,
          iosNavigatorStandalone: false,
        ),
        PwaInstallSurface.iosSafari,
      );
    });

    test("detects iOS in-app and Chrome iOS", () {
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Zalo",
          displayStandalone: false,
          iosNavigatorStandalone: false,
        ),
        PwaInstallSurface.iosInApp,
      );
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/128.0.6613.98 Mobile/15E148 Safari/604.1",
          displayStandalone: false,
          iosNavigatorStandalone: false,
        ),
        PwaInstallSurface.iosInApp,
      );
    });

    test("detects Android Chrome vs WebView", () {
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36",
          displayStandalone: false,
          iosNavigatorStandalone: false,
        ),
        PwaInstallSurface.androidChrome,
      );
      expect(
        PwaInstall.surface(
          userAgent:
              "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/128.0.0.0 Mobile Safari/537.36; wv) Zalo",
          displayStandalone: false,
          iosNavigatorStandalone: false,
        ),
        PwaInstallSurface.androidInApp,
      );
    });
  });

  group("PwaInstall.shareUrlFrom", () {
    test("uses production URL on localhost", () {
      expect(
        PwaInstall.shareUrlFrom(Uri.parse("http://localhost:5000/")),
        PwaInstall.productionAppUrl,
      );
    });

    test("strips query, fragment, and index.html", () {
      expect(
        PwaInstall.shareUrlFrom(
          Uri.parse(
            "https://phamchinang151020.github.io/home-manager/index.html?x=1#/foo",
          ),
        ),
        "https://phamchinang151020.github.io/home-manager/",
      );
    });
  });
}
