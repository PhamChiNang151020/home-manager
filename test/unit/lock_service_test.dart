import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/services/lock_service.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test("hashPin is stable and not plaintext", () async {
    final a = LockService.hashPin("1234");
    final b = LockService.hashPin("1234");
    expect(a, b);
    expect(a, isNot("1234"));
    expect(a.length, 64);
  });

  test("setPin verifyPin and clearPin", () async {
    final prefs = await SharedPreferences.getInstance();
    final service = LockService(prefs);
    expect(service.hasPinSet, isFalse);
    await service.setPin("5678");
    expect(service.hasPinSet, isTrue);
    expect(service.pinLength, 4);
    expect(service.verifyPin("5678"), isTrue);
    expect(service.verifyPin("0000"), isFalse);
    await service.clearPin();
    expect(service.hasPinSet, isFalse);
  });

  test("legacy PIN without pin_length defaults to 4", () async {
    SharedPreferences.setMockInitialValues({
      LockService.pinHashKey: LockService.hashPin("1234"),
      LockService.lockEnabledKey: true,
    });
    final prefs = await SharedPreferences.getInstance();
    final service = LockService(prefs);
    expect(service.pinLength, LockService.legacyPinLength);
    expect(service.verifyPin("1234"), isTrue);
  });

  test("setPin stores digit length for 6-digit PIN", () async {
    final prefs = await SharedPreferences.getInstance();
    final service = LockService(prefs);
    await service.setPin("123456");
    expect(service.pinLength, 6);
    expect(service.verifyPin("123456"), isTrue);
  });
}
