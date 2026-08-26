import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/form_dirty.dart";

void main() {
  test("is not dirty when every field matches the opening value", () {
    expect(isFormDirty(["Nhà tôi", "3500"], ["Nhà tôi", "3500"]), isFalse);
  });

  test("is dirty when any field changed", () {
    expect(isFormDirty(["Nhà tôi", "3500"], ["Nhà ba mẹ", "3500"]), isTrue);
    expect(isFormDirty(["Nhà tôi", "3500"], ["Nhà tôi", "3600"]), isTrue);
  });

  test("ignores surrounding whitespace", () {
    expect(isFormDirty(["Nhà tôi"], ["  Nhà tôi  "]), isFalse);
  });

  test("treats a different field count as dirty", () {
    expect(isFormDirty(["1"], ["1", "2"]), isTrue);
  });

  test("handles empty day fields", () {
    expect(isFormDirty(["", "", ""], ["", "", ""]), isFalse);
    expect(isFormDirty(["", "", ""], ["5", "", ""]), isTrue);
  });
}
