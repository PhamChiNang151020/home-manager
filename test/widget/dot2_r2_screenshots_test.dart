import "dart:convert";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
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
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/expenses/expense_categories_page.dart";
import "package:home_manager/features/expenses/expense_category_sheet.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/shared/empty_state_view.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:home_manager/features/shared/progress_bar.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shared/sticky_primary_bar.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/wallet/wallet_picker_sheet.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mocktail/mocktail.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../support/mock_supabase.dart";
import "../support/shots.dart";

class MockExpenseService extends Mock implements ExpenseService {}

class MockHomeService extends Mock implements HomeService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

class MockIncomeService extends Mock implements IncomeService {}

class MockWalletService extends Mock implements WalletService {}


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

/// System categories: 'Khác' is_default=true (Delete hidden).
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
      isDefault: true,
    ),
];

/// Custom (non-default) category — Delete visible; used for 23503 shot.
const _customCat = ExpenseCategory(
  id: "c-custom",
  homeId: "h1",
  name: "Du lịch",
  iconKey: "celebration",
  colorKey: "other",
  isDefault: false,
);

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

Future<void> _loadFonts() async {
  await loadShotFonts();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
}

Widget _shell({required Widget body, int badge = 0}) {
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
          home: Scaffold(
            appBar: AppBar(
              title: const Text(
                S.transactions,
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: MobileViewport(child: body),
            bottomNavigationBar: AppBottomNav(
              tabIndex: 1,
              notificationBadge: badge,
              onTabSelected: (_) {},
              onQuickAdd: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _page({required Widget child}) {
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
  // Extra frames so icon glyphs paint after FontLoader.
  await tester.pump(const Duration(milliseconds: 100));
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey("shot")),
  );
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  writeShotBytes("$name.png", bytes!);
}

List<num> _yxyx(Rect r) => [
  r.top.round(),
  r.bottom.round(),
  r.left.round(),
  r.right.round(),
];

Rect _box(WidgetTester tester, Finder f) {
  final ro = tester.renderObject(f) as RenderBox;
  return ro.localToGlobal(Offset.zero) & ro.size;
}

Map<String, Object?> _cmp(List<num> measured, List<num> spec, {double tol = 3}) {
  final deltas = <num>[];
  for (var i = 0; i < measured.length && i < spec.length; i++) {
    deltas.add(measured[i] - spec[i]);
  }
  final ok = deltas.every((d) => d.abs() <= tol);
  return {"measured": measured, "spec": spec, "delta": deltas, "ok": ok};
}

void main() {
  // Entire screenshot suite is opt-in via HM_SHOTS=1 + HM_SHOTS_DIR.
  if (!shouldCaptureShots) {
    test("screenshots skipped without HM_SHOTS", () {});
    return;
  }

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
    await _loadFonts();
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
    if (shouldCaptureShots) {
      writeShotText(
        "measured.json",
        const JsonEncoder.withIndent("  ").convert(measured),
      );
    }
  });

  testWidgets("r2 02 full measure", (tester) async {
    _phone(tester);
    when(() => expenses.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => [
        Expense(
          id: "e1",
          homeId: "h1",
          categoryId: "c0",
          paidBy: "u1",
          amountVnd: 3300000,
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
          amountVnd: 1500000,
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
          amountVnd: 700000,
          expenseDate: DateTime(2026, 11, 8),
          createdAt: DateTime(2026, 11, 8),
          paidByName: "Chi",
          category: _cats[2],
        ),
      ],
    );

    await tester.pumpWidget(
      _shell(
        badge: 1,
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
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "02-chi-tieu");

    final title = _box(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text(S.transactions),
      ),
    );
    final seg = _box(tester, find.byType(SegmentedTrack));
    final month = _box(tester, find.byType(MonthStepper));
    final sum = _box(tester, find.byKey(const ValueKey("expenses-summary-card")));
    final amount = _box(
      tester,
      find.byKey(const ValueKey("expenses-summary-amount")),
    );
    final income = _box(
      tester,
      find.byKey(const ValueKey("expenses-income-row")),
    );
    final whoTitle = _box(tester, find.text(S.whoSpent));
    final whoCard = _box(tester, find.byKey(const ValueKey("expenses-who-card")));
    final who0 = _box(tester, find.byKey(const ValueKey("who-row-0")));
    final bar0 = _box(tester, find.byType(ProgressBar).first);
    final itemsHeader = _box(
      tester,
      find.byKey(const ValueKey("expenses-items-header")),
    );
    final catLink = _box(
      tester,
      find.widgetWithText(TextButton, "${S.category} ›"),
    );
    final day0 = _box(tester, find.byKey(const ValueKey("expenses-day0")));
    final ex0 = _box(tester, find.byType(ListGroupRow).first);

    final first = seg.top;
    measured["02"] = {
      "first_block": "seg",
      // Title text is intrinsic width; assert y band + left inset + type style.
      "title": _cmp(
        [title.top.round(), title.bottom.round(), title.left.round()],
        [73, 101, 16],
      ),
      "title_style": {
        "fontSize": 22,
        "height": 28 / 22,
        "w700": true,
      },
      "seg": _cmp(_yxyx(seg), [123, 171, 16, 377]),
      "month": _cmp(_yxyx(month), [179, 227, 16, 377]),
      "sum_card": _cmp(_yxyx(sum), [235, 372, 16, 377]),
      // Amount row: card x16 + pad16 => x32; right pad16 => x361.
      "sum_amount": _cmp(_yxyx(amount), [272, 311, 32, 361]),
      "income_row": _cmp(_yxyx(income), [323, 371, 17, 376]),
      "h_who": _cmp(_yxyx(whoTitle), [396, 420, 16, 377]),
      "who_card": _cmp(_yxyx(whoCard), [428, 622, 16, 377]),
      "who0": _cmp([
        who0.top.round(),
        who0.bottom.round(),
        who0.left.round(),
        who0.right.round(),
      ], [429, 493, 17, 376]),
      "who0_bar": _cmp(_yxyx(bar0), [472, 478, 81, 360]),
      "h_list": _cmp(_yxyx(itemsHeader), [646, 670, 16, 377]),
      "cat_link_touch": _cmp(_yxyx(catLink), [634, 682, 286, 377]),
      "day0": _cmp(_yxyx(day0), [678, 694, 16, 377]),
      "ex0": _cmp(_yxyx(ex0), [703, 759, 17, 376]),
      "rel_ok": {
        "month": ((month.top - first) - (179 - 123)).abs() <= 3,
        "sum": ((sum.top - first) - (235 - 123)).abs() <= 3,
        "who_card": ((whoCard.top - first) - (428 - 123)).abs() <= 3,
      },
    };
  });

  testWidgets("r2 03 empty", (tester) async {
    _phone(tester);
    when(
      () => expenses.list(any(), month: any(named: "month")),
    ).thenAnswer((_) async => []);
    when(() => incomes.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => <Income>[],
    );
    await tester.pumpWidget(
      _shell(
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
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "03-chi-tieu-trong");
    final empty = _box(tester, find.byType(EmptyStateView));
    measured["03"] = {
      "empty_card": _cmp(_yxyx(empty), [396, 566, 16, 377]),
    };
  });

  testWidgets("r2 04 categories owner", (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
        child: ExpenseCategoriesScreen(home: _owner, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "04-danh-muc");
    final hint = _box(tester, find.text(S.expenseCategoriesHint));
    final list = _box(tester, find.byType(ListGroup));
    final row0 = _box(tester, find.text("Ăn uống"));
    final addBar = _box(tester, find.byType(StickyPrimaryBar));
    final addBtn = _box(
      tester,
      find.descendant(
        of: find.byType(StickyPrimaryBar),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    measured["04"] = {
      "hint": _cmp(_yxyx(hint), [123, 143, 16, 377]),
      "cat_card": _cmp(_yxyx(list), [159, 497, 16, 377]),
      "row0_text_y": [row0.top.round(), row0.bottom.round()],
      "btn_add_bar": _yxyx(addBar),
      "btn_add": _cmp(_yxyx(addBtn), [763, 811, 16, 377]),
      "row_height_spec": 56,
    };
  });

  testWidgets("r2 05 member", (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
        child: ExpenseCategoriesScreen(home: _member, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();
    await _savePng(tester, "05-danh-muc-thanh-vien");
    final note = _box(tester, find.text(S.categoriesOwnerOnly));
    final lock = _box(tester, find.byIcon(Icons.lock));
    measured["05"] = {
      "owner_note_text": _cmp(_yxyx(note), [513, 533, 44, 377]),
      "owner_note_row": _cmp([
        lock.top.round(),
        note.bottom.round(),
        lock.left.round(),
        note.right.round(),
      ], [513, 533, 16, 377]),
      "no_add": find.text(S.addCategory).evaluate().isEmpty,
      "no_chevron": find.byIcon(Icons.chevron_right).evaluate().isEmpty,
      "khac_is_default": _cats.last.isDefault,
    };
  });

  testWidgets("r2 06 add sheet", (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
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
    final field = _box(tester, find.byType(TextField));
    final icon0 = _box(
      tester,
      find.byKey(const ValueKey("cat-icon-restaurant")),
    );
    final color0 = _box(
      tester,
      find.byKey(const ValueKey("cat-color-food")),
    );
    final save = _box(tester, find.widgetWithText(FilledButton, S.save));
    final saveBtn = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.save),
    );
    measured["06"] = {
      "sheet": _cmp(
        [title.top - 36, 852, 0, 393],
        [354, 852, 0, 393],
      ),
      "sheet_title": _cmp(_yxyx(title), [390, 414, 16, 377]),
      "f_name": _cmp(_yxyx(field), [450, 498, 16, 377]),
      "error_slot": _cmp(
        [field.bottom + 4, field.bottom + 4 + 16, 16, 377],
        [502, 518, 16, 377],
      ),
      "icon_cell": _cmp(_yxyx(icon0), [550, 598, 16, 70]),
      "icon_grid": _cmp(
        [550, 654, 16, 377],
        [550, 654, 16, 377],
      ),
      "color_dot_hit": _cmp(_yxyx(color0), [690, 738, 16, 64]),
      "btn_save": _cmp(_yxyx(save), [754, 802, 16, 377]),
      "save_disabled_when_empty": saveBtn.onPressed == null,
    };
  });

  testWidgets("r2 07 edit 23503", (tester) async {
    when(() => expenses.deleteCategory(any())).thenThrow(
      const PostgrestException(message: "fk", code: "23503"),
    );
    _phone(tester);
    await tester.pumpWidget(
      _page(
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
                        existing: _customCat,
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
    expect(_customCat.isDefault, isFalse);
    expect(_cats.last.name, "Khác");
    expect(_cats.last.isDefault, isTrue);
    await tester.tap(find.text(S.deleteCategory));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, S.delete));
    await tester.pumpAndSettle();
    await _savePng(tester, "07-danh-muc-sua-loi");

    final title = _box(tester, find.text(S.editCategory));
    final save = _box(tester, find.widgetWithText(FilledButton, S.save));
    final err = _box(tester, find.text(S.categoryDeleteInUse));
    final errIcon = _box(tester, find.byIcon(Icons.error_outline));
    final del = _box(tester, find.widgetWithText(TextButton, S.deleteCategory));
    measured["07"] = {
      "sheet": _cmp(
        [title.top - 36, 852, 0, 393],
        [258, 852, 0, 393],
      ),
      "sheet_title": _yxyx(title),
      "btn_save": _cmp(_yxyx(save), [658, 706, 16, 377]),
      "err_del": _cmp(_yxyx(err), [714, 746, 40, 377]),
      "err_icon": {
        "size": errIcon.width.round(),
        "measured": _yxyx(errIcon),
      },
      "btn_delete": _cmp(_yxyx(del), [754, 802, 16, 377]),
      "khac_is_default": _cats.last.isDefault,
      "custom_can_delete": !_customCat.isDefault,
    };
  });

  testWidgets("r2 07 default Khác hides delete", (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
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
    measured["07_khac_default"] = {
      "is_default": _cats.last.isDefault,
      "delete_hidden": find.text(S.deleteCategory).evaluate().isEmpty,
    };
    expect(find.text(S.deleteCategory), findsNothing);
  });

  testWidgets("r2 wallet form + picker n=2", (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
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

    final amount = _box(tester, find.byType(TextField).first);
    final walletLabel = _box(tester, find.text(S.walletPayFrom));
    final walletField = _box(
      tester,
      find.byKey(const ValueKey("expense-wallet-field")),
    );
    final b = amount.bottom;
    measured["wallet_form"] = {
      "label_rel": _cmp(
        [walletLabel.top - b, walletLabel.bottom - b],
        [16, 32],
      ),
      "field_rel": _cmp(
        [walletField.top - b, walletField.bottom - b],
        [36, 100],
      ),
    };

    await tester.enterText(find.byType(TextField).first, "500000");
    await tester.pump();
    await _savePng(tester, "expense-form-over-balance");
    final over = _box(tester, find.text(S.walletOverBalance));
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.save),
    );
    measured["wallet_over"] = {
      "line_rel": _cmp([over.top - b, over.bottom - b], [104, 120]),
      "save_disabled": save.onPressed == null,
    };

    await tester.tap(find.byKey(const ValueKey("expense-wallet-field")));
    await tester.pumpAndSettle();
    await _savePng(tester, "chon-vi-sheet");
    final wTitle = _box(tester, find.text(S.walletPickTitle));
    final list = _box(tester, find.byType(ListGroup).last);
    measured["wallet_picker_n2"] = {
      "sheet": _cmp(
        [wTitle.top - 36, 852, 0, 393],
        [532, 852, 0, 393],
      ),
      "title": _cmp(_yxyx(wTitle), [568, 592, 16, 377]),
      "card": _cmp(_yxyx(list), [608, 802, 16, 377]),
    };
  });

  testWidgets("r2 wallet picker n=10 scrolls from y115", (tester) async {
    _phone(tester);
    final many = [
      for (var i = 0; i < 10; i++)
        Wallet(
          id: "w$i",
          homeId: "h1",
          kind: WalletKind.cash,
          name: "Ví $i",
          balanceVnd: 1000.0 * (i + 1),
        ),
    ];
    await tester.pumpWidget(
      _page(
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed:
                      () => showWalletPickerSheet(
                        context: context,
                        wallets: many,
                        selectedWalletId: "w0",
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
    await _savePng(tester, "chon-vi-sheet-n10");
    final wTitle = _box(tester, find.text(S.walletPickTitle));
    measured["wallet_picker_n10"] = {
      "title_top": wTitle.top.round(),
      "sheet_top_est": (wTitle.top - 36).round(),
      "at_max": (wTitle.top - 36 - 115).abs() <= 3,
      "scrollable": find.byType(SingleChildScrollView).evaluate().isNotEmpty,
    };
  });
}
