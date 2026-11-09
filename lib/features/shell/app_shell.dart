import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/state/reminder_controller.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/homes/create_home_dialog.dart";
import "package:home_manager/features/notifications/notifications_page.dart";
import "package:home_manager/features/overview/overview_page.dart";
import "package:home_manager/features/personal/personal_hub_page.dart";
import "package:home_manager/features/pwa/install_home_screen_banner.dart";
import "package:home_manager/features/shared/app_ambient_background.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/avatar_button.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/shell/empty_home_view.dart";
import "package:home_manager/features/shell/quick_add_picker_sheet.dart";
import "package:home_manager/features/transactions/transactions_hub_page.dart";
import "package:home_manager/features/wallet/wallet_hub_page.dart";

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.session,
    required this.theme,
    required this.lock,
    required this.services,
  });

  final SessionController session;
  final ThemeController theme;
  final LockController lock;
  final AppServices services;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  late final ReminderController _reminders;

  /// Set after a successful invite join; toast runs post-frame once nav exists.
  bool _pendingJoinedToast = false;

  @override
  void initState() {
    super.initState();
    _reminders = ReminderController(widget.services);
    final home = widget.session.selected;
    if (home != null) {
      _reminders.refresh(home);
    }
  }

  void _scheduleJoinedToastIfNeeded(bool hasHome) {
    if (!_pendingJoinedToast || !hasHome) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pendingJoinedToast) return;
      _pendingJoinedToast = false;
      showAppToast(context, S.joinedHome);
    });
  }

  Future<void> _joinViaCode(String code) async {
    await widget.services.invites.acceptInviteCode(code);
    await widget.session.refreshHomes();
    if (!mounted) return;
    setState(() => _pendingJoinedToast = true);
  }

  Future<void> _joinViaToken(String token) async {
    await widget.services.invites.acceptJoinToken(token);
    await widget.session.refreshHomes();
    if (!mounted) return;
    setState(() => _pendingJoinedToast = true);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final home = widget.session.selected;
    if (home?.id != _reminders.homeId) {
      _reminders.refresh(home);
    }
  }

  @override
  void dispose() {
    _reminders.dispose();
    super.dispose();
  }

  Future<void> _openQuickAdd() async {
    final home = widget.session.selected;
    if (home == null) return;
    await showQuickAddPickerSheet(
      context: context,
      home: home,
      services: widget.services,
      currentUserId: widget.session.user?.id ?? "",
      onSaved: () {
        _reminders.refresh(home);
      },
    );
  }

  void _openPersonal() {
    final session = widget.session;
    final home = session.selected;
    if (home == null) return;
    Navigator.of(context).push<void>(
      AppPageRoute<void>(
        page: PersonalHubPage(
          key: ValueKey("personal-${home.id}"),
          home: home,
          homes: session.homes,
          homesApi: widget.services.homes,
          invites: widget.services.invites,
          notifications: widget.services.notifications,
          theme: widget.theme,
          lock: widget.lock,
          user: session.user,
          onChanged: session.refreshHomes,
          onSelectHome: (h) {
            session.selectHome(h);
            _reminders.refresh(h);
          },
          onAddHome:
              () => showCreateHomeDialog(
                context: context,
                homesApi: widget.services.homes,
                onCreated: session.refreshHomes,
              ),
          onSignOut: () {
            // Pop Cá nhân (and any deeper pushed routes) so SignInPage is
            // not left buried under the personal hub after session clears.
            final nav = Navigator.of(context);
            if (nav.canPop()) {
              nav.popUntil((route) => route.isFirst);
            }
            session.signOut();
          },
        ),
      ),
    );
  }

  String get _avatarLabel {
    final user = widget.session.user;
    final name = user?.userMetadata?["full_name"] as String?;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final email = user?.email;
    if (email != null && email.isNotEmpty) return email;
    return "?";
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final home = session.selected;
    final services = widget.services;
    final colors = context.appColors;
    _scheduleJoinedToastIfNeeded(home != null);

    return Stack(
      fit: StackFit.expand,
      children: [
        const AppAmbientBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: colors.glass ? Colors.transparent : colors.bgBase,
            surfaceTintColor: Colors.transparent,
            // Hit area x 341–389; circle x 347–383 (10px from screen right).
            actionsPadding: EdgeInsets.zero,
            title: Text(
              home == null
                  ? S.appName
                  : switch (_tab) {
                    0 => S.overview,
                    1 => S.transactions,
                    2 => S.dues,
                    _ => S.assets,
                  },
              style:
                  home == null
                      ? const TextStyle(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      )
                      : const TextStyle(
                        fontSize: 22,
                        height: 28 / 22,
                        fontWeight: FontWeight.w700,
                      ),
            ),
            actions:
                home == null
                    ? null
                    : [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: AvatarButton(
                          key: const ValueKey("shell-avatar"),
                          label: _avatarLabel,
                          onPressed: _openPersonal,
                        ),
                      ),
                    ],
          ),
          body: MobileViewport(
            child: Column(
              children: [
                if (home != null) const InstallHomeScreenBanner(),
                Expanded(
                  child: LoadingOverlay(
                    loading: session.loading,
                    child:
                        home == null
                            ? EmptyHomeView(
                              email: session.user?.email ?? "",
                              onAddHome:
                                  () => showCreateHomeDialog(
                                    context: context,
                                    homesApi: services.homes,
                                    onCreated: session.refreshHomes,
                                  ),
                              onSignOut: session.signOut,
                              onAcceptCode: _joinViaCode,
                              onAcceptToken: _joinViaToken,
                            )
                            : IndexedStack(
                              index: _tab,
                              children: [
                                OverviewPage(
                                  key: ValueKey("overview-${home.id}"),
                                  home: home,
                                  services: services,
                                  currentUserId: session.user?.id ?? "",
                                  onOpenAssets: () => setState(() => _tab = 3),
                                  onOpenExpenses: () => setState(() => _tab = 1),
                                ),
                                TransactionsHubPage(
                                  key: ValueKey("tx-${home.id}"),
                                  home: home,
                                  services: services,
                                  currentUserId: session.user?.id ?? "",
                                ),
                                // Temporary until Đợt 3 (Cần trả).
                                NotificationsPage(
                                  key: ValueKey("dues-${home.id}"),
                                  home: home,
                                  services: services,
                                  reminders: _reminders,
                                  currentUserId: session.user?.id ?? "",
                                ),
                                // Temporary until Đợt 4 (Tài sản hub).
                                WalletHubPage(
                                  key: ValueKey("assets-${home.id}"),
                                  home: home,
                                  services: services,
                                  currentUserId: session.user?.id ?? "",
                                  embedded: true,
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              home == null
                  ? null
                  : AnimatedBuilder(
                    animation: _reminders,
                    builder: (context, _) {
                      return AppBottomNav(
                        tabIndex: _tab,
                        notificationBadge: _reminders.badgeCount,
                        onTabSelected: (index) => setState(() => _tab = index),
                        onQuickAdd: _openQuickAdd,
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
