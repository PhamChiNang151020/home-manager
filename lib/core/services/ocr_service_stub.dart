import "dart:typed_data";

/// Stub for non-web platforms / unit tests.
bool get isReceiptOcrSupported => false;

Future<String> recognizeReceiptText(Uint8List imageBytes) async {
  throw UnsupportedError("OCR is only available on Flutter Web.");
}
