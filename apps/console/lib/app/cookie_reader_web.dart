import 'package:web/web.dart' as web;

/// Reads a cookie the page may see (the CSRF token; the refresh cookie is
/// httpOnly and invisible here by design, ADR-010).
String? readCookie(String name) {
  for (final part in web.document.cookie.split(';')) {
    final i = part.indexOf('=');
    if (i > 0 && part.substring(0, i).trim() == name) {
      return Uri.decodeComponent(part.substring(i + 1).trim());
    }
  }
  return null;
}
