import "package:flutter/animation.dart";

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 450);

  static const staggerStep = Duration(milliseconds: 40);
  static const staggerCap = 6;
}

abstract final class AppCurves {
  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const press = Curves.easeOut;
}
