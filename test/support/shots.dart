import "dart:io";

import "package:flutter/services.dart";

/// Screenshot capture is off unless both env vars are set:
/// - `HM_SHOTS=1`
/// - `HM_SHOTS_DIR=<writable directory>`
///
/// No absolute machine paths. Callers must not fall back to `/cursor` or `$HOME`.
bool get hmShotsEnabled => Platform.environment["HM_SHOTS"] == "1";

String? get hmShotsDir {
  final dir = Platform.environment["HM_SHOTS_DIR"];
  if (dir == null || dir.trim().isEmpty) return null;
  return dir;
}

bool get shouldCaptureShots => hmShotsEnabled && hmShotsDir != null;

/// Nunito is declared in pubspec. MaterialIcons for golden/toImage harnesses
/// load from the committed repo asset (not `$HOME/flutter/...`).
Future<void> loadShotFonts() async {
  final nunito =
      FontLoader("Nunito")
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Regular.ttf"))
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Medium.ttf"))
        ..addFont(
          rootBundle.load("assets/fonts/Nunito/static/Nunito-SemiBold.ttf"),
        )
        ..addFont(rootBundle.load("assets/fonts/Nunito/static/Nunito-Bold.ttf"))
        ..addFont(
          rootBundle.load("assets/fonts/Nunito/static/Nunito-ExtraBold.ttf"),
        );
  await nunito.load();
  final material =
      FontLoader("MaterialIcons")
        ..addFont(rootBundle.load("assets/fonts/MaterialIcons-Regular.otf"));
  await material.load();
}

void writeShotBytes(String fileName, List<int> bytes) {
  final dir = hmShotsDir;
  if (dir == null) {
    throw StateError("HM_SHOTS_DIR is required when HM_SHOTS=1");
  }
  final folder = Directory(dir);
  if (!folder.existsSync()) folder.createSync(recursive: true);
  File("$dir/$fileName").writeAsBytesSync(bytes);
}

void writeShotText(String fileName, String text) {
  final dir = hmShotsDir;
  if (dir == null) {
    throw StateError("HM_SHOTS_DIR is required when HM_SHOTS=1");
  }
  final folder = Directory(dir);
  if (!folder.existsSync()) folder.createSync(recursive: true);
  File("$dir/$fileName").writeAsStringSync(text);
}
