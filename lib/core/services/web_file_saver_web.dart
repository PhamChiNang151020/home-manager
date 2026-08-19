import "dart:convert";

import "package:web/web.dart" as web;

void saveTextFile({required String filename, required String content}) {
  final href = Uri.dataFromString(
    content,
    mimeType: "text/calendar",
    encoding: utf8,
  ).toString();
  final anchor = web.HTMLAnchorElement()
    ..href = href
    ..download = filename;
  web.document.body?.appendChild(anchor);
  anchor.click();
  web.document.body?.removeChild(anchor);
}
