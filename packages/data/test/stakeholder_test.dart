@TestOn('vm')
library;

import 'dart:convert';

import 'package:data/data.dart';
import 'package:data/src/db/database.dart'
    show AttachmentsCompanion, SanitaryInspectionsCompanion;
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'dashboard_test.dart' show buildFixture;
import 'support/fixtures.dart';

void main() {
  late AppDatabase db;
  late StakeholderRepository repo;
  final now = fixedClock();

  setUp(() async {
    db = memoryDb();
    await SeedImporter(
      db,
      clock: fixedClock,
    ).importBundle(await seedFromInfra());
    await buildFixture(db, sources: 2, testsPerSource: 2, now: now);
    repo = StakeholderRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('a flag is stored and queued with the API field names', () async {
    final id = await repo.flagSubmission(
      resultId: 'res-0-0',
      reason: 'Same readings as last week',
      userId: 'u-1',
    );
    final queued = (await db.select(db.outbox).get()).single;
    expect(queued.entity, 'submission_flag');
    expect(queued.entityId, id);
    final payload = jsonDecode(queued.payload) as Map;
    expect(payload['result_id'], 'res-0-0');
    expect(payload['reason'], 'Same readings as last week');
    expect(payload['created_at_device'], isA<String>());
    final flagged = await DashboardQueries(db, clock: () => now).load(
      DashboardFilter(from: now.subtract(const Duration(days: 60)), to: now),
    );
    expect(
      flagged.sources
          .expand((s) => s.history)
          .singleWhere((h) => h.resultId == 'res-0-0')
          .flagged,
      isTrue,
    );
  });

  test('marking a collector twice keeps the latest decision', () async {
    await repo.markCollector(
      collectorKey: 'col-1',
      status: 'flagged',
      userId: 'u-1',
    );
    await repo.markCollector(
      collectorKey: 'col-1',
      status: 'known',
      userId: 'u-1',
    );
    final marks = await db.select(db.collectorMarks).get();
    expect(marks.single.status, 'known');
    final queued = await db.select(db.outbox).get();
    expect(queued.map((q) => q.entity), everyElement('collector_mark'));
    expect(queued.map((q) => q.entityId), everyElement('col-1'));
    expect((jsonDecode(queued.last.payload) as Map)['status'], 'known');
  });

  test('photos of the source and its tests; inspection risks', () async {
    for (final (id, owner) in [
      ('p1', 'src-0'),
      ('p2', 'ses-0-1'),
      ('p3', 'src-1'),
    ]) {
      await db
          .into(db.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: id,
              ownerType: owner.startsWith('src')
                  ? 'water_source'
                  : 'test_session',
              ownerId: owner,
              sha256: 'x',
              bytes: 1,
              mime: 'image/jpeg',
              uploadStatus: Value(id == 'p1' ? 'uploaded' : 'pending'),
            ),
          );
    }
    await db
        .into(db.sanitaryInspections)
        .insert(
          SanitaryInspectionsCompanion.insert(
            id: 'i1',
            sourceId: 'src-0',
            answers: jsonEncode({
              'latrine': 'yes',
              'fence': 'no',
              'pool': 'yes',
            }),
            inspectedAtDevice: now,
          ),
        );
    final photos = await repo.photos('src-0');
    expect(photos.map((p) => p.id), unorderedEquals(['p1', 'p2']));
    expect(photos.firstWhere((p) => p.id == 'p1').uploaded, isTrue);
    final inspections = await repo.inspections('src-0');
    expect(inspections.single.risks, 2);
    expect(inspections.single.answered, 3);
  });
}
