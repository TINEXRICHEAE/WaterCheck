import 'package:ui_kit/ui_kit.dart';

import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import 'pdf_theme.dart';

/// Community notice for one source (F-ALR-5): status, what to do and the
/// values, in large type with icons, for A4 or A5 (SPEC P10).
Future<Uint8List> noticePdf({
  required AppLocalizations l10n,
  required ReportSource source,
  required PdfPageFormat format,
  required DateTime printedAt,
}) async {
  final kit = await PdfKit.load();
  final small = format.width < PdfPageFormat.a4.width - 1;
  final scale = small ? 0.75 : 1.0;
  double pt(double v) => v * scale;
  final (color, icon, headline) = switch (source.overall) {
    OverallStatus.unsafe => (
      PdfKit.unsafe,
      PdfKit.warning,
      l10n.noticeHeadlineUnsafe,
    ),
    OverallStatus.inconclusive => (
      PdfKit.caution,
      PdfKit.help,
      l10n.noticeHeadlineCaution,
    ),
    OverallStatus.safe => (
      PdfKit.safe,
      PdfKit.checkCircle,
      l10n.noticeHeadlineSafe,
    ),
    null => (PdfKit.neutral, PdfKit.info, l10n.noticeHeadlineNotTested),
  };
  final notSafe = source.overall != OverallStatus.safe;
  final germTested = source.readings.any(
    (r) => r.parameterCode == 'ecoli' && r.result == ReadingResult.ok,
  );
  final day = DateFormat('d MMMM y');

  pw.Widget step(String i, String text) => pw.Padding(
    padding: pw.EdgeInsets.only(bottom: pt(10)),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        PdfKit.icon(i, size: pt(30), color: color),
        pw.SizedBox(width: pt(12)),
        pw.Expanded(
          child: pw.Text(text, style: pw.TextStyle(fontSize: pt(20))),
        ),
      ],
    ),
  );

  final doc = pw.Document(theme: kit.theme, title: l10n.noticeTitle)
    ..addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(pt(32)),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              children: [
                pw.Image(kit.logo, width: pt(32), height: pt(32)),
                pw.SizedBox(width: pt(8)),
                pw.Text(
                  l10n.noticeTitle.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: pt(18),
                    fontWeight: pw.FontWeight.bold,
                    color: PdfKit.neutral,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: pt(8)),
            pw.Text(
              source.name ?? source.code,
              style: pw.TextStyle(
                fontSize: pt(30),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              [
                source.code,
                if (source.village.isNotEmpty) source.village,
              ].join(' · '),
              style: pw.TextStyle(fontSize: pt(16)),
            ),
            pw.SizedBox(height: pt(14)),
            // The status: icon + words + colour, never colour alone.
            pw.Container(
              padding: pw.EdgeInsets.all(pt(16)),
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(pt(10)),
              ),
              child: pw.Row(
                children: [
                  PdfKit.icon(icon, size: pt(56), color: PdfColors.white),
                  pw.SizedBox(width: pt(14)),
                  pw.Expanded(
                    child: pw.Text(
                      headline,
                      style: pw.TextStyle(
                        fontSize: pt(28),
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (source.testedAt case final at?)
              pw.Padding(
                padding: pw.EdgeInsets.only(top: pt(6)),
                child: pw.Text(
                  l10n.noticeTested(day.format(WcTime.local(at))),
                  style: pw.TextStyle(fontSize: pt(16)),
                ),
              ),
            pw.SizedBox(height: pt(18)),
            pw.Text(
              l10n.noticeWhatToDo,
              style: pw.TextStyle(
                fontSize: pt(24),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: pt(8)),
            if (notSafe) ...[
              step(PdfKit.fire, l10n.noticeBoil),
              step(PdfKit.swap, l10n.noticeOtherSource),
            ],
            step(PdfKit.container, l10n.noticeContainers),
            if (!notSafe) step(PdfKit.info, l10n.noticeReportChange),
            if (source.readings.isNotEmpty) ...[
              pw.SizedBox(height: pt(8)),
              pw.Text(
                l10n.noticeMeasured,
                style: pw.TextStyle(
                  fontSize: pt(18),
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: pt(4)),
              pw.TableHelper.fromTextArray(
                headers: [
                  l10n.pdfColParameter,
                  l10n.pdfColValue,
                  l10n.pdfColLimit,
                  l10n.pdfColResult,
                ],
                data: [
                  for (final r in source.readings)
                    [
                      r.parameterName,
                      r.value == null ? '-' : '${r.value} ${r.unit}'.trim(),
                      r.limit ?? '-',
                      l10n.readingResult(r.result.code),
                    ],
                ],
                headerStyle: pw.TextStyle(
                  fontSize: pt(15),
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(fontSize: pt(15)),
                border: pw.TableBorder.all(color: PdfKit.line),
                cellPadding: pw.EdgeInsets.all(pt(4)),
              ),
            ],
            pw.Spacer(),
            pw.Text(
              germTested
                  ? l10n.noticeLimitationGermNegative
                  : l10n.noticeLimitationNoGermTest,
              style: pw.TextStyle(
                fontSize: pt(15),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: pt(6)),
            pw.Text(l10n.noticeContact, style: pw.TextStyle(fontSize: pt(14))),
            pw.SizedBox(height: pt(4)),
            pw.Text(
              l10n.noticePrinted(day.format(WcTime.local(printedAt))),
              style: pw.TextStyle(fontSize: pt(10), color: PdfKit.neutral),
            ),
          ],
        ),
      ),
    );
  return doc.save();
}
