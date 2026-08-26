import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/safe_bottom_inset.dart";

void main() {
  test("uses the larger of padding and viewPadding", () {
    expect(
      safeBottomInset(
        paddingBottom: 20,
        viewPaddingBottom: 34,
        paddingTop: 59,
        isCupertino: true,
      ),
      34,
    );
  });

  test("falls back on iOS when top inset exists but bottom is zero", () {
    expect(
      safeBottomInset(
        paddingBottom: 0,
        viewPaddingBottom: 0,
        paddingTop: 59,
        isCupertino: true,
      ),
      34,
    );
  });

  test("does not invent an inset on non-iOS", () {
    expect(
      safeBottomInset(
        paddingBottom: 0,
        viewPaddingBottom: 0,
        paddingTop: 59,
        isCupertino: false,
      ),
      0,
    );
  });

  test("iPhone SE style (small top inset) stays flush", () {
    expect(
      safeBottomInset(
        paddingBottom: 0,
        viewPaddingBottom: 0,
        paddingTop: 20,
        isCupertino: true,
      ),
      0,
    );
  });
}
