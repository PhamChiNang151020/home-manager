import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_loading.dart";
import "package:home_manager/features/shared/app_refresh_indicator.dart";

Widget _host(Future<void> Function() onRefresh) {
  return MaterialApp(
    theme: AppTheme.build(brightness: Brightness.dark, accent: AppAccent.amber),
    home: Scaffold(
      body: AppRefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(children: const [SizedBox(height: 1200)]),
      ),
    ),
  );
}

void main() {
  test("every pull-to-refresh goes through AppRefreshIndicator", () {
    // A page building its own indicator is how the branded loader gets lost
    // and Material's default comes back.
    final bare = RegExp(
      r"\b(RefreshIndicator|CustomMaterialIndicator|CustomRefreshIndicator)\(",
    );
    final offenders = <String>[];
    for (final entity in Directory("lib").listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith(".dart")) continue;
      if (entity.path.endsWith("app_refresh_indicator.dart")) continue;
      if (bare.hasMatch(entity.readAsStringSync())) {
        offenders.add(entity.path);
      }
    }
    expect(offenders, isEmpty);
  });

  testWidgets("pulling down shows the branded overlay, not a top spinner", (
    tester,
  ) async {
    final completer = Completer<void>();
    await tester.pumpWidget(_host(() => completer.future));

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AppLoadingScrim), findsOneWidget);
    expect(find.byType(AppLoader), findsOneWidget);
    expect(
      tester.widget<AppLoader>(find.byType(AppLoader)).size,
      AppLoadingScrim.loaderSize,
    );
    expect(find.byType(RefreshProgressIndicator), findsNothing);

    completer.complete();
    await tester.pump();
    expect(find.byType(AppLoadingScrim), findsNothing);
  });
}
