import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/invite_email.dart";

void main() {
  const members = ["phamchinang.dev@gmail.com", "marcus.pham@beyondedge.co"];

  test("rejects empty and invalid", () {
    expect(
      InviteEmail.reject(email: "  ", memberEmails: members),
      InviteEmailReject.empty,
    );
    expect(
      InviteEmail.reject(email: "not-an-email", memberEmails: members),
      InviteEmailReject.invalid,
    );
  });

  test("rejects owner or existing member (self-invite)", () {
    expect(
      InviteEmail.reject(
        email: "PhamChiNang.dev@gmail.com",
        memberEmails: members,
      ),
      InviteEmailReject.alreadyMember,
    );
  });

  test("rejects email that already has a pending invite", () {
    expect(
      InviteEmail.reject(
        email: "new@gmail.com",
        memberEmails: members,
        pendingEmails: const ["new@gmail.com"],
      ),
      InviteEmailReject.alreadyPending,
    );
  });

  test("allows a new Google email", () {
    expect(
      InviteEmail.reject(
        email: "family@gmail.com",
        memberEmails: members,
        pendingEmails: const ["other@gmail.com"],
      ),
      isNull,
    );
  });
}
