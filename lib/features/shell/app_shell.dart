import "package:flutter/material.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/home_service.dart";
import "package:home_manager/core/services/invite_service.dart";
import "package:home_manager/core/state/session_controller.dart";
import "package:home_manager/features/electricity/electricity_page.dart";
import "package:home_manager/features/homes/create_home_dialog.dart";
import "package:home_manager/features/settings/settings_page.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.session});

  final SessionController session;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final home = session.selected;
    final client = Supabase.instance.client;
    final homesApi = HomeService(client);
    final electricity = ElectricityService(client);
    final photos = BillPhotoService(client);
    final invites = InviteService(client);

    return Scaffold(
      appBar: AppBar(
        title: Text(home?.name ?? S.appName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (id) {
              if (id == "_add") {
                showCreateHomeDialog(
                  context: context,
                  homesApi: homesApi,
                  onCreated: session.refreshHomes,
                );
                return;
              }
              final match = session.homes.where((item) => item.id == id);
              if (match.isNotEmpty) {
                session.selectHome(match.first);
              }
            },
            itemBuilder: (context) => [
              for (final item in session.homes)
                PopupMenuItem(value: item.id, child: Text(item.name)),
              const PopupMenuItem(value: "_add", child: Text(S.addHome)),
            ],
            icon: const Icon(Icons.home_work_outlined),
          ),
        ],
      ),
      body: session.loading
          ? const Center(child: CircularProgressIndicator())
          : home == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(S.noHomes),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => showCreateHomeDialog(
                          context: context,
                          homesApi: homesApi,
                          onCreated: session.refreshHomes,
                        ),
                        child: const Text(S.addHome),
                      ),
                    ],
                  ),
                )
              : _tab == 0
                  ? ElectricityPage(
                      key: ValueKey(home.id),
                      home: home,
                      electricity: electricity,
                      photos: photos,
                    )
                  : SettingsPage(
                      key: ValueKey("settings-${home.id}"),
                      home: home,
                      homesApi: homesApi,
                      invites: invites,
                      onChanged: session.refreshHomes,
                      onSignOut: session.signOut,
                    ),
      bottomNavigationBar: home == null
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (index) => setState(() => _tab = index),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.bolt), label: S.electricity),
                NavigationDestination(icon: Icon(Icons.settings), label: S.settings),
              ],
            ),
    );
  }
}
