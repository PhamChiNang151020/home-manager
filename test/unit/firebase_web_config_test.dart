import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/config/firebase_web_config.dart";

void main() {
  test("messagingServiceWorkerScriptPath resolves under Uri.base", () {
    final path = FirebaseWebConfig.messagingServiceWorkerScriptPath;
    expect(path.endsWith("firebase-messaging-sw.js"), isTrue);
    expect(path.startsWith("/"), isTrue);
  });

  test("isConfigured is false without --dart-define FIREBASE_*", () {
    // CI/unit tests run without Firebase defines.
    expect(FirebaseWebConfig.isConfigured, isFalse);
  });
}
