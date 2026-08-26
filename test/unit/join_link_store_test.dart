import "package:flutter_test/flutter_test.dart";
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
}
