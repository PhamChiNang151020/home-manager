import "package:flutter/material.dart";
import "package:home_manager/core/models/lock_settings.dart";
import "package:home_manager/core/services/lock_service.dart";
import "package:shared_preferences/shared_preferences.dart";

class LockController extends ChangeNotifier {
  LockController._(this._service, this._settings, this._isLocked);

  final LockService _service;
  LockSettings _settings;
  bool _isLocked;

  LockSettings get settings => _settings;
  bool get isLocked => _isLocked;
  bool get hasPinSet => _service.hasPinSet;
  bool get enabled => _settings.enabled && hasPinSet;
  int get pinLength => _service.pinLength;

  static Future<LockController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LockService(prefs);
    final settings = service.loadSettings();
    final locked = settings.enabled && service.hasPinSet;
    return LockController._(service, settings, locked);
  }

  Future<void> enableWithPin(String pin) async {
    await _service.setPin(pin);
    await _service.setEnabled(true);
    _settings = _settings.copyWith(enabled: true);
    _isLocked = false;
    await _service.updateLastActive();
    notifyListeners();
  }

  Future<void> changePin(String pin) async {
    await _service.setPin(pin);
    notifyListeners();
  }

  Future<void> disable() async {
    await _service.clearPin();
    _settings = _settings.copyWith(enabled: false);
    _isLocked = false;
    notifyListeners();
  }

  Future<void> setAutoLockDuration(AutoLockDuration duration) async {
    await _service.setAutoLockDuration(duration);
    _settings = _settings.copyWith(autoLockDuration: duration);
    notifyListeners();
  }

  bool unlock(String pin) {
    if (!_service.verifyPin(pin)) return false;
    _isLocked = false;
    _service.updateLastActive();
    notifyListeners();
    return true;
  }

  void lockNow() {
    if (!enabled) return;
    _isLocked = true;
    notifyListeners();
  }

  Future<void> onPaused() async {
    if (!enabled) return;
    await _service.updateLastActive();
  }

  void onResumed() {
    if (!enabled) return;
    final last = _service.lastActive();
    if (last == null) {
      _isLocked = true;
      notifyListeners();
      return;
    }
    final elapsed = DateTime.now().difference(last);
    final threshold = _settings.autoLockDuration.duration;
    if (elapsed >= threshold) {
      _isLocked = true;
      notifyListeners();
    }
  }
}
