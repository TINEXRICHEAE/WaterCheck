@TestOn('vm')
library;

import 'dart:convert';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

void main() {
  late AppDatabase db;
  late SeedBundle seed;
  late DriftReferenceDataRepository reference;
  late DriftSourceRepository sources;
  late DriftTestingRepository testing;

  setUpAll(() async => seed = await seedFromInfra());

  setUp(() async {
    db = memoryDb();
    await SeedImporter(db, clock: fixedClock).importBundle(seed);
    reference = DriftReferenceDataRepository(db, clock: fixedClock);
    sources = DriftSourceRepository(db, clock: fixedClock);
    testing = DriftTestingRepository(db, clock: fixedClock);
  });
  tearDown(() => db.close());

  Future<int> outboxCount() async => (await db.select(db.outbox).get()).length;

  Future<WaterSource> borehole() => sources.create(
    const NewSource(
      villageId: 'village-1',
      code: 'ABIM-ENT-001',
      sourceType: 'borehole',
      location: GeoPoint(lat: 2.7, lon: 33.6, accuracyM: 8),
    ),
    origin,
  );

  Future<
    ({
      ReferenceProfile profile,
      List<ReadingInput> readings,
      ClassificationResult result,
    })
  >
  coreTest({String tds = '560'}) async {
    final profile = (await reference.referenceProfiles()).firstWhere(
      (p) => p.code == 'US201-2008-ClassII',
    );
    final readings = [
      ReadingInput(
        parameterCode: 'temp',
        unit: '°C',
        value: Decimal.parse('25'),
      ),
      ReadingInput(
        parameterCode: 'ph',
        unit: 'pH',
        value: Decimal.parse('7.1'),
      ),
      ReadingInput(
        parameterCode: 'ec',
        unit: 'µS/cm',
        value: Decimal.parse('800'),
      ),
      ReadingInput(
        parameterCode: 'tds',
        unit: 'mg/L',
        value: Decimal.parse(tds),
      ),
    ];
    final classifier = Classifier(
      catalogue: await reference.catalogue(),
      rules: await reference.rules(),
    );
    return (
      profile: profile,
      readings: readings,
      result: classifier.classify(readings: readings, profile: profile),
    );
  }

  group('seed import', () {
    test('imports the bundled reference data', () async {
      final catalogue = await reference.catalogue();
      expect(catalogue.parameters.length, 42);
      expect(catalogue.core.map((p) => p.code), ['temp', 'ph', 'ec', 'tds']);
      expect((await reference.rules()).requiredParameters, hasLength(4));
      final profiles = await reference.referenceProfiles();
      expect(profiles.map((p) => p.code), [
        'US201-2008-ClassI',
        'US201-2008-ClassII',
      ]);
      expect(profiles.every((p) => p.isProvisional), isTrue);
      expect(
        (await reference.testerProfiles()).single.parameterCodes,
        hasLength(4),
      );
      expect(
        (await reference.adminUnits()).map((u) => u.level),
        contains('village'),
      );
      expect((await reference.lists())['source_types'], isNotEmpty);
      expect(await db.select(db.responseCards).get(), hasLength(3));
    });

    test('re-import is skipped; a higher version is imported again', () async {
      expect(await SeedImporter(db).importBundle(seed), isEmpty);
      final bumped = jsonDecode(jsonEncode(seed.rules)) as Map<String, Object?>;
      bumped['version'] = (seed.rules['version']! as int) + 1;
      bumped['required_parameters'] = ['ph', 'ec', 'tds'];
      final newer = SeedBundle(
        catalogue: seed.catalogue,
        rules: bumped,
        lists: seed.lists,
        testerProfiles: seed.testerProfiles,
        referenceProfiles: seed.referenceProfiles,
        responseCards: seed.responseCards,
        responsibilities: seed.responsibilities,
        adminUnits: seed.adminUnits,
      );
      expect(await SeedImporter(db).importBundle(newer), ['rules']);
      expect((await reference.rules()).requiredParameters, hasLength(3));
    });

    test('a broken seed document is rejected and nothing is written', () async {
      final fresh = memoryDb();
      final broken = SeedBundle(
        catalogue: seed.catalogue,
        rules: {'version': 1},
        lists: seed.lists,
        testerProfiles: seed.testerProfiles,
        referenceProfiles: seed.referenceProfiles,
        responseCards: seed.responseCards,
        responsibilities: seed.responsibilities,
        adminUnits: seed.adminUnits,
      );
      await expectLater(
        SeedImporter(fresh).importBundle(broken),
        throwsA(anything),
      );
      expect(await fresh.select(fresh.parameterDefinitions).get(), isEmpty);
      await fresh.close();
    });
  });

  group('outbox atomicity (P2 gate)', () {
    test(
      'a submitted test writes session, result, readings and outbox together',
      () async {
        final source = await borehole();
        final t = await coreTest();
        final before = await outboxCount();
        final ids = await testing.submit(
          TestSubmission(
            sourceId: source.id,
            profile: t.profile,
            calibrated: true,
            readings: t.readings,
            classification: t.result,
          ),
          origin,
        );
        expect(await outboxCount(), before + 1 + 1 + 4);
        final session = await (db.select(
          db.testSessions,
        )..where((s) => s.id.equals(ids.sessionId))).getSingle();
        expect(
          jsonDecode(session.collectorSnapshot!)['full_name'],
          'Example Collector',
        );
        expect(session.installationId, origin.installationId);
        final payload = jsonDecode(
          (await db.select(db.outbox).get())
              .firstWhere((o) => o.entity == 'test_session')
              .payload,
        ) as Map;
        expect(payload['tested_at_device'], '2026-10-10T09:00:00.000Z');
        expect(
          payload.containsKey('source_id'),
          isTrue,
          reason: 'snake_case keys',
        );
      },
    );

    test(
      'a failing write rolls back and leaves no orphaned outbox rows',
      () async {
        final source = await borehole();
        final t = await coreTest();
        final before = await outboxCount();
        final sessionsBefore = (await db.select(db.testSessions).get()).length;
        // A reading the classification does not cover makes the third write
        // fail after the session and result rows were already inserted.
        await expectLater(
          testing.submit(
            TestSubmission(
              sourceId: source.id,
              profile: t.profile,
              calibrated: true,
              readings: [
                ...t.readings,
                ReadingInput(
                  parameterCode: 'iron',
                  unit: 'mg/L',
                  value: Decimal.parse('0.1'),
                ),
              ],
              classification: t.result,
            ),
            origin,
          ),
          throwsArgumentError,
        );
        expect(await outboxCount(), before);
        expect(
          await db.select(db.testSessions).get(),
          hasLength(sessionsBefore),
        );
        expect(await db.select(db.testResults).get(), isEmpty);
        expect(await db.select(db.readings).get(), isEmpty);
      },
    );

    test('a foreign-key failure also leaves nothing behind', () async {
      final t = await coreTest();
      await expectLater(
        testing.submit(
          TestSubmission(
            sourceId: 'no-such-source',
            profile: t.profile,
            calibrated: true,
            readings: t.readings,
            classification: t.result,
          ),
          origin,
        ),
        throwsA(anything),
      );
      expect(await outboxCount(), 0);
    });
  });

  group('alerts', () {
    test(
      'an unsafe submission raises its alerts in the same transaction',
      () async {
        final source = await borehole();
        final t = await coreTest(tds: '1600');
        final before = await outboxCount();
        final ids = await testing.submit(
          TestSubmission(
            sourceId: source.id,
            profile: t.profile,
            calibrated: true,
            readings: t.readings,
            classification: t.result,
            alertTriggers: alertTriggers(t.result),
          ),
          origin,
        );
        expect(ids.alertIds, hasLength(1));
        expect(await outboxCount(), before + 1 + 1 + 4 + 1);
        final alerts = DriftAlertRepository(db, clock: fixedClock);
        final open = await alerts.watchOpen(sourceId: source.id).first;
        expect(open.single.triggerRule, 'unsafe');
        expect(open.single.severity, 'high');
        expect(open.single.status, AlertStatus.open);
        expect(
          (await alerts.forResult(ids.resultId)).single.id,
          ids.alertIds.single,
        );

        await alerts.recordActions(
          ids.alertIds.single,
          actions: ['Told people to boil water', 'Informed the VHT'],
          origin: origin,
        );
        final events = await alerts.events(ids.alertIds.single);
        expect(events.single.actions, hasLength(2));
        expect(events.single.byName, 'Example Collector');
        expect((await db.select(db.outbox).get()).last.entity, 'alert_event');
      },
    );

    test('safe history feeds the baseline check', () async {
      final source = await borehole();
      for (final tds in ['700', '690', '710']) {
        final t = await coreTest(tds: tds);
        await testing.submit(
          TestSubmission(
            sourceId: source.id,
            profile: t.profile,
            calibrated: true,
            readings: t.readings,
            classification: t.result,
          ),
          origin,
        );
      }
      final history = await testing.safeHistory(source.id);
      expect(history['tds'], hasLength(3));
      final trends = await testing.trends(source.id);
      expect(trends['tds']!.map((p) => p.value.toString()).toSet(), {
        '700',
        '690',
        '710',
      });
      expect(
        trends['tds']!.every((p) => p.overall == OverallStatus.safe),
        isTrue,
      );
      expect(history.containsKey('temp'), isTrue);
    });

    test('response cards are found by trigger', () async {
      final card = await reference.responseCard('unsafe');
      expect(card!['actions'], isNotEmpty);
      expect(await reference.responseCard('nothing'), isNull);
    });
  });

  group('sanitary inspections', () {
    test('are saved, queued and the latest is watched', () async {
      final source = await borehole();
      final repo = DriftInspectionRepository(db, clock: fixedClock);
      expect(await repo.watchLatest(source.id).first, isNull);
      await repo.save(source.id, {
        'latrine_30m': 'yes',
        'drainage_ok': 'yes',
      }, origin);
      final latest = await repo.watchLatest(source.id).first;
      expect(latest!.answers['latrine_30m'], 'yes');
      expect(
        (await db.select(db.outbox).get()).last.entity,
        'sanitary_inspection',
      );
      await expectLater(
        db.customStatement('DELETE FROM sanitary_inspections'),
        throwsA(anything),
      );
    });
  });

  group('immutability', () {
    test(
      'readings, results and sessions cannot be changed or deleted',
      () async {
        final source = await borehole();
        final t = await coreTest();
        final ids = await testing.submit(
          TestSubmission(
            sourceId: source.id,
            profile: t.profile,
            calibrated: true,
            readings: t.readings,
            classification: t.result,
          ),
          origin,
        );
        await expectLater(
          db.customStatement(
            "UPDATE readings SET value = '1' WHERE result_id = ?",
            [ids.resultId],
          ),
          throwsA(anything),
        );
        await expectLater(
          db.customStatement('DELETE FROM test_sessions'),
          throwsA(anything),
        );
        await expectLater(
          db.customStatement("UPDATE test_results SET overall = 'unsafe'"),
          throwsA(anything),
        );
        await expectLater(
          db.customStatement('DELETE FROM water_sources'),
          throwsA(anything),
        );
        // Recording the server sequence after sync is allowed.
        await db.customStatement('UPDATE readings SET server_seq = 42');
        expect(
          (await db.select(db.readings).get()).every((r) => r.serverSeq == 42),
          isTrue,
        );
      },
    );
  });

  group('amendments and history', () {
    test('an amendment is a new result with its own readings', () async {
      final source = await borehole();
      final t = await coreTest(tds: '1600');
      final ids = await testing.submit(
        TestSubmission(
          sourceId: source.id,
          profile: t.profile,
          calibrated: true,
          readings: t.readings,
          classification: t.result,
        ),
        origin,
      );
      final fixed = await coreTest(tds: '600');
      await expectLater(
        testing.amend(
          resultId: ids.resultId,
          readings: fixed.readings,
          classification: fixed.result,
          reason: ' ',
          origin: origin,
        ),
        throwsArgumentError,
      );
      final amendedId = await testing.amend(
        resultId: ids.resultId,
        readings: fixed.readings,
        classification: fixed.result,
        reason: 'Typed 600 as 1600',
        origin: origin,
      );
      final history = await testing.history(source.id);
      expect(history, hasLength(2));
      expect(history.map((h) => h.overall).toSet(), {
        OverallStatus.unsafe,
        OverallStatus.safe,
      });
      expect(
        history.firstWhere((h) => h.resultId == amendedId).isAmendment,
        isTrue,
      );
      // The correction's trail: what changed, from what to what, who, why.
      final trail = await TrailQueries(db).forTest(ids.sessionId);
      final tds = trail.singleWhere((e) => e.field == 'tds');
      expect((tds.oldValue, tds.newValue), ('1600', '600'));
      expect(tds.reason, 'Typed 600 as 1600');
      expect(tds.who, isNotNull);
      final overall = trail.singleWhere((e) => e.field == 'overall');
      expect((overall.oldValue, overall.newValue), ('unsafe', 'safe'));
      final row = await (db.select(
        db.testResults,
      )..where((r) => r.id.equals(amendedId))).getSingle();
      expect(row.collectorKey, origin.collectorKey);
      final detail = await testing.resultDetail(amendedId);
      expect(detail!.sourceId, source.id);
      expect(detail.amendmentOf, ids.resultId);
      expect(detail.readings, hasLength(4));
      expect(await testing.resultDetail('missing'), isNull);
      final effective = await testing.effectiveHistory(source.id);
      expect(effective, hasLength(1));
      expect(effective.single.resultId, amendedId);
      expect(effective.single.overall, OverallStatus.safe);
      final original = await testing.readingsOf(ids.resultId);
      final amended = await testing.readingsOf(amendedId);
      expect(
        original.firstWhere((r) => r.parameterCode == 'tds').value,
        Decimal.parse('1600'),
      );
      expect(
        amended.firstWhere((r) => r.parameterCode == 'tds').value,
        Decimal.parse('600'),
      );
    });

    test('a classification from another profile is refused', () async {
      final source = await borehole();
      final t = await coreTest();
      final classI = (await reference.referenceProfiles()).first;
      expect(
        () => testing.submit(
          TestSubmission(
            sourceId: source.id,
            profile: classI,
            calibrated: true,
            readings: t.readings,
            classification: t.result,
          ),
          origin,
        ),
        throwsArgumentError,
      );
    });
  });

  group('calibration', () {
    test('the latest calibration of this installation is returned', () async {
      expect(await testing.latestCalibration(origin.installationId!), isNull);
      final id = await testing.saveCalibration(
        const NewCalibration(
          referenceStandardId: 'p',
          passed: true,
          testerSerial: 'PEN-1',
          buffers: [
            {'ph': '7.00', 'read': '7.02'},
          ],
        ),
        origin,
      );
      final latest = await testing.latestCalibration(origin.installationId!);
      expect(latest!.id, id);
      expect(latest.passed, isTrue);
      expect(latest.performedAt, fixedClock());
      expect(await testing.latestCalibration('other'), isNull);
    });
  });

  group('sources', () {
    test('a typed village is added below the official sub-county, once, '
        'and queued for the server', () async {
      final places = PlaceRepository(db, clock: fixedClock);
      const area = (
        district: 'Jinja',
        subcounty: 'Butagaya',
        parish: 'Nawangoma',
        village: 'Kitanaba',
      );
      expect(await places.findVillage(area), isNull);
      final village = await places.ensureVillage(area, origin);
      expect(village.level, 'village');
      expect(village.name, 'Kitanaba');
      // Same names again (any spacing or case): the same place.
      final again = await places.ensureVillage((
        district: 'jinja',
        subcounty: 'butagaya ',
        parish: 'NAWANGOMA',
        village: ' kitanaba',
      ), origin);
      expect(again.id, village.id);
      final queued = await (db.select(
        db.outbox,
      )..where((o) => o.entity.equals('admin_unit'))).get();
      // The parish and the village; the sub-county is official.
      expect(queued, hasLength(2));
      expect(await places.findVillage(area), isNotNull);
      expect(
        () => places.ensureVillage((
          district: 'Nowhere',
          subcounty: 'x',
          parish: 'y',
          village: 'z',
        ), origin),
        throwsArgumentError,
      );
    });

    test('codes are short and random, and never one already used', () async {
      final code = await sources.suggestCode();
      expect(code, matches(RegExp(r'^WC-[2-9A-HJ-NP-Z]{5}$')));
      final codes = {for (var i = 0; i < 50; i++) await sources.suggestCode()};
      expect(codes.length, greaterThan(45));
    });

    test('edits are versioned and only changed fields are queued', () async {
      final source = await borehole();
      final updated = await sources.update(
        source.id,
        const SourceChanges(functionalStatus: 'broken'),
        origin,
      );
      expect(updated.version, 2);
      final row = (await db.select(db.outbox).get()).last;
      expect(row.op, 'update');
      expect(row.baseVersion, 1);
      final payload = jsonDecode(row.payload) as Map;
      expect(payload['functional_status'], 'broken');
      expect(payload.containsKey('name'), isFalse);

      final gone = await sources.deactivate(source.id, origin);
      expect(gone.isActive, isFalse);
      expect(await sources.watchSources().first, isEmpty);
      expect(
        await sources.watchSources(includeInactive: true).first,
        hasLength(1),
      );
    });
  });

  group('custom reference data', () {
    test('a new test starts with the nearest area default (D11)', () async {
      final units = await reference.adminUnits();
      final village = units.firstWhere((u) => u.level == 'village');
      expect(await reference.areaDefaultProfileId(village.id), isNull);
      final profile = (await reference.referenceProfiles()).first;
      // Set on an area above the village: the village inherits it.
      await db.customStatement(
        'UPDATE admin_units SET default_standard_id = ? WHERE id = ?',
        [profile.id, village.parentId],
      );
      expect(await reference.areaDefaultProfileId(village.id), profile.id);
    });

    test('a custom profile from calibration is stored and queued', () async {
      final base = (await reference.referenceProfiles()).last;
      final custom = base.customize(
        id: 'custom-1',
        code: 'CUSTOM-MN04',
        reason: 'Provisional manganese limit',
        overrides: [
          ParameterLimit(
            parameterCode: 'manganese',
            unit: 'mg/L',
            max: Decimal.parse('0.4'),
          ),
        ],
      );
      await reference.saveCustomProfile(custom, origin);
      final stored = await reference.referenceProfile('custom-1');
      expect(stored!.limitFor('manganese')!.max, Decimal.parse('0.4'));
      expect(stored.basedOnId, base.id);
      expect(
        (await db.select(db.outbox).get()).single.entity,
        'reference_standard',
      );
      expect(
        () => reference.saveCustomProfile(base, origin),
        throwsArgumentError,
      );
    });

    test('a custom parameter becomes part of the catalogue', () async {
      await reference.saveCustomParameter(
        const ParameterDefinition(
          code: 'custom:silica',
          name: 'Silica',
          categoryCode: 'chemical',
          defaultUnit: 'mg/L',
          valueType: ValueType.numeric,
          isCustom: true,
        ),
        origin,
      );
      expect((await reference.catalogue())['custom:silica'], isNotNull);
      expect(await outboxCount(), 1);
      // Re-importing the seed leaves user parameters alone.
      await SeedImporter(db).importBundle(seed);
      expect((await reference.catalogue())['custom:silica'], isNotNull);
    });
  });

  group('collector profiles', () {
    test('edits keep the key and bump the version', () async {
      final repo = DriftCollectorProfileRepository(db, clock: fixedClock);
      const input = CollectorProfileInput(
        fullName: ' Example Collector ',
        phone: '+256700000000',
        collectorType: 'vht',
        village: 'Entebbe',
        parish: 'P',
        subcounty: 'S',
        district: 'Abim',
      );
      final first = await repo.save(input);
      expect(first.fullName, 'Example Collector');
      final second = await repo.save(input, key: first.collectorKey);
      expect(second.collectorKey, first.collectorKey);
      expect(second.profileVersion, 2);
      expect(() => repo.save(input, key: 'unknown'), throwsArgumentError);
      await repo.deactivate(first.collectorKey);
      expect(await repo.watchActive().first, isEmpty);
    });

    test('saves are queued for the server with their details', () async {
      final repo = DriftCollectorProfileRepository(db, clock: fixedClock);
      const input = CollectorProfileInput(
        fullName: 'New Person',
        phone: '+256700000001',
        collectorType: 'vht',
        village: 'V',
        parish: 'P',
        subcounty: 'S',
        district: 'Abim',
        side: AppSide.research,
      );
      final made = await repo.save(input);
      await repo.save(input, key: made.collectorKey);
      await repo.send(made.collectorKey);
      final queued = await (db.select(
        db.outbox,
      )..where((o) => o.entity.equals('collector_profile'))).get();
      expect(queued.map((o) => o.op), ['insert', 'update', 'update']);
      final payload = jsonDecode(queued.first.payload) as Map;
      expect(payload['collector_key'], made.collectorKey);
      final snapshot = jsonDecode(payload['collector_snapshot'] as String);
      expect((snapshot as Map)['side'], 'research');
      expect(queued.map((o) => o.entityId).toSet(), {made.collectorKey});
      // Only profiles never queued are caught up.
      await repo.sendNeverSent();
      expect(
        await (db.select(
          db.outbox,
        )..where((o) => o.entity.equals('collector_profile'))).get(),
        hasLength(3),
      );
    });
  });

  group('local settings', () {
    test(
      'installation ID is created once; consent and values persist',
      () async {
        final settings = DriftLocalSettingsRepository(db, clock: fixedClock);
        final id = await settings.installationId();
        expect(await settings.installationId(), id);
        expect(await settings.consentVersion(), isNull);
        await settings.recordConsent(1);
        expect(await settings.consentVersion(), 1);
        await settings.write('collect.active_collector', 'abc');
        expect(await settings.read('collect.active_collector'), 'abc');
        await settings.write('collect.active_collector', null);
        expect(await settings.read('collect.active_collector'), isNull);
        // Local settings never reach the outbox.
        expect(await outboxCount(), 0);
      },
    );
  });

  group('outbox summary', () {
    test('counts pending items for the sync indicator', () async {
      final repo = DriftOutboxRepository(db);
      expect((await repo.watchSummary().first).pending, 0);
      await borehole();
      final summary = await repo.watchSummary().first;
      expect(summary.pending, 1);
      expect(summary.lastSuccessAt, isNull);
      expect(await repo.pending(), hasLength(1));
    });
  });

  test('alert IDs match the server (shared vector)', () {
    expect(
      alertIdFor('01a1aaaa-0000-7000-8000-000000000003', 'unsafe'),
      'e5a06055-3d8d-58a8-8f9b-de57d18f7b2a',
    );
  });
}
