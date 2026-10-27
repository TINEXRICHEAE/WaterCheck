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
      taken: at,
    );
    final dropped = await repo.addDraftPicture(
      id,
      'H_photo',
      Uint8List.fromList([4, 5]),
      files,
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
