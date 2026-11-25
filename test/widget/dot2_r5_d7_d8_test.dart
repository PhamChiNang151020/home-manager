import "package:flutter/material.dart";
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
  balanceVnd: 100000,
);

void _web(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
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
  late List<Expense> store;

  setUpAll(() async {
    await initializeDateFormatting("vi");
    await loadShotFonts();
    registerFallbackValue("");
    registerFallbackValue(0.0);
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  setUp(() {
    expenses = MockExpenseService();
    homes = MockHomeService();
    photos = MockBillPhotoService();
    incomes = MockIncomeService();
    wallets = MockWalletService();
    services = AppServices(MockSupabaseClient());
    store = [];

    when(() => expenses.listCategories(any())).thenAnswer((_) async => [_cat]);
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
      () => expenses.list(any(), month: any(named: "month")),
    ).thenAnswer((_) async => List<Expense>.from(store));
    when(
      () => expenses.insert(
        homeId: any(named: "homeId"),
        categoryId: any(named: "categoryId"),
        paidBy: any(named: "paidBy"),
        amountVnd: any(named: "amountVnd"),
        expenseDate: any(named: "expenseDate"),
        note: any(named: "note"),
      ),
    ).thenAnswer((inv) async {
      final e = Expense(
        id: "e-new",
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

  testWidgets(
    "D7 quick save from shell refreshes Khoản chi list and month total",
    (tester) async {
      _web(tester);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: AppAccent.amber,
            glass: false,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text(S.transactions)),
            body: ExpensesPage(
              home: _home,
              expenses: expenses,
              homesApi: homes,
              photos: photos,
              currentUserId: "u1",
              incomes: incomes,
              services: services,
              wallets: wallets,
            ),
            bottomNavigationBar: AppBottomNav(
              tabIndex: 1,
              notificationBadge: 0,
              onTabSelected: (_) {},
              onQuickAdd: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(S.noExpenses), findsOneWidget);
      expect(find.textContaining("0 đ"), findsWidgets);

      // Same path as shell + → Chi tiêu: quick sheet then save.
      // Shell onSaved (app_shell.dart:107-109) must refresh the open list.
      final ctx = tester.element(find.byType(ExpensesPage));
      showQuickAddSheet(
        context: ctx,
        home: _home,
        expenses: expenses,
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
        onSaved: () {
          // Mirrors AppShell._openQuickAdd onSaved after the fix.
          ExpensesPageState.refreshActive();
        },
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
      await tester.pump(const Duration(milliseconds: 50));

      expect(store, isNotEmpty, reason: "insert must have landed");
      expect(find.text(S.noExpenses), findsNothing);
      expect(find.text("Khác"), findsWidgets);
      expect(find.textContaining("1.000"), findsWidgets);
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets(
    "D8 Khoản chi subtitle is 1 line ellipsis; email shows local-part only",
    (tester) async {
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
          note: "TEST QA r2 có ví",
          paidByName: "phamchinang.vn+hmtest-owner-20261109@gmail.com",
          category: _cat,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(
            brightness: Brightness.light,
            accent: AppAccent.amber,
            glass: false,
          ),
          home: Scaffold(
            body: ExpensesPage(
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
      );
      await tester.pump();
      // AnimatedEntrance uses an 80ms timer.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      final row = find.byType(ListGroupRow).first;
      final subtitleFinder = find.descendant(
        of: row,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data?.contains("phamchinang") ?? false) &&
              (w.data?.contains(" · ") ?? false),
        ),
      );
      expect(subtitleFinder, findsOneWidget);
      final subtitle = tester.widget<Text>(subtitleFinder);
      expect(
        subtitle.data!.contains("@"),
        isFalse,
        reason: "Khoản chi subtitle must use email local-part only",
      );
      expect(subtitle.data!, contains("phamchinang.vn+hmtest-owner-20261109"));
      expect(subtitle.data!, contains("TEST QA r2 có ví"));
      expect(subtitle.maxLines, 1);
      expect(subtitle.overflow, TextOverflow.ellipsis);

      final subBox = tester.renderObject(subtitleFinder) as RenderBox;
      expect(subBox.size.height, lessThanOrEqualTo(17));
      // Fixed 56 body + optional 1px divider.
      final rowBox = tester.renderObject(row) as RenderBox;
      expect(rowBox.size.height, lessThanOrEqualTo(57));
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );

  testWidgets("D8 ListGroupRow subtitle clips with ellipsis", (tester) async {
    _web(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: SizedBox(
            width: 361,
            child: ListGroupRow(
              title: "Khác",
              subtitle:
                  "phamchinang.vn+hmtest-owner-20261109 · TEST QA r2 có ví rất dài",
              height: ListGroupRowHeight.h56,
              trailing: const Text("1.000 đ"),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final text = tester.widget<Text>(
      find.textContaining("phamchinang"),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });
}
