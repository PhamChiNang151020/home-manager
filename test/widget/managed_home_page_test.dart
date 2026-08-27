import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/personal/managed_home_page.dart";
import "package:mocktail/mocktail.dart";

class MockHomeService extends Mock implements HomeService {}

const _home = Home(
  id: "h1",
  name: "Testing",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  createdBy: "u1",
  myRole: "member",
);

void main() {
  testWidgets("shows current home and leave action", (tester) async {
    final homesApi = MockHomeService();
    when(() => homesApi.listMembers(any())).thenAnswer((_) async => const []);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: ManagedHomePage(
          home: _home,
          homes: const [_home],
          homesApi: homesApi,
          currentUserId: "u2",
          onSelectHome: (_) {},
          onAddHome: () {},
          onLeft: () {},
        ),
      ),
    );

    expect(find.text(S.managedHome), findsWidgets);
    expect(find.text("Testing"), findsOneWidget);
    expect(find.text(S.modeMeter), findsOneWidget);
    expect(find.text(S.leaveHome), findsOneWidget);
    expect(find.text(S.addHome), findsOneWidget);
    expect(find.text(S.signOut), findsNothing);
  });
}
