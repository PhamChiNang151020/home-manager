import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_icons.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/electricity/reminder_banner.dart";
import "package:home_manager/features/shared/app_asset_icon.dart";

Home _homeWithPhotoDueToday() {
  final today = DateTime.now().day;
  return Home(
    id: "h1",
    name: "Nhà tôi",
    trackingMode: TrackingMode.meter,
    kwhRate: 3500,
    createdBy: "u1",
    photoDueDay: today,
  );
}

void main() {
  testWidgets("shows banner when photo due day is today", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(body: ReminderBanner(home: _homeWithPhotoDueToday())),
      ),
    );

    expect(find.text(S.bannerPhoto), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppAssetIcon && widget.assetPath == AppIcons.reminder,
      ),
      findsOneWidget,
    );
  });

  testWidgets("hides banner when no reminder day matches today", (
    tester,
  ) async {
    const home = Home(
      id: "h1",
      name: "Nhà tôi",
      trackingMode: TrackingMode.meter,
      kwhRate: 3500,
      createdBy: "u1",
      photoDueDay: 1,
      paydayDay: 2,
      remindDay: 3,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: const Scaffold(body: ReminderBanner(home: home)),
      ),
    );

    expect(find.text(S.bannerPhoto), findsNothing);
    expect(find.text(S.bannerPayday), findsNothing);
    expect(find.text(S.bannerRemind), findsNothing);
  });

  testWidgets("same-day reminders appear photo then payday then remind", (
    tester,
  ) async {
    final today = DateTime.now().day;
    final home = Home(
      id: "h1",
      name: "Nhà tôi",
      trackingMode: TrackingMode.meter,
      kwhRate: 3500,
      createdBy: "u1",
      photoDueDay: today,
      paydayDay: today,
      remindDay: today,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(body: ReminderBanner(home: home)),
      ),
    );

    final texts =
        tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data)
            .whereType<String>()
            .toList();
    expect(
      texts,
      containsAllInOrder([S.bannerPhoto, S.bannerPayday, S.bannerRemind]),
    );
  });
}
