import "package:home_manager/core/domain/join_link.dart";
import "package:web/web.dart" as web;

void persistJoinTokenJs(String token) {
  web.window.localStorage.setItem(JoinLink.jsBackupKey, token);
}

String? readJoinTokenJs() {
  final value = web.window.localStorage.getItem(JoinLink.jsBackupKey)?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

void clearJoinTokenJs() {
  web.window.localStorage.removeItem(JoinLink.jsBackupKey);
}
