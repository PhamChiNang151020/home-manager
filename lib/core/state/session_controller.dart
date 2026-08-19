import "package:flutter/foundation.dart";
import "package:home_manager/core/logging/app_log.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/services/auth_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class SessionController extends ChangeNotifier {
  SessionController({
    required this.auth,
    required this.homesApi,
  });

  final AuthService auth;
  final HomeService homesApi;

  User? user;
  List<Home> homes = [];
  Home? selected;
  bool loading = true;
  String? error;

  Future<void> start() async {
    AppLog.i("SessionController starting");
    auth.onAuthStateChange.listen((state) async {
      user = state.session?.user;
      AppLog.d("Auth state: ${user?.id ?? "signed out"}");
      if (user != null) {
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
    loading = true;
    error = null;
    notifyListeners();
    try {
      await homesApi.acceptPendingInvites();
      homes = await homesApi.listHomes();
      if (selected != null) {
        selected = homes.cast<Home?>().firstWhere(
              (home) => home?.id == selected!.id,
              orElse: () => homes.isEmpty ? null : homes.first,
            );
      } else if (homes.isNotEmpty) {
        selected = homes.first;
      }
    } catch (e, st) {
      AppLog.e("refreshHomes failed", error: e, stackTrace: st);
      error = "$e";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void selectHome(Home home) {
    selected = home;
    notifyListeners();
  }

  Future<void> signIn() => auth.signInWithGoogle();

  Future<void> signOut() => auth.signOut();
}
