import "dart:async";

import "package:flutter/foundation.dart";
import "package:home_manager/core/domain/oauth_launch.dart";
import "package:home_manager/core/domain/selected_home.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/services/join_link_store.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SessionController extends ChangeNotifier {
  SessionController({
    required this.auth,
    required this.homesApi,
    required this.invites,
    JoinLinkListener? joinLinks,
  }) : _joinLinks = joinLinks ?? JoinLinkListener();

  static const selectedHomeKey = "selected_home_id";

  final AuthService auth;
  final HomeService homesApi;
  final InviteService invites;
  final JoinLinkListener _joinLinks;

  StreamSubscription<AuthState>? _authSub;
  bool _disposed = false;

  User? user;
  List<Home> homes = [];
  Home? selected;
  bool loading = true;
  String? error;

  @override
  void dispose() {
    _disposed = true;
    _authSub?.cancel();
    unawaited(_joinLinks.dispose());
    super.dispose();
  }

  Future<void> start() async {
    AppLog.i("SessionController starting");
    await _joinLinks.start(
      onCaptured: () async {
        if (_disposed || user == null) return;
        await refreshHomes();
      },
    );
    await _authSub?.cancel();
    _authSub = auth.onAuthStateChange.listen((state) async {
      if (_disposed) return;
      user = state.session?.user;
      AppLog.d("Auth state: ${user?.id ?? "signed out"}");
      if (user != null) {
        await dismissOAuthBrowser();
        await refreshHomes();
      } else {
        homes = [];
        selected = null;
        loading = false;
        notifyListeners();
      }
    });
    user = auth.currentUser;
    if (user != null) {
      await refreshHomes();
    } else {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHomes() async {
    if (_disposed || user == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      await homesApi.acceptPendingInvites();
      String? joinError;
      try {
        await _acceptPendingJoinToken();
      } catch (e, st) {
        AppLog.e("accept join token failed", error: e, stackTrace: st);
        joinError = "$e";
      }
      homes = await homesApi.listHomes();
      if (_disposed) return;
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      selected = resolveSelectedHome(
        homes: homes,
        current: selected,
        persistedId: prefs.getString(selectedHomeKey),
      );
      if (selected != null) {
        await prefs.setString(selectedHomeKey, selected!.id);
      } else {
        await prefs.remove(selectedHomeKey);
      }
      if (joinError != null && selected == null) {
        error = joinError;
      }
    } catch (e, st) {
      if (_disposed || _isClosedClientError(e)) {
        AppLog.d("refreshHomes skipped: client closed");
        return;
      }
      AppLog.e("refreshHomes failed", error: e, stackTrace: st);
      error = "$e";
    } finally {
      if (!_disposed) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _acceptPendingJoinToken() async {
    final token = await JoinLinkStore.read();
    if (token == null) return;
    try {
      await invites.acceptJoinToken(token);
    } finally {
      await JoinLinkStore.clear();
    }
  }

  bool _isClosedClientError(Object e) {
    final message = e.toString();
    return message.contains("Client is already closed");
  }

  void selectHome(Home home) {
    selected = home;
    notifyListeners();
    unawaited(_persistSelectedHomeId(home.id));
  }

  Future<void> _persistSelectedHomeId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedHomeKey, id);
  }

  Future<void> signIn() => auth.signInWithGoogle();

  Future<void> signOut() => auth.signOut();
}
