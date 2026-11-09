import "dart:js_interop";
import "dart:js_interop_unsafe";

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
import "package:home_manager/features/shared/animated_money_text.dart";
import "package:home_manager/features/shared/app_card.dart";
import "package:home_manager/features/shared/app_toast.dart";
import "package:home_manager/features/shared/avatar_button.dart";
import "package:home_manager/features/shared/list_group.dart";
import "package:home_manager/features/shared/segmented_track.dart";
import "package:home_manager/features/shell/app_bottom_nav.dart";
import "package:home_manager/features/shared/app_sheet.dart";
import "package:web/web.dart" as web;

void _publishMeasure(Map<String, Object?> data) {
  web.window.setProperty("__dot1Measure".toJS, data.jsify());
}

Rect? _rectOf(GlobalKey key) {
  final box = key.currentContext?.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return null;
  final topLeft = box.localToGlobal(Offset.zero);
  return topLeft & box.size;
}

Map<String, Object?>? _rectMap(GlobalKey key) {
  final r = _rectOf(key);
  if (r == null) return null;
  return {
    "top": r.top,
    "bottom": r.bottom,
    "left": r.left,
    "right": r.right,
    "width": r.width,
    "height": r.height,
  };
}

/// Local-only Đợt 1 nav demo (hard-coded mock data, no Supabase).
///
/// Web Chromium (inset 0): sheet y 348–852, nav y 788–852.
///
///   flutter run -d web-server -t tool/dot1_nav_web_demo.dart \
///     --web-hostname=0.0.0.0 --web-port=5556 --release
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(
        brightness: Brightness.light,
        accent: AppAccent.amber,
      ),
      // Real web inset is 0 — do not fake +34 here (QA Chromium measure).
      home: const MediaQuery(
        data: MediaQueryData(
          size: Size(393, 852),
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
  bool _signedIn = true;
  final _heroKey = GlobalKey();
  final _amountKey = GlobalKey();
  final _navKey = GlobalKey();
  final _sheetKey = GlobalKey();
  final Map<String, GlobalKey> _assetKeys = {
    S.wallet: GlobalKey(),
    S.savings: GlobalKey(),
    S.bankCredit: GlobalKey(),
    S.personalDebts: GlobalKey(),
  };
  final Map<String, GlobalKey> _assetIconKeys = {
    S.wallet: GlobalKey(),
    S.savings: GlobalKey(),
    S.bankCredit: GlobalKey(),
    S.personalDebts: GlobalKey(),
  };

  // Long amount proves FittedBox scaleDown inside fixed hero h 98.
  static const _homeName = "TEST Nhà";
  static const _netWorth = 9999999999999.0;
  static const _monthExpenses = 320000.0;
  static const _monthIncome = 15000000.0;

  void _emitMeasure({String? sheetState}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assets = <String, Object?>{};
      for (final e in _assetKeys.entries) {
        assets[e.key] = {
          "row": _rectMap(e.value),
          "icon": _rectMap(_assetIconKeys[e.key]!),
        };
      }
      _publishMeasure({
        "tab": _tab,
        "signedIn": _signedIn,
        "sheetState": sheetState,
        "hero": _rectMap(_heroKey),
        "amount": _rectMap(_amountKey),
        "nav": _rectMap(_navKey),
        "sheet": _rectMap(_sheetKey),
        "assets": assets,
        "viewport": {"w": 393, "h": 852},
      });
    });
  }

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
              children: [
                const ListTile(title: Text(S.managedHome)),
                const ListTile(title: Text(S.personalInfo)),
                const ListTile(title: Text(S.personalShare)),
                const ListTile(title: Text(S.personalSettings)),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: OutlinedButton(
                    onPressed: () {
                      final nav = Navigator.of(context);
                      if (nav.canPop()) {
                        nav.popUntil((route) => route.isFirst);
                      }
                      setState(() => _signedIn = false);
                      _emitMeasure();
                    },
                    child: const Text(S.signOut),
                  ),
                ),
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
        final bottomInset = MediaQuery.viewPaddingOf(ctx).bottom;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _emitMeasure(sheetState: "open");
          Future<void>.delayed(const Duration(milliseconds: 450), () {
            if (mounted) _emitMeasure(sheetState: "open");
          });
        });
        return Padding(
          key: _sheetKey,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
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

  Widget _assetsTab(BuildContext context) {
    final colors = context.appColors;
    Widget entry({
      required String label,
      required IconData icon,
      bool showDivider = true,
    }) {
      return KeyedSubtree(
        key: _assetKeys[label],
        child: ListGroupRow(
          key: ValueKey("assets-entry-$label"),
          title: label,
          height: ListGroupRowHeight.h64,
          leading: KeyedSubtree(
            key: _assetIconKeys[label],
            child: ListGroupIcon(icon: icon),
          ),
          trailing: Icon(Icons.chevron_right, size: 24, color: colors.textMuted),
          showDivider: showDivider,
          onTap: () {},
        ),
      );
    }

    return ListView(
      padding: AppSpacing.shellListPadding,
      children: [
        ListGroup(
          children: [
            entry(label: S.wallet, icon: Icons.account_balance_wallet_outlined),
            entry(label: S.savings, icon: Icons.savings),
            entry(label: S.bankCredit, icon: Icons.credit_card_outlined),
            entry(
              label: S.personalDebts,
              icon: Icons.handshake_outlined,
              showDivider: false,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _emitMeasure());
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.appName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(S.appTagline),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => setState(() => _signedIn = true),
                child: const Text("Sign in (demo)"),
              ),
            ],
          ),
        ),
      );
    }

    final colors = context.appColors;
    final month = DateTime.now().month;
    final heroStyle = TextStyle(
      color: colors.success,
      fontWeight: FontWeight.w800,
      fontSize: 32,
      height: 40 / 32,
      fontFamily: "Nunito",
    );

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
                  key: _heroKey,
                  height: 98,
                  child: AppCard(
                    key: const ValueKey("overview-net-worth"),
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
                                  fontFamily: "Nunito",
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                key: _amountKey,
                                height: 40,
                                width: double.infinity,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: AnimatedMoneyText(
                                    amount: _netWorth,
                                    large: true,
                                    style: heroStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 24, color: colors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  key: const ValueKey("overview-month"),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
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
            _assetsTab(context),
          ],
        ),
      ),
      bottomNavigationBar: KeyedSubtree(
        key: _navKey,
        child: AppBottomNav(
          tabIndex: _tab,
          notificationBadge: 2,
          onTabSelected: (i) {
            setState(() => _tab = i);
            _emitMeasure();
          },
          onQuickAdd: _openQuickAdd,
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _emitMeasure();
  }
}
