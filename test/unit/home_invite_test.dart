import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/models/home.dart";

void main() {
  test("HomeInvite.fromJson parses email delivery fields", () {
    final invite = HomeInvite.fromJson({
      "id": "i1",
      "email": "a@b.com",
      "status": "pending",
      "email_sent_at": "2026-08-26T07:00:00.000Z",
      "email_last_error": null,
    });

    expect(invite.emailSent, isTrue);
    expect(invite.emailSentAt?.toUtc(), DateTime.utc(2026, 8, 26, 7));
    expect(invite.emailLastError, isNull);
  });

  test("HomeInvite.fromJson treats missing sent_at as not sent", () {
    final invite = HomeInvite.fromJson({
      "id": "i2",
      "email": "c@d.com",
      "status": "pending",
    });

    expect(invite.emailSent, isFalse);
    expect(invite.emailSentAt, isNull);
  });
}
