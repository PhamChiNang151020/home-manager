import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/pwa_viewport.dart";

void main() {
  group("PwaViewport.standaloneTouchGap", () {
    test("returns zero outside standalone mismatch", () {
      expect(
        PwaViewport.standaloneTouchGap(
          screenMaxDimension: 844,
          innerHeight: 844,
        ),
        0,
      );
    });

    test("returns measured gap on iOS standalone cold start", () {
      expect(
        PwaViewport.standaloneTouchGap(
          screenMaxDimension: 852,
          innerHeight: 793,
        ),
        59,
      );
    });

    test("returns zero when innerHeight is invalid", () {
      expect(
        PwaViewport.standaloneTouchGap(screenMaxDimension: 852, innerHeight: 0),
        0,
      );
    });
  });
}
