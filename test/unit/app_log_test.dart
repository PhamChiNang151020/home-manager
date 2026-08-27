import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/logging/app_log.dart";

void main() {
  tearDown(() {
    AppLog.sink = null;
    AppLog.now = DateTime.now;
  });

  List<String> capture() {
    final lines = <String>[];
    AppLog.sink = lines.add;
    AppLog.now = () => DateTime(2026, 8, 27, 10, 3, 45, 123);
    return lines;
  }

  test("info line includes time, logger name, and level", () {
    final lines = capture();
    AppLog.i("Starting home_manager");
    expect(lines, ["10:03:45.123 [home_manager] I Starting home_manager"]);
  });

  test("debug and warn use D and W tags", () {
    final lines = capture();
    AppLog.d("listHomes for uid");
    AppLog.w("Supabase not configured");
    expect(lines, [
      "10:03:45.123 [home_manager] D listHomes for uid",
      "10:03:45.123 [home_manager] W Supabase not configured",
    ]);
  });

  test("error appends the error object", () {
    final lines = capture();
    AppLog.e("refreshHomes failed", error: "timeout");
    expect(lines, [
      "10:03:45.123 [home_manager] E refreshHomes failed | timeout",
    ]);
  });

  test("custom name replaces the default logger", () {
    final lines = capture();
    AppLog.i("Starting Google OAuth sign-in", name: "auth");
    expect(lines, ["10:03:45.123 [auth] I Starting Google OAuth sign-in"]);
  });
}
