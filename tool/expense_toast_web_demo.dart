import "dart:async";
import "dart:js_interop";
import "dart:js_interop_unsafe";

import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
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
import "package:home_manager/features/expenses/quick_add_sheet.dart";
import "package:home_manager/features/shared/month_stepper.dart";
import "package:home_manager/features/shared/section_header.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:web/web.dart" as web;

/// Local-only Sổ GD toast demo (mocks only — no Supabase / DB writes).
///
/// Flow: + / auto → quick Chi tiêu sheet → fill → category save →
/// [popWithAppToast] "Đã thêm chi tiêu".
///
///   flutter build web --release -t tool/expense_toast_web_demo.dart \
///     --output=build/web_toast
///
/// Open `/?auto=1` at 393×852. When settled: `data-toast-ready="1"` and
/// `window.__toastMeasure`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final auto = Uri.base.queryParameters["auto"] == "1";
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(
        brightness: Brightness.light,
        accent: AppAccent.amber,
        glass: false,
      ),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(393, 852),
          textScaler: TextScaler.noScaling,
        ),
        child: _Shell(auto: auto),
      ),
    ),
  );
}

void _publish(Map<String, Object?> data) {
  web.window.setProperty("__toastMeasure".toJS, data.jsify());
  web.document.documentElement?.setAttribute(
    "data-toast-ready",
    data["toastVisible"] == true ? "1" : "0",
  );
}

const _home = Home(
  id: "h1",
  name: "Nhà demo",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

final _cats = [
  for (final e in [
    ("c1", "Ăn uống", "restaurant", "food"),
    ("c2", "Đi lại", "directions_car", "loan"),
    ("c3", "Nhà cửa", "home", "other"),
  ])
    ExpenseCategory(
      id: e.$1,
      homeId: "h1",
      name: e.$2,
      iconKey: e.$3,
      colorKey: e.$4,
      isDefault: true,
    ),
];

final _walletList = [
  Wallet(
    id: "w1",
    homeId: "h1",
    kind: WalletKind.cash,
    name: "Tiền mặt",
    balanceVnd: 5_000_000,
  ),
  Wallet(
    id: "w2",
    homeId: "h1",
    kind: WalletKind.bank,
    name: "Vietcombank",
    balanceVnd: 2_000_000,
  ),
];

class _UnusedClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError("demo mock: ${invocation.memberName}");
}

class _FakeExpenses extends ExpenseService {
  _FakeExpenses() : super(_UnusedClient());
  int n = 0;

  @override
  Future<List<ExpenseCategory>> listCategories(String homeId) async => _cats;

  @override
  Future<Expense> insert({
    required String homeId,
    required String categoryId,
    required String paidBy,
    required double amountVnd,
    required DateTime expenseDate,
    String? note,
    String? receiptPhotoPath,
  }) async {
    n++;
    return Expense(
      id: "e$n",
      homeId: homeId,
      categoryId: categoryId,
      paidBy: paidBy,
      amountVnd: amountVnd,
      expenseDate: expenseDate,
      createdAt: DateTime.now(),
      note: note,
    );
  }

  @override
  Future<Expense> update({
    required String id,
    required String categoryId,
    required String paidBy,
    required double amountVnd,
    required DateTime expenseDate,
    String? note,
    String? receiptPhotoPath,
  }) async => Expense(
    id: id,
    homeId: "h1",
    categoryId: categoryId,
    paidBy: paidBy,
    amountVnd: amountVnd,
    expenseDate: expenseDate,
    createdAt: DateTime.now(),
    note: note,
    receiptPhotoPath: receiptPhotoPath,
  );
}

class _FakePhotos extends BillPhotoService {
  _FakePhotos() : super(_UnusedClient());
}

class _FakeWallets extends WalletService {
  _FakeWallets() : super(_UnusedClient());

  @override
  Future<String?> lastUsedWalletId({
    required String homeId,
    required String userId,
  }) async => "w1";

  @override
  Future<void> applyExpense({
    required String expenseId,
    required String walletId,
    required double amount,
  }) async {}

  @override
  Future<void> revertExpense(String expenseId) async {}
}

class _Shell extends StatefulWidget {
  const _Shell({required this.auto});
  final bool auto;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  final _expenses = _FakeExpenses();
  final _photos = _FakePhotos();
  final _walletSvc = _FakeWallets();
  final _navKey = GlobalKey();
  bool _started = false;
  String _status = "Sổ giao dịch — waiting";

  Rect? _globalRect(BuildContext? ctx) {
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Map<String, Object?>? _map(Rect? r) {
    if (r == null) return null;
    return {
      "top": r.top,
      "bottom": r.bottom,
      "left": r.left,
      "right": r.right,
      "height": r.height,
      "width": r.width,
    };
  }

  Rect? _findSnackBarMaterial() {
    Rect? found;
    void visit(Element el) {
      if (found != null) return;
      if (el.widget is SnackBar) {
        el.visitChildren((child) {
          void deep(Element e) {
            if (found != null) return;
            if (e.widget is Material) {
              final r = _globalRect(e);
              if (r != null && r.height >= 40 && r.height <= 56) {
                found = r;
                return;
              }
            }
            e.visitChildren(deep);
          }

          deep(child);
        });
      }
      el.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    return found;
  }

  void _publishMeasure({required bool toastVisible}) {
    final toast = _map(_findSnackBarMaterial());
    final nav = _map(_globalRect(_navKey.currentContext));
    final gap =
        toast != null && nav != null
            ? (nav["top"]! as double) - (toast["bottom"]! as double)
            : null;
    _publish({
      "toastVisible": toastVisible && toast != null,
      "toast": toast,
      "nav": nav,
      "gap": gap,
      "status": _status,
      "message": S.toastExpenseAdded,
      "viewport": {"w": 393, "h": 852},
    });
  }

  Future<void> _openAndSave() async {
    unawaited(
      showQuickAddSheet(
        context: context,
        home: _home,
        expenses: _expenses,
        photos: _photos,
        categories: _cats,
        members: const [
          HomeMember(userId: "u1", role: "owner", displayName: "An"),
        ],
        currentUserId: "u1",
        wallets: _walletList,
        walletService: _walletSvc,
        onSaved: () {
          setState(() => _status = "Saved — toast settling");
        },
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    TextEditingController? amount;
    void findCtrl(Element el) {
      if (amount != null) return;
      if (el.widget is EditableText) {
        amount = (el.widget as EditableText).controller;
      }
      el.visitChildren(findCtrl);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(findCtrl);
    if (amount != null) {
      final text = VndFormat.input(50000);
      amount!.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _status = "Tapping category to save…");

    VoidCallback? onTap;
    void findCat(Element el) {
      if (onTap != null) return;
      final w = el.widget;
      if (w is Text && w.data == "Ăn uống") {
        Element? cur = el;
        while (cur != null) {
          final cw = cur.widget;
          if (cw is InkWell && cw.onTap != null) {
            onTap = cw.onTap;
            return;
          }
          Element? parent;
          cur.visitAncestorElements((a) {
            parent = a;
            return false;
          });
          cur = parent;
        }
      }
      el.visitChildren(findCat);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(findCat);
    onTap?.call();

    // Sheet pop + SnackBar enter (~250ms).
    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    setState(() => _status = "Toast settled");
    _publishMeasure(toastVisible: true);

    for (var i = 0; i < 8; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      _publishMeasure(toastVisible: true);
    }
  }

  Future<void> _runFlow() async {
    if (_started) return;
    _started = true;
    setState(() => _status = "Opening quick Chi tiêu sheet…");
    await _openAndSave();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.auto && !_started) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_runFlow());
      });
    }

    return Scaffold(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            SegmentedTrack(
              labels: const [S.expenses, S.electricity, S.water],
              index: 0,
              onChanged: (_) {},
            ),
            MonthStepper(
              month: DateTime(DateTime.now().year, DateTime.now().month, 1),
              onChanged: (_) {},
            ),
            SectionHeader(
              title: S.expenseItems,
              linkLabel: "${S.category} ›",
              onLink: () {},
            ),
            Expanded(
              child: Center(
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: KeyedSubtree(
        key: _navKey,
        child: AppBottomNav(
          tabIndex: 1,
          notificationBadge: 0,
          onTabSelected: (_) {},
          onQuickAdd: () {
            _started = false;
            unawaited(_runFlow());
          },
        ),
      ),
    );
  }
}
