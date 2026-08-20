import "dart:js_interop";
import "dart:js_interop_unsafe";

import "package:web/web.dart" as web;

void installPwaHistoryGuard() {}

void resetPwaBrowserHistory() {
  final reset = web.window.getProperty("resetPwaBrowserHistory".toJS);
  if (reset.isA<JSFunction>()) {
    (reset as JSFunction).callAsFunction();
  }
}
