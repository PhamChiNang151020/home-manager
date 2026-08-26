import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/app_glass_surface.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("ThemeController defaults glass off", () async {
    SharedPreferences.setMockInitialValues({});
    final theme = await ThemeController.load();
    expect(theme.glass, isFalse);

    await theme.setGlass(true);
    expect(theme.glass, isTrue);

    final again = await ThemeController.load();
    expect(again.glass, isTrue);
  });

  testWidgets("AppGlassSurface is opaque Material when glass is off", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: const Scaffold(body: AppGlassSurface(child: Text("panel"))),
      ),
    );

    expect(find.text("panel"), findsOneWidget);
    expect(find.byType(Material), findsWidgets);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets("AppGlassSurface.light has no BackdropFilter when glass is on", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
          glass: true,
        ),
        home: const Scaffold(
          body: AppGlassSurface.light(child: Text("light")),
        ),
      ),
    );

    expect(find.text("light"), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets("default AppGlassSurface maps to light (no blur)", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
          glass: true,
        ),
        home: const Scaffold(body: AppGlassSurface(child: Text("default"))),
      ),
    );

    expect(find.text("default"), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets("AppGlassSurface.blurred uses BackdropFilter when glass is on", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
          glass: true,
        ),
        home: const Scaffold(
          body: AppGlassSurface.blurred(child: Text("frost")),
        ),
      ),
    );

    expect(find.text("frost"), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
