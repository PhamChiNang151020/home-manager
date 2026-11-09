import "dart:convert";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
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
import "package:home_manager/features/expenses/quick_add_sheet.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/shared/sticky_primary_bar.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/wallet/wallet_picker_sheet.dart";
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

/// Web geometry: safe-area 0.
void _web(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);
}

Widget _shot({required Widget home}) {
  return RepaintBoundary(
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
          home: home,
        ),
      ),
    ),
  );
}

Future<void> _png(WidgetTester tester, String name) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
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

Map<String, Object?> _cmp(List<num> m, List<num> s, {double tol = 3}) {
  final d = [for (var i = 0; i < m.length && i < s.length; i++) m[i] - s[i]];
  return {
    "measured": m,
    "spec": s,
    "delta": d,
    "ok": d.every((x) => x.abs() <= tol),
  };
}

void main() {
  if (!shouldCaptureShots) {
    test("r3 screenshots skipped without HM_SHOTS", () {});
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();
  final measured = <String, dynamic>{};
  late MockExpenseService expenses;
  late MockBillPhotoService photos;
  late MockWalletService wallets;

  setUpAll(loadShotFonts);

  setUp(() {
    expenses = MockExpenseService();
    photos = MockBillPhotoService();
    wallets = MockWalletService();
    when(() => expenses.listCategories(any())).thenAnswer((_) async => _cats);
    when(
      () => wallets.lastUsedWalletId(
        homeId: any(named: "homeId"),
        userId: any(named: "userId"),
      ),
    ).thenAnswer((_) async => "w1");
  });

  tearDownAll(() {
    writeShotText(
      "measured.json",
      const JsonEncoder.withIndent("  ").convert(measured),
    );
  });

  testWidgets("r3 quick-add Vi normal + over-balance", (tester) async {
    _web(tester);
    await tester.pumpWidget(
      _shot(
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
    await _png(tester, "quick-add-vi");

    final amount = _box(tester, find.byType(TextField).first);
    final label = _box(tester, find.text(S.walletPayFrom));
    final field = _box(
      tester,
      find.byKey(const ValueKey("expense-wallet-field")),
    );
    final b = amount.bottom;
    measured["quick_vi"] = {
      "label": "Ví",
      "label_rel": _cmp([label.top - b, label.bottom - b], [16, 32]),
      "field_rel": _cmp([field.top - b, field.bottom - b], [36, 100]),
    };

    await tester.enterText(find.byType(TextField).first, "500000");
    await tester.pump();
    await _png(tester, "quick-add-vi-over");
    final over = _box(tester, find.text(S.walletOverBalance));
    measured["quick_over"] = {
      "line_rel": _cmp([over.top - b, over.bottom - b], [104, 120]),
    };
  });

  testWidgets("r3 danh muc title + sticky button", (tester) async {
    _web(tester);
    await tester.pumpWidget(
      _shot(
        home: ExpenseCategoriesScreen(home: _home, expenses: expenses),
      ),
    );
    await tester.pumpAndSettle();
    await _png(tester, "danh-muc-title-btn");

    final title = tester.widget<Text>(find.text(S.expenseCategoriesTitle));
    final bar = _box(tester, find.byType(StickyPrimaryBar));
    final btn = _box(
      tester,
      find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    measured["danh_muc"] = {
      "title_style": {
        "fontSize": title.style?.fontSize,
        "height": title.style?.height,
        "w700": title.style?.fontWeight == FontWeight.w700,
      },
      "bar_top": _cmp([bar.top], [788]),
      "btn": _cmp(
        [btn.top, btn.bottom, btn.left, btn.right],
        [797, 845, 16, 377],
      ),
    };
  });

  testWidgets("r3 month stepper + danh muc link + toast + chon vi n=2", (
    tester,
  ) async {
    _web(tester);
    final now = DateTime.now();
    await tester.pumpWidget(
      _shot(
        home: Scaffold(
          body: MobileViewport(
            child: Column(
              children: [
                MonthStepper(
                  month: DateTime(now.year, now.month, 1),
                  onChanged: (_) {},
                ),
                SectionHeader(
                  title: S.expenseItems,
                  linkLabel: "${S.category} ›",
                  onLink: () {},
                ),
                Builder(
                  builder: (context) {
                    return FilledButton(
                      onPressed:
                          () => showAppToast(context, S.toastExpenseAdded),
                      child: const Text("toast"),
                    );
                  },
                ),
                Builder(
                  builder: (context) {
                    return FilledButton(
                      onPressed:
                          () => showWalletPickerSheet(
                            context: context,
                            wallets: _wallets,
                            selectedWalletId: "w1",
                          ),
                      child: const Text("picker"),
                    );
                  },
                ),
              ],
            ),
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
    await tester.pumpAndSettle();

    final link = _box(
      tester,
      find.widgetWithText(TextButton, "${S.category} ›"),
    );
    measured["link"] = _cmp(
      [link.left, link.right, link.height],
      [286, 385, 48],
    );
    measured["stepper_no_opacity"] =
        find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(Opacity),
        ).evaluate().isEmpty;

    await tester.tap(find.text("toast"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await _png(tester, "toast-so-gd");
    final toast = _box(
      tester,
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Material),
      ),
    );
    final nav = _box(tester, find.byType(AppBottomNav));
    measured["toast"] = {
      "toast": _cmp([toast.top, toast.bottom], [732, 780]),
      "nav_top": _cmp([nav.top], [788]),
      "gap": nav.top - toast.bottom,
    };

    await tester.tap(find.text("picker"));
    await tester.pumpAndSettle();
    await _png(tester, "chon-vi-n2");
    final wTitle = _box(tester, find.text(S.walletPickTitle));
    measured["chon_vi_n2"] = {
      "sheet_top_est": wTitle.top - 36,
      // Web: 566–852 (= iPhone 532 + 34). Keep measuring; do not change code.
      "title": _cmp([wTitle.top, wTitle.bottom], [566 + 36, 566 + 60]),
      "note": "web sheet top spec 566; iPhone 532 — code unchanged",
    };
  });
}
