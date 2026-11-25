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
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/expenses/quick_add_sheet.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mocktail/mocktail.dart";

import "../support/mock_supabase.dart";
import "../support/shots.dart";

class MockExpenseService extends Mock implements ExpenseService {}

class MockHomeService extends Mock implements HomeService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

class MockIncomeService extends Mock implements IncomeService {}

class MockWalletService extends Mock implements WalletService {}

const _home = Home(
  id: "h1",
  name: "Nhà",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

final _cat = ExpenseCategory(
  id: "c1",
  homeId: "h1",
  name: "Khác",
  iconKey: "more_horiz",
  colorKey: "other",
  isDefault: true,
);

final _wallet = Wallet(
  id: "w1",
  homeId: "h1",
  kind: WalletKind.cash,
  name: "TEST ví",
  balanceVnd: 99000,
);

void _web(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);
}

Future<void> _png(WidgetTester tester, String name) async {
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
  writeShotBytes("$name.png", bytes!);
}

Rect _box(WidgetTester tester, Finder f) {
  final ro = tester.renderObject(f) as RenderBox;
  return ro.localToGlobal(Offset.zero) & ro.size;
}

void main() {
  if (!shouldCaptureShots) {
    test("r5 screenshots skipped without HM_SHOTS", () {});
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();
  final measured = <String, dynamic>{};
  late MockExpenseService expensesApi;
  late MockHomeService homes;
  late MockBillPhotoService photos;
  late MockIncomeService incomes;
  late MockWalletService wallets;
  late AppServices services;
  late List<Expense> store;

  setUpAll(() async {
    await initializeDateFormatting("vi");
    await loadShotFonts();
    registerFallbackValue("");
    registerFallbackValue(0.0);
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  setUp(() {
    expensesApi = MockExpenseService();
    homes = MockHomeService();
    photos = MockBillPhotoService();
    incomes = MockIncomeService();
    wallets = MockWalletService();
    services = AppServices(MockSupabaseClient());
    store = [];
    when(() => expensesApi.listCategories(any())).thenAnswer((_) async => [_cat]);
    when(() => homes.listMembers(any())).thenAnswer(
      (_) async => const [
        HomeMember(
          userId: "u1",
          role: "owner",
          email: "phamchinang.vn+hmtest-owner-20261109@gmail.com",
        ),
      ],
    );
    when(() => wallets.list(any())).thenAnswer((_) async => [_wallet]);
    when(
      () => wallets.lastUsedWalletId(
        homeId: any(named: "homeId"),
        userId: any(named: "userId"),
      ),
    ).thenAnswer((_) async => "w1");
    when(() => wallets.revertExpense(any())).thenAnswer((_) async {});
    when(
      () => wallets.applyExpense(
        expenseId: any(named: "expenseId"),
        walletId: any(named: "walletId"),
        amount: any(named: "amount"),
      ),
    ).thenAnswer((_) async {});
    when(() => incomes.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => <Income>[],
    );
    when(
      () => expensesApi.list(any(), month: any(named: "month")),
    ).thenAnswer((_) async => List<Expense>.from(store));
    when(
      () => expensesApi.insert(
        homeId: any(named: "homeId"),
        categoryId: any(named: "categoryId"),
        paidBy: any(named: "paidBy"),
        amountVnd: any(named: "amountVnd"),
        expenseDate: any(named: "expenseDate"),
        note: any(named: "note"),
      ),
    ).thenAnswer((inv) async {
      final e = Expense(
        id: "e-${store.length + 1}",
        homeId: "h1",
        categoryId: inv.namedArguments[#categoryId] as String,
        paidBy: inv.namedArguments[#paidBy] as String,
        amountVnd: inv.namedArguments[#amountVnd] as double,
        expenseDate: inv.namedArguments[#expenseDate] as DateTime,
        createdAt: DateTime.now(),
        note: inv.namedArguments[#note] as String?,
        paidByName: "phamchinang.vn+hmtest-owner-20261109@gmail.com",
        category: _cat,
      );
      store = [e, ...store];
      return e;
    });
  });

  tearDownAll(() {
    writeShotText(
      "measured.json",
      const JsonEncoder.withIndent("  ").convert(measured),
    );
  });

  testWidgets("r5 D7 so-gd after quick save shows row + total", (tester) async {
    _web(tester);
    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey("shot"),
        child: SizedBox(
          width: 393,
          height: 852,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(393, 852),
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
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
                        home: _home,
                        expenses: expensesApi,
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
                  notificationBadge: 0,
                  onTabSelected: (_) {},
                  onQuickAdd: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final ctx = tester.element(find.byType(ExpensesPage));
    showQuickAddSheet(
      context: ctx,
      home: _home,
      expenses: expensesApi,
      photos: photos,
      categories: [_cat],
      members: const [
        HomeMember(
          userId: "u1",
          role: "owner",
          email: "phamchinang.vn+hmtest-owner-20261109@gmail.com",
        ),
      ],
      currentUserId: "u1",
      wallets: [_wallet],
      walletService: wallets,
      onSaved: ExpensesPageState.refreshActive,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField).first, "1000");
    await tester.pump();
    await tester.tap(find.text("Khác"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(S.noExpenses), findsNothing);
    expect(find.textContaining("1.000"), findsWidgets);

    // Hide toast so RepaintBoundary.toImage does not hang on Overlay.
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await _png(tester, "01-so-gd-sau-quick-save");
    final total = _box(tester, find.textContaining("1.000").first);
    final row = _box(tester, find.byType(ListGroupRow).first);
    measured["d7_after_quick_save"] = {
      "empty": false,
      "total_text_top": total.top,
      "row": {
        "top": row.top,
        "bottom": row.bottom,
        "height": row.height,
      },
      "spec": "new row + updated total visible without navigation",
    };
  });

  testWidgets("r5 D8 email local-part + ellipsis in 56 row", (tester) async {
    _web(tester);
    store = [
      Expense(
        id: "e1",
        homeId: "h1",
        categoryId: "c1",
        paidBy: "u1",
        amountVnd: 1000,
        expenseDate: DateTime(2026, 11, 25),
        createdAt: DateTime(2026, 11, 25),
        note: "TEST QA r2 có ví — ghi chú rất dài để buộc ellipsis",
        paidByName: "phamchinang.vn+hmtest-owner-20261109@gmail.com",
        category: _cat,
      ),
      Expense(
        id: "e2",
        homeId: "h1",
        categoryId: "c1",
        paidBy: "u1",
        amountVnd: 2000,
        expenseDate: DateTime(2026, 11, 25),
        createdAt: DateTime(2026, 11, 25),
        note: "không trừ ví",
        paidByName: "phamchinang.vn+hmtest-owner-20261109@gmail.com",
        category: _cat,
      ),
    ];

    await tester.pumpWidget(
      RepaintBoundary(
        key: const ValueKey("shot"),
        child: SizedBox(
          width: 393,
          height: 852,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(393, 852),
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
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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
                        home: _home,
                        expenses: expensesApi,
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
                  notificationBadge: 0,
                  onTabSelected: (_) {},
                  onQuickAdd: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    final row = find.byType(ListGroupRow).first;
    final sub = find.descendant(
      of: row,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.data?.contains("phamchinang") ?? false) &&
            (w.data?.contains(" · ") ?? false),
      ),
    );
    final subText = tester.widget<Text>(sub);
    final rowRect = _box(tester, row);
    final subRect = _box(tester, sub);

    await _png(tester, "02-khoan-chi-email-ellipsis");
    measured["d8_email_ellipsis"] = {
      "subtitle": subText.data,
      "has_at": subText.data!.contains("@"),
      "maxLines": subText.maxLines,
      "overflow": subText.overflow.toString(),
      "row_height": rowRect.height,
      "subtitle_height": subRect.height,
      "subtitle_top": subRect.top,
      "subtitle_bottom": subRect.bottom,
      "spec": {
        "row_height": 56,
        "subtitle_maxLines": 1,
        "email_local_part_only": true,
      },
      "ok":
          !subText.data!.contains("@") &&
          subText.maxLines == 1 &&
          rowRect.height <= 57 &&
          subRect.height <= 17,
    };
  });
}
