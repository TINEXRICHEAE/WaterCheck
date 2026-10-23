import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_server.dart';
import 'support/harness.dart';

const _village = 'ad625def-3111-5ddd-835f-b24118d37f01';

Future<void> addSource(AppDatabase db, String code) async {
  await DriftSourceRepository(db).create(
    NewSource(villageId: _village, code: code, sourceType: 'borehole'),
    SubmissionOrigin.collect(
      installationId: FakeServer.installationId,
      collector: (await DriftCollectorProfileRepository(
        db,
      ).watchActive().first).first,
    ),
  );
}

void main() {
  testWidgets('records are sent on start and the sync tab says so', (
    tester,
  ) async {
    final svc = TestServices();
    final db = await pumpCollect(
      tester,
      services: svc,
      prepare: (db) => addSource(db, 'ABIM-ENT-001'),
    );
    expect(svc.server.pushed.single['entity'], 'water_source');
    await tapAndSettle(tester, find.text('Sync'));
    expect(find.text('Everything is sent'), findsOneWidget);
    expect(find.textContaining('Last sent'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('offline: records wait and the app says when it retries', (
    tester,
  ) async {
    final svc = TestServices()..server.offline = true;
    final db = await pumpCollect(
      tester,
      services: svc,
      prepare: (db) => addSource(db, 'ABIM-ENT-001'),
    );
    await tapAndSettle(tester, find.text('Sync'));
    expect(find.text('1 item waiting to send'), findsOneWidget);
    expect(find.textContaining('No connection'), findsOneWidget);

    // Back online: "Sync now" does not wait for the backoff.
    svc.server.offline = false;
    await tapAndSettle(tester, find.text('Sync now'));
    expect(find.text('Everything is sent'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('a refused record is listed with the reason, never lost', (
    tester,
  ) async {
    final svc = TestServices()..server.offline = true;
    final db = await pumpCollect(
      tester,
      services: svc,
      prepare: (db) => addSource(db, 'ABIM-ENT-001'),
    );
    final id = (await tester.runAsync(() => db.select(db.outbox).getSingle()))!
        .entityId;
    svc.server
      ..offline = false
      ..reject[id] = 'out_of_scope';
    await tapAndSettle(tester, find.text('Sync'));
    await tapAndSettle(tester, find.text('Sync now'));
    expect(find.text('1 item was refused'), findsOneWidget);
    expect(find.text('Not accepted by the server'), findsOneWidget);
    expect(find.textContaining("outside this device's area"), findsOneWidget);
    final row = (await tester.runAsync(
      () => db.select(db.outbox).getSingle(),
    ))!;
    expect(row.status, 'rejected');
    await disposeApp(tester, db);
  });

  testWidgets('a source added on another device arrives by pull', (
    tester,
  ) async {
    final svc = TestServices();
    final now = DateTime.utc(2026, 10, 10).toIso8601String();
    svc.server.serve['area:$_village'] = [
      {
        '_entity': 'water_source',
        'id': '01a1aaaa-0000-7000-8000-000000000001',
        'village_id': _village,
        'code': 'ABIM-ENT-077',
        'name': 'Spring by the school',
        'source_type': 'protected_spring',
        'lat': 2.71,
        'lon': 33.65,
        'location_accuracy_m': 6.0,
        'households_served': null,
        'functional_status': 'functional',
        'is_active': true,
        'version': 1,
        'created_by': null,
        'installation_id': '0b9e1f4a-6c2d-4e8f-a1b3-c5d7e9f00002',
        'collector_key': null,
        'collector_snapshot': null,
        'created_at_device': now,
        'updated_at_device': now,
        'server_seq': 99,
      },
    ];
    final db = await pumpCollect(tester, services: svc);
    expect(find.text('Spring by the school'), findsOneWidget);
    final state = (await tester.runAsync(
      () => (db.select(
        db.syncState,
      )..where((t) => t.stream.equals('area:$_village'))).getSingle(),
    ))!;
    expect(state.cursorToken, '1.1');
    await disposeApp(tester, db);
  });

  testWidgets('a revocation found while syncing leads to export-then-wipe', (
    tester,
  ) async {
    final svc = TestServices();
    final db = await pumpCollect(tester, services: svc);
    svc.server.revoked.add(FakeServer.installationId);
    await tapAndSettle(tester, find.text('Sync'));
    await tapAndSettle(tester, find.text('Sync now'));
    expect(find.text('This device has been switched off'), findsOneWidget);
    await disposeApp(tester, db);
  });
}
