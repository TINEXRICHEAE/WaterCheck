@TestOn('vm')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:domain/domain.dart' show GeoFix;
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';

import 'support/fixtures.dart';

const _form = 'f-hq';

Future<void> _published(AppDatabase db) async {
  final pull = PullApplier(db);
  await pull.apply('research_project', {
    'id': 'p-ent',
    'code': 'ENT',
    'title': 'Household water treatment, Entebbe',
  });
  await pull.apply('research_form', {
    'id': _form,
    'project_id': 'p-ent',
    'code': 'HQ',
    'title': 'Household Questionnaire',
    'status': 'published',
    'collect_access': 'open',
    'hidden': false,
    'numbering': 'typed',
    'current_version': 1,
  });
  await pull.apply('research_form_version', {
    'form_id': _form,
    'version': 1,
    'definition': {
      'title': 'Household Questionnaire',
      'settings': {'numbering': 'typed', 'number_label': 'Household code'},
      'fields': [
        {'name': 'consent', 'type': 'consent', 'label': 'Agree?'},
        {'name': 'H_photo', 'type': 'photo', 'label': 'Container'},
      ],
    },
  });
}

void main() {
  late AppDatabase db;
  late MemoryPhotoFiles files;
  late ResearchRepository repo;
  late DriftAttachmentRepository attachments;
  setUp(() async {
    db = memoryDb();
    files = MemoryPhotoFiles();
    repo = ResearchRepository(db);
    attachments = DriftAttachmentRepository(db, files);
    await _published(db);
  });
  tearDown(() => db.close());

  test('a form this phone may no longer use leaves it, with its drafts '
      '(2026-10-27)', () async {
    await repo.startDraft(formId: _form, version: 1);
    expect(await repo.keepOnlyForms({_form}), 0);
    expect(await repo.watchForms().first, hasLength(1));
    expect(await repo.keepOnlyForms({}), 1);
    expect(await repo.watchForms().first, isEmpty);
    expect(await db.select(db.researchDrafts).get(), isEmpty);
  });

  test('published forms come from the server with their definition', () async {
    final forms = await repo.watchForms().first;
    expect(forms.single.code, 'HQ');
    expect(forms.single.projectCode, 'ENT');
    expect(forms.single.definition.numberLabel, 'Household code');
  });

  test('a draft keeps its point and pictures; finishing queues the record '
      'first, then only the pictures still answering', () async {
    final at = GeoFix(
      lat: 2.7019,
      lon: 33.6531,
      at: DateTime.utc(2026, 11, 10, 8),
    );
    final id = await repo.startDraft(
      formId: _form,
      version: 1,
      collectorKey: origin.collectorKey,
      at: at,
    );
    final kept = await repo.addDraftPicture(
      id,
      'H_photo',
      Uint8List.fromList([1, 2, 3]),
      files,
      attachments: attachments,
      origin: origin,
      taken: at,
    );
    final dropped = await repo.addDraftPicture(
      id,
      'H_photo',
      Uint8List.fromList([4, 5]),
      files,
      attachments: attachments,
      origin: origin,
    );
    await repo.saveDraft(id, {
      'consent': 'yes',
      'H_photo': kept,
    }, number: 'H-001');
    expect(
      (await repo.watchDrafts(origin.collectorKey).first).single.number,
      'H-001',
    );

    await repo.finish(
      draftId: id,
      number: ' H-001 ',
      answers: {'consent': 'yes', 'H_photo': kept},
      origin: origin,
      attachments: attachments,
      files: files,
    );
    expect(await repo.watchDrafts(null).first, isEmpty);
    final queued = await (db.select(
      db.outbox,
    )..orderBy([(o) => OrderingTerm.asc(o.id)])).get();
    expect(queued.map((o) => o.entity), ['research_record', 'attachment']);
    final record = jsonDecode(queued.first.payload) as Map<String, Object?>;
    expect(record['number'], 'H-001');
    expect(record['lat'], 2.7019);
    expect(record['answers'], {'consent': 'yes', 'H_photo': kept});
    final picture = jsonDecode(queued.last.payload) as Map<String, Object?>;
    expect(
      (picture['id'], picture['field_name'], picture['owner_type']),
      (kept, 'H_photo', 'research_record'),
    );
    expect(files.files.keys.any((k) => k.contains(dropped)), isFalse);

    final mine = await repo.watchRecords(origin.collectorKey).first;
    expect((mine.single.number, mine.single.sent), ('H-001', false));
    expect(await repo.numberUsed(_form, 'h-001'), isTrue);
  });

  group('unfinished forms reach the server (ADR-034)', () {
    Future<List<OutboxRow>> queued() => (db.select(
      db.outbox,
    )..where((o) => o.entity.equals('research_draft'))).get();

    test('one copy waits, always the newest', () async {
      final id = await repo.startDraft(
        formId: _form,
        version: 1,
        collectorKey: origin.collectorKey,
      );
      await repo.saveDraft(id, {'consent': 'yes'}, number: 'H-1');
      await repo.saveDraft(id, {'consent': 'no'}, number: 'H-1');
      final rows = await queued();
      expect(rows, hasLength(1));
      final sent = jsonDecode(rows.single.payload) as Map<String, Object?>;
      expect(sent['answers'], {'consent': 'no'});
      expect(sent['collector_key'], origin.collectorKey);
    });

    test(
      'finishing takes the copy off the queue; discarding says so',
      () async {
        final id = await repo.startDraft(
          formId: _form,
          version: 1,
          collectorKey: origin.collectorKey,
        );
        await repo.finish(
          draftId: id,
          number: 'H-1',
          answers: const {'consent': 'yes'},
          origin: origin,
          attachments: attachments,
          files: files,
        );
        expect(await queued(), isEmpty);

        final other = await repo.startDraft(
          formId: _form,
          version: 1,
          collectorKey: origin.collectorKey,
        );
        await repo.deleteDraft(other, files);
        final rows = await queued();
        expect(rows.single.op, 'update');
        expect(
          jsonDecode(rows.single.payload),
          containsPair('discarded', true),
        );
      },
    );

    test(
      'a picture sent with a draft joins its record, not sent twice',
      () async {
        final id = await repo.startDraft(
          formId: _form,
          version: 1,
          collectorKey: origin.collectorKey,
        );
        final picture = await repo.addDraftPicture(
          id,
          'H_photo',
          Uint8List.fromList([1, 2, 3]),
          files,
          attachments: attachments,
          origin: origin,
        );
        await repo.finish(
          draftId: id,
          number: 'H-1',
          answers: {'H_photo': picture},
          origin: origin,
          attachments: attachments,
          files: files,
        );
        final rows = await (db.select(
          db.outbox,
        )..orderBy([(o) => OrderingTerm.asc(o.id)])).get();
        expect(rows.map((o) => o.entity), ['research_record', 'attachment']);
        expect(
          jsonDecode(rows.last.payload),
          containsPair('owner_type', 'research_record'),
        );
        expect(await db.select(db.attachmentQueue).get(), hasLength(1));
      },
    );

    test('a draft comes back from the server, never over newer work or a '
        'finished record', () async {
      final pull = PullApplier(db);
      Map<String, Object?> copy(String at, Map<String, Object?> answers) => {
        'id': 'd-1',
        'form_id': _form,
        'form_version': 1,
        'number': 'H-9',
        'collector_key': origin.collectorKey,
        'answers': answers,
        'media': <String, Object?>{},
        'started_at': '2026-11-10T08:00:00.000Z',
        'updated_at': at,
      };
      await pull.apply(
        'research_draft',
        copy('2026-11-10T08:05:00.000Z', {'consent': 'yes'}),
      );
      expect((await repo.draft('d-1'))?.number, 'H-9');
      await pull.apply(
        'research_draft',
        copy('2026-11-10T08:01:00.000Z', {'consent': 'no'}),
      );
      expect((await repo.draft('d-1'))?.answers, contains('yes'));
      await pull.apply('research_draft', {
        ...copy('2026-11-10T08:06:00.000Z', {}),
        'closed_at': '2026-11-10T08:07:00.000Z',
      });
      expect(await repo.draft('d-1'), isNull);
    });
  });

  group('water tests in progress (ADR-034)', () {
    late WaterDraftRepository water;
    setUp(() => water = WaterDraftRepository(db));

    Future<List<OutboxRow>> queued() => (db.select(
      db.outbox,
    )..where((o) => o.entity.equals('water_draft'))).get();

    Future<void> save(String number) => water.save(
      id: 't-1',
      sourceId: 's-1',
      collectorKey: origin.collectorKey,
      state: {
        'values': {
          'ph': {'number': number},
        },
      },
    );

    test('one copy waits, always the newest', () async {
      await save('7');
      await save('7.5');
      final rows = await queued();
      expect(rows, hasLength(1));
      final sent = jsonDecode(rows.single.payload) as Map<String, Object?>;
      expect((sent['state']! as Map)['values'], {
        'ph': {'number': '7.5'},
      });
    });

    test(
      'submitted, its pictures follow the session and the draft goes',
      () async {
        await save('7');
        await water.addPicture(
          draftId: 't-1',
          pictureId: 'p-1',
          jpeg: Uint8List.fromList([1, 2, 3]),
          files: files,
          attachments: attachments,
          origin: origin,
        );
        expect(water.pictures((await water.draft('t-1'))!).keys, [
          'p-1',
        ]);
        await water.finish('t-1');
        expect(await water.draft('t-1'), isNull);
        expect(await queued(), isEmpty);
        final picture = await (db.select(
          db.outbox,
        )..where((o) => o.entity.equals('attachment'))).getSingle();
        expect(
          jsonDecode(picture.payload),
          containsPair('owner_type', 'test_session'),
        );
      },
    );

    test('discarded, the server is told', () async {
      await save('7');
      await water.discard('t-1', files);
      expect(await water.draft('t-1'), isNull);
      expect((await queued()).single.op, 'update');
    });

    test('comes back from the server, never over newer work', () async {
      final pull = PullApplier(db);
      Map<String, Object?> copy(String at, String ph) => {
        'id': 't-9',
        'source_id': 's-1',
        'collector_key': origin.collectorKey,
        'state': {'ph': ph},
        'media': <String, Object?>{},
        'started_at': '2026-11-10T08:00:00.000Z',
        'updated_at': at,
      };
      await pull.apply('water_draft', copy('2026-11-10T08:05:00.000Z', '7'));
      await pull.apply('water_draft', copy('2026-11-10T08:01:00.000Z', '9'));
      expect((await water.draft('t-9'))?.state, contains('7'));
      await pull.apply('water_draft', {
        ...copy('2026-11-10T08:06:00.000Z', '7'),
        'closed_at': '2026-11-10T08:07:00.000Z',
      });
      expect(await water.draft('t-9'), isNull);
    });
  });

  group('a submitted record corrected or done again (ADR-034)', () {
    Future<ResearchRecordRow> finished() async {
      final id = await repo.startDraft(
        formId: _form,
        version: 1,
        collectorKey: origin.collectorKey,
        at: GeoFix(lat: 2.7, lon: 33.6, at: DateTime.utc(2026, 11, 10, 8)),
      );
      await repo.finish(
        draftId: id,
        number: 'H-5',
        answers: const {'consent': 'yes'},
        origin: origin,
        attachments: attachments,
        files: files,
      );
      return (await repo.record(id))!;
    }

    test('a correction keeps the answers, number and point, and the reason '
        'goes with the new record', () async {
      final first = await finished();
      final id = await repo.startCorrection(
        first,
        collectorKey: origin.collectorKey,
      );
      expect(
        await repo.startCorrection(first, collectorKey: origin.collectorKey),
        id,
      );
      final d = (await repo.draft(id))!;
      expect((d.number, d.lat, d.answers), ('H-5', 2.7, first.answers));
      await repo.saveDraft(
        id,
        const {'consent': 'no'},
        number: 'H-5',
        replaceReason: 'wrong answer',
      );
      await repo.finish(
        draftId: id,
        number: 'H-5',
        answers: const {'consent': 'no'},
        origin: origin,
        attachments: attachments,
        files: files,
      );
      final made = (await repo.record(id))!;
      expect(
        (made.replaces, made.replaceKind, made.replaceReason),
        (first.id, 'correction', 'wrong answer'),
      );
      expect(await repo.isReplaced(first.id), isTrue);
      final list = await repo.watchRecords(origin.collectorKey).first;
      expect(
        {for (final r in list) r.id: r.replaced},
        {first.id: true, id: false},
      );
    });

    test('doing it again starts empty with the same number', () async {
      final first = await finished();
      final id = await repo.startRetake(
        first,
        version: 1,
        collectorKey: origin.collectorKey,
      );
      final d = (await repo.draft(id))!;
      expect(
        (d.number, d.answers, d.lat, d.replaceKind),
        ('H-5', '{}', null, 'retake'),
      );
    });
  });

  test(
    'generated numbers carry project, form and device, and count on',
    () async {
      final first = await repo.nextNumber(
        formId: _form,
        projectCode: 'ENT',
        formCode: 'HQ',
        deviceCode: '7Q2K',
      );
      expect(first, 'ENT-HQ-7Q2K-0001');
      final id = await repo.startDraft(formId: _form, version: 1);
      await repo.saveDraft(id, const {}, number: first);
      expect(
        await repo.nextNumber(
          formId: _form,
          projectCode: 'ENT',
          formCode: 'HQ',
          deviceCode: '7Q2K',
        ),
        'ENT-HQ-7Q2K-0002',
      );
    },
  );
}
