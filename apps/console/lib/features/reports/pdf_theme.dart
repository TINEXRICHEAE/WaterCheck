import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Fonts, colours and icons for the PDFs (P10). The text font is embedded,
/// so a report renders the same on every device and works offline.
class PdfKit {
  PdfKit._(this.theme);

  final pw.ThemeData theme;

  static PdfKit? _cached;

  static Future<PdfKit> load() async {
    if (_cached case final k?) return k;
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );
    return _cached = PdfKit._(pw.ThemeData.withFont(base: regular, bold: bold));
  }

  // Status colours (as in the apps); the word is always printed too.
  static const unsafe = PdfColor.fromInt(0xFFB3261E);
  static const caution = PdfColor.fromInt(0xFF8A5A00);
  static const safe = PdfColor.fromInt(0xFF1E6B34);
  static const neutral = PdfColor.fromInt(0xFF5F6368);
  static const line = PdfColor.fromInt(0xFFDADCE0);

  // Icons as vector paths (Material Icons, Apache 2.0, 24×24). The icon
  // font cannot be used: the PDF library reads it without a Unicode map.
  static const warning = 'M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z';
  static const checkCircle =
      'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 '
      '15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z';
  static const help =
      'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 '
      '17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 '
      '1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H8c0-2.21 '
      '1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z';
  static const info =
      'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 '
      '15h-2v-6h2v6zm0-8h-2V7h2v2z';
  static const waterDrop = 'M12 2s-7 8-7 13a7 7 0 0 0 14 0c0-5-7-13-7-13z';
  static const fire =
      'M13.5.67s.74 2.65.74 4.8c0 2.06-1.35 3.73-3.41 3.73-2.07 0-3.63-1.67-3.63-3.73'
      'l.03-.36C5.21 7.51 4 10.62 4 14c0 4.42 3.58 8 8 8s8-3.58 8-8C20 8.61 17.41 3.8 '
      '13.5.67zM11.71 19c-1.78 0-3.22-1.4-3.22-3.14 0-1.62 1.05-2.76 2.81-3.12 1.77-.36 '
      '3.6-1.21 4.62-2.58.39 1.29.59 2.65.59 4.04 0 2.65-2.15 4.8-4.8 4.8z';
  static const swap =
      'M6.99 11L3 15l3.99 4v-3H14v-2H6.99v-3zM21 9l-3.99-4v3H10v2h7.01v3L21 9z';
  static const container =
      'M3 2l2.01 18.23C5.13 21.23 5.97 22 7 22h10c1.03 0 1.87-.77 1.99-1.77L21 2H3zm9 '
      '17c-1.66 0-3-1.34-3-3 0-2 3-5.4 3-5.4s3 3.4 3 5.4c0 1.66-1.34 3-3 3zm6.33-11'
      'H5.67l-.44-4h13.53l-.43 4z';

  static pw.Widget icon(String path, {double size = 24, PdfColor? color}) {
    final hex = (color ?? PdfColors.black).toHex();
    return pw.SvgImage(
      svg:
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
          '<path fill="$hex" d="$path"/></svg>',
      width: size,
      height: size,
    );
  }
}
