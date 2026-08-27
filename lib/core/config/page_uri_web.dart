import "package:web/web.dart" as web;

Uri currentPageUri() {
  final href = web.window.location.href;
  final parsed = Uri.tryParse(href);
  if (parsed != null &&
      (parsed.scheme == "http" || parsed.scheme == "https") &&
      parsed.host.isNotEmpty) {
    return parsed;
  }
  return Uri.base;
}
