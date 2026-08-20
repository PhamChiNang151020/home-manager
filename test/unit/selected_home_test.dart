import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/selected_home.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";

Home _home(String id) {
  return Home(
    id: id,
    name: id,
    trackingMode: TrackingMode.meter,
    kwhRate: 3500,
    createdBy: "u1",
  );
}

void main() {
  final first = _home("h1");
  final second = _home("h2");

  test("returns null when there are no homes", () {
    expect(
      resolveSelectedHome(homes: const [], current: first, persistedId: "h1"),
      isNull,
    );
  });

  test("keeps in-memory selection when still in the list", () {
    expect(
      resolveSelectedHome(
        homes: [first, second],
        current: second,
        persistedId: "h1",
      )?.id,
      "h2",
    );
  });

  test("uses persisted id when current is missing", () {
    expect(
      resolveSelectedHome(homes: [first, second], persistedId: "h2")?.id,
      "h2",
    );
  });

  test("does not jump to first while persisted id is still a member", () {
    expect(
      resolveSelectedHome(homes: [first, second], persistedId: "h2")?.id,
      isNot("h1"),
    );
  });

  test("falls back to first when persisted id is gone", () {
    expect(
      resolveSelectedHome(
        homes: [first, second],
        current: _home("gone"),
        persistedId: "gone",
      )?.id,
      "h1",
    );
  });
}
