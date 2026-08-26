import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/shared/bill_photo_pick_field.dart";

/// Smallest valid PNG so `Image.memory` can decode it in tests.
final _pngBytes = Uint8List.fromList([
  137, 80, 78, 71, 13, 10, 26, 10, //
  0, 0, 0, 13, 73, 72, 68, 82,
  0, 0, 0, 1, 0, 0, 0, 1,
  8, 6, 0, 0, 0, 31, 21, 196, 137,
  0, 0, 0, 10, 73, 68, 65, 84,
  120, 156, 99, 0, 1, 0, 0, 5, 0, 1,
  13, 10, 45, 180,
  0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
]);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.build(brightness: Brightness.dark, accent: AppAccent.amber),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets("states the file constraint before a photo is picked", (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(BillPhotoPickField(bytes: null, onChanged: (_) {})),
    );

    expect(find.text(S.pickPhoto), findsOneWidget);
    expect(find.text(S.photoConstraintHint), findsOneWidget);
    expect(find.text(S.removePhoto), findsNothing);
  });

  testWidgets("previews the picked photo and can drop it", (tester) async {
    Uint8List? current = _pngBytes;
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return BillPhotoPickField(
              bytes: current,
              onChanged: (bytes) => setState(() => current = bytes),
            );
          },
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text(S.photoSelected), findsOneWidget);
    expect(find.text(S.pickPhotoReplace), findsOneWidget);

    await tester.tap(find.text(S.removePhoto));
    await tester.pump();

    expect(current, isNull);
    expect(find.byType(Image), findsNothing);
    expect(find.text(S.photoConstraintHint), findsOneWidget);
  });
}
