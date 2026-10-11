@TestOn('vm')
library;

import 'dart:convert';

import 'package:data/data.dart';
import 'package:data/src/db/database.dart'
    show
        AdminUnitsCompanion,
        AlertsCompanion,
        ReadingsCompanion,
        SubmissionFlagsCompanion,
        TestResultsCompanion,
        TestSessionsCompanion,
        WaterSourcesCompanion;
import 'package:domain/domain.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

const classII = 'ba9093d7-4551-54b4-9da1-3c14a7041644';
const classI = '1c8c532b-bc51-58ba-94f4-c9e9093073c8';
const ent = 'ad625def-3111-5ddd-835f-b24118d37f01'; // ABIM-ENT (seed)
const otherDistrict = 'd0000000-0000-4000-8000-000000000099';
const otherVillage = 'd0000000-0000-4000-8000-000000000098';

/// The P9 performance fixture: [sources] sources × [testsPerSource] tests
/// × 4 readings (50 × 10 × 4 = 2,000 readings), one test a week.
Future<void> buildFixture(
  AppDatabase db, {
  int sources = 50,
  int testsPerSource = 10,
  DateTime? now,
}) async {
  final today = now ?? fixedClock();
  await db.batch((b) {
    b.insert(
      db.adminUnits,
      AdminUnitsCompanion.insert(
        id: otherDistrict,
        level: 'district',
        name: 'Other',
        code: 'UG-OTHER',
      ),
    );
    b.insert(
      db.adminUnits,
      AdminUnitsCompanion.insert(
        id: otherVillage,
        level: 'village',
        name: 'Elsewhere',
        code: 'OTH-1',
        parentId: const Value(otherDistrict),
      ),
    );
    for (var s = 0; s < sources; s++) {
      final src = 'src-$s';
      b.insert(
        db.waterSources,
        WaterSourcesCompanion.insert(
          id: src,
          // Every tenth source is in another district.
          villageId: s % 10 == 9 ? otherVillage : ent,
          code: 'S-${s.toString().padLeft(3, '0')}',
          sourceType: 'borehole',
          name: Value('Source $s'),
          lat: Value(2.70 + s / 1000),
          lon: Value(33.60 + s / 1000),
          createdAtDevice: today,
          updatedAtDevice: today,
        ),
      );
      for (var t = 0; t < testsPerSource; t++) {
        final ses = 'ses-$s-$t';
        final res = 'res-$s-$t';
        final at = today.subtract(Duration(days: 7 * t + (s % 7)));
        // Source 0's latest test is unsafe under both profiles.
        final ph = s == 0 && t == 0 ? '9.6' : '7.1';
        b.insert(
          db.testSessions,
          TestSessionsCompanion.insert(
            id: ses,
            sourceId: src,
            referenceStandardId: classII,
            calibrated: true,
            testedAtDevice: at,
            collectorKey: Value('col-${s % 5}'),
            collectorSnapshot: Value(
              jsonEncode({
                'full_name': 'Collector ${s % 5}',
                'phone': '+2567000000${s % 5}',
              }),
            ),
          ),
        );
        b.insert(
          db.testResults,
          TestResultsCompanion.insert(
            id: res,
            sessionId: ses,
            overall: ph == '9.6' ? 'unsafe' : 'safe',
            standardId: classII,
            createdAtDevice: at,
          ),
        );
        for (final (code, unit, value, result) in [
          ('temp', '°C', '25', 'ok'),
          ('ph', 'pH', ph, ph == '9.6' ? 'high' : 'ok'),
          ('ec', 'µS/cm', '1000', 'ok'),
          // Safe under Class II (1500), unsafe under Class I (500).
          ('tds', 'mg/L', '800', 'ok'),
        ]) {
          b.insert(
            db.readings,
            ReadingsCompanion.insert(
              id: 'rd-$s-$t-$code',
              sessionId: ses,
              resultId: res,
              parameterCode: code,
              value: Value(value),
              unit: Value(unit),
              result: result,
            ),
          );
        }
      }
    }
  });
}

void main() {
  late AppDatabase db;
  late DashboardQueries dashboard;
  final now = fixedClock();
  final month = DashboardFilter(
    from: now.subtract(const Duration(days: 30)),
    to: now,
  );

  setUp(() async {
    db = memoryDb();
    await SeedImporter(
      db,
      clock: fixedClock,
    ).importBundle(await seedFromInfra());
    await buildFixture(db, now: now);
    dashboard = DashboardQueries(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('KPIs, overdue sources and collector activity', () async {
    await db
        .into(db.alerts)
        .insert(
          AlertsCompanion.insert(
            id: 'al-1',
            sourceId: 'src-0',
            triggerRule: 'unsafe',
            openedAt: now.subtract(const Duration(hours: 10)),
            acknowledgedAt: Value(now.subtract(const Duration(hours: 4))),
            status: const Value('acknowledged'),
          ),
        );
    final d = await dashboard.load(month);
    expect(d.sources, hasLength(50));
    expect(d.testedInPeriod, 50);
    expect(d.unsafeInPeriod, 1);
    expect(d.unsafeShare, closeTo(0.02, 1e-9));
    expect(d.openAlerts, 1);
    expect(d.medianTimeToAcknowledge, const Duration(hours: 6));
    expect(d.collectors, hasLength(5));
    expect(d.collectors.first.submissions, greaterThan(0));
    // Source 0 had an unsafe result: weekly retests, so it is due.
    final s0 = d.sources.firstWhere((s) => s.id == 'src-0');
    expect(s0.schedule.mode, ScheduleMode.afterAbnormal);
    expect(s0.latest!.overall, OverallStatus.unsafe);
    expect(s0.latest!.collectorName, 'Collector 0');
  });

  test('an area shows only its sources', () async {
    final ent = await dashboard.load(
      DashboardFilter(
        from: month.from,
        to: month.to,
        areaId: 'd6c106a8-75c2-5da8-84a2-d31674be7a9a',
      ),
    );
    expect(ent.sources, hasLength(45));
    final other = await dashboard.load(
      DashboardFilter(from: month.from, to: month.to, areaId: otherDistrict),
    );
    expect(other.sources.map((s) => s.villageId).toSet(), {otherVillage});
  });

  test(
    'switching the profile changes what is shown, never what is stored',
    () async {
      Future<List<String>> stored() async => [
        for (final r in await db.select(db.testResults).get())
          '${r.id}:${r.overall}',
        for (final r in await db.select(db.readings).get())
          '${r.id}:${r.result}',
      ];
      final before = await stored();

      final asCollected = await dashboard.load(month);
      final safe = asCollected.sources.where(
        (s) => s.latest!.overall == OverallStatus.safe,
      );
      expect(safe, hasLength(49));
      expect(asCollected.sources.first.latest!.reEvaluated, isFalse);
      expect(asCollected.profileCode, isNull);

      final underClassI = await dashboard.load(
        DashboardFilter(from: month.from, to: month.to, profileId: classI),
      );
      // TDS 800 exceeds Class I (500): every source is now unsafe.
      expect(underClassI.unsafeInPeriod, 50);
      expect(underClassI.profileCode, 'US201-2008-ClassI');
      final shown = underClassI.sources.first.latest!;
      expect(
        (shown.reEvaluated, shown.profileCode),
        (true, 'US201-2008-ClassI'),
      );

      expect(
        await stored(),
        before,
        reason: 'stored results are never changed',
      );
    },
  );

  test('flagged submissions are marked', () async {
    await db
        .into(db.submissionFlags)
        .insert(
          SubmissionFlagsCompanion.insert(
            id: 'fl-1',
            resultId: 'res-1-0',
            reason: 'copied values',
            createdAtDevice: now,
          ),
        );
    final d = await dashboard.load(month);
    expect(
      d.sources.firstWhere((s) => s.id == 'src-1').latest!.flagged,
      isTrue,
    );
  });

  test(
    'performance: 50 sources and 2,000 readings load in under 2 s',
    () async {
      expect((await db.select(db.readings).get()).length, 2000);
      final watch = Stopwatch()..start();
      await dashboard.load(month);
      final asCollected = watch.elapsed;
      watch.reset();
      await dashboard.load(
        DashboardFilter(from: month.from, to: month.to, profileId: classI),
      );
      final reEvaluated = watch.elapsed;
      // ignore: avoid_print
      print('dashboard: as collected $asCollected, re-evaluated $reEvaluated');
      expect(asCollected, lessThan(const Duration(seconds: 2)));
      expect(reEvaluated, lessThan(const Duration(seconds: 2)));
    },
  );
}
