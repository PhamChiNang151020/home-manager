import "dart:js_interop";
import "dart:js_interop_unsafe";

import "package:web/web.dart" as web;

String pwaUserAgent() => web.window.navigator.userAgent;

bool pwaDisplayStandalone() =>
    web.window.matchMedia("(display-mode: standalone)").matches;

bool pwaIosNavigatorStandalone() {
  final value = web.window.navigator.getProperty("standalone".toJS);
  return value.dartify() == true;
}
