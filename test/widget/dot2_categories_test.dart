import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/expenses/expense_categories_page.dart";
import "package:home_manager/features/expenses/expense_category_sheet.dart";
import "package:mocktail/mocktail.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class MockExpenseService extends Mock implements ExpenseService {}

const _ownerHome = Home(
  id: "h1",
  name: "Nhà",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

const _memberHome = Home(
  id: "h1",
  name: "Nhà",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "member",
);

final _cats = [
  ExpenseCategory(
    id: "c1",
    homeId: "h1",
    name: "Ăn uống",
    iconKey: "restaurant",
    colorKey: "food",
    isDefault: true,
  ),
  ExpenseCategory(
    id: "c2",
    homeId: "h1",
    name: "Khác",
    iconKey: "more_horiz",
    colorKey: "other",
    isDefault: false,
  ),
];

Future<void> _loadNunito() async {
  final loader =
      FontLoader("Nunito")
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Regular.ttf"))
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Medium.ttf"))
        ..addFont(
          rootBundle.load("assets/fonts/Nunito/static/Nunito-SemiBold.ttf"),
        )
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Bold.ttf"))
        ..addFont(
          rootBundle.load("assets/fonts/Nunito/static/Nunito-ExtraBold.ttf"),
        );
  await loader.load();
}

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockExpenseService expenses;

  setUpAll(_loadNunito);

  setUp(() {
    expenses = MockExpenseService();
    when(() => expenses.listCategories(any())).thenAnswer((_) async => _cats);
  });

  testWidgets("owner categories page shows add and chevrons", (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: ExpenseCategoriesScreen(home: _ownerHome, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(S.expenseCategoriesTitle), findsOneWidget);
    expect(find.text(S.expenseCategoriesHint), findsOneWidget);
    expect(find.text(S.addCategory), findsOneWidget);
    expect(find.text(S.categoryDefault), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsWidgets);
    expect(find.text(S.categoriesOwnerOnly), findsNothing);
  });

  testWidgets("member categories page is read-only", (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: ExpenseCategoriesScreen(home: _memberHome, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(S.addCategory), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    expect(find.text(S.categoriesOwnerOnly), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets("add category sheet disables save when name empty", (
    tester,
  ) async {
    _setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed:
                    () => showExpenseCategorySheet(
                      context: context,
                      expenses: expenses,
                      homeId: "h1",
                    ),
                child: const Text("open"),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    expect(find.text(S.addCategory), findsOneWidget);
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.save),
    );
    expect(save.onPressed, isNull);

    await tester.enterText(find.byType(TextField), "Du lịch");
    await tester.pump();
    final save2 = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.save),
    );
    expect(save2.onPressed, isNotNull);
  });

  testWidgets("edit category shows delete error 23503 under delete", (
    tester,
  ) async {
    when(() => expenses.deleteCategory(any())).thenThrow(
      const PostgrestException(message: "fk", code: "23503"),
    );
    _setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed:
                    () => showExpenseCategorySheet(
                      context: context,
                      expenses: expenses,
                      homeId: "h1",
                      existing: _cats[1],
                    ),
                child: const Text("open"),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    expect(find.text(S.editCategory), findsOneWidget);
    expect(find.text(S.deleteCategory), findsOneWidget);

    await tester.tap(find.text(S.deleteCategory));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, S.delete));
    await tester.pumpAndSettle();

    expect(find.text(S.categoryDeleteInUse), findsOneWidget);
  });

  testWidgets("default category hides delete button", (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed:
                    () => showExpenseCategorySheet(
                      context: context,
                      expenses: expenses,
                      homeId: "h1",
                      existing: _cats[0],
                    ),
                child: const Text("open"),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    expect(find.text(S.deleteCategory), findsNothing);
  });
}
