import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import '../alerts/alerts_screen.dart' show triggerText;
import 'pdf_theme.dart';

/// The area report (F-RPT-3, F-RPT-6): summary, limit sets used, impact
/// indicators, sources with their latest values, alerts and what was done,
/// and the limitations statement. Made on the device (SPEC P10).
Future<Uint8List> reportPdf({
  required AppLocalizations l10n,
  required ReportData r,
}) async {
  final kit = await PdfKit.load();
  final day = DateFormat('d MMM y');
  final when = DateFormat('d MMM y HH:mm');
  final i = r.indicators;
  String pct(int n, int total) =>
      total == 0 ? '-' : '${(100 * n / total).round()}%';
  String duration(Duration? d) => d == null
      ? '-'
      : d.inHours >= 48
      ? l10n.durationDays(d.inDays)
      : d.inMinutes >= 120
      ? l10n.durationHours(d.inHours)
      : l10n.durationMinutes(d.inMinutes);

  PdfColor statusColor(OverallStatus? s) => switch (s) {
    OverallStatus.unsafe => PdfKit.unsafe,
    OverallStatus.inconclusive => PdfKit.caution,
    OverallStatus.safe => PdfKit.safe,
    null => PdfKit.neutral,
  };

  pw.Widget heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    ),
  );

  final table = pw.TextStyle(fontSize: 8.5);
  final tableHead = pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold);

  final doc = pw.Document(theme: kit.theme, title: l10n.reportTitle)
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${l10n.reportTitle} · ${r.areaName}',
              style: const pw.TextStyle(fontSize: 8, color: PdfKit.neutral),
            ),
            pw.Text(
              l10n.reportPage(ctx.pageNumber, ctx.pagesCount),
              style: const pw.TextStyle(fontSize: 8, color: PdfKit.neutral),
            ),
          ],
        ),
        build: (_) => [
          pw.Row(
            children: [
              PdfKit.icon(PdfKit.waterDrop, size: 22, color: PdfKit.neutral),
              pw.SizedBox(width: 6),
              pw.Text(
                l10n.reportTitle,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(l10n.reportArea(r.areaName)),
          pw.Text(
            l10n.reportPeriod(
              day.format(r.filter.from.toLocal()),
              day.format(r.filter.to.toLocal()),
            ),
          ),
          pw.Text(
            l10n.reportGenerated(when.format(r.generatedAt.toLocal())),
            style: const pw.TextStyle(color: PdfKit.neutral, fontSize: 9),
          ),

          heading(l10n.reportProfiles),
          if (r.profiles.isEmpty) pw.Text(l10n.reportNone),
          for (final p in r.profiles)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    l10n.reportProfileLine(p.code, p.title, p.version),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  if (p.isProvisional)
                    pw.Text(l10n.reportProvisional, style: table),
                  if (p.isCustom)
                    pw.Text(
                      l10n.reportCustom(
                        p.basedOnCode ?? '-',
                        p.customReason ?? '-',
                      ),
                      style: table,
                    ),
                  for (final c in p.changedLimits)
                    pw.Bullet(text: c, style: table),
                ],
              ),
            ),

          heading(l10n.reportIndicators),
          pw.TableHelper.fromTextArray(
            headers: [l10n.colIndicator, l10n.colValue, '%'],
            headerStyle: tableHead,
            data: [
              [
                l10n.indSourcesTested,
                l10n.indOf(i.sourcesTested, i.sourcesTotal),
                pct(i.sourcesTested, i.sourcesTotal),
              ],
              [l10n.indTests, '${i.testsInPeriod}', ''],
              [
                l10n.indAbnormalAction,
                l10n.indOf(i.abnormalWithAction, i.abnormalTests),
                pct(i.abnormalWithAction, i.abnormalTests),
              ],
              [
                l10n.indOnSchedule,
                l10n.indOf(i.sourcesOnSchedule, i.sourcesWithSchedule),
                pct(i.sourcesOnSchedule, i.sourcesWithSchedule),
              ],
              [l10n.indCollectors, '${i.collectorsActive}', ''],
              [l10n.indAck, duration(i.medianTimeToAcknowledge), ''],
            ],
            cellStyle: const pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(color: PdfKit.line),
            columnWidths: {
              0: const pw.FlexColumnWidth(4),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
            },
          ),

          heading(l10n.reportSources),
          pw.TableHelper.fromTextArray(
            headers: [
              l10n.colSource,
              l10n.colVillage,
              l10n.colLastTest,
              l10n.colStatus,
              l10n.colReadings,
            ],
            data: [
              for (final s in r.sources)
                [
                  s.name == null ? s.code : '${s.name}\n${s.code}',
                  s.village,
                  s.testedAt == null ? '-' : day.format(s.testedAt!.toLocal()),
                  l10n.statusWord(s.overall?.name ?? 'none'),
                  s.readings
                      .map(
                        (x) =>
                            '${x.parameterName}: ${x.value ?? '-'} ${x.unit}'
                            '${x.limit == null ? '' : ' (${x.limit})'}'
                            '${x.result.isAbnormal ? ' ${l10n.readingResult(x.result.code)}' : ''}',
                      )
                      .join('\n'),
                ],
            ],
            headerStyle: tableHead,
            cellStyle: table,
            cellDecoration: (index, data, row) => index == 3 && row > 0
                ? pw.BoxDecoration(
                    color: _tint(statusColor(r.sources[row - 1].overall)),
                  )
                : const pw.BoxDecoration(),
            border: pw.TableBorder.all(color: PdfKit.line),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.2),
              1: const pw.FlexColumnWidth(1.6),
              2: const pw.FlexColumnWidth(1.6),
              3: const pw.FlexColumnWidth(1.4),
              4: const pw.FlexColumnWidth(4.5),
            },
          ),

          heading(l10n.reportAlerts),
          if (r.alerts.isEmpty) pw.Text(l10n.reportNoAlerts),
          if (r.alerts.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: [
                l10n.colOpened,
                l10n.colSource,
                l10n.colAlert,
                l10n.colStatus,
                l10n.colActions,
              ],
              data: [
                for (final a in r.alerts)
                  [
                    when.format(a.openedAt.toLocal()),
                    a.sourceName == null
                        ? a.sourceCode
                        : '${a.sourceName}\n${a.sourceCode}',
                    '${triggerText(l10n, a.rule)}\n${a.severity}',
                    a.status,
                    a.actions.isEmpty ? '-' : a.actions.join('\n'),
                  ],
              ],
              headerStyle: tableHead,
              cellStyle: table,
              border: pw.TableBorder.all(color: PdfKit.line),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.6),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(4),
              },
            ),

          heading(l10n.reportLimitations),
          pw.Text(
            l10n.reportLimitationsText,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  return doc.save();
}

/// A light tint of a status colour, for table cells (dark text stays legible).
PdfColor _tint(PdfColor c, [double amount = 0.18]) => PdfColor(
  1 - (1 - c.red) * amount,
  1 - (1 - c.green) * amount,
  1 - (1 - c.blue) * amount,
);
