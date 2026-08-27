import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";
import "package:home_manager/features/settings/settings_members_page.dart";
import "package:qr_flutter/qr_flutter.dart";

void main() {
  testWidgets("owner join QR shows scan hint and actions", (tester) async {
    var copied = false;
    var regenerated = false;
    var revoked = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.light,
          accent: AppAccent.amber,
        ),
        home: Scaffold(
          body: JoinQrSection(
            joinUrl: "https://example.test/home-manager/join.html?join=abc123",
            expiresAt: DateTime(2026, 9, 8),
            busy: false,
            onCopy: () => copied = true,
            onRegenerate: () => regenerated = true,
            onRevoke: () => revoked = true,
          ),
        ),
      ),
    );

    expect(find.text(S.joinQrHint), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      find.text("https://example.test/home-manager/join.html?join=abc123"),
      findsNothing,
    );

    await tester.tap(find.text(S.joinQrCopy));
    await tester.pump();
    expect(copied, isTrue);

    await tester.tap(find.text(S.joinQrRegenerate));
    await tester.pump();
    expect(regenerated, isTrue);

    await tester.tap(find.text(S.joinQrRevoke));
    await tester.pump();
    expect(revoked, isTrue);
  });
}
