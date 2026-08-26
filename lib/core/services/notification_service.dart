import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:home_manager/core/config/firebase_web_config.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/services/fcm_token_service.dart";

enum NotificationPermissionStatus { granted, denied, notDetermined }

/// Web FCM helpers. Permission is never requested at startup — only on user action.
class NotificationService {
  const NotificationService({this.tokens});

  final FcmTokenService? tokens;

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

  /// Request permission, fetch token, and upsert to Supabase when possible.
  Future<EnablePushResult> enableAndRegister() async {
    if (!isAvailable) {
      return const EnablePushResult(
        status: NotificationPermissionStatus.denied,
        configured: false,
      );
    }
    final status = await requestPermission();
    if (status != NotificationPermissionStatus.granted) {
      return EnablePushResult(status: status, configured: true);
    }
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return EnablePushResult(
        status: status,
        configured: true,
        tokenFailed: true,
      );
    }
    var saved = false;
    final store = tokens;
    if (store != null) {
      try {
        saved = await store.upsertToken(token);
      } catch (e, st) {
        AppLog.e("FCM token upsert failed", error: e, stackTrace: st);
        // ignore: avoid_print
        print("FCM token upsert failed: $e");
      }
    }
    return EnablePushResult(
      status: status,
      configured: true,
      token: token,
      saved: saved,
    );
  }
}

class EnablePushResult {
  const EnablePushResult({
    required this.status,
    required this.configured,
    this.token,
    this.saved = false,
    this.tokenFailed = false,
  });

  final NotificationPermissionStatus status;
  final bool configured;
  final String? token;
  final bool saved;
  final bool tokenFailed;
}
