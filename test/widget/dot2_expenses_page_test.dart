import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/income.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/income_service.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";

class MockExpenseService extends Mock implements ExpenseService {}

class MockHomeService extends Mock implements HomeService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

class MockIncomeService extends Mock implements IncomeService {}

class MockWalletService extends Mock implements WalletService {}

const _home = Home(
  id: "h1",
  name: "Nhà test",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

final _cat = ExpenseCategory(
  id: "c1",
  homeId: "h1",
  name: "Ăn uống",
  iconKey: "restaurant",
  colorKey: "food",
  isDefault: true,
);

Expense _expense({
  required String id,
  required double amount,
  required DateTime date,
  String paidBy = "u1",
  String? paidByName = "An",
  String? note,
}) {
  return Expense(
    id: id,
    homeId: "h1",
    categoryId: "c1",
    paidBy: paidBy,
    amountVnd: amount,
    expenseDate: date,
    createdAt: date,
    paidByName: paidByName,
    note: note,
    category: _cat,
  );
}

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
  late MockHomeService homes;
  late MockBillPhotoService photos;
  late MockIncomeService incomes;
  late MockWalletService wallets;
  late AppServices services;

  setUpAll(() async {
    await initializeDateFormatting("vi");
    await _loadNunito();
  });

  setUp(() {
    expenses = MockExpenseService();
    homes = MockHomeService();
    photos = MockBillPhotoService();
    incomes = MockIncomeService();
    wallets = MockWalletService();
    services = AppServices(MockSupabaseClient());
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    List<Expense> items = const [],
    List<HomeMember> members = const [
      HomeMember(userId: "u1", role: "owner", displayName: "An"),
      HomeMember(userId: "u2", role: "member", displayName: "Bình"),
    ],
    double income = 0,
    bool fail = false,
  }) async {
    _setPhone(tester);
    if (fail) {
      when(() => expenses.listCategories(any())).thenThrow(Exception("net"));
    } else {
      when(() => expenses.listCategories(any())).thenAnswer((_) async => [_cat]);
      when(
        () => expenses.list(any(), month: any(named: "month")),
      ).thenAnswer((_) async => items);
      when(() => homes.listMembers(any())).thenAnswer((_) async => members);
      when(() => wallets.list(any())).thenAnswer((_) async => []);
      when(
        () => incomes.list(any(), month: any(named: "month")),
      ).thenAnswer(
        (_) async =>
            income <= 0
                ? <Income>[]
                : [
                  Income(
                    id: "i1",
                    homeId: "h1",
                    userId: "u1",
                    incomeMonth: DateTime(2026, 11, 1),
                    amountVnd: income,
                    createdAt: DateTime(2026, 11, 1),
                  ),
                ],
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
          glass: false,
        ),
        home: Scaffold(
          body: SizedBox(
            width: 393,
            height: 700,
            child: ExpensesPage(
              home: _home,
              expenses: expenses,
              homesApi: homes,
              photos: photos,
              currentUserId: "u1",
              incomes: incomes,
              services: services,
              wallets: wallets,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets("expenses month view shows summary whoSpent and day groups", (
    tester,
  ) async {
    await pumpPage(
      tester,
      items: [
        _expense(
          id: "e1",
          amount: 100000,
          date: DateTime(2026, 11, 9),
          note: "chợ",
        ),
        _expense(
          id: "e2",
          amount: 50000,
          date: DateTime(2026, 11, 9),
          paidBy: "u2",
          paidByName: "Bình",
        ),
        _expense(
          id: "e3",
          amount: 20000,
          date: DateTime(2026, 11, 8),
          paidBy: "left",
          paidByName: "Cũ",
        ),
      ],
      income: 15000000,
    );
    await tester.pumpAndSettle();

    expect(find.byType(MonthStepper), findsOneWidget);
    expect(find.textContaining("Tổng chi tháng"), findsOneWidget);
    expect(find.text(S.whoSpent), findsOneWidget);
    expect(find.text(S.expenseItems), findsOneWidget);
    expect(find.textContaining("Danh mục"), findsWidgets);
    expect(find.text("An"), findsWidgets);
    expect(find.text("Bình"), findsWidgets);
    expect(find.text("Cũ"), findsWidgets);
    expect(find.textContaining("Thu nhập tháng"), findsOneWidget);
  });

  testWidgets("expenses empty keeps summary and empty copy", (tester) async {
    await pumpPage(tester, items: []);
    await tester.pumpAndSettle();

    expect(find.textContaining("Tổng chi tháng"), findsOneWidget);
    expect(find.text(S.incomeNone), findsOneWidget);
    expect(find.text(S.noExpenses), findsOneWidget);
    expect(find.text(S.noExpensesHint), findsOneWidget);
    expect(find.text(S.whoSpent), findsNothing);
  });

  testWidgets("expenses load error shows sample 14 copy and retry", (
    tester,
  ) async {
    await pumpPage(tester, fail: true);
    await tester.pumpAndSettle();

    expect(find.text(S.loadFailedTitle), findsOneWidget);
    expect(find.text(S.loadFailedHint), findsOneWidget);
    expect(find.text(S.retry), findsOneWidget);
  });

  testWidgets("income row key is present for navigation", (tester) async {
    await pumpPage(tester, items: [], income: 1000);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey("expenses-income-row")), findsOneWidget);
  });
}
