import "dart:io";

import "package:flutter/material.dart";
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
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/expenses/expense_category_sheet.dart";
import "package:home_manager/features/expenses/expenses_page.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/wallet/wallet_picker_sheet.dart";
import "package:intl/date_symbol_data_local.dart";
import "package:mocktail/mocktail.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../support/mock_supabase.dart";

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
  name: "Ăn uống",
  iconKey: "restaurant",
  colorKey: "food",
  isDefault: true,
);

final _catCustom = ExpenseCategory(
  id: "c2",
  homeId: "h1",
  name: "Du lịch",
  iconKey: "celebration",
  colorKey: "other",
  isDefault: false,
);

Future<void> _loadFonts() async {
  final nunito =
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
  await nunito.load();
  // MaterialIcons from the Flutter SDK cache (bundled into test via engine).
  final materialPath =
      "${Platform.environment["HOME"]}/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf";
  final material =
      FontLoader("MaterialIcons")
        ..addFont(
          File(materialPath).readAsBytes().then((b) => ByteData.view(b.buffer)),
        );
  await material.load();
}

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
}

Rect _r(WidgetTester tester, Finder f) {
  final box = tester.renderObject(f) as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
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
    await _loadFonts();
  });

  setUp(() {
    expenses = MockExpenseService();
    homes = MockHomeService();
    photos = MockBillPhotoService();
    incomes = MockIncomeService();
    wallets = MockWalletService();
    services = AppServices(MockSupabaseClient());
    when(() => expenses.listCategories(any())).thenAnswer((_) async => [_cat]);
    when(() => homes.listMembers(any())).thenAnswer(
      (_) async => const [
        HomeMember(userId: "u1", role: "owner", displayName: "An"),
        HomeMember(userId: "u2", role: "member", displayName: "Bình"),
      ],
    );
    when(() => wallets.list(any())).thenAnswer((_) async => []);
    when(() => incomes.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => [
        Income(
          id: "i1",
          homeId: "h1",
          userId: "u1",
          amountVnd: 1000000,
          incomeMonth: DateTime(2026, 11, 1),
          createdAt: DateTime(2026, 11, 1),
        ),
      ],
    );
    when(() => expenses.list(any(), month: any(named: "month"))).thenAnswer(
      (_) async => [
        Expense(
          id: "e1",
          homeId: "h1",
          categoryId: "c1",
          paidBy: "u1",
          amountVnd: 100000,
          expenseDate: DateTime(2026, 11, 9),
          createdAt: DateTime(2026, 11, 9),
          paidByName: "An",
          note: "chợ",
          category: _cat,
        ),
      ],
    );
  });

  /// Spec: segmented + cards at x 16–377 inside MobileViewport.
  testWidgets(
    "02 expenses content left/right inset is 16 (x 16-377)",
    (tester) async {
      _phone(tester);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: AppAccent.amber,
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
            body: MobileViewport(
              child: Column(
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
            bottomNavigationBar: AppBottomNav(
              tabIndex: 1,
              onTabSelected: (_) {},
              onQuickAdd: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final seg = _r(tester, find.byType(SegmentedTrack));
      expect(seg.left, closeTo(16, 3));
      expect(seg.right, closeTo(377, 3));
      expect(seg.width, closeTo(361, 3));

      final cards = find.byType(AppCard);
      expect(cards, findsWidgets);
      for (final e in cards.evaluate().take(3)) {
        final r = _r(tester, find.byWidget(e.widget));
        expect(r.left, closeTo(16, 3), reason: "card left");
        expect(r.right, closeTo(377, 3), reason: "card right");
      }
    },
  );

  testWidgets("AppBar title Sổ giao dịch is 22/28 w700 at y 73-101", (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
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
          body: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final title = _r(tester, find.text(S.transactions));
    expect(title.top, closeTo(73, 3));
    expect(title.bottom, closeTo(101, 3));
    final style = tester.widget<Text>(find.text(S.transactions)).style!;
    expect(style.fontSize, 22);
    expect(style.fontWeight, FontWeight.w700);
  });

  testWidgets("Chọn ví n=2 hugs content sheet top ~532", (tester) async {
    _phone(tester);
    final ws = [
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
        name: "VCB",
        balanceVnd: 50000,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed:
                      () => showWalletPickerSheet(
                        context: context,
                        wallets: ws,
                        selectedWalletId: "w1",
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

    final title = _r(tester, find.text(S.walletPickTitle));
    // Spec: sheet 532–852, title 568–592 => title.top ≈ 568
    expect(
      title.top,
      closeTo(568, 3),
      reason: "n=2 sheet must hug; title at y 568 not stretched to top",
    );
    expect(title.bottom, closeTo(592, 3));
  });

  testWidgets("Chọn ví n=10 grows up to y 115 and scrolls", (tester) async {
    _phone(tester);
    final ws = [
      for (var i = 0; i < 10; i++)
        Wallet(
          id: "w$i",
          homeId: "h1",
          kind: WalletKind.cash,
          name: "Ví $i",
          balanceVnd: 1000.0 * i,
        ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed:
                      () => showWalletPickerSheet(
                        context: context,
                        wallets: ws,
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

    final title = _r(tester, find.text(S.walletPickTitle));
    // Sheet top >= 115; title at S+36 => >= 151
    expect(title.top, greaterThanOrEqualTo(115 + 36 - 3));
    expect(title.top, lessThan(200));
    // Last none-row may be off-screen; list scrolls.
    expect(find.text(S.walletPayFromNoneHint), findsOneWidget);
  });

  testWidgets("07 edit sheet shows 23503 error at y 714-746 and Lưu 658-706", (
    tester,
  ) async {
    when(() => expenses.deleteCategory(any())).thenThrow(
      const PostgrestException(message: "fk", code: "23503"),
    );
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed:
                      () => showExpenseCategorySheet(
                        context: context,
                        expenses: expenses,
                        homeId: "h1",
                        existing: _catCustom,
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

    await tester.tap(find.text(S.deleteCategory));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, S.delete));
    await tester.pumpAndSettle();

    expect(find.text(S.categoryDeleteInUse), findsOneWidget);

    final save = _r(tester, find.widgetWithText(FilledButton, S.save));
    final err = _r(tester, find.text(S.categoryDeleteInUse));
    // Measure the TextButton hit area (48), not the label text inside it.
    final del = _r(tester, find.widgetWithText(TextButton, S.deleteCategory));

    expect(save.top, closeTo(658, 3));
    expect(save.bottom, closeTo(706, 3));
    expect(err.top, closeTo(714, 3));
    expect(err.bottom, lessThanOrEqualTo(746 + 3));
    expect(del.top, closeTo(754, 3));
    expect(del.bottom, closeTo(802, 3));
  });

  testWidgets("default category hides Xoá danh mục", (tester) async {
    _phone(tester);
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
                      existing: _cat, // is_default true
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

  testWidgets("MonthStepper is present for month band measure", (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: MobileViewport(
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
    await tester.pumpAndSettle();
    expect(find.byType(MonthStepper), findsOneWidget);
  });
}
