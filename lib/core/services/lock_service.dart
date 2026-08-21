import "dart:convert";

import "package:crypto/crypto.dart";
import "package:home_manager/core/models/lock_settings.dart";
import "package:shared_preferences/shared_preferences.dart";

class LockService {
  LockService(this._prefs);

  final SharedPreferences _prefs;

  static const pinHashKey = "pin_hash";
  static const pinLengthKey = "pin_length";
  static const lockEnabledKey = "lock_enabled";
  static const autoLockDurationKey = "auto_lock_duration";
  static const lastActiveTimestampKey = "last_active_timestamp";

  /// Legacy default before length was persisted (old app used 4 digits).
  static const legacyPinLength = 4;

  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  bool get hasPinSet {
    final hash = _prefs.getString(pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  /// Digits expected on the lock screen for the stored PIN.
  int get pinLength {
    if (!hasPinSet) return legacyPinLength;
    return _prefs.getInt(pinLengthKey) ?? legacyPinLength;
  }

  LockSettings loadSettings() {
    return LockSettings(
      enabled: _prefs.getBool(lockEnabledKey) ?? false,
      autoLockDuration: AutoLockDuration.fromStorage(
        _prefs.getString(autoLockDurationKey),
      ),
    );
  }

  Future<void> setPin(String pin) async {
    await _prefs.setString(pinHashKey, hashPin(pin));
    await _prefs.setInt(pinLengthKey, pin.length);
  }

  bool verifyPin(String pin) {
    final stored = _prefs.getString(pinHashKey);
    if (stored == null || stored.isEmpty) return false;
    return stored == hashPin(pin);
  }

  Future<void> clearPin() async {
    await _prefs.remove(pinHashKey);
    await _prefs.remove(pinLengthKey);
    await _prefs.setBool(lockEnabledKey, false);
  }

  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(lockEnabledKey, enabled);
  }

  Future<void> setAutoLockDuration(AutoLockDuration duration) async {
    await _prefs.setString(autoLockDurationKey, duration.storageKey);
  }

  Future<void> updateLastActive([DateTime? at]) async {
    final ts = (at ?? DateTime.now()).millisecondsSinceEpoch;
    await _prefs.setInt(lastActiveTimestampKey, ts);
  }

  DateTime? lastActive() {
    final ms = _prefs.getInt(lastActiveTimestampKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
