import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/bank_brand.dart";

void main() {
  test("resolves common Vietnamese bank names to VietQR codes", () {
    expect(BankBrand.codeForName("Vietcombank"), "VCB");
    expect(BankBrand.codeForName("VCB"), "VCB");
    expect(BankBrand.codeForName("Techcombank"), "TCB");
    expect(BankBrand.codeForName("MB Bank"), "MB");
    expect(BankBrand.codeForName("VietinBank"), "ICB");
    expect(BankBrand.codeForName("BIDV"), "BIDV");
  });

  test("unknown bank returns null", () {
    expect(BankBrand.codeForName("Ngân hàng XYZ"), isNull);
    expect(BankBrand.codeForName(""), isNull);
  });

  test("logoUrl uses VietQR CDN", () {
    expect(
      BankBrand.logoUrlForName("Vietcombank"),
      "https://api.vietqr.io/img/VCB.png",
    );
  });

  test("popular banks have resolvable codes", () {
    for (final bank in BankBrand.popular) {
      expect(BankBrand.codeForName(bank.name), bank.code);
    }
  });
}
