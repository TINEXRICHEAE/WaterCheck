final _ugMobile = RegExp(r'^\+256[1-9]\d{8}$');

/// Normalises a Ugandan phone number to `+256XXXXXXXXX`, or returns null if
/// it is not valid (SPEC §2.1: phone is required and its format validated).
///
/// Accepts `0772 123456`, `+256 772 123 456`, `256772123456` and similar;
/// spaces, dashes and brackets are ignored.
String? normalizeUgandaPhone(String input) {
  var digits = input.replaceAll(RegExp(r'[\s\-().]'), '');
  if (digits.startsWith('00256')) digits = '+${digits.substring(2)}';
  if (digits.startsWith('256')) digits = '+$digits';
  if (digits.startsWith('0') && digits.length == 10) {
    digits = '+256${digits.substring(1)}';
  }
  return _ugMobile.hasMatch(digits) ? digits : null;
}
