import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import "package:home_manager/core/config/firebase_web_config.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/services/fcm_token_service.dart";
import "package:shared_preferences/shared_preferences.dart";

enum NotificationPermissionStatus { granted, denied, notDetermined }

/// Web FCM helpers. Permission is never requested at startup — only on user action.
class NotificationService {
  const NotificationService({this.tokens});

  static const _prefsEnabledKey = "push_notifications_enabled";

  final FcmTokenService? tokens;

  bool get isAvailable => kIsWeb && FirebaseWebConfig.isConfigured;

  Future<bool> isEnabledLocally() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsEnabledKey) ?? false;
  }

  Future<void> _setEnabledLocally(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsEnabledKey, value);
  }

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
        AppLog.i("FCM token acquired (${token.length} chars)");
      }
      return token;
    } catch (e, st) {
      AppLog.e("getToken failed", error: e, stackTrace: st);
      return null;
    }
  }

  /// Request permission, fetch token, upsert to Supabase, persist local flag.
  Future<EnablePushResult> enableAndRegister() async {
    if (!isAvailable) {
      return const EnablePushResult(
        status: NotificationPermissionStatus.denied,
        configured: false,
      );
    }
    final status = await requestPermission();
    if (status != NotificationPermissionStatus.granted) {
      await _setEnabledLocally(false);
      return EnablePushResult(status: status, configured: true);
    }
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await _setEnabledLocally(false);
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
      }
    }
    if (saved) {
      await _setEnabledLocally(true);
    }
    return EnablePushResult(
      status: status,
      configured: true,
      token: token,
      saved: saved,
    );
  }

  /// Turn off push: remove server token, delete FCM token, clear local flag.
  Future<void> disableAndUnregister() async {
    try {
      final token = await getToken();
      final store = tokens;
      if (store != null && token != null && token.isNotEmpty) {
        await store.deleteToken(token);
      }
    } catch (e, st) {
      AppLog.e("FCM token delete failed", error: e, stackTrace: st);
    }
    try {
      if (isAvailable) {
        await FirebaseMessaging.instance.deleteToken();
      }
    } catch (e, st) {
      AppLog.e("FCM deleteToken failed", error: e, stackTrace: st);
    }
    await _setEnabledLocally(false);
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
