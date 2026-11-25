import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/features/expenses/expense_category_sheet.dart";
import "package:supabase_flutter/supabase_flutter.dart";

void main() {
  test("categoryErrorMessage maps 23505 / 23503 / other", () {
    expect(
      categoryErrorMessage(
        const PostgrestException(message: "dup", code: "23505"),
      ),
      S.categoryNameTaken,
    );
    expect(
      categoryErrorMessage(
        const PostgrestException(message: "fk", code: "23503"),
      ),
      S.categoryDeleteInUse,
    );
    expect(
      categoryErrorMessage(
        const PostgrestException(message: "x", code: "42501"),
      ),
      S.errorGeneric,
    );
    expect(categoryErrorMessage(Exception("boom")), S.errorGeneric);
  });

  test("normalizeCategoryName trims and caps at 30", () {
    expect(normalizeCategoryName("  Ăn uống  "), "Ăn uống");
    expect(normalizeCategoryName("a" * 40), "a" * 30);
  });
}
