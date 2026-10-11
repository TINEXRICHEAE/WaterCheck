@TestOn('vm')
library;

import 'package:data/data.dart';
import 'package:data/src/db/database.dart'
    show AlertEventsCompanion, AlertsCompanion, TestResultsCompanion;
import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';

import 'dashboard_test.dart' show buildFixture, ent;
import 'support/fixtures.dart';

/// The P10 gate: the report's numbers equal independent database queries
/// (50 sources × 10 tests × 4 readings), and the CSV matches its filter.
void main() {
  late AppDatabase db;
  late ReportQueries reports;
  final now = fixedClock();
  final month = ReportFilter(
    from: now.subtract(const Duration(days: 30)),
    to: now,
  );

  Future<int> count(String sql, [List<Object> args = const []]) async =>
      (await db
              .customSelect(sql, variables: [for (final a in args) Variable(a)])
              .getSingle())
          .read<int>('n');

  setUp(() async {
    db = memoryDb();
    await SeedImporter(
      db,
      clock: fixedClock,
    ).importBundle(await seedFromInfra());
    await buildFixture(db, now: now);
    // Two alerts on the fixture's unsafe result: "unsafe" records an
    // action, "baseline_jump" only an acknowledgement.
    final unsafe = await db
        .customSelect(
          "SELECT r.id, s.source_id FROM test_results r "
          "JOIN test_sessions s ON s.id = r.session_id WHERE r.overall = 'unsafe' "
          'ORDER BY s.tested_at_device DESC LIMIT 1',
        )
        .getSingle();
    for (final (i, rule) in ['unsafe', 'baseline_jump'].indexed) {
      await db
          .into(db.alerts)
          .insert(
            AlertsCompanion.insert(
              id: 'al-$i',
              sourceId: unsafe.read<String>('source_id'),
              triggerResultId: Value(unsafe.read<String>('id')),
              triggerRule: rule,
              openedAt: now.subtract(Duration(days: 2 + i)),
            ),
          );
      await db
          .into(db.alertEvents)
          .insert(
            AlertEventsCompanion.insert(
              id: 'ev-$i',
              alertId: 'al-$i',
              eventType: i == 0 ? 'action_taken' : 'acknowledged',
              note: const Value('{"actions":["advise_boil"]}'),
              occurredAtDevice: now,
            ),
          );
    }
    reports = ReportQueries(db, clock: () => now);
  });
  tearDown(() => db.close());

  // Results that count: not replaced by a correction, tested in the period,
  // of an active source.
  const effective =
      'FROM test_results r JOIN test_sessions s ON s.id = r.session_id '
      'JOIN water_sources w ON w.id = s.source_id '
      'WHERE w.is_active = 1 AND s.tested_at_device BETWEEN ? AND ? '
      'AND NOT EXISTS (SELECT 1 FROM test_results x WHERE x.amendment_of = r.id)';
  List<Object> period() => [
    month.from.toIso8601String(),
    month.to.toIso8601String(),
  ];

  test('report numbers match database queries', () async {
    final r = await reports.report(month);
    final i = r.indicators;
    expect(
      i.sourcesTotal,
      await count(
        'SELECT count(*) AS n FROM water_sources WHERE is_active = 1',
      ),
    );
    expect(
      i.testsInPeriod,
      await count('SELECT count(*) AS n $effective', period()),
    );
    expect(
      i.sourcesTested,
      await count(
        'SELECT count(DISTINCT s.source_id) AS n $effective',
        period(),
      ),
    );
    expect(
      i.abnormalTests,
      await count(
        "SELECT count(*) AS n $effective AND coalesce((SELECT c.overall "
        "FROM classifications c WHERE c.result_id = r.id AND c.standard_id = "
        "r.standard_id AND c.computed_by = 'server'), r.overall) = 'unsafe'",
        period(),
      ),
    );
    expect(i.abnormalTests, greaterThan(0));
    expect(
      i.abnormalWithAction,
      await count(
        "SELECT count(DISTINCT r.id) AS n $effective AND r.overall = 'unsafe' "
        'AND EXISTS (SELECT 1 FROM alerts a JOIN alert_events e ON e.alert_id = a.id '
        'WHERE a.trigger_result_id = r.id AND e.event_type IN '
        "('action_taken', 'action_in_progress', 'closed'))",
        period(),
      ),
    );
    expect(i.abnormalWithAction, 1);
    expect(
      i.collectorsActive,
      await count(
        'SELECT count(DISTINCT s.collector_key) AS n $effective',
        period(),
      ),
    );
    expect(r.sources, hasLength(i.sourcesTotal));
    expect(r.alerts, hasLength(2));
    expect(r.alerts.first.actions.single, startsWith('acknowledged'));
    expect(r.profiles.map((p) => p.code), isNotEmpty);
    // The latest test's readings come with their limits.
    final tested = r.sources.firstWhere((s) => s.testedAt != null);
    expect(tested.readings, hasLength(4));
    expect(
      tested.readings.firstWhere((x) => x.parameterCode == 'ph').limit,
      '6.5–8.5 pH',
    );
  });

  test(
    'a correction replaces what it corrects in the report and the CSV',
    () async {
      final before = await reports.report(month);
      final old = await db
          .customSelect(
            'SELECT r.id, r.session_id, r.standard_id FROM test_results r '
            'JOIN test_sessions s ON s.id = r.session_id ORDER BY s.tested_at_device DESC LIMIT 1',
          )
          .getSingle();
      await db
          .into(db.testResults)
          .insert(
            TestResultsCompanion.insert(
              id: 'fix-1',
              sessionId: old.read<String>('session_id'),
              overall: 'safe',
              standardId: old.read<String>('standard_id'),
              computedBy: const Value('device'),
              amendmentOf: Value(old.read<String>('id')),
              amendmentReason: const Value('typo'),
              createdAtDevice: now,
            ),
          );
      final after = await reports.report(month);
      expect(after.indicators.testsInPeriod, before.indicators.testsInPeriod);
      final csv = await reports.readingsCsv(month);
      expect(csv.contains(old.read<String>('id')), isFalse);
    },
  );

  test('CSV: one row per reading in the filter, with typed columns', () async {
    final csv = await reports.readingsCsv(month);
    expect(
      csv.startsWith('﻿'),
      isTrue,
      reason: 'UTF-8 marked for spreadsheets',
    );
    final lines = csv.substring(1).trimRight().split('\n');
    final header = lines.first.split(',');
    expect(
      header,
      containsAll([
        'tested_at_utc',
        'value',
        'standard_code',
        'standard_version',
      ]),
    );
    final rows = lines.skip(1).map((l) => l.split(',')).toList();
    expect(
      rows,
      hasLength(
        await count(
          'SELECT count(*) AS n FROM readings g JOIN test_results r ON r.id = g.result_id '
          'JOIN test_sessions s ON s.id = r.session_id JOIN water_sources w ON w.id = s.source_id '
          'WHERE w.is_active = 1 AND s.tested_at_device BETWEEN ? AND ? '
          'AND NOT EXISTS (SELECT 1 FROM test_results x WHERE x.amendment_of = r.id)',
          period(),
        ),
      ),
    );
    final at = header.indexOf('tested_at_utc');
    final value = header.indexOf('value');
    final version = header.indexOf('standard_version');
    for (final r in rows) {
      expect(r, hasLength(header.length));
      expect(DateTime.parse(r[at]).isUtc, isTrue);
      expect(
        double.tryParse(r[value]),
        isNotNull,
        reason: 'numeric value: ${r[value]}',
      );
      expect(int.tryParse(r[version]), isNotNull);
    }
    // One area: only its sources.
    final one = await reports.readingsCsv(
      ReportFilter(areaId: ent, from: month.from, to: month.to),
    );
    final oneRows = one.substring(1).trimRight().split('\n').length - 1;
    expect(oneRows, lessThan(rows.length));
    expect(oneRows, greaterThan(0));
  });
}
