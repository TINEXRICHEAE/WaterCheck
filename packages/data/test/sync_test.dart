@TestOn('vm')
library;

import 'dart:convert';
import 'dart:math';

import 'package:data/data.dart';
import 'package:data/src/db/database.dart'
    show OutboxCompanion, SyncLocksCompanion, SyncStateCompanion;
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

/// A scripted server: answers pushes with [answer], serves [pages].
class FakeTransport implements SyncTransport {
  final pushes = <List<OutgoingChange>>[];
  final pulls = <(String, String?)>[];
  String Function(OutgoingChange c) answer = (_) => 'applied';
  SyncFailure? failPush;
  SyncFailure? failPull;
  final pages = <String, List<PullPage>>{};

  @override
  Future<List<ChangeOutcome>> push(
    String batchId,
    List<OutgoingChange> changes,
  ) async {
    if (failPush != null) throw failPush!;
    pushes.add(changes);
    return [
      for (final c in changes)
        ChangeOutcome(
          answer(c),
          reason: answer(c) == 'rejected' ? 'invalid_value' : null,
        ),
    ];
  }

  @override
  Future<PullPage> pull(
    String stream,
    String? cursor, {
    int limit = 500,
  }) async {
    if (failPull != null) throw failPull!;
    pulls.add((stream, cursor));
    final queue = pages[stream] ?? [];
    if (queue.isEmpty) {
      return PullPage(
        changes: const [],
        nextCursor: cursor ?? '0',
        hasMore: false,
      );
    }
    return queue.removeAt(0);
  }
}

Future<void> queue(AppDatabase db, int n, {int payloadBytes = 20}) async {
  for (var i = 0; i < n; i++) {
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            entity: 'sanitary_inspection',
            entityId: 'id-$i',
            op: 'insert',
            payload: jsonEncode({'pad': 'x' * payloadBytes, 'n': i}),
            createdAt: fixedClock(),
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  late FakeTransport server;
  late DateTime now;

  SyncService service({List<String> streams = const ['reference']}) =>
      SyncService(
        db,
        server,
        streams: streams,
        clock: () => now,
        random: Random(1),
      );

  setUp(() {
    db = memoryDb();
    server = FakeTransport();
    now = fixedClock();
  });
  tearDown(() => db.close());

  Future<List<OutboxRow>> outbox() => db.select(db.outbox).get();

  test('backoff doubles from 5 s with jitter, capped at 15 min', () {
    final r = Random(7);
    for (final (n, max) in [(1, 5), (2, 10), (3, 20), (10, 900), (40, 900)]) {
      final d = backoffDelay(n, r).inMilliseconds / 1000;
      expect(d, inInclusiveRange(max / 2, max));
    }
    expect(backoffDelay(0), Duration.zero);
  });

  test('pushes oldest first in batches of 50, then marks them sent', () async {
    await queue(db, 120);
    final report = await service().run();
    expect(report.ok, isTrue);
    expect(report.sent, 120);
    expect(server.pushes.map((b) => b.length), [50, 50, 20]);
    expect(server.pushes.first.first.id, 'id-0');
    expect((await outbox()).map((r) => r.status).toSet(), {'sent'});
  });

  test('batches stay under 256 KB; a huge record goes alone', () async {
    await queue(db, 6, payloadBytes: 100 * 1024);
    await service().run();
    expect(server.pushes.map((b) => b.length), [2, 2, 2]);
    await db.delete(db.outbox).go();
    server.pushes.clear();
    await queue(db, 2, payloadBytes: 400 * 1024);
    await service().run();
    expect(server.pushes.map((b) => b.length), [1, 1]);
  });

  test(
    'rejections are kept with the reason; conflicts count as sent',
    () async {
      await queue(db, 3);
      server.answer = (c) => switch (c.id) {
        'id-0' => 'rejected',
        'id-1' => 'conflict',
        _ => 'duplicate',
      };
      final report = await service().run();
      expect((report.sent, report.rejected, report.conflicts), (2, 1, 1));
      final rows = {for (final r in await outbox()) r.entityId: r};
      expect(rows['id-0']!.status, 'rejected');
      expect(rows['id-0']!.lastError, 'invalid_value');
      expect(rows['id-1']!.status, 'sent');
      expect(rows['id-1']!.lastError, startsWith('conflict'));
      expect(rows['id-2']!.attempts, 1);
      // Never deleted (SPEC §8.1); a later run does not resend them.
      await service().run();
      expect(server.pushes, hasLength(1));
    },
  );

  test(
    'a failed push backs off, skips the pull and keeps the records',
    () async {
      await queue(db, 3);
      server.failPush = const SyncFailure(SyncFailureKind.server, 'http_500');
      final first = await service().run();
      expect(first.failure!.code, 'http_500');
      expect(server.pulls, isEmpty);
      expect((await outbox()).map((r) => r.status).toSet(), {'pending'});
      expect((await outbox()).first.attempts, 1);

      // Chaos #5: repeated failures wait longer each time, no busy loop.
      final waits = <Duration>[];
      for (var i = 0; i < 4; i++) {
        final state = await (db.select(
          db.syncState,
        )..where((t) => t.stream.equals('push'))).getSingle();
        waits.add(state.nextAttemptAt!.difference(now));
        expect((await service().run()).skipped, isTrue);
        now = state.nextAttemptAt!;
        await service().run();
      }
      for (var i = 1; i < waits.length; i++) {
        expect(waits[i] > waits[i - 1] * 1.4, isTrue, reason: '$waits');
      }

      // "Sync now" ignores the wait; success resets the backoff.
      server.failPush = null;
      final forced = await service().run(force: true);
      expect(forced.ok, isTrue);
      final state = await (db.select(
        db.syncState,
      )..where((t) => t.stream.equals('push'))).getSingle();
      expect(state.failures, 0);
      expect(state.nextAttemptAt, isNull);
      expect(state.lastSuccessAt, now);
    },
  );

  test('only one sync runs at a time, also across isolates', () async {
    await queue(db, 2);
    final s = service();
    final a = s.run();
    final b = s.run();
    expect(identical(await a, await b), isTrue);

    // A lease held by another isolate (e.g. the background worker).
    await db
        .into(db.syncLocks)
        .insert(
          SyncLocksCompanion.insert(
            name: 'sync',
            owner: 'worker',
            expiresAt: now.add(const Duration(minutes: 5)),
          ),
        );
    expect((await service().run()).skipped, isTrue);
    // A lease left behind by a killed process expires (chaos #2).
    now = now.add(const Duration(minutes: 6));
    expect((await service().run()).skipped, isFalse);
    expect(await db.select(db.syncLocks).get(), isEmpty);
  });

  test('pull applies pages and resumes from the saved cursor', () async {
    server.pages['reference'] = [
      const PullPage(
        changes: [
          IncomingChange(
            entity: 'admin_unit',
            op: 'upsert',
            id: 'u-1',
            data: {
              'id': 'u-1',
              'level': 'district',
              'name': 'Abim',
              'code': 'UG-ABIM',
              'parent_id': null,
              'server_seq': 4,
            },
          ),
        ],
        nextCursor: '900.4',
        hasMore: true,
      ),
      const PullPage(
        changes: [
          IncomingChange(
            entity: 'config_document',
            op: 'upsert',
            id: 'lists',
            data: {
              'key': 'lists',
              'document': {'version': 9, 'source_types': <Object?>[]},
              'version': 9,
            },
          ),
          IncomingChange(
            entity: 'something_new',
            op: 'upsert',
            id: 'x',
            data: {},
          ),
        ],
        nextCursor: '901.7',
        hasMore: false,
      ),
    ];
    final report = await service().run();
    expect(report.pulled, 2);
    expect(server.pulls, [('reference', null), ('reference', '900.4')]);
    final unit = await db.select(db.adminUnits).getSingle();
    expect(unit.code, 'UG-ABIM');
    final lists = await (db.select(
      db.configDocuments,
    )..where((t) => t.key.equals('lists'))).getSingle();
    expect(jsonDecode(lists.document), {
      'version': 9,
      'source_types': <Object?>[],
    });

    await service().run();
    expect(server.pulls.last, ('reference', '901.7'));
  });

  test('a child may arrive pages before its parent (the parent was '
      'edited later); the stream still applies', () async {
    // An escalation updates the alert after its events were written, so on
    // a first sync the events come a page before the alert.
    const at = '2026-10-10T08:30:00Z';
    server.pages['scope'] = [
      const PullPage(
        changes: [
          IncomingChange(
            entity: 'alert_event',
            op: 'upsert',
            id: 'e-1',
            data: {
              'id': 'e-1',
              'alert_id': 'a-1',
              'event_type': 'escalated',
              'occurred_at_device': at,
            },
          ),
        ],
        nextCursor: '900.1',
        hasMore: true,
      ),
      const PullPage(
        changes: [
          IncomingChange(
            entity: 'water_source',
            op: 'upsert',
            id: 's-1',
            data: {
              'id': 's-1',
              'village_id': 'ad625def-3111-5ddd-835f-b24118d37f01',
              'code': 'ABIM-ENT-001',
              'source_type': 'borehole',
              'functional_status': 'functional',
              'is_active': true,
              'version': 1,
              'created_at_device': at,
              'updated_at_device': at,
            },
          ),
          IncomingChange(
            entity: 'alert',
            op: 'upsert',
            id: 'a-1',
            data: {
              'id': 'a-1',
              'source_id': 's-1',
              'trigger_rule': 'unsafe',
              'status': 'open',
              'severity': 'high',
              'opened_at': at,
              'version': 2,
            },
          ),
        ],
        nextCursor: '901.3',
        hasMore: false,
      ),
    ];
    final report = await service(streams: const ['scope']).run();
    expect(report.failure, isNull);
    expect(report.pulled, 3);
    expect((await db.select(db.alertEvents).getSingle()).alertId, 'a-1');
    expect((await db.select(db.alerts).getSingle()).id, 'a-1');
  });

  test('a pull failure is recorded and retried later', () async {
    server.failPull = const SyncFailure(SyncFailureKind.offline, 'offline');
    final report = await service().run();
    expect(report.failure!.kind, SyncFailureKind.offline);
    final state = await (db.select(
      db.syncState,
    )..where((t) => t.stream.equals('push'))).getSingle();
    expect(state.lastError, 'offline');
    expect(state.failures, 1);
    await service().resetBackoff();
    server.failPull = null;
    expect((await service().run()).ok, isTrue);
  });

  test('real repository records survive the trip as JSON', () async {
    // What Collect queues must decode into the map the server expects.
    await SeedImporter(
      db,
      clock: fixedClock,
    ).importBundle(await seedFromInfra());
    final source = await DriftSourceRepository(db, clock: fixedClock).create(
      const NewSource(
        villageId: 'village-1',
        code: 'ABIM-ENT-001',
        sourceType: 'borehole',
      ),
      origin,
    );
    await service().run();
    final sent = server.pushes.single.single;
    expect(sent.entity, 'water_source');
    expect(sent.id, source.id);
    expect(sent.data['village_id'], 'village-1');
    expect(sent.data['created_at_device'], isA<String>());
    expect(
      (await outbox()).single,
      isA<OutboxRow>().having((r) => r.status, 'status', 'sent'),
    );
  });

  test('sync state rows need no migration of the old cursor', () async {
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            stream: 'reference',
            cursor: const Value(7),
          ),
        );
    await service().run();
    expect(server.pulls.single, ('reference', null));
  });
}
