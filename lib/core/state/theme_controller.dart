import "package:flutter/material.dart";
import "package:home_manager/core/theme/app_accent.dart";
import "package:shared_preferences/shared_preferences.dart";

class ThemeController extends ChangeNotifier {
  ThemeController._({
    required ThemeMode mode,
    required AppAccent accent,
    required bool glass,
  }) : _mode = mode,
       _accent = accent,
       _glass = glass;

  static const _modeKey = "theme_mode";
  static const _accentKey = "theme_accent";
  static const _glassKey = "theme_glass";

  ThemeMode _mode;
  AppAccent _accent;
  bool _glass;

  ThemeMode get mode => _mode;
  AppAccent get accent => _accent;
  bool get glass => _glass;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_modeKey);
    final accentName = prefs.getString(_accentKey);
    return ThemeController._(
      mode: _parseMode(modeName),
      accent: AppAccent.fromStorage(accentName),
      // Glass upgrade ships off by default until UX/perf sign-off.
      glass: prefs.getBool(_glassKey) ?? false,
    );
  }

  static ThemeMode _parseMode(String? value) {
    return switch (value) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _modeToStorage(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      ThemeMode.system => "system",
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _modeToStorage(mode));
  }

  Future<void> setAccent(AppAccent accent) async {
    if (_accent == accent) return;
    _accent = accent;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentKey, accent.storageKey);
  }

  Future<void> setGlass(bool glass) async {
    if (_glass == glass) return;
    _glass = glass;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_glassKey, glass);
  }
}
