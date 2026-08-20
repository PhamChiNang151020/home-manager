import "dart:js_interop";
import "dart:js_interop_unsafe";
import "dart:math" as math;

import "package:web/web.dart" as web;

String pwaUserAgent() => web.window.navigator.userAgent;

bool pwaIsIos() {
  final ua = pwaUserAgent().toLowerCase();
  return ua.contains("iphone") || ua.contains("ipad") || ua.contains("ipod");
}

bool pwaDisplayStandalone() =>
    web.window.matchMedia("(display-mode: standalone)").matches;

bool pwaIosNavigatorStandalone() {
  final value = web.window.navigator.getProperty("standalone".toJS);
  return value.dartify() == true;
}

bool pwaIsStandaloneWebApp() =>
    pwaDisplayStandalone() || pwaIosNavigatorStandalone();

/// iOS app opened from home-screen icon (PWA, Web Clip, or profile shortcut).
bool pwaIosHomeScreenShell() {
  if (!pwaIsIos()) return false;
  if (pwaIsStandaloneWebApp()) return true;
  if (web.window.matchMedia("(display-mode: fullscreen)").matches) return true;
  final chrome = (web.window.outerHeight - web.window.innerHeight).abs();
  return chrome <= 50;
}

double pwaScreenMaxDimension() {
  final screen = web.window.screen;
  return math.max(screen.width, screen.height).toDouble();
}

double pwaInnerHeight() => web.window.innerHeight.toDouble();
