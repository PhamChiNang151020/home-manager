import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/join_link.dart";

void main() {
  group("JoinLink.tokenFromUri", () {
    test("reads ?join= from https app URL", () {
      expect(
        JoinLink.tokenFromUri(
          Uri.parse("https://example.test/home-manager/?join=abc123"),
        ),
        "abc123",
      );
    });

    test("reads ?join= from join.html landing", () {
      expect(
        JoinLink.tokenFromUri(
          Uri.parse("https://example.test/home-manager/join.html?join=abc123"),
        ),
        "abc123",
      );
    });

    test("trims join query value", () {
      expect(
        JoinLink.tokenFromUri(Uri.parse("https://example.test/?join= abc ")),
        "abc",
      );
    });

    test("ignores empty join query", () {
      expect(
        JoinLink.tokenFromUri(Uri.parse("https://example.test/?join=")),
        isNull,
      );
    });

    test("reads join token from hash query", () {
      expect(
        JoinLink.tokenFromUri(
          Uri.parse("https://example.test/home-manager/#/?join=hash-token"),
        ),
        "hash-token",
      );
    });

    test("reads native scheme join?token=", () {
      expect(
        JoinLink.tokenFromUri(
          Uri.parse("com.pcn.home-manager://join?token=family-token"),
        ),
        "family-token",
      );
    });

    test("reads native path /join?token=", () {
      expect(
        JoinLink.tokenFromUri(
          Uri.parse("com.pcn.home-manager:///join?token=path-token"),
        ),
        "path-token",
      );
    });

    test("ignores OAuth login-callback", () {
      expect(
        JoinLink.tokenFromUri(
          Uri.parse("com.pcn.home-manager://login-callback?code=xyz"),
        ),
        isNull,
      );
    });

    test("returns null when no join token", () {
      expect(
        JoinLink.tokenFromUri(Uri.parse("https://example.test/home-manager/")),
        isNull,
      );
    });
  });

  group("JoinLink.httpsJoinUrl", () {
    test("points camera scans at join.html landing", () {
      expect(
        JoinLink.httpsJoinUrl(
          baseUrl: "https://phamchinang151020.github.io/home-manager/",
          token: "abc123",
        ),
        "https://phamchinang151020.github.io/home-manager/join.html?join=abc123",
      );
    });
  });

  group("JoinLink.appUrlWithJoin", () {
    test("keeps OAuth return on the Flutter app path", () {
      expect(
        JoinLink.appUrlWithJoin(
          baseUrl: "https://phamchinang151020.github.io/home-manager/",
          token: "abc123",
        ),
        "https://phamchinang151020.github.io/home-manager/?join=abc123",
      );
    });
  });

  group("JoinLink.appBaseUrl", () {
    test("strips join.html so OAuth does not land on the landing page", () {
      expect(
        JoinLink.appBaseUrl(
          Uri.parse(
            "https://phamchinang151020.github.io/home-manager/join.html?join=x",
          ),
        ),
        "https://phamchinang151020.github.io/home-manager/",
      );
    });
  });
}
