import 'dart:convert';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:watercheck_console/features/reports/notice_pdf.dart';
import 'package:watercheck_console/features/reports/report_pdf.dart';
import 'package:watercheck_console/l10n/app_localizations.dart';

import 'support/harness.dart';

final l10nForTests = lookupAppLocalizations(const Locale('en'));
final _now = DateTime.utc(2026, 10, 11, 9);

ReportSource sourceForTests(OverallStatus? overall) => (
  id: 's-1',
  code: 'ABIM-ENT-001',
  name: 'Main borehole',
  village: 'Entebbe',
  functionalStatus: 'functional',
  testedAt: overall == null ? null : _now,
  overall: overall,
  profileCode: 'US201-2008-ClassII',
  schedule: ScheduleStatus.ok,
  readings: [
    (
      parameterCode: 'ph',
      parameterName: 'pH',
      value: '9.4',
      unit: 'pH',
      result: ReadingResult.high,
      limit: '6.5–8.5 pH',
    ),
  ],
);

ReportData sampleReport() => ReportData(
  areaName: 'Abim',
  filter: ReportFilter(from: _now.subtract(const Duration(days: 30)), to: _now),
  generatedAt: _now,
  sources: [sourceForTests(OverallStatus.unsafe), sourceForTests(null)],
  alerts: [
    (
      sourceCode: 'ABIM-ENT-001',
      sourceName: 'Main borehole',
      rule: 'unsafe',
      severity: 'high',
      status: 'closed',
      openedAt: _now,
      acknowledgedAt: _now,
      closedAt: _now,
      actions: const ['acknowledged', 'closed: borehole chlorinated'],
    ),
  ],
  profiles: const [
    (
      code: 'US201-2008-ClassII',
      title: 'US 201:2008 Class II',
      version: 1,
      isCustom: false,
      isProvisional: true,
      customReason: null,
      basedOnCode: null,
      changedLimits: <String>[],
    ),
  ],
  indicators: (
    sourcesTotal: 2,
    sourcesTested: 1,
    testsInPeriod: 1,
    abnormalTests: 1,
    abnormalWithAction: 1,
    sourcesOnSchedule: 1,
    sourcesWithSchedule: 1,
    collectorsActive: 1,
    medianTimeToAcknowledge: const Duration(hours: 3),
  ),
);

String _text(List<int> pdf) => latin1.decode(pdf, allowInvalid: true);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'community notice: a valid one-page PDF on A4 and A5, every status',
    () async {
      for (final format in [PdfPageFormat.a4, PdfPageFormat.a5]) {
        for (final status in [...OverallStatus.values, null]) {
          final pdf = await noticePdf(
            l10n: l10nForTests,
            source: sourceForTests(status),
            format: format,
            printedAt: _now,
          );
          expect(_text(pdf).startsWith('%PDF-'), isTrue);
          // One page by construction (pw.Page); the font is embedded (subset).
          expect(pdf.length, greaterThan(5000));
          expect(_text(pdf), contains('Roboto'));
        }
      }
    },
  );

  test('report: a valid PDF with the fonts embedded', () async {
    final r = sampleReport();
    final pdf = await reportPdf(l10n: l10nForTests, r: r);
    final text = _text(pdf);
    expect(text.startsWith('%PDF-'), isTrue);
    expect(text, contains('Roboto'), reason: 'embedded font, renders offline');
  });

  testWidgets('the Reports tab offers the PDF report and the CSV', (
    tester,
  ) async {
    final env = ConsoleTestEnv(cookieMode: true);
    env.api.sessionFor('admin@example.org');
    final db = await pumpConsole(tester, env: env);
    await tester.tap(find.text('Reports').last);
    await settle(tester);
    expect(find.text('Reports and exports'), findsOneWidget);
    expect(find.text('PDF report'), findsOneWidget);
    expect(find.text('Readings (CSV)'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
    // Reports are judged as collected: no limit-set selector.
    expect(find.text('Judge results by'), findsNothing);
    await disposeConsole(tester, db);
  });
}
