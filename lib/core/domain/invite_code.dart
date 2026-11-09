import "package:home_manager/core/domain/join_link.dart";

/// 6-character home invite codes (alphabet omits 0/O/1/I).
abstract final class InviteCode {
  static const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  static const length = 6;

  /// Uppercase and strip spaces/dashes/other non-alphanumeric.
  static String normalize(String raw) {
    return raw.toUpperCase().replaceAll(RegExp(r"[^A-Z0-9]"), "");
  }

  static bool isValidNormalized(String code) {
    if (code.length != length) return false;
    for (final unit in code.codeUnits) {
      if (!alphabet.codeUnits.contains(unit)) return false;
    }
    return true;
  }

  /// Display form "K7M 2QP" (3+3). Copy value stays without space.
  static String formatDisplay(String code) {
    final n = normalize(code);
    if (n.length <= 3) return n;
    return "${n.substring(0, 3)} ${n.substring(3)}";
  }

  /// If [raw] looks like a join URL, return the token; otherwise null.
  static String? tokenFromPaste(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    return JoinLink.tokenFromUri(uri);
  }
}

enum InviteCodeAcceptError { invalidOrExpired, tooManyAttempts, other }

class InviteCodeException implements Exception {
  const InviteCodeException(this.kind, [this.message]);

  final InviteCodeAcceptError kind;
  final String? message;

  @override
  String toString() {
    if (message != null && message!.isNotEmpty) return message!;
    return switch (kind) {
      InviteCodeAcceptError.tooManyAttempts => "too many attempts",
      InviteCodeAcceptError.invalidOrExpired =>
        "invalid or expired invite code",
      InviteCodeAcceptError.other => "invite code error",
    };
  }
}

InviteCodeAcceptError mapInviteCodeError(Object error) {
  if (error is InviteCodeException) return error.kind;
  final lower = "$error".toLowerCase();
  if (lower.contains("too many attempts") || lower.contains("locked")) {
    return InviteCodeAcceptError.tooManyAttempts;
  }
  if (lower.contains("invalid or expired") || lower.contains("invalid")) {
    return InviteCodeAcceptError.invalidOrExpired;
  }
  return InviteCodeAcceptError.other;
}
