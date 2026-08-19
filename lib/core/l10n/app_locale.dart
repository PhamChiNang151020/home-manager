import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

abstract final class AppLocale {
  static const locale = Locale("vi");

  static const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const supportedLocales = [Locale("vi"), Locale("en")];
}
