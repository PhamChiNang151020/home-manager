import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/personal/leave_home_sheet.dart";

const _home = Home(
  id: "h1",
  name: "Nhà tôi",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "member",
);

const _ownedHome = Home(
  id: "h1",
  name: "Nhà tôi",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "owner",
);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.build(
      brightness: Brightness.light,
      accent: AppAccent.amber,
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets("member sheet keeps history copy and confirm", (tester) async {
    await tester.pumpWidget(
      _wrap(
        LeaveHomeSheet(
          home: _home,
          members: const [
            HomeMember(userId: "u1", role: "owner", displayName: "An"),
            HomeMember(userId: "u2", role: "member", displayName: "Bình"),
          ],
          currentUserId: "u2",
          onLeave: ({String? newOwnerId}) async {},
        ),
      ),
    );

    expect(find.text(S.leaveHomeConfirmHint), findsOneWidget);
    expect(find.text(S.leaveHomeNewOwner), findsNothing);
    expect(find.text(S.leaveHomeSoleOwnerHint), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets("owner with others must pick a successor", (tester) async {
    var left = false;
    await tester.pumpWidget(
      _wrap(
        LeaveHomeSheet(
          home: _ownedHome,
          members: const [
            HomeMember(userId: "u1", role: "owner", displayName: "An"),
            HomeMember(userId: "u2", role: "member", displayName: "Bình"),
          ],
          currentUserId: "u1",
          onLeave: ({String? newOwnerId}) async {
            left = true;
          },
        ),
      ),
    );

    expect(find.text(S.leaveHomeConfirmHint), findsOneWidget);
    expect(find.text(S.leaveHomeNewOwner), findsOneWidget);
    expect(find.text(S.leaveHomePickOwner), findsOneWidget);

    await tester.tap(find.text(S.leaveHomeConfirm));
    await tester.pump();
    expect(left, isFalse);
  });

  testWidgets("sole owner cannot confirm leave", (tester) async {
    await tester.pumpWidget(
      _wrap(
        LeaveHomeSheet(
          home: _ownedHome,
          members: const [
            HomeMember(userId: "u1", role: "owner", displayName: "An"),
          ],
          currentUserId: "u1",
          onLeave: ({String? newOwnerId}) async {},
        ),
      ),
    );

    expect(find.text(S.leaveHomeSoleOwnerHint), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
}
