import "dart:convert";
import "dart:js_interop";
import "dart:js_interop_unsafe";
import "dart:typed_data";

import "package:web/web.dart" as web;

/// Runs Tesseract.js OCR on [imageBytes] (JPEG/PNG). Prefers Vietnamese, falls
/// back to English if `vie` traineddata fails to load.
Future<String> recognizeReceiptText(Uint8List imageBytes) async {
  final tesseract = web.window.getProperty("Tesseract".toJS);
  if (tesseract.isUndefinedOrNull || !tesseract.isA<JSObject>()) {
    throw StateError("Tesseract.js chưa được tải. Kiểm tra CDN trong index.html.");
  }

  final recognize = (tesseract as JSObject).getProperty("recognize".toJS);
  if (!recognize.isA<JSFunction>()) {
    throw StateError("Tesseract.recognize không khả dụng.");
  }

  final dataUrl =
      "data:image/jpeg;base64,${base64Encode(imageBytes)}";

  try {
    return await _recognizeWithLang(recognize as JSFunction, dataUrl, "vie");
  } catch (_) {
    return _recognizeWithLang(recognize as JSFunction, dataUrl, "eng");
  }
}

Future<String> _recognizeWithLang(
  JSFunction recognize,
  String dataUrl,
  String lang,
) async {
  final promise =
      recognize.callAsFunction(null, dataUrl.toJS, lang.toJS) as JSPromise;
  final result = await promise.toDart;
  if (result == null || !result.isA<JSObject>()) {
    throw StateError("OCR không trả về kết quả.");
  }
  final data = (result as JSObject).getProperty("data".toJS);
  if (data == null || !data.isA<JSObject>()) {
    throw StateError("OCR thiếu trường data.");
  }
  final text = (data as JSObject).getProperty("text".toJS);
  final dartText = text.dartify();
  if (dartText is! String) {
    throw StateError("OCR text không hợp lệ.");
  }
  return dartText;
}
