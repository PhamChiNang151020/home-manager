import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/join_link.dart";
import "package:home_manager/core/services/join_link_store.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test("captureFrom persists join query until cleared", () async {
    await JoinLinkStore.captureFrom(
      Uri.parse("https://example.test/?join=family-token"),
    );

    expect(await JoinLinkStore.read(), "family-token");

    await JoinLinkStore.clear();
    expect(await JoinLinkStore.read(), isNull);
  });

  test("captureFrom ignores URLs without a join token", () async {
    await JoinLinkStore.captureFrom(Uri.parse("https://example.test/"));
    expect(await JoinLinkStore.read(), isNull);
  });

  test("captureFrom reads hash query used by Flutter web", () async {
    await JoinLinkStore.captureFrom(
      Uri.parse("https://example.test/home-manager/#/?join=hash-token"),
    );
    expect(await JoinLinkStore.read(), "hash-token");
  });

  test("js backup key is the localStorage key written by join.html", () {
    expect(JoinLink.jsBackupKey, "toam_pending_join_token");
  });
}
