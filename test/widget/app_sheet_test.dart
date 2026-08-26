import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_sheet.dart";

const _headerKey = Key("sheet-header");
const _statusBar = 59.0;

void main() {
  testWidgets("a full-height sheet keeps its header below the status bar", (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: _statusBar);
    addTearDown(tester.view.reset);

    late BuildContext pageContext;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: Builder(
          builder: (context) {
            pageContext = context;
            return const Scaffold();
          },
        ),
      ),
    );

    // A ListView takes every pixel the sheet offers, so this is the tall-form
    // case that used to slide under the Dynamic Island.
    unawaited(
      showAppSheet<void>(
        context: pageContext,
        builder:
            (_) => ListView(
              children: const [SizedBox(key: _headerKey, height: 40)],
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byKey(_headerKey)).top,
      greaterThanOrEqualTo(_statusBar),
    );
  });

  test("every sheet goes through showAppSheet", () {
    // Bypassing the helper is how a sheet ends up under the status bar, or
    // drawing a second drag handle of its own.
    final offenders = <String>[];
    for (final entity in Directory("lib").listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith(".dart")) continue;
      if (entity.path.endsWith("app_sheet.dart")) continue;
      if (entity.readAsStringSync().contains("showModalBottomSheet")) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty);
  });

  test("sheets share one drag handle style", () {
    for (final brightness in Brightness.values) {
      final sheet =
          AppTheme.build(
            brightness: brightness,
            accent: AppAccent.amber,
          ).bottomSheetTheme;
      expect(sheet.dragHandleSize, const Size(40, 4), reason: brightness.name);
      expect(sheet.dragHandleColor, isNotNull, reason: brightness.name);
    }
  });
}
