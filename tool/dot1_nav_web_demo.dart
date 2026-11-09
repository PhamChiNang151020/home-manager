import "package:flutter/material.dart";
import "package:home_manager/core/format/vnd_format.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/navigation/app_page_route.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_color_scheme.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_spacing.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/core/theme/mobile_viewport.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/avatar_button.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/shared/app_sheet.dart";

/// Local-only Đợt 1 nav demo (hard-coded mock data, no Supabase).
///
///   flutter run -d chrome -t tool/dot1_nav_web_demo.dart \
///     --web-browser-flag "--window-size=393,852"
///
/// Or: flutter run -d web-server -t tool/dot1_nav_web_demo.dart \
///     --web-hostname=0.0.0.0 --web-port=5556
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(
        brightness: Brightness.light,
        accent: AppAccent.amber,
      ),
      home: const MediaQuery(
        data: MediaQueryData(
          size: Size(393, 852),
          padding: EdgeInsets.only(top: 59, bottom: 34),
          viewPadding: EdgeInsets.only(top: 59, bottom: 34),
          textScaler: TextScaler.noScaling,
        ),
        child: _Dot1Demo(),
      ),
    ),
  );
}

class _Dot1Demo extends StatefulWidget {
  const _Dot1Demo();

  @override
  State<_Dot1Demo> createState() => _Dot1DemoState();
}

class _Dot1DemoState extends State<_Dot1Demo> {
  int _tab = 0;
  int _segment = 0;

  static const _homeName = "TEST Nhà";
  static const _netWorth = 1250000.0;
  static const _monthExpenses = 320000.0;
  static const _monthIncome = 15000000.0;

  void _openPersonal() {
    Navigator.of(context).push<void>(
      AppPageRoute<void>(
        page: Scaffold(
          appBar: AppBar(
            title: const Text(
              S.personal,
              style: TextStyle(
                fontSize: 22,
                height: 28 / 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: MobileViewport(
            child: ListView(
              padding: AppSpacing.shellListPadding,
              children: const [
                ListTile(title: Text(S.managedHome)),
                ListTile(title: Text(S.personalInfo)),
                ListTile(title: Text(S.personalShare)),
                ListTile(title: Text(S.personalSettings)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openQuickAdd() {
    return showAppSheet<void>(
      context: context,
      showDragHandle: false,
      builder: (ctx) {
        final colors = ctx.appColors;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 36,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const Text(
                S.quickAddPickTitle,
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListGroup(
                children: [
                  ListGroupRow(
                    title: S.expenses,
                    leading: const ListGroupIcon(icon: AppIcons.expenses),
                    onTap: () => Navigator.pop(ctx),
                  ),
                  ListGroupRow(
                    title: S.income,
                    leading: const ListGroupIcon(icon: AppIcons.income),
                    onTap: () => Navigator.pop(ctx),
                  ),
                  ListGroupRow(
                    title: S.electricity,
                    leading: const ListGroupIcon(icon: AppIcons.electricity),
                    onTap: () => Navigator.pop(ctx),
                  ),
                  ListGroupRow(
                    title: S.water,
                    leading: const ListGroupIcon(icon: AppIcons.water),
                    showDivider: false,
                    onTap: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListGroup(
                children: [
                  ListGroupRow(
                    title: S.addBankAccount,
                    leading: const ListGroupIcon(icon: Icons.credit_card_outlined),
                    onTap: () => Navigator.pop(ctx),
                  ),
                  ListGroupRow(
                    title: S.addDebt,
                    leading: const ListGroupIcon(icon: Icons.handshake_outlined),
                    onTap: () => Navigator.pop(ctx),
                  ),
                  ListGroupRow(
                    title: S.addSavings,
                    leading: const ListGroupIcon(icon: Icons.savings_outlined),
                    showDivider: false,
                    onTap: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final month = DateTime.now().month;
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.zero,
        title: Text(
          switch (_tab) {
            0 => S.overview,
            1 => S.transactions,
            2 => S.dues,
            _ => S.assets,
          },
          style: const TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AvatarButton(
              key: const ValueKey("shell-avatar"),
              label: "N",
              onPressed: _openPersonal,
            ),
          ),
        ],
      ),
      body: MobileViewport(
        child: IndexedStack(
          index: _tab,
          children: [
            ListView(
              padding: AppSpacing.shellListPadding,
              children: [
                SizedBox(
                  height: 98,
                  child: AppCard(
                    key: const ValueKey("overview-net-worth"),
                    onTap: () => setState(() => _tab = 3),
                    padding: const EdgeInsets.fromLTRB(16, 19, 16, 19),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                S.netWorthHomeLabel(_homeName),
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 16 / 12,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                VndFormat.format(_netWorth),
                                style: TextStyle(
                                  fontSize: 32,
                                  height: 40 / 32,
                                  fontWeight: FontWeight.w800,
                                  color: colors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: colors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  key: const ValueKey("overview-month"),
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: 79,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _tab = 1),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    S.monthSpentLabel(month),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    VndFormat.format(_monthExpenses),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, color: colors.border),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  S.monthIncomeLabel(month),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                                Text(
                                  VndFormat.format(_monthIncome),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => showAppToast(context, S.joinedHome),
                  child: const Text("Show success toast"),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SegmentedTrack(
                    labels: const [S.expenses, S.electricity, S.water],
                    index: _segment,
                    onChanged: (i) => setState(() => _segment = i),
                  ),
                ),
                Expanded(child: Center(child: Text("segment $_segment"))),
              ],
            ),
            const Center(child: Text("Cần trả (temp)")),
            const Center(child: Text("Tài sản (temp)")),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        tabIndex: _tab,
        notificationBadge: 2,
        onTabSelected: (i) => setState(() => _tab = i),
        onQuickAdd: _openQuickAdd,
      ),
    );
  }
}
