import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/labeled_text_field.dart";

void main() {
  testWidgets("LabeledDropdownField opens sheet and reports selection", (
    tester,
  ) async {
    var selected = "a";
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return LabeledDropdownField<String>(
                label: "Danh mục",
                value: selected,
                items: [
                  SelectOption(value: "a", builder: (_) => const Text("Một")),
                  SelectOption(value: "b", builder: (_) => const Text("Hai")),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => selected = value);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text("Một"), findsOneWidget);
    await tester.tap(find.text("Một"));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(2));
    await tester.tap(find.text("Hai").last);
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
    expect(find.text("Hai"), findsOneWidget);
    expect(selected, "b");
  });

  testWidgets("dismissing select sheet does not change value", (tester) async {
    var selected = "a";
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: LabeledDropdownField<String>(
            label: "Danh mục",
            value: selected,
            items: [
              SelectOption(value: "a", builder: (_) => const Text("Một")),
              SelectOption(value: "b", builder: (_) => const Text("Hai")),
            ],
            onChanged: (value) {
              if (value != null) selected = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text("Một"));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ModalBarrier).last);
    await tester.pumpAndSettle();

    expect(selected, "a");
    expect(find.text("Một"), findsOneWidget);
  });
}
