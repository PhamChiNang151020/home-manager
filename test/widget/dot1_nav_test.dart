import "dart:io";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/services/notification_service.dart";
import "package:home_manager/core/services/overview_service.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/features/auth/sign_in_page.dart";
import "package:home_manager/features/overview/overview_page.dart";
import "package:home_manager/features/personal/personal_hub_page.dart";
import "package:home_manager/features/savings/savings_page.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/avatar_button.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/shell/empty_home_view.dart";
import "package:home_manager/features/shell/quick_add_picker_sheet.dart";
import "package:home_manager/features/transactions/transactions_hub_page.dart";
import "package:home_manager/features/wallet/wallet_hub_page.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../support/mock_supabase.dart";

class MockHomeService extends Mock implements HomeService {}

class MockInviteService extends Mock implements InviteService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockAuthService extends AuthService {
  MockAuthService() : super(MockSupabaseClient());
}

const _home = Home(
  id: "h1",
  name: "TEST Nhà",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

const _outDir = "/opt/cursor/artifacts/dot1";

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

void _setPhoneView(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(tester.view.reset);
}

Widget _phoneFrame({
  required Widget child,
  double bottomInset = 34,
  double topInset = 59,
}) {
  // RepaintBoundary outside MaterialApp so Overlay SnackBars are captured.
  return RepaintBoundary(
    key: const ValueKey("shot"),
    child: SizedBox(
      width: 393,
      height: 852,
      child: MediaQuery(
        data: MediaQueryData(
          size: const Size(393, 852),
          padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
          viewPadding: EdgeInsets.only(top: topInset, bottom: bottomInset),
          textScaler: TextScaler.noScaling,
        ),
        child: MaterialApp(
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

void _setWebView(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  tester.view.viewPadding = FakeViewPadding.zero;
  addTearDown(tester.view.reset);
}

OverviewSnapshot _snap({
  double netWorth = 1250000,
  double monthExpenses = 320000,
  double monthIncome = 15000000,
}) {
  return OverviewSnapshot(
    netWorth: netWorth,
    latestElectricity: null,
    latestWater: null,
    monthExpenses: monthExpenses,
    monthIncome: monthIncome,
    bankUsed: 0,
    bankLimit: 0,
    debtNet: 0,
    savingsTotal: 0,
    walletsTotal: netWorth,
    incomeSpendHistory: const [],
    categorySpend: const [],
  );
}

class _TabKeepShell extends StatefulWidget {
  const _TabKeepShell();

  @override
  State<_TabKeepShell> createState() => _TabKeepShellState();
}

class _TabKeepShellState extends State<_TabKeepShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("tab $_tab")),
      body: IndexedStack(
        index: _tab,
        children: [
          const TextField(
            key: ValueKey("keep-0"),
            decoration: InputDecoration(hintText: "a"),
          ),
          const TextField(
            key: ValueKey("keep-1"),
            decoration: InputDecoration(hintText: "b"),
          ),
          const Center(child: Text("dues")),
          const Center(child: Text("assets")),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        tabIndex: _tab,
        onTabSelected: (i) => setState(() => _tab = i),
        onQuickAdd: () {},
      ),
    );
  }
}

class _AvatarShell extends StatelessWidget {
  const _AvatarShell({
    required this.theme,
    required this.lock,
    required this.homes,
    required this.invites,
    required this.notifications,
    this.onSignOut,
  });

  final ThemeController theme;
  final LockController lock;
  final HomeService homes;
  final InviteService invites;
  final NotificationService notifications;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.overview),
        actionsPadding: EdgeInsets.zero,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AvatarButton(
              key: const ValueKey("shell-avatar"),
              label: "N",
              onPressed: () {
                Navigator.of(context).push<void>(
                  AppPageRoute<void>(
                    page: PersonalHubPage(
                      home: _home,
                      homes: const [_home],
                      homesApi: homes,
                      invites: invites,
                      notifications: notifications,
                      theme: theme,
                      lock: lock,
                      user: null,
                      onChanged: () {},
                      onSelectHome: (_) {},
                      onAddHome: () {},
                      // Mirrors AppShell._openPersonal onSignOut wiring.
                      onSignOut: onSignOut ?? () {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: const MobileViewport(child: Center(child: Text("body"))),
      bottomNavigationBar: AppBottomNav(
        tabIndex: 0,
        onTabSelected: (_) {},
        onQuickAdd: () {},
      ),
    );
  }
}

/// Auth gate like [_AppHome]: when signed out, [SignInPage] replaces the shell
/// as MaterialApp.home — pushed routes must be popped or Cá nhân stays on top.
class _SignOutAuthGate extends StatefulWidget {
  const _SignOutAuthGate({
    required this.theme,
    required this.lock,
    required this.homes,
    required this.invites,
    required this.notifications,
  });

  final ThemeController theme;
  final LockController lock;
  final HomeService homes;
  final InviteService invites;
  final NotificationService notifications;

  @override
  State<_SignOutAuthGate> createState() => _SignOutAuthGateState();
}

class _SignOutAuthGateState extends State<_SignOutAuthGate> {
  bool _signedIn = true;

  void _signOut() {
    // Must match AppShell: pop Cá nhân (and any pushed routes) then sign out.
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.popUntil((route) => route.isFirst);
    }
    setState(() => _signedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      return SignInPage(authService: MockAuthService());
    }
    return _AvatarShell(
      theme: widget.theme,
      lock: widget.lock,
      homes: widget.homes,
      invites: widget.invites,
      notifications: widget.notifications,
      onSignOut: _signOut,
    );
  }
}

void main() {
  // Screenshots only when the artifacts dir exists; fonts always load so
  // layout assertions match QA machines without /opt/cursor/artifacts.
  final runShots = Directory("/opt/cursor/artifacts").existsSync();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue("");
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadNunito();
  });

  testWidgets("bottom nav geometry y 754-852 with pill and + button", (
    tester,
  ) async {
    _setPhoneView(tester);
    await tester.pumpWidget(
      _phoneFrame(
        child: Scaffold(
          appBar: AppBar(title: const Text(S.overview)),
          body: const SizedBox.expand(),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 0,
            notificationBadge: 2,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );

    final nav = tester.getRect(find.byType(AppBottomNav));
    expect(nav.top, closeTo(754, 3));
    expect(nav.bottom, closeTo(852, 3));

    final item0 = tester.getRect(find.byKey(const ValueKey("nav-item-0")));
    expect(item0.width, inInclusiveRange(78, 79));
    expect(item0.height, closeTo(64, 3));

    final pill = tester.getRect(find.byKey(const ValueKey("nav-pill")));
    expect(pill.width, closeTo(48, 3));
    expect(pill.height, closeTo(28, 3));
    expect(pill.top, closeTo(763, 3));
    expect(pill.bottom, closeTo(791, 3));

    final plus = tester.getRect(find.byKey(const ValueKey("nav-plus")));
    // Hit target is Expanded slot; measure the 48 circle Material inside.
    final plusCircle = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey("nav-plus")),
        matching: find.byType(Material),
      ),
    );
    expect(plusCircle.width, closeTo(48, 3));
    expect(plusCircle.height, closeTo(48, 3));
    expect(plusCircle.top, closeTo(763, 3));
    expect(plusCircle.bottom, closeTo(811, 3));
    expect(plusCircle.left, closeTo(173, 3));
    expect(plusCircle.right, closeTo(221, 3));
    expect(plus.width, greaterThan(48));

    expect(find.text(S.overview), findsWidgets);
    expect(find.text(S.transactions), findsOneWidget);
    expect(find.text(S.dues), findsOneWidget);
    expect(find.text(S.assets), findsOneWidget);

    if (runShots) {
      await _savePng(tester, "01_nav_geometry");
      File("$_outDir/measured.nav.txt").writeAsStringSync(
        "nav_top=${nav.top}\n"
        "nav_bottom=${nav.bottom}\n"
        "pill=${pill.left},${pill.top},${pill.right},${pill.bottom}\n"
        "plus=${plusCircle.left},${plusCircle.top},${plusCircle.right},${plusCircle.bottom}\n"
        "item0_w=${item0.width}\n",
      );
    }
  });

  testWidgets("avatar 36 opens PersonalHubPage with back and no bottom nav", (
    tester,
  ) async {
    _setPhoneView(tester);
    SharedPreferences.setMockInitialValues({});
    final theme = await ThemeController.load();
    final lock = await LockController.load();
    final homes = MockHomeService();
    final invites = MockInviteService();
    final notifications = MockNotificationService();
    when(() => notifications.isEnabledLocally()).thenAnswer((_) async => false);

    await tester.pumpWidget(
      _phoneFrame(
        child: _AvatarShell(
          theme: theme,
          lock: lock,
          homes: homes,
          invites: invites,
          notifications: notifications,
        ),
      ),
    );

    final avatarBtn = tester.getRect(find.byKey(const ValueKey("shell-avatar")));
    expect(avatarBtn.width, closeTo(48, 0.5));
    expect(avatarBtn.height, closeTo(48, 0.5));
    // Spec: hit 341–389; circle 347–383 (right edge 10px from screen).
    expect(avatarBtn.left, closeTo(341, 0.5));
    expect(avatarBtn.right, closeTo(389, 0.5));

    final circleFinder = find.descendant(
      of: find.byKey(const ValueKey("shell-avatar")),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      ),
    );
    final circleRect = tester.getRect(circleFinder);
    // Spec avatar circle rect (347,69)-(383,105).
    expect(circleRect.left, closeTo(347, 0.5));
    expect(circleRect.top, closeTo(69, 0.5));
    expect(circleRect.right, closeTo(383, 0.5));
    expect(circleRect.bottom, closeTo(105, 0.5));
    expect(circleRect.width, closeTo(36, 0.5));
    expect(circleRect.height, closeTo(36, 0.5));

    expect(find.byType(AppBottomNav), findsOneWidget);
    if (runShots) {
      File("$_outDir/measured.avatar.txt").writeAsStringSync(
        "avatar_hit=${avatarBtn.left},${avatarBtn.top},${avatarBtn.right},${avatarBtn.bottom}\n"
        "avatar_circle=${circleRect.left},${circleRect.top},${circleRect.right},${circleRect.bottom}\n",
      );
    }

    await tester.tap(find.byKey(const ValueKey("shell-avatar")));
    await tester.pumpAndSettle();

    expect(find.text(S.personal), findsWidgets);
    expect(find.byType(PersonalHubPage), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);

    if (runShots) await _savePng(tester, "04_personal_hub");

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomNav), findsOneWidget);
  });

  testWidgets("segmented 361x48 at y 123-171 with 3 items", (tester) async {
    _setPhoneView(tester);
    final client = MockSupabaseClient();
    final services = AppServices(client);

    await tester.pumpWidget(
      _phoneFrame(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              S.transactions,
              style: TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700),
            ),
          ),
          body: MobileViewport(
            child: TransactionsHubPage(
              home: _home,
              services: services,
              currentUserId: "u1",
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
    await tester.pump();

    final seg = tester.getRect(find.byKey(const ValueKey("tx-segmented")));
    expect(seg.width, closeTo(361, 3));
    expect(seg.height, closeTo(48, 3));
    expect(seg.top, closeTo(123, 3));
    expect(seg.bottom, closeTo(171, 3));
    expect(find.text(S.expenses), findsWidgets);
    expect(find.text(S.electricity), findsWidgets);
    expect(find.text(S.water), findsWidgets);
    expect(find.byType(SegmentedTrack), findsOneWidget);

    await tester.tap(find.text(S.electricity).first);
    await tester.pump();
    await tester.tap(find.text(S.water).first);
    await tester.pump();
  });

  testWidgets("quick add sheet 314-852 with 7 rows of 56", (tester) async {
    _setPhoneView(tester);
    final client = MockSupabaseClient();
    final services = AppServices(client);

    await tester.pumpWidget(
      _phoneFrame(
        child: Scaffold(
          appBar: AppBar(title: const Text(S.overview)),
          body: Builder(
            builder:
                (context) => Center(
                  child: TextButton(
                    onPressed:
                        () => showQuickAddPickerSheet(
                          context: context,
                          home: _home,
                          services: services,
                          currentUserId: "u1",
                        ),
                    child: const Text("open"),
                  ),
                ),
          ),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 0,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    expect(find.text(S.quickAddPickTitle), findsOneWidget);
    expect(find.text(S.expenses), findsOneWidget);
    expect(find.text(S.income), findsOneWidget);
    expect(find.text(S.electricity), findsOneWidget);
    expect(find.text(S.water), findsOneWidget);
    expect(find.text(S.addBankAccount), findsOneWidget);
    expect(find.text(S.addDebt), findsOneWidget);
    expect(find.text(S.addSavings), findsOneWidget);

    final sheet = tester.getRect(find.byType(BottomSheet));
    expect(sheet.top, closeTo(314, 3));
    expect(sheet.bottom, closeTo(852, 3));

    for (final label in [
      S.expenses,
      S.income,
      S.electricity,
      S.water,
      S.addBankAccount,
      S.addDebt,
      S.addSavings,
    ]) {
      final row = tester.getRect(find.byKey(ValueKey("quick-add-$label")));
      expect(row.height, closeTo(56, 4), reason: label);
    }

    if (runShots) {
      await _savePng(tester, "03_quick_add");
      File("$_outDir/measured.sheet.txt").writeAsStringSync(
        "sheet_top=${sheet.top}\nsheet_bottom=${sheet.bottom}\n",
      );
    }
  });

  // D4: web inset 0 → sheet y 348–852 (no hard-coded +34).
  testWidgets("quick add sheet 348-852 when viewPadding.bottom is 0", (
    tester,
  ) async {
    _setWebView(tester);
    final client = MockSupabaseClient();
    final services = AppServices(client);

    await tester.pumpWidget(
      _phoneFrame(
        bottomInset: 0,
        topInset: 0,
        child: Scaffold(
          appBar: AppBar(title: const Text(S.overview)),
          body: Builder(
            builder:
                (context) => Center(
                  child: TextButton(
                    onPressed:
                        () => showQuickAddPickerSheet(
                          context: context,
                          home: _home,
                          services: services,
                          currentUserId: "u1",
                        ),
                    child: const Text("open"),
                  ),
                ),
          ),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 0,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text("open"));
    await tester.pumpAndSettle();

    final sheet = tester.getRect(find.byType(BottomSheet));
    expect(sheet.top, closeTo(348, 3));
    expect(sheet.bottom, closeTo(852, 3));
  });

  // D1: Tài sản temp hub — Ví · Tiết kiệm · Tín dụng NH · Nợ vay mượn.
  testWidgets("assets tab rows include savings opening SavingsPage", (
    tester,
  ) async {
    _setPhoneView(tester);
    final client = MockSupabaseClient();
    final services = AppServices(client);

    await tester.pumpWidget(
      _phoneFrame(
        child: Scaffold(
          appBar: AppBar(title: const Text(S.assets)),
          body: MobileViewport(
            child: WalletHubPage(
              home: _home,
              services: services,
              currentUserId: "u1",
              embedded: true,
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 3,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final labels = [S.wallet, S.savings, S.bankCredit, S.personalDebts];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    // Order: Ví, Tiết kiệm, Tín dụng NH, Nợ vay mượn.
    final tops = [
      for (final label in labels)
        tester.getTopLeft(find.byKey(ValueKey("assets-entry-$label"))).dy,
    ];
    expect(tops, orderedEquals(tops.toList()..sort()));

    for (final label in labels) {
      final row = tester.getRect(find.byKey(ValueKey("assets-entry-$label")));
      expect(row.height, closeTo(64, 1), reason: label);
    }

    final savingsIcon = tester.getRect(
      find.descendant(
        of: find.byKey(ValueKey("assets-entry-${S.savings}")),
        matching: find.byType(ListGroupIcon),
      ),
    );
    expect(savingsIcon.width, closeTo(36, 0.5));
    expect(savingsIcon.height, closeTo(36, 0.5));

    await tester.tap(find.byKey(ValueKey("assets-entry-${S.savings}")));
    await tester.pumpAndSettle();
    expect(find.byType(SavingsRoutePage), findsOneWidget);
  });

  // D2: sign-out from Cá nhân must land on SignInPage (pop pushed route).
  testWidgets("sign-out from Cá nhân shows SignInPage and leaves personal", (
    tester,
  ) async {
    _setPhoneView(tester);
    SharedPreferences.setMockInitialValues({});
    final theme = await ThemeController.load();
    final lock = await LockController.load();
    final homes = MockHomeService();
    final invites = MockInviteService();
    final notifications = MockNotificationService();
    when(() => notifications.isEnabledLocally()).thenAnswer((_) async => false);

    await tester.pumpWidget(
      _phoneFrame(
        child: _SignOutAuthGate(
          theme: theme,
          lock: lock,
          homes: homes,
          invites: invites,
          notifications: notifications,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey("shell-avatar")));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalHubPage), findsOneWidget);

    final signOut = find.widgetWithText(OutlinedButton, S.signOut);
    await tester.ensureVisible(signOut);
    await tester.pumpAndSettle();
    await tester.tap(signOut);
    await tester.pumpAndSettle();

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.byType(PersonalHubPage), findsNothing);
    expect(find.text(S.personal), findsNothing);
  });

  // D3: long hero amount stays 1 line inside fixed h 98 (no RenderFlex overflow).
  testWidgets("overview hero long amount stays single line at height 98", (
    tester,
  ) async {
    _setPhoneView(tester);
    final client = MockSupabaseClient();
    final services = AppServices(client);
    const huge = 9999999999999.0;

    await tester.pumpWidget(
      _phoneFrame(
        child: Scaffold(
          appBar: AppBar(title: const Text(S.overview)),
          body: MobileViewport(
            child: OverviewPage(
              home: _home,
              services: services,
              currentUserId: "u1",
              loadOverview: (_) async => _snap(netWorth: huge),
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 0,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hero = tester.getRect(find.byKey(const ValueKey("overview-net-worth")));
    expect(hero.height, closeTo(98, 0.5));

    final amountText = find.descendant(
      of: find.byKey(const ValueKey("overview-net-worth")),
      matching: find.textContaining("đ"),
    );
    expect(amountText, findsOneWidget);
    final amountRect = tester.getRect(amountText);
    // Single line at 32/40 — must not wrap.
    expect(amountRect.height, lessThanOrEqualTo(40.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets("IndexedStack keeps tab field state", (tester) async {
    _setPhoneView(tester);
    await tester.pumpWidget(_phoneFrame(child: const _TabKeepShell()));

    expect(find.byType(IndexedStack), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey("keep-0")), "kept");
    await tester.tap(find.text(S.transactions));
    await tester.pump();
    await tester.tap(find.text(S.overview));
    await tester.pump();
    expect(find.text("kept"), findsOneWidget);
  });

  testWidgets("home null shows empty home without bottom nav", (tester) async {
    _setPhoneView(tester);
    await tester.pumpWidget(
      _phoneFrame(
        child: Scaffold(
          appBar: AppBar(title: const Text(S.appName)),
          body: MobileViewport(
            child: EmptyHomeView(
              email: "a@b.com",
              onAddHome: () {},
              onSignOut: () {},
              onAcceptCode: (_) async {},
              onAcceptToken: (_) async {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(EmptyHomeView), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);
    expect(find.text(S.emptyHomeTitle), findsOneWidget);
  });

  testWidgets("overview hero + month card + toast above nav", (tester) async {
    _setPhoneView(tester);
    final client = MockSupabaseClient();
    final services = AppServices(client);

    await tester.pumpWidget(
      _phoneFrame(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              S.overview,
              style: TextStyle(
                fontSize: 22,
                height: 28 / 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            actionsPadding: EdgeInsets.zero,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: AvatarButton(key: ValueKey("shell-avatar"), label: "N"),
              ),
            ],
          ),
          body: MobileViewport(
            child: OverviewPage(
              home: _home,
              services: services,
              currentUserId: "u1",
              loadOverview: (_) async => _snap(),
            ),
          ),
          bottomNavigationBar: AppBottomNav(
            tabIndex: 0,
            onTabSelected: (_) {},
            onQuickAdd: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hero = tester.getRect(find.byKey(const ValueKey("overview-net-worth")));
    // Spec hero y 123–221 (height 98).
    expect(hero.top, closeTo(123, 0.5));
    expect(hero.height, closeTo(98, 0.5));

    final month = tester.getRect(find.byKey(const ValueKey("overview-month")));
    // No Cần trả yet: month top = hero bottom + 16 -> y 237–316 (height 79).
    expect(month.top, closeTo(hero.bottom + 16, 0.5));
    expect(month.top, closeTo(237, 0.5));
    expect(month.height, closeTo(79, 0.5));

    final circleRect = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey("shell-avatar")),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
      ),
    );
    expect(circleRect.left, closeTo(347, 0.5));
    expect(circleRect.right, closeTo(383, 0.5));

    final nav = tester.getRect(find.byType(AppBottomNav));
    expect(nav.top, closeTo(754, 0.5));

    if (runShots) await _savePng(tester, "01_tong_quan");

    // Context must be a descendant of Scaffold so [_scaffoldHasBottomNav] sees
    // the bottom nav (Scaffold.maybeOf from the Scaffold element itself fails).
    showAppToast(tester.element(find.byType(OverviewPage)), S.joinedHome);
    await tester.pump(); // insert snackbar
    await tester.pump(const Duration(milliseconds: 750)); // enter animation
    expect(find.text(S.joinedHome), findsOneWidget);

    final toastRect = tester.getRect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Material),
      ),
    );
    expect(toastRect.top, closeTo(698, 3));
    expect(toastRect.bottom, closeTo(746, 3));
    expect(toastRect.bottom, closeTo(nav.top - 8, 0.5));

    if (runShots) {
      await _savePng(tester, "02_tong_quan_toast");
      File("$_outDir/measured.overview.txt").writeAsStringSync(
        "hero_top=${hero.top}\n"
        "month_top=${month.top}\n"
        "nav_top=${nav.top}\n"
        "toast_top=${toastRect.top}\n"
        "toast_bottom=${toastRect.bottom}\n"
        "avatar_x=${tester.getRect(find.byKey(const ValueKey("shell-avatar"))).left}\n",
      );
    }
  });
}
