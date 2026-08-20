import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/models/home.dart";
import "package:home_manager/core/models/tracking_mode.dart";
import "package:home_manager/core/models/water_period.dart";
import "package:home_manager/core/services/electricity_service.dart";
import "package:home_manager/core/services/water_service.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/water/water_form.dart";
import "package:mocktail/mocktail.dart";

class MockWaterService extends Mock implements WaterService {}

class MockBillPhotoService extends Mock implements BillPhotoService {}

const _meterHome = Home(
  id: "h1",
  name: "Nhà tôi",
  trackingMode: TrackingMode.meter,
  kwhRate: 3500,
  m3Rate: 10000,
  createdBy: "u1",
);

const _invoiceHome = Home(
  id: "h2",
  name: "Nhà ba mẹ",
  trackingMode: TrackingMode.invoice,
  kwhRate: 3500,
  createdBy: "u1",
);

void main() {
  late MockWaterService water;
  late MockBillPhotoService photos;

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(_meterHome.id);
  });

  setUp(() {
    water = MockWaterService();
    photos = MockBillPhotoService();
  });

  Future<void> pumpAddForm(
    WidgetTester tester, {
    required Home home,
    List<WaterPeriod> existingPeriods = const [],
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed:
                      () => showWaterAddForm(
                        context: context,
                        home: home,
                        water: water,
                        photos: photos,
                        existingPeriods: existingPeriods,
                        onSaved: () {},
                      ),
                  child: const Text("Open"),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();
  }

  testWidgets(
    "meter form shows invalidReadings when new m3 less than previous",
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpAddForm(tester, home: _meterHome);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), "120");
      await tester.enterText(fields.at(1), "100");
      await tester.ensureVisible(find.widgetWithText(FilledButton, S.save));
      await tester.tap(find.widgetWithText(FilledButton, S.save));
      await tester.pump();

      expect(find.text(S.invalidReadings), findsOneWidget);
      verifyZeroInteractions(water);
    },
  );

  testWidgets("invoice form shows invalidAmount for zero amount", (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpAddForm(tester, home: _invoiceHome);

    await tester.enterText(find.byType(TextField).first, "0");
    await tester.ensureVisible(find.widgetWithText(FilledButton, S.save));
    await tester.tap(find.widgetWithText(FilledButton, S.save));
    await tester.pump();

    expect(find.text(S.invalidAmount), findsOneWidget);
    verifyZeroInteractions(water);
  });

  testWidgets("meter form shows duplicate hint for existing month", (
    tester,
  ) async {
    final existing = [
      WaterPeriod(
        id: "p1",
        homeId: "h1",
        periodMonth: DateTime(DateTime.now().year, DateTime.now().month),
        amountVnd: 70000,
        recordedAt: DateTime.now(),
      ),
    ];

    await pumpAddForm(tester, home: _meterHome, existingPeriods: existing);

    expect(find.text(S.duplicateWaterPeriodHint), findsOneWidget);
  });
}
