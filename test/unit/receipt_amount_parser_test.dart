import "package:flutter_test/flutter_test.dart";
import "package:home_manager/core/domain/receipt_amount_parser.dart";

void main() {
  test("picks amount near Tổng cộng", () {
    const text = """
Cơm tấm
45.000
Nước
15.000
Tổng cộng
125.000
Cảm ơn
""";
    expect(parseReceiptAmount(text), 125000);
  });

  test("picks amount near Thành tiền", () {
    const text = """
SP001  20.000
SP002  30.000
Thành tiền: 1,250,000
""";
    expect(parseReceiptAmount(text), 1250000);
  });

  test("picks amount near Total case-insensitive", () {
    const text = "Item A 10.000\nTOTAL 99.000\n";
    expect(parseReceiptAmount(text), 99000);
  });

  test("falls back to largest amount without keyword", () {
    const text = """
Dòng 1 12.000
Dòng 2 45.000
Dòng 3 8.000
""";
    expect(parseReceiptAmount(text), 45000);
  });

  test("returns null when no amounts", () {
    expect(parseReceiptAmount("Cảm ơn quý khách"), isNull);
    expect(parseReceiptAmount(""), isNull);
  });

  test("ignores tiny numbers", () {
    const text = "VAT 8\nSL 2\nTổng 40.000";
    expect(parseReceiptAmount(text), 40000);
  });
}
