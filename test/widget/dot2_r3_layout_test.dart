import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/expense.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/models/wallet.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/expense_service.dart";
import "package:home_manager/core/services/wallet_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/expenses/expense_categories_page.dart";
import "package:home_manager/features/expenses/expense_form.dart";
import "package:home_manager/features/expenses/quick_add_sheet.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/feature_page_scaffold.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/shared/sticky_primary_bar.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:mocktail/mocktail.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "../support/shots.dart";

class MockExpenseService extends Mock implements ExpenseService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

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
    name: "VCB",
    balanceVnd: 50000,
  ),
];

/// Web viewport: safe-area 0 (QA web geometry).
void _webPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);
}

Rect _r(WidgetTester tester, Finder f) {
  final box = tester.renderObject(f) as RenderBox;
  return box.localToGlobal(Offset.zero) & box.size;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadShotFonts();
    registerFallbackValue("");
    registerFallbackValue(0.0);
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  testWidgets("D2 quick-add sheet shows Ô Ví labeled Ví under amount", (
    tester,
  ) async {
    _webPhone(tester);
    final expenses = MockExpenseService();
    final photos = MockBillPhotoService();
    final wallets = MockWalletService();
    when(
      () => wallets.lastUsedWalletId(
        homeId: any(named: "homeId"),
        userId: any(named: "userId"),
      ),
    ).thenAnswer((_) async => "w1");

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
                      () => showQuickAddSheet(
                        context: context,
                        home: _home,
                        expenses: expenses,
                        photos: photos,
                        categories: [_cat],
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

    expect(find.text(S.walletPayFrom), findsOneWidget);
    expect(find.text("Ví"), findsOneWidget);
    expect(find.text("Trả từ ví"), findsNothing);
    expect(find.byKey(const ValueKey("expense-wallet-field")), findsOneWidget);
    expect(find.text("Tiền mặt"), findsOneWidget);
  });

  testWidgets("D3 FeaturePageScaffold title is 22/28 w700", (tester) async {
    _webPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: const FeaturePageScaffold(
          title: S.expenseCategoriesTitle,
          body: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(find.text(S.expenseCategoriesTitle));
    expect(text.style?.fontSize, 22);
    expect(text.style?.height, closeTo(28 / 22, 0.001));
    expect(text.style?.fontWeight, FontWeight.w700);
  });

  testWidgets("D4 StickyPrimaryBar button is 48 tall; bar top 788 on web", (
    tester,
  ) async {
    _webPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: StickyPrimaryBar(
            label: S.addCategory,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bar = _r(tester, find.byType(StickyPrimaryBar));
    final btn = _r(
      tester,
      find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    expect(bar.top, closeTo(788, 3), reason: "web bar top ${bar.top}");
    expect(btn.height, closeTo(48, 1), reason: "btn h ${btn.height}");
    expect(btn.top, closeTo(797, 3), reason: "btn top ${btn.top}");
    expect(btn.bottom, closeTo(845, 3), reason: "btn bottom ${btn.bottom}");
  });

  testWidgets("D5 month stepper next disabled is single 38% opacity", (
    tester,
  ) async {
    _webPhone(tester);
    // Current month → next disabled.
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: MobileViewport(
            child: MonthStepper(month: month, onChanged: (_) {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // IconButton builds a Tooltip child — find via chevron_right icon.
    final nextIcon = find.byIcon(Icons.chevron_right);
    expect(nextIcon, findsOneWidget);
    expect(
      find.ancestor(of: nextIcon, matching: find.byType(Opacity)),
      findsNothing,
      reason: "Opacity+disabled compounds to ~14%",
    );
    final nextBtn = find.ancestor(
      of: nextIcon,
      matching: find.byType(IconButton),
    );
    expect(tester.widget<IconButton>(nextBtn).onPressed, isNull);
  });

  testWidgets("D6 Danh mục › touch is x 286–385", (tester) async {
    _webPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: MobileViewport(
            child: SectionHeader(
              title: S.expenseItems,
              linkLabel: "${S.category} ›",
              onLink: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final link = _r(
      tester,
      find.widgetWithText(TextButton, "${S.category} ›"),
    );
    expect(link.left, closeTo(286, 3), reason: "L ${link.left}");
    expect(link.right, closeTo(385, 3), reason: "R ${link.right}");
    expect(link.height, closeTo(48, 1));
  });

  testWidgets("toast sits 8px above bottom nav on web (732–780)", (
    tester,
  ) async {
    _webPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: FilledButton(
                  onPressed: () => showAppToast(context, S.toastExpenseAdded),
                  child: const Text("toast"),
                ),
              );
            },
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
    await tester.tap(find.text("toast"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final toast = _r(
      tester,
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Material),
      ),
    );
    final nav = _r(tester, find.byType(AppBottomNav));
    expect(nav.top, closeTo(788, 3), reason: "nav top ${nav.top}");
    expect(
      toast.bottom,
      closeTo(nav.top - 8, 3),
      reason: "toast bottom ${toast.bottom} vs nav ${nav.top}",
    );
    expect(toast.top, closeTo(732, 3), reason: "toast top ${toast.top}");
    expect(toast.bottom, closeTo(780, 3));
  });

  testWidgets("duplicate expense prevented when wallet debit rejects", (
    tester,
  ) async {
    _webPhone(tester);
    final expenses = MockExpenseService();
    final photos = MockBillPhotoService();
    final wallets = MockWalletService();
    var inserts = 0;
    when(
      () => wallets.lastUsedWalletId(
        homeId: any(named: "homeId"),
        userId: any(named: "userId"),
      ),
    ).thenAnswer((_) async => "w1");
    when(
      () => expenses.insert(
        homeId: any(named: "homeId"),
        categoryId: any(named: "categoryId"),
        paidBy: any(named: "paidBy"),
        amountVnd: any(named: "amountVnd"),
        expenseDate: any(named: "expenseDate"),
        note: any(named: "note"),
      ),
    ).thenAnswer((_) async {
      inserts++;
      return Expense(
        id: "e-created",
        homeId: "h1",
        categoryId: "c1",
        paidBy: "u1",
        amountVnd: 500000,
        expenseDate: DateTime(2026, 11, 9),
        createdAt: DateTime(2026, 11, 9),
      );
    });
    when(
      () => expenses.update(
        id: any(named: "id"),
        categoryId: any(named: "categoryId"),
        paidBy: any(named: "paidBy"),
        amountVnd: any(named: "amountVnd"),
        expenseDate: any(named: "expenseDate"),
        note: any(named: "note"),
        receiptPhotoPath: any(named: "receiptPhotoPath"),
      ),
    ).thenAnswer(
      (inv) async => Expense(
        id: inv.namedArguments[#id] as String,
        homeId: "h1",
        categoryId: "c1",
        paidBy: "u1",
        amountVnd: 500000,
        expenseDate: DateTime(2026, 11, 9),
        createdAt: DateTime(2026, 11, 9),
      ),
    );
    when(() => wallets.revertExpense(any())).thenAnswer((_) async {});
    when(
      () => wallets.applyExpense(
        expenseId: any(named: "expenseId"),
        walletId: any(named: "walletId"),
        amount: any(named: "amount"),
      ),
    ).thenThrow(
      const PostgrestException(message: "insufficient balance", code: "P0001"),
    );

    await tester.pumpWidget(
      MaterialApp(
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
                      () => showExpenseForm(
                        context: context,
                        home: _home,
                        expenses: expenses,
                        photos: photos,
                        categories: [_cat],
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
    await tester.enterText(find.byType(TextField).first, "50000");
    await tester.pump();
    // Balance 100000 — not over; force apply to throw via mock.
    await tester.tap(find.widgetWithText(FilledButton, S.save));
    await tester.pumpAndSettle();
    expect(inserts, 1);
    expect(find.text(S.walletOverBalance), findsOneWidget);

    // Pick "Không trừ ví" so Save re-enables, then save again.
    await tester.tap(find.byKey(const ValueKey("expense-wallet-field")));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.walletPayFromNone));
    await tester.pumpAndSettle();
    when(
      () => wallets.applyExpense(
        expenseId: any(named: "expenseId"),
        walletId: any(named: "walletId"),
        amount: any(named: "amount"),
      ),
    ).thenAnswer((_) async {});
    // Still no wallet → apply skipped; should update not insert.
    await tester.tap(find.widgetWithText(FilledButton, S.save));
    await tester.pumpAndSettle();
    expect(inserts, 1, reason: "second save must not insert again");
  });

  testWidgets("wallet label is exactly Ví not Trả từ ví", (tester) async {
    expect(S.walletPayFrom, "Ví");
  });

  testWidgets("categories screen wires FeaturePageScaffold title style", (
    tester,
  ) async {
    final expenses = MockExpenseService();
    when(() => expenses.listCategories(any())).thenAnswer((_) async => [_cat]);
    _webPhone(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: ExpenseCategoriesScreen(home: _home, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();
    final text = tester.widget<Text>(find.text(S.expenseCategoriesTitle));
    expect(text.style?.fontSize, 22);
    expect(text.style?.fontWeight, FontWeight.w700);
  });
}
