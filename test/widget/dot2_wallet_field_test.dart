import "package:flutter/material.dart";
import "package:flutter/services.dart";
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
import "package:home_manager/features/expenses/expense_form.dart";
import "package:mocktail/mocktail.dart";

class MockExpenseService extends Mock implements ExpenseService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

class MockWalletService extends Mock implements WalletService {}

const _home = Home(
  id: "h1",
  name: "Nhà",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
);

final _category = ExpenseCategory(
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockExpenseService expenses;
  late MockBillPhotoService photos;
  late MockWalletService walletService;

  setUpAll(_loadNunito);

  setUp(() {
    expenses = MockExpenseService();
    photos = MockBillPhotoService();
    walletService = MockWalletService();
    when(
      () => walletService.lastUsedWalletId(
        homeId: any(named: "homeId"),
        userId: any(named: "userId"),
      ),
    ).thenAnswer((_) async => "w2");
  });

  Future<void> openForm(
    WidgetTester tester, {
    List<Wallet> wallets = const [],
    Expense? existing,
  }) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
                    () => showExpenseForm(
                      context: context,
                      home: _home,
                      expenses: expenses,
                      photos: photos,
                      categories: [_category],
                      members: const [
                        HomeMember(
                          userId: "u1",
                          role: "owner",
                          displayName: "An",
                        ),
                      ],
                      currentUserId: "u1",
                      wallets: wallets,
                      walletService: walletService,
                      existing: existing,
                      onSaved: () {},
                    ),
                child: const Text("Open"),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();
  }

  testWidgets("wallet field order after amount; default last used wallet", (
    tester,
  ) async {
    await openForm(tester, wallets: _wallets);
    expect(find.byKey(const ValueKey("expense-wallet-field")), findsOneWidget);
    expect(find.text(S.walletPayFrom), findsOneWidget);
    expect(find.text("Vietcombank"), findsOneWidget);

    // Field order: Amount label, then Ví label.
    final amountY = tester.getTopLeft(find.text(S.amount)).dy;
    final walletY = tester.getTopLeft(find.text(S.walletPayFrom)).dy;
    final categoryY = tester.getTopLeft(find.text(S.category)).dy;
    expect(amountY < walletY, isTrue);
    expect(walletY < categoryY, isTrue);
  });

  testWidgets("no wallets shows disabled Không trừ ví", (tester) async {
    await openForm(tester, wallets: []);
    expect(find.text(S.walletPayFromNone), findsOneWidget);
    final ink = tester.widget<InkWell>(
      find.byKey(const ValueKey("expense-wallet-field")),
    );
    expect(ink.onTap, isNull);
  });

  testWidgets("over balance shows red line and disables save", (tester) async {
    await openForm(tester, wallets: _wallets);
    await tester.enterText(find.byType(TextField).first, "200000");
    await tester.pump();

    expect(find.text(S.walletOverBalance), findsOneWidget);
    final save = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, S.save),
    );
    expect(save.onPressed, isNull);
  });

  testWidgets("picker sheet lists wallets and Không trừ ví", (tester) async {
    await openForm(tester, wallets: _wallets);
    await tester.tap(find.byKey(const ValueKey("expense-wallet-field")));
    await tester.pumpAndSettle();

    expect(find.text(S.walletPickTitle), findsOneWidget);
    expect(find.text("Tiền mặt"), findsOneWidget);
    expect(find.text(S.walletPayFromNoneHint), findsOneWidget);

    await tester.tap(find.text(S.walletPayFromNone).last);
    await tester.pumpAndSettle();
    expect(find.text(S.walletPayFromNone), findsOneWidget);
    expect(find.text(S.walletOverBalance), findsNothing);
  });

  testWidgets("edit same wallet adds back old amount for balance check", (
    tester,
  ) async {
    final existing = Expense(
      id: "e1",
      homeId: "h1",
      categoryId: "c1",
      paidBy: "u1",
      amountVnd: 80000,
      expenseDate: DateTime(2026, 11, 9),
      createdAt: DateTime(2026, 11, 9),
      walletId: "w2",
      category: _category,
    );
    // w2 balance 50k + old 80k = 130k available
    await openForm(tester, wallets: _wallets, existing: existing);
    await tester.enterText(find.byType(TextField).first, "120000");
    await tester.pump();
    expect(find.text(S.walletOverBalance), findsNothing);

    await tester.enterText(find.byType(TextField).first, "140000");
    await tester.pump();
    expect(find.text(S.walletOverBalance), findsOneWidget);
  });
}
