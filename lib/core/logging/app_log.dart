import "dart:developer" as developer;

import "package:flutter/foundation.dart";

/// Debug-only logger. Lines go to `debugPrint` (Chrome / Debug Console) and
/// `dart:developer` (Dart observatory). Silent in release.
abstract final class AppLog {
  static const _name = "home_manager";
  static const _inTest = bool.fromEnvironment("FLUTTER_TEST");

  /// Test hook. When set, [d]/[i]/[w]/[e] write formatted lines here only.
  @visibleForTesting
  static void Function(String line)? sink;

  /// Test hook for stable timestamps.
  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  static void d(
    String message, {
    String name = _name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _emit(
      tag: "D",
      level: 500,
      message: message,
      name: name,
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
    _emit(
      tag: "I",
      level: 800,
      message: message,
      name: name,
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
    _emit(
      tag: "W",
      level: 900,
      message: message,
      name: name,
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
    _emit(
      tag: "E",
      level: 1000,
      message: message,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Route Flutter framework and uncaught async errors through [e].
  static void bindFlutterErrors() {
    FlutterError.onError = (details) {
      e(
        details.exceptionAsString(),
        error: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      e("Uncaught", error: error, stackTrace: stack);
      return false;
    };
  }

  static String _line({
    required String tag,
    required String message,
    required String name,
    Object? error,
  }) {
    final t = now();
    final ts =
        "${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}.${_three(t.millisecond)}";
    final core = "$ts [$name] $tag $message";
    if (error == null) return core;
    return "$core | $error";
  }

  static String _two(int n) => n.toString().padLeft(2, "0");

  static String _three(int n) => n.toString().padLeft(3, "0");

  static void _emit({
    required String tag,
    required int level,
    required String message,
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    final line = _line(tag: tag, message: message, name: name, error: error);
    final testSink = sink;
    if (testSink != null) {
      testSink(line);
      return;
    }
    if (!_inTest) {
      debugPrint(line);
      if (stackTrace != null && level >= 900) {
        debugPrint(stackTrace.toString());
      }
    }
    developer.log(
      message,
      name: name,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
