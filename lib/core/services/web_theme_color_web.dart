import "package:flutter/material.dart";
import "package:web/web.dart" as web;

void updateWebThemeColor(Color color) {
  final hex =
      "#${color.toARGB32().toRadixString(16).padLeft(8, "0").substring(2)}";
  var meta = web.document.querySelector('meta[name="theme-color"]');
  if (meta == null) {
    meta =
        web.HTMLMetaElement()
          ..name = "theme-color"
          ..content = hex;
    web.document.head?.appendChild(meta);
  } else {
    meta.setAttribute("content", hex);
  }
}
