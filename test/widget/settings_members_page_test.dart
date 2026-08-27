import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/settings/settings_members_page.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:mocktail/mocktail.dart";
import "package:qr_flutter/qr_flutter.dart";

class MockHomeService extends Mock implements HomeService {}

class MockInviteService extends Mock implements InviteService {}

const _home = Home(
  id: "h1",
  name: "Nhà tôi",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

void main() {
  setUpAll(() {
    registerFallbackValue("");
  });

  testWidgets("owner join QR shows scan hint and actions", (tester) async {
    var copied = false;
    var regenerated = false;
    var revoked = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: JoinQrSection(
            joinUrl: "https://example.test/home-manager/join.html?join=abc123",
            expiresAt: DateTime(2026, 9, 8),
            busy: false,
            onCopy: () => copied = true,
            onRegenerate: () => regenerated = true,
            onRevoke: () => revoked = true,
          ),
        ),
      ),
    );

    expect(find.text(S.joinQrHint), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      find.text("https://example.test/home-manager/join.html?join=abc123"),
      findsNothing,
    );

    await tester.tap(find.text(S.joinQrCopy));
    await tester.pump();
    expect(copied, isTrue);

    await tester.tap(find.text(S.joinQrRegenerate));
    await tester.pump();
    expect(regenerated, isTrue);

    await tester.tap(find.text(S.joinQrRevoke));
    await tester.pump();
    expect(revoked, isTrue);
  });

  testWidgets("sending invite shows full-page overlay, not button spinner", (
    tester,
  ) async {
    final homes = MockHomeService();
    final invites = MockInviteService();
    final gate = Completer<String>();

    when(() => homes.listMembers(any())).thenAnswer((_) async => const []);
    when(() => invites.listPending(any())).thenAnswer((_) async => []);
    when(() => invites.createOrGetJoinLink(any())).thenAnswer(
      (_) async => HomeJoinLink(
        token: "tok",
        homeId: "h1",
        expiresAt: DateTime(2026, 9, 8),
      ),
    );
    when(
      () => invites.invite(
        homeId: any(named: "homeId"),
        email: any(named: "email"),
      ),
    ).thenAnswer((_) => gate.future);

    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: SettingsMembersPage(
          home: _home,
          homesApi: homes,
          invites: invites,
          joinShareUrl: "https://example.test/home-manager/",
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), "family@gmail.com");
    await tester.tap(find.text(S.sendInvite));
    await tester.pump();

    expect(find.byType(AppLoadingScrim), findsOneWidget);
    expect(find.text(S.sending), findsNothing);
    expect(find.text(S.sendInvite), findsOneWidget);
    expect(tester.widget<AppLoader>(find.byType(AppLoader)).size, 88);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets("pending invite has no resend mail action", (tester) async {
    final homes = MockHomeService();
    final invites = MockInviteService();

    when(() => homes.listMembers(any())).thenAnswer((_) async => const []);
    when(() => invites.listPending(any())).thenAnswer(
      (_) async => const [
        HomeInvite(id: "inv-1", email: "family@gmail.com", status: "pending"),
      ],
    );
    when(() => invites.createOrGetJoinLink(any())).thenAnswer(
      (_) async => HomeJoinLink(
        token: "tok",
        homeId: "h1",
        expiresAt: DateTime(2026, 9, 8),
      ),
    );

    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: SettingsMembersPage(
          home: _home,
          homesApi: homes,
          invites: invites,
          joinShareUrl: "https://example.test/home-manager/",
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("family@gmail.com"), findsOneWidget);
    expect(find.text(S.pendingInviteHint), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
