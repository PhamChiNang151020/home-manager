import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/format/vnd_format.dart";

void main() {
  test("VndFormat formats and parses vi_VN amounts", () {
    expect(VndFormat.format(539000), "539.000 đ");
    expect(VndFormat.input(539000), "539.000");
    expect(VndFormat.parse("539.000"), 539000);
    expect(VndFormat.parse("539.000 đ"), 539000);
  });

  test("VndFormat compact uses k and tr labels", () {
    expect(VndFormat.compact(539000), "539 k");
    expect(VndFormat.compact(1200000), "1,2 tr");
  });

  test("VndFormat parse empty returns null", () {
    expect(VndFormat.parse(""), isNull);
    expect(VndFormat.parse("   "), isNull);
  });
}
