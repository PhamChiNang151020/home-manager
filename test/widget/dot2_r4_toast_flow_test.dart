import "dart:convert";

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
import "package:home_manager/features/expenses/quick_add_sheet.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:mocktail/mocktail.dart";

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
    balanceVnd: 5_000_000,
  ),
];

void _web(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);
}

// PNG pixel capture for toast lives in the web-release Chrome harness
// (tool/expense_toast_web_demo.dart → r4/). RepaintBoundary.toImage hangs
// in widget tests when a SnackBar Overlay is present.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadShotFonts();
    registerFallbackValue("");
    registerFallbackValue(0.0);
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  testWidgets(
    "real quick-add flow: toast paints at web 732–780 with 8px gap",
    (tester) async {
      _web(tester);
      final expenses = MockExpenseService();
      final photos = MockBillPhotoService();
      final wallets = MockWalletService();
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
      ).thenAnswer(
        (_) async => Expense(
          id: "e1",
          homeId: "h1",
          categoryId: "c1",
          paidBy: "u1",
          amountVnd: 50000,
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
      ).thenAnswer((_) async {});

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
                home: Builder(
                  builder: (context) {
                    return Scaffold(
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
                      body: Center(
                        child: FilledButton(
                          onPressed: () {
                            showQuickAddSheet(
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
                            );
                          },
                          child: const Text("Chi tiêu"),
                        ),
                      ),
                      bottomNavigationBar: AppBottomNav(
                        tabIndex: 1,
                        notificationBadge: 0,
                        onTabSelected: (_) {},
                        onQuickAdd: () {},
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text("Chi tiêu"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(S.quickAddExpense), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, "50000");
      await tester.pump();
      await tester.tap(find.text("Ăn uống"));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(S.toastExpenseAdded), findsOneWidget);

      final nav = tester.getRect(find.byType(AppBottomNav));
      final toastMat = tester.getRect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.byType(Material),
        ),
      );

      expect(nav.top, closeTo(788, 3));
      expect(toastMat.top, closeTo(732, 3));
      expect(toastMat.bottom, closeTo(780, 3));
      expect(nav.top - toastMat.bottom, closeTo(8, 3));

      // Pixel PNG evidence is produced by the web-release Chrome capture
      // into HM_SHOTS_DIR (see tool/expense_toast_web_demo.dart). Widget
      // tests assert layout geometry only — toImage hangs with SnackBar.
      if (shouldCaptureShots) {
        writeShotText(
          "toast-layout-widget.json",
          const JsonEncoder.withIndent("  ").convert({
            "source": "widget_quick_add_flow_layout_only",
            "note":
                "Geometry after real quick-add save. PNG pixels: see "
                "toast-so-gd-flow.png from web release.",
            "layout": {
              "toast_top": toastMat.top,
              "toast_bottom": toastMat.bottom,
              "toast_height": toastMat.height,
              "nav_top": nav.top,
              "gap": nav.top - toastMat.bottom,
            },
            "spec": {
              "toast": [732, 780],
              "gap": 8,
              "nav_top": 788,
            },
          }),
        );
      }
    },
    timeout: const Timeout(Duration(seconds: 45)),
  );
}
