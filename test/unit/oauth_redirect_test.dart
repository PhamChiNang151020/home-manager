import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/oauth_redirect.dart";

void main() {
  group("OauthRedirect.webFromPage", () {
    test("uses GitHub Pages origin without query", () {
      expect(
        OauthRedirect.webFromPage(
          Uri.parse(
            "https://phamchinang151020.github.io/home-manager/?join=abc123",
          ),
        ),
        "https://phamchinang151020.github.io/home-manager/",
      );
    });

    test("does not attach join token that would fail GoTrue allow-list", () {
      final redirect = OauthRedirect.webFromPage(
        Uri.parse(
          "https://phamchinang151020.github.io/home-manager/join.html?join=tok",
        ),
      );
      expect(redirect.contains("join="), isFalse);
      expect(redirect.contains("join.html"), isFalse);
      expect(redirect, "https://phamchinang151020.github.io/home-manager/");
    });

    test("keeps localhost when already on local Flutter web", () {
      expect(
        OauthRedirect.webFromPage(Uri.parse("http://localhost:8080/#/")),
        "http://localhost:8080/",
      );
    });

    test("falls back to local dev when page URI is not http(s)", () {
      expect(
        OauthRedirect.webFromPage(Uri.parse("file:///tmp/index.html")),
        OauthRedirect.localDev,
      );
    });
  });
}
