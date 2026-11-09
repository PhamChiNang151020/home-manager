import "dart:async";
import "dart:io";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/settings/settings_members_page.dart";
import "package:home_manager/features/shell/empty_home_view.dart";
import "package:mocktail/mocktail.dart";

class MockHomeService extends Mock implements HomeService {}

class MockInviteService extends Mock implements InviteService {}

const _outDir = "/opt/cursor/artifacts/dot0";

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

Widget _frame(
  Widget body, {
  PreferredSizeWidget? appBar,
  bool wrapViewport = true,
  bool includeOuterScaffold = true,
}) {
  final themedBody =
      wrapViewport ? MobileViewport(child: body) : body;
  final page =
      includeOuterScaffold
          ? Scaffold(
            backgroundColor: const Color(0xFFF5F6F8),
            appBar:
                appBar ??
                AppBar(
                  title: const Text(
                    S.appName,
                    style: TextStyle(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
            body: themedBody,
          )
          : themedBody;
  return MaterialApp(
    theme: AppTheme.build(
      brightness: Brightness.light,
      accent: AppAccent.amber,
      glass: false,
    ),
    home: RepaintBoundary(
      key: const ValueKey("shot"),
      child: SizedBox(
        width: 393,
        height: 852,
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(393, 852),
            textScaler: TextScaler.noScaling,
          ),
          child: page,
        ),
      ),
    ),
  );
}

double _top(WidgetTester tester, Finder f) => tester.getTopLeft(f).dy;

void main() {
  final artifactsRoot = Directory("/opt/cursor/artifacts");
  final runShots = artifactsRoot.existsSync();

  setUpAll(() async {
    registerFallbackValue("");
    TestWidgetsFlutterBinding.ensureInitialized();
    // Always load Nunito; only the screenshot cases stay gated by runShots.
    await _loadNunito();
  });

  Future<void> prep(WidgetTester tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets("01 default", skip: !runShots, (tester) async {
    await prep(tester);
    await tester.pumpWidget(
      _frame(
        EmptyHomeView(
          email: "nang.pham@gmail.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {},
          onAcceptToken: (_) async {},
        ),
      ),
    );
    await tester.pump();
    await _savePng(tester, "01-sau-mac-dinh");

    final accountTop =
        tester
            .getRect(
              find
                  .ancestor(
                    of: find.text(S.signedInLabel),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .top;
    final titleTop = _top(tester, find.text(S.emptyHomeTitle));
    final hintTop = _top(tester, find.text(S.emptyHomeHint));
    final addTop = _top(tester, find.widgetWithText(FilledButton, S.addHome));
    final inviteTop = _top(tester, find.text(S.receiveInvite));
    final enterTop = _top(
      tester,
      find.widgetWithText(FilledButton, S.enterHome),
    );
    final signOutTop = _top(
      tester,
      find.widgetWithText(OutlinedButton, S.signOut),
    );

    final lines = StringBuffer()
      ..writeln("state,element,measured_delta,spec_delta,diff")
      ..writeln(
        "01,accountCardTop_abs,${accountTop.toStringAsFixed(1)},123 (safe-area table),n/a",
      )
      ..writeln(
        "01,title,${(titleTop - accountTop).toStringAsFixed(1)},90,${(titleTop - accountTop - 90).toStringAsFixed(1)}",
      )
      ..writeln(
        "01,hint,${(hintTop - accountTop).toStringAsFixed(1)},122,${(hintTop - accountTop - 122).toStringAsFixed(1)}",
      )
      ..writeln(
        "01,addHome,${(addTop - accountTop).toStringAsFixed(1)},158,${(addTop - accountTop - 158).toStringAsFixed(1)}",
      )
      ..writeln(
        "01,inviteTitle,${(inviteTop - accountTop).toStringAsFixed(1)},247,${(inviteTop - accountTop - 247).toStringAsFixed(1)}",
      )
      ..writeln(
        "01,enterHome,${(enterTop - accountTop).toStringAsFixed(1)},375,${(enterTop - accountTop - 375).toStringAsFixed(1)}",
      )
      ..writeln(
        "01,signOut,${(signOutTop - accountTop).toStringAsFixed(1)},464,${(signOutTop - accountTop - 464).toStringAsFixed(1)}",
      );
    File("$_outDir/measured.csv").writeAsStringSync(lines.toString());
  });

  testWidgets("02 typing", skip: !runShots, (tester) async {
    await prep(tester);
    await tester.pumpWidget(
      _frame(
        EmptyHomeView(
          email: "nang.pham@gmail.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {},
          onAcceptToken: (_) async {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), "K7M");
    await tester.pump();
    await _savePng(tester, "02-sau-dang-nhap-ma");
  });

  testWidgets("03 invalid code", skip: !runShots, (tester) async {
    await prep(tester);
    await tester.pumpWidget(
      _frame(
        EmptyHomeView(
          email: "nang.pham@gmail.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {
            throw Exception("invalid or expired invite code");
          },
          onAcceptToken: (_) async {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), "K7M2QX");
    await tester.pump();
    await tester.tap(find.text(S.enterHome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await _savePng(tester, "03-sau-loi-ma-moi");
  });

  testWidgets("04 locked", skip: !runShots, (tester) async {
    await prep(tester);
    await tester.pumpWidget(
      _frame(
        EmptyHomeView(
          email: "nang.pham@gmail.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {
            throw Exception("too many attempts");
          },
          onAcceptToken: (_) async {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), "K7M2QP");
    await tester.pump();
    await tester.tap(find.text(S.enterHome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await _savePng(tester, "04-sau-khoa-tam");
  });

  testWidgets("05 submitting", skip: !runShots, (tester) async {
    await prep(tester);
    final gate = Completer<void>();
    await tester.pumpWidget(
      _frame(
        EmptyHomeView(
          email: "nang.pham@gmail.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) => gate.future,
          onAcceptToken: (_) async {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), "K7M2QP");
    await tester.pump();
    await tester.tap(find.text(S.enterHome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    await _savePng(tester, "05-sau-dang-vao-nha");
    gate.complete();
    await tester.pump();
  });

  testWidgets("06 success toast", skip: !runShots, (tester) async {
    await prep(tester);
    await tester.pumpWidget(
      _frame(
        EmptyHomeView(
          email: "nang.pham@gmail.com",
          onAddHome: () {},
          onSignOut: () {},
          onAcceptCode: (_) async {},
          onAcceptToken: (_) async {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), "K7M2QP");
    await tester.pump();
    await tester.tap(find.text(S.enterHome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await _savePng(tester, "06-sau-thanh-cong");
  });

  testWidgets("08 owner members", skip: !runShots, (tester) async {
    await prep(tester);
    final homes = MockHomeService();
    final invites = MockInviteService();
    when(() => homes.listMembers(any())).thenAnswer(
      (_) async => const [
        HomeMember(
          userId: "u1",
          role: "owner",
          displayName: "Nang Pham",
          email: "nang.pham@gmail.com",
        ),
      ],
    );
    when(() => invites.createOrGetJoinLink(any())).thenAnswer(
      (_) async => HomeJoinLink(
        token: "tok",
        homeId: "h1",
        expiresAt: DateTime(2026, 11, 6),
        code: "K7M2QP",
      ),
    );

    await tester.pumpWidget(
      _frame(
        SettingsMembersPage(
          home: const Home(
            id: "h1",
            name: "Nhà tôi",
            trackingMode: TrackingMode.meter,
            kwhRate: 3500,
            createdBy: "u1",
            myRole: "owner",
          ),
          homesApi: homes,
          invites: invites,
          currentUserId: "u1",
          joinShareUrl: "https://example.test/home-manager/",
        ),
        wrapViewport: false,
        includeOuterScaffold: false,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await _savePng(tester, "08-chu-nha-sau");

    final sectionTop = _top(tester, find.text(S.joinQrTitle.toUpperCase()));
    final hintTop = _top(tester, find.text(S.joinQrHint));
    final codeLabelTop = _top(tester, find.text(S.inviteCodeLabel));
    final codeTop = _top(tester, find.text("K7M 2QP"));
    final copyCodeTop =
        tester
            .getRect(
              find
                  .ancestor(
                    of: find.text(S.inviteCodeCopy),
                    matching: find.byWidgetPredicate(
                      (w) => w is OutlinedButton || w is TextButton,
                    ),
                  )
                  .first,
            )
            .top;
    final copyLinkTop =
        tester
            .getRect(
              find
                  .ancestor(
                    of: find.text(S.joinQrCopy),
                    matching: find.byWidgetPredicate((w) => w is OutlinedButton),
                  )
                  .first,
            )
            .top;
    final codeCard = tester.getRect(
      find
          .ancestor(
            of: find.text(S.inviteCodeLabel),
            matching: find.byType(Container),
          )
          .first,
    );

    final existing = File("$_outDir/measured.csv").readAsStringSync();
    final buf =
        StringBuffer(existing)
          ..writeln(
            "08,hint_from_section,${(hintTop - sectionTop).toStringAsFixed(1)},24,${(hintTop - sectionTop - 24).toStringAsFixed(1)}",
          )
          ..writeln(
            "08,codeCard_from_section,${(codeCard.top - sectionTop).toStringAsFixed(1)},80,${(codeCard.top - sectionTop - 80).toStringAsFixed(1)}",
          )
          ..writeln(
            "08,codeCard_height,${codeCard.height.toStringAsFixed(1)},122,${(codeCard.height - 122).toStringAsFixed(1)}",
          )
          ..writeln(
            "08,codeLabel_from_section,${(codeLabelTop - sectionTop).toStringAsFixed(1)},97,${(codeLabelTop - sectionTop - 97).toStringAsFixed(1)}",
          )
          ..writeln(
            "08,code_from_section,${(codeTop - sectionTop).toStringAsFixed(1)},123,${(codeTop - sectionTop - 123).toStringAsFixed(1)}",
          )
          ..writeln(
            "08,copyCodeBtn_from_section,${(copyCodeTop - sectionTop).toStringAsFixed(1)},117,${(copyCodeTop - sectionTop - 117).toStringAsFixed(1)}",
          )
          ..writeln(
            "08,copyLinkBtn_from_section,${(copyLinkTop - sectionTop).toStringAsFixed(1)},414,${(copyLinkTop - sectionTop - 414).toStringAsFixed(1)}",
          );
    File("$_outDir/measured.csv").writeAsStringSync(buf.toString());
  });
}
