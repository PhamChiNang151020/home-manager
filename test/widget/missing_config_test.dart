import "package:flutter_test/flutter_test.dart";
import "package:home_manager/app.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/state/theme_controller.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets("missing config screen", (tester) async {
    final theme = await ThemeController.load();
    await tester.pumpWidget(MissingConfigApp(theme: theme));
    expect(find.text(S.missingConfig), findsOneWidget);
  });
}
