import "dart:developer" as developer;

import "package:flutter/foundation.dart";

abstract final class AppLog {
  static const _name = "home_manager";

  static void d(
    String message, {
    String name = _name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    developer.log(
      message,
      name: name,
      level: 500,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void i(
    String message, {
    String name = _name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    developer.log(
      message,
      name: name,
      level: 800,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void w(
    String message, {
    String name = _name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    developer.log(
      message,
      name: name,
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void e(
    String message, {
    String name = _name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    developer.log(
      message,
      name: name,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
