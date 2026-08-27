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

final _joinLink = HomeJoinLink(
  token: "tok",
  homeId: "h1",
  expiresAt: DateTime(2026, 9, 8),
);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.build(
      brightness: Brightness.light,
      accent: AppAccent.amber,
    ),
    home: child,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue("");
  });

  testWidgets("owner join QR shows scan hint and actions", (tester) async {
    var copied = false;
    var regenerated = false;
    var revoked = false;

    await tester.pumpWidget(
      _wrap(
        Scaffold(
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

  testWidgets("owner sees QR placeholder while join link loads", (
    tester,
  ) async {
    final homes = MockHomeService();
    final invites = MockInviteService();
    final gate = Completer<HomeJoinLink>();

    when(() => homes.listMembers(any())).thenAnswer((_) async => const []);
    when(
      () => invites.createOrGetJoinLink(any()),
    ).thenAnswer((_) => gate.future);

    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        SettingsMembersPage(
          home: _home,
          homesApi: homes,
          invites: invites,
          currentUserId: "u1",
          joinShareUrl: "https://example.test/home-manager/",
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(JoinQrPlaceholder), findsOneWidget);
    expect(find.text(S.joinQrLoading), findsOneWidget);
    expect(find.byType(QrImageView), findsNothing);
    expect(find.text(S.sendInvite), findsNothing);
    expect(find.text(S.invite), findsNothing);

    gate.complete(_joinLink);
    await tester.pumpAndSettle();

    expect(find.byType(JoinQrPlaceholder), findsNothing);
    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets("owner can remove a member, not themselves", (tester) async {
    final homes = MockHomeService();
    final invites = MockInviteService();

    when(() => homes.listMembers(any())).thenAnswer(
      (_) async => const [
        HomeMember(
          userId: "u1",
          role: "owner",
          displayName: "An",
          email: "an@example.com",
        ),
        HomeMember(
          userId: "u2",
          role: "member",
          displayName: "Bình",
          email: "binh@example.com",
        ),
      ],
    );
    when(
      () => invites.createOrGetJoinLink(any()),
    ).thenAnswer((_) async => _joinLink);
    when(
      () => homes.removeMember(
        homeId: any(named: "homeId"),
        userId: any(named: "userId"),
      ),
    ).thenAnswer((_) async {});

    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        SettingsMembersPage(
          home: _home,
          homesApi: homes,
          invites: invites,
          currentUserId: "u1",
          joinShareUrl: "https://example.test/home-manager/",
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip(S.removeMember), findsOneWidget);

    await tester.tap(find.byTooltip(S.removeMember));
    await tester.pumpAndSettle();

    expect(find.text(S.removeMemberTitle), findsOneWidget);
    expect(find.text(S.removeMemberConfirmHint("Bình")), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, S.removeMember));
    await tester.pumpAndSettle();

    verify(() => homes.removeMember(homeId: "h1", userId: "u2")).called(1);
  });
}
