import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/join_link.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/services/join_link_store.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:mocktail/mocktail.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class MockAuthService extends Mock implements AuthService {}

class MockHomeService extends Mock implements HomeService {}

class MockInviteService extends Mock implements InviteService {}

/// Skips AppLinks so unit tests do not touch platform channels.
class QuietJoinLinkListener extends JoinLinkListener {
  @override
  Future<void> start({required Future<void> Function() onCaptured}) async {}

  @override
  Future<void> dispose() async {}
}

User _user() {
  return User(
    id: "user-1",
    appMetadata: const {},
    userMetadata: const {},
    aud: "authenticated",
    createdAt: "2026-01-01T00:00:00.000Z",
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService auth;
  late MockHomeService homes;
  late MockInviteService invites;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      JoinLink.prefsKey: "pending-token",
    });
    auth = MockAuthService();
    homes = MockHomeService();
    invites = MockInviteService();
  });

  test(
    "refreshHomes clears JoinLinkStore after acceptJoinToken succeeds",
    () async {
      when(() => homes.acceptPendingInvites()).thenAnswer((_) async => 0);
      when(
        () => invites.acceptJoinToken("pending-token"),
      ).thenAnswer((_) async => "home-1");
      when(() => homes.listHomes()).thenAnswer(
        (_) async => [
          const Home(
            id: "home-1",
            name: "Nhà test",
            trackingMode: TrackingMode.meter,
            kwhRate: 3500,
            createdBy: "user-1",
          ),
        ],
      );

      final session = SessionController(
        auth: auth,
        homesApi: homes,
        invites: invites,
        joinLinks: QuietJoinLinkListener(),
      );
      addTearDown(session.dispose);
      session.user = _user();

      expect(await JoinLinkStore.read(), "pending-token");
      await session.refreshHomes();

      verify(() => invites.acceptJoinToken("pending-token")).called(1);
      expect(await JoinLinkStore.read(), isNull);
    },
  );
}
