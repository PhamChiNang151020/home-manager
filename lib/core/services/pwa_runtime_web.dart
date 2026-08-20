import "dart:js_interop";
import "dart:js_interop_unsafe";
import "dart:math" as math;

import "package:web/web.dart" as web;

String pwaUserAgent() => web.window.navigator.userAgent;

bool pwaDisplayStandalone() =>
    web.window.matchMedia("(display-mode: standalone)").matches;

bool pwaIosNavigatorStandalone() {
  final value = web.window.navigator.getProperty("standalone".toJS);
  return value.dartify() == true;
}

bool pwaIsStandaloneWebApp() =>
    pwaDisplayStandalone() || pwaIosNavigatorStandalone();

double pwaScreenMaxDimension() {
  final screen = web.window.screen;
  return math.max(screen.width, screen.height).toDouble();
}

double pwaInnerHeight() => web.window.innerHeight.toDouble();
