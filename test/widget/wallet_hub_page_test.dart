import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/l10n/strings.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:home_manager/core/theme/app_theme.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("wallet hub copy is available", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(
          brightness: Brightness.dark,
          accent: AppAccent.amber,
        ),
        home: const Scaffold(
          body: Column(
            children: [
              Text(S.wallet),
              Text(S.walletTotal),
              Text(S.walletSectionCredit),
              Text(S.walletSectionDebts),
              Text(S.noWallets),
            ],
          ),
        ),
      ),
    );

    expect(find.text(S.wallet), findsOneWidget);
    expect(find.text(S.walletSectionCredit), findsOneWidget);
    expect(find.text(S.walletSectionDebts), findsOneWidget);
  });
}
