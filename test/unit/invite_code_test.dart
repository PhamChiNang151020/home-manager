import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/invite_code.dart";

void main() {
  group("InviteCode.normalize", () {
    test("uppercases and strips spaces dashes", () {
      expect(InviteCode.normalize("k7m 2qp"), "K7M2QP");
      expect(InviteCode.normalize("k7m-2qp"), "K7M2QP");
      expect(InviteCode.normalize("  ab  "), "AB");
    });
  });

  group("InviteCode.isValidNormalized", () {
    test("accepts alphabet length 6", () {
      expect(InviteCode.isValidNormalized("K7M2QP"), isTrue);
    });

    test("rejects wrong length or ambiguous chars", () {
      expect(InviteCode.isValidNormalized("K7M2Q"), isFalse);
      expect(InviteCode.isValidNormalized("K7M2QPO"), isFalse);
      expect(InviteCode.isValidNormalized("K7M0QP"), isFalse); // 0 omitted
      expect(InviteCode.isValidNormalized("K7MIQP"), isFalse); // I omitted
    });
  });

  group("InviteCode.formatDisplay", () {
    test("splits 3+3", () {
      expect(InviteCode.formatDisplay("K7M2QP"), "K7M 2QP");
    });
  });

  group("InviteCode.tokenFromPaste", () {
    test("reads join query from url", () {
      expect(
        InviteCode.tokenFromPaste(
          "https://example.test/join.html?join=abc123tok",
        ),
        "abc123tok",
      );
    });

    test("returns null for plain code", () {
      expect(InviteCode.tokenFromPaste("K7M2QP"), isNull);
    });
  });

  group("mapInviteCodeError", () {
    test("maps known messages", () {
      expect(
        mapInviteCodeError(Exception("too many attempts")),
        InviteCodeAcceptError.tooManyAttempts,
      );
      expect(
        mapInviteCodeError(Exception("invalid or expired invite code")),
        InviteCodeAcceptError.invalidOrExpired,
      );
      expect(
        mapInviteCodeError(Exception("network down")),
        InviteCodeAcceptError.other,
      );
    });
  });
}
