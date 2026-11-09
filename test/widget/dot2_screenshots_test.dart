import "dart:convert";
import "dart:io";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/income.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/income_service.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/expenses/expense_categories_page.dart";
import "package:home_manager/features/expenses/expense_category_sheet.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";

class MockExpenseService extends Mock implements ExpenseService {}

class MockHomeService extends Mock implements HomeService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

class MockIncomeService extends Mock implements IncomeService {}

class MockWalletService extends Mock implements WalletService {}

const _outDir = "/cursor/stores/self/artifacts/dot2";

const _owner = Home(
  id: "h1",
  name: "Nhà test",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

const _member = Home(
  id: "h1",
  name: "Nhà test",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "member",
);

final _cats = [
  for (var i = 0; i < 6; i++)
    ExpenseCategory(
      id: "c$i",
      homeId: "h1",
      name: ["Ăn uống", "Đi lại", "Nhà cửa", "Sức khoẻ", "Học phí", "Khác"][i],
      iconKey: [
        "restaurant",
        "directions_car",
        "home",
        "health_and_safety",
        "school",
        "more_horiz",
      ][i],
      colorKey: ["food", "loan", "other", "health", "tuition", "other"][i],
      isDefault: i < 5,
    ),
];

final _wallets = [
  Wallet(
    id: "w1",
    homeId: "h1",
    kind: WalletKind.cash,
    name: "Tiền mặt",
    balanceVnd: 100000,
  ),
  Wallet(
    id: "w2",
    homeId: "h1",
    kind: WalletKind.bank,
    name: "Vietcombank",
    balanceVnd: 50000,
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
  final materialPath =
      "${Platform.environment["HOME"]}/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf";
  final material =
      FontLoader("MaterialIcons")
        ..addFont(
          File(materialPath).readAsBytes().then((b) => ByteData.view(b.buffer)),
        );
  await material.load();
}

void _setPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
}

Widget _frame({required Widget child}) {
  return RepaintBoundary(
    key: const ValueKey("shot"),
    child: SizedBox(
      width: 393,
      height: 852,
      child: MediaQuery(
        data: const MediaQueryData(
          size: Size(393, 852),
          padding: EdgeInsets.only(top: 59, bottom: 34),
          viewPadding: EdgeInsets.only(top: 59, bottom: 34),
          textScaler: TextScaler.noScaling,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: AppAccent.amber,
            glass: false,
          ),
          home: child,
        ),
      ),
    ),
  );
}

Future<void> _savePng(WidgetTester tester, String name) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey("shot")),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  final dir = Directory(_outDir);
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File("$_outDir/$name.png").writeAsBytesSync(bytes!);
}

Rect _box(WidgetTester tester, Finder f) {
  final ro = tester.renderObject(f) as RenderBox;
  final topLeft = ro.localToGlobal(Offset.zero);
  return topLeft & ro.size;
}

List<num> _yxyx(Rect r) => [
  r.top.round(),
  r.bottom.round(),
  r.left.round(),
  r.right.round(),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockExpenseService expenses;
  late MockHomeService homes;
  late MockBillPhotoService photos;
  late MockIncomeService incomes;
  late MockWalletService wallets;
  late AppServices services;
  final measured = <String, dynamic>{};

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
    when(() => expenses.listCategories(any())).thenAnswer((_) async => _cats);
    when(() => homes.listMembers(any())).thenAnswer(
      (_) async => const [
        HomeMember(userId: "u1", role: "owner", displayName: "An"),
        HomeMember(userId: "u2", role: "member", displayName: "Bình"),
        HomeMember(userId: "u3", role: "member", displayName: "Chi"),
      ],
    );
    when(() => wallets.list(any())).thenAnswer((_) async => _wallets);
    when(
      () => wallets.lastUsedWalletId(
        homeId: any(named: "homeId"),
        userId: any(named: "userId"),
      ),
    ).thenAnswer((_) async => "w1");
    when(() => incomes.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => [
        Income(
          id: "i1",
          homeId: "h1",
          userId: "u1",
          amountVnd: 15000000,
          incomeMonth: DateTime(2026, 11, 1),
          createdAt: DateTime(2026, 11, 1),
        ),
      ],
    );
  });

  tearDownAll(() {
    final dir = Directory(_outDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File("$_outDir/measured.json").writeAsStringSync(
      const JsonEncoder.withIndent("  ").convert(measured),
    );
  });

  testWidgets("02 chi tieu with data screenshot + measure", (tester) async {
    _setPhone(tester);
    when(() => expenses.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => [
        Expense(
          id: "e1",
          homeId: "h1",
          categoryId: "c0",
          paidBy: "u1",
          amountVnd: 200000,
          expenseDate: DateTime(2026, 11, 9),
          createdAt: DateTime(2026, 11, 9),
          paidByName: "An",
          note: "chợ",
          category: _cats[0],
        ),
        Expense(
          id: "e2",
          homeId: "h1",
          categoryId: "c1",
          paidBy: "u2",
          amountVnd: 120000,
          expenseDate: DateTime(2026, 11, 9),
          createdAt: DateTime(2026, 11, 9),
          paidByName: "Bình",
          category: _cats[1],
        ),
        Expense(
          id: "e3",
          homeId: "h1",
          categoryId: "c2",
          paidBy: "u3",
          amountVnd: 80000,
          expenseDate: DateTime(2026, 11, 8),
          createdAt: DateTime(2026, 11, 8),
          paidByName: "Chi",
          category: _cats[2],
        ),
      ],
    );

    await tester.pumpWidget(
      _frame(
        child: Scaffold(
          appBar: AppBar(title: const Text(S.transactions)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SegmentedTrack(
                  labels: const [S.expenses, S.electricity, S.water],
                  index: 0,
                  onChanged: (_) {},
                ),
              ),
              Expanded(
                child: ExpensesPage(
                  home: _owner,
                  expenses: expenses,
                  homesApi: homes,
                  photos: photos,
                  currentUserId: "u1",
                  incomes: incomes,
                  services: services,
                  wallets: wallets,
                ),
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 1,
            notificationBadge: 1,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "02-chi-tieu");

    final seg = _box(tester, find.byType(SegmentedTrack));
    final month = _box(tester, find.byType(MonthStepper));
    final sum = _box(tester, find.textContaining("Tổng chi tháng"));
    final income = _box(tester, find.byKey(const ValueKey("expenses-income-row")));
    final who = _box(tester, find.text(S.whoSpent));
    measured["02"] = {
      "first_block": "seg",
      "seg": _yxyx(seg),
      "month": _yxyx(month),
      "month_rel": [month.top - seg.top, month.bottom - seg.top],
      "sum_label_rel": [sum.top - seg.top, sum.bottom - seg.top],
      "income_rel": [income.top - seg.top, income.bottom - seg.top],
      "who_rel": [who.top - seg.top, who.bottom - seg.top],
      "spec_rel": {
        "month": [179 - 123, 227 - 123],
        "sum_label": [252 - 123, 268 - 123],
        "income": [323 - 123, 371 - 123],
        "who": [396 - 123, 420 - 123],
      },
      "delta_rel": {
        "month": [
          (month.top - seg.top) - (179 - 123),
          (month.bottom - seg.top) - (227 - 123),
        ],
        "sum_label": [
          (sum.top - seg.top) - (252 - 123),
          (sum.bottom - seg.top) - (268 - 123),
        ],
        "income": [
          (income.top - seg.top) - (323 - 123),
          (income.bottom - seg.top) - (371 - 123),
        ],
        "who": [
          (who.top - seg.top) - (396 - 123),
          (who.bottom - seg.top) - (420 - 123),
        ],
      },
    };
  });

  testWidgets("03 empty screenshot", (tester) async {
    _setPhone(tester);
    when(
      () => expenses.list(any(), month: any(named: "month")),
    ).thenAnswer((_) async => []);
    when(() => incomes.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => <Income>[],
    );

    await tester.pumpWidget(
      _frame(
        child: Scaffold(
          appBar: AppBar(title: const Text(S.transactions)),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SegmentedTrack(
                  labels: const [S.expenses, S.electricity, S.water],
                  index: 0,
                  onChanged: (_) {},
                ),
              ),
              Expanded(
                child: ExpensesPage(
                  home: _owner,
                  expenses: expenses,
                  homesApi: homes,
                  photos: photos,
                  currentUserId: "u1",
                  incomes: incomes,
                  services: services,
                  wallets: wallets,
                ),
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 1,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "03-chi-tieu-trong");
    final seg = _box(tester, find.byType(SegmentedTrack));
    final empty = _box(tester, find.text(S.noExpenses));
    measured["03"] = {
      "empty_title_rel": [empty.top - seg.top, empty.bottom - seg.top],
      "spec_empty_title": [493 - 123, 517 - 123],
    };
  });

  testWidgets("04 categories owner", (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(
      _frame(
        child: ExpenseCategoriesScreen(home: _owner, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "04-danh-muc");
    final hint = _box(tester, find.text(S.expenseCategoriesHint));
    final add = _box(tester, find.text(S.addCategory));
    measured["04"] = {
      "first_block": "hint",
      "hint": _yxyx(hint),
      "add_btn": _yxyx(add),
      "spec_hint": [123, 143],
      "spec_add": [763, 811],
    };
  });

  testWidgets("05 categories member", (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(
      _frame(
        child: ExpenseCategoriesScreen(home: _member, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "05-danh-muc-thanh-vien");
    final note = _box(tester, find.text(S.categoriesOwnerOnly));
    measured["05"] = {
      "owner_note": _yxyx(note),
      "spec_note": [513, 533],
    };
  });

  testWidgets("06 add sheet", (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(
      _frame(
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed:
                      () => showExpenseCategorySheet(
                        context: context,
                        expenses: expenses,
                        homeId: "h1",
                      ),
                  child: const Text("open"),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    await _savePng(tester, "06-danh-muc-them");
    final title = _box(tester, find.text(S.addCategory));
    measured["06"] = {
      "sheet_title": _yxyx(title),
      "spec_title": [390, 414],
    };
  });

  testWidgets("07 edit sheet delete error", (tester) async {
    when(() => expenses.deleteCategory(any())).thenThrow(
      Exception("fk"),
    );
    // Force 23503 via categoryErrorMessage path — throw Postgrest in real code;
    // here we just open edit sheet with delete visible.
    _setPhone(tester);
    await tester.pumpWidget(
      _frame(
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed:
                      () => showExpenseCategorySheet(
                        context: context,
                        expenses: expenses,
                        homeId: "h1",
                        existing: _cats.last,
                      ),
                  child: const Text("open"),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    await _savePng(tester, "07-danh-muc-sua");
    measured["07"] = {
      "has_delete": find.text(S.deleteCategory).evaluate().isNotEmpty,
    };
  });

  testWidgets("expense form wallet field + over balance", (tester) async {
    _setPhone(tester);
    await tester.pumpWidget(
      _frame(
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed:
                      () => showExpenseForm(
                        context: context,
                        home: _owner,
                        expenses: expenses,
                        photos: photos,
                        categories: _cats,
                        members: const [
                          HomeMember(
                            userId: "u1",
                            role: "owner",
                            displayName: "An",
                          ),
                        ],
                        currentUserId: "u1",
                        wallets: _wallets,
                        walletService: wallets,
                        onSaved: () {},
                      ),
                  child: const Text("open"),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();
    await _savePng(tester, "expense-form-vi");

    final amountField = _box(tester, find.byType(TextField).first);
    final wallet = _box(tester, find.byKey(const ValueKey("expense-wallet-field")));
    measured["wallet_form"] = {
      "amount_bottom": amountField.bottom.round(),
      "wallet_rel": [
        wallet.top - amountField.bottom,
        wallet.bottom - amountField.bottom,
      ],
      "spec_wallet_rel": [36, 100],
    };

    await tester.enterText(find.byType(TextField).first, "500000");
    await tester.pump();
    await _savePng(tester, "expense-form-over-balance");
    expect(find.text(S.walletOverBalance), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey("expense-wallet-field")));
    await tester.pumpAndSettle();
    await _savePng(tester, "chon-vi-sheet");
    measured["wallet_picker"] = {
      "title": _yxyx(_box(tester, find.text(S.walletPickTitle))),
    };
  });
}
