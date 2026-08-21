import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/app_services.dart";
import "package:home_manager/core/services/pwa_runtime.dart";
import "package:home_manager/core/state/lock_controller.dart";
import "package:home_manager/core/state/reminder_controller.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/homes/create_home_dialog.dart";
import "package:home_manager/features/notifications/notifications_page.dart";
import "package:home_manager/features/overview/overview_page.dart";
import "package:home_manager/features/personal/personal_hub_page.dart";
import "package:home_manager/features/pwa/install_home_screen_banner.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/shell/quick_add_picker_sheet.dart";
import "package:home_manager/features/transactions/transactions_hub_page.dart";

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

  @override
  void initState() {
    super.initState();
    _reminders = ReminderController(widget.services);
    final home = widget.session.selected;
    if (home != null) {
      _reminders.refresh(home);
    }
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

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final home = session.selected;
    final services = widget.services;
    final colors = context.appColors;

    return ColoredBox(
      color: colors.bgBase,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: colors.bgBase,
          surfaceTintColor: Colors.transparent,
          title: Text(
            home == null
                ? S.appName
                : switch (_tab) {
                  0 => S.overview,
                  1 => S.transactions,
                  2 => S.notifications,
                  _ => S.personal,
                },
          ),
        ),
        body: MobileViewport(
          child: Column(
            children: [
              const InstallHomeScreenBanner(),
              Expanded(
                child: LoadingOverlay(
                  loading: session.loading,
                  child:
                      home == null
                          ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(S.noHomes),
                                const SizedBox(height: AppSpacing.md),
                                FilledButton(
                                  onPressed:
                                      () => showCreateHomeDialog(
                                        context: context,
                                        homesApi: services.homes,
                                        onCreated: session.refreshHomes,
                                      ),
                                  child: const Text(S.addHome),
                                ),
                              ],
                            ),
                          )
                          : IndexedStack(
                            index: _tab,
                            children: [
                              OverviewPage(
                                key: ValueKey("overview-${home.id}"),
                                home: home,
                                services: services,
                                currentUserId: session.user?.id ?? "",
                              ),
                              TransactionsHubPage(
                                key: ValueKey("tx-${home.id}"),
                                home: home,
                                services: services,
                                currentUserId: session.user?.id ?? "",
                              ),
                              NotificationsPage(
                                key: ValueKey("notif-${home.id}"),
                                home: home,
                                services: services,
                                reminders: _reminders,
                                currentUserId: session.user?.id ?? "",
                              ),
                              PersonalHubPage(
                                key: ValueKey("personal-${home.id}"),
                                home: home,
                                homes: session.homes,
                                homesApi: services.homes,
                                invites: services.invites,
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
                                      homesApi: services.homes,
                                      onCreated: session.refreshHomes,
                                    ),
                                onSignOut: session.signOut,
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
                : SafeArea(
                  top: false,
                  bottom: !(kIsWeb && pwaIosHomeScreenShell()),
                  child: AnimatedBuilder(
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
      ),
    );
  }
}
