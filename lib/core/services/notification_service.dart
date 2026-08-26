import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:home_manager/core/config/firebase_web_config.dart";
import "package:home_manager/core/logging/app_log.dart";

enum NotificationPermissionStatus { granted, denied, notDetermined }

/// Web FCM helpers. Permission is never requested at startup — only on user action.
class NotificationService {
  const NotificationService();

  bool get isAvailable => kIsWeb && FirebaseWebConfig.isConfigured;

  Future<NotificationPermissionStatus> requestPermission() async {
    if (!isAvailable) {
      AppLog.w("FCM not configured; skip requestPermission");
      return NotificationPermissionStatus.denied;
    }
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return switch (settings.authorizationStatus) {
        AuthorizationStatus.authorized || AuthorizationStatus.provisional =>
          NotificationPermissionStatus.granted,
        AuthorizationStatus.denied => NotificationPermissionStatus.denied,
        AuthorizationStatus.notDetermined =>
          NotificationPermissionStatus.notDetermined,
      };
    } catch (e, st) {
      AppLog.e("requestPermission failed", error: e, stackTrace: st);
      return NotificationPermissionStatus.denied;
    }
  }

  Future<String?> getToken() async {
    if (!isAvailable) {
      AppLog.w("FCM not configured; skip getToken");
      return null;
    }
    try {
      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: FirebaseWebConfig.vapidKey,
        serviceWorkerScriptPath:
            FirebaseWebConfig.messagingServiceWorkerScriptPath,
      );
      if (token != null && token.isNotEmpty) {
        // ignore: avoid_print — Phase 1: visible in release Pages console
        print("FCM token: $token");
      }
      return token;
    } catch (e, st) {
      AppLog.e("getToken failed", error: e, stackTrace: st);
      // ignore: avoid_print
      print("FCM getToken failed: $e");
      return null;
    }
  }
}
