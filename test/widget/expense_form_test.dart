import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:mocktail/mocktail.dart";

class MockExpenseService extends Mock implements ExpenseService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

const _home = Home(
  id: "h1",
  name: "Nhà tôi",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
);

final _category = ExpenseCategory(
  id: "c1",
  homeId: "h1",
  name: "Ăn uống/Chợ",
  iconKey: "restaurant",
  colorKey: "food",
  isDefault: true,
);

void main() {
  testWidgets("expense form shows invalid amount for zero", (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final expenses = MockExpenseService();
    final photos = MockBillPhotoService();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed:
                      () => showExpenseForm(
                        context: context,
                        home: _home,
                        expenses: expenses,
                        photos: photos,
                        categories: [_category],
                        members: const [
                          HomeMember(
                            userId: "u1",
                            role: "owner",
                            displayName: "An",
                          ),
                        ],
                        currentUserId: "u1",
                        onSaved: () {},
                      ),
                  child: const Text("Open"),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, "0");
    await tester.ensureVisible(find.widgetWithText(FilledButton, S.save));
    await tester.tap(find.widgetWithText(FilledButton, S.save));
    await tester.pump();
    expect(find.text(S.invalidExpenseAmount), findsOneWidget);
    verifyZeroInteractions(expenses);
  });
}
