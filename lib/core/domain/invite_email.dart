enum InviteEmailReject { empty, invalid, alreadyMember, alreadyPending }

abstract final class InviteEmail {
  static String normalize(String email) => email.trim().toLowerCase();

  static bool looksLikeEmail(String email) {
    final value = normalize(email);
    final at = value.indexOf("@");
    return at > 0 && at < value.length - 1 && !value.contains(" ");
  }

  /// Rejects empty / invalid addresses, people already in the home, and
  /// emails that already have a pending invite. Owner self-invite is
  /// [InviteEmailReject.alreadyMember] because the owner is a member.
  static InviteEmailReject? reject({
    required String email,
    required Iterable<String?> memberEmails,
    Iterable<String> pendingEmails = const [],
  }) {
    final normalized = normalize(email);
    if (normalized.isEmpty) return InviteEmailReject.empty;
    if (!looksLikeEmail(normalized)) return InviteEmailReject.invalid;
    for (final member in memberEmails) {
      if (member == null) continue;
      if (normalize(member) == normalized) {
        return InviteEmailReject.alreadyMember;
      }
    }
    for (final pending in pendingEmails) {
      if (normalize(pending) == normalized) {
        return InviteEmailReject.alreadyPending;
      }
    }
    return null;
  }
}
