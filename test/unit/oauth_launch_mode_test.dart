import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/oauth_launch.dart";
import "package:url_launcher/url_launcher.dart";

void main() {
  test("web OAuth keeps platform default launch", () {
    expect(oauthLaunchMode(isWeb: true), LaunchMode.platformDefault);
  });

  test("native OAuth opens the system browser so the sheet can dismiss", () {
    expect(oauthLaunchMode(isWeb: false), LaunchMode.externalApplication);
  });
}
