import 'dart:convert';

import 'package:domain/domain.dart' show GeoFix;
import 'package:drift/drift.dart';
import 'package:forms/forms.dart';

import '../attachments/attachment_repository.dart';
import '../attachments/photo_files.dart';
import '../db/database.dart';
import 'support.dart';

/// A research form this device may collect with, at its current version.
typedef ResearchFormItem = ({
  String id,
  String projectId,
  String projectCode,
  String projectTitle,
  String code,
  String title,
  String? description,
  int version,
  FormDefinition definition,
});

/// A record being filled.
typedef ResearchDraftItem = ({
  String id,
  String formId,
  String formTitle,
  String? number,
  DateTime startedAt,
  DateTime updatedAt,
  String? replaceKind,
});

/// A finished record of this device's testers, for their list and map.
typedef ResearchRecordItem = ({
  String id,
  String formId,
  String formCode,
  String formTitle,
  String number,
  bool numberClash,
  DateTime? finishedAt,
  double? lat,
  double? lon,
  bool sent,
  String? replaceKind,
  bool replaced,
});

/// A picture taken while filling a draft: kept as a file until the record
/// is finished (ADR-030 R1).
typedef DraftPicture = ({String path, String field, GeoFix? taken});

/// The pictures an unfinished form lists (JSON): id → file and fix.
Map<String, DraftPicture> parseDraftMedia(String media) => {
  for (final e in (jsonDecode(media) as Map).cast<String, Object?>().entries)
    e.key: () {
      final m = (e.value! as Map).cast<String, Object?>();
      return (
        path: m['path']! as String,
        field: m['field']! as String,
        taken: m['lat'] == null
            ? null
            : GeoFix(
                lat: (m['lat']! as num).toDouble(),
                lon: (m['lon']! as num).toDouble(),
                at: DateTime.parse(m['at']! as String),
                accuracyM: (m['accuracy_m'] as num?)?.toDouble(),
                altitudeM: (m['altitude_m'] as num?)?.toDouble(),
              ),
      );
    }(),
};

/// FieldQuire research on the device (ADR-030): the forms to collect with,
/// drafts saved as the collector goes, and finished records queued for the
/// server with the point of interview. Records are kept as made.
class ResearchRepository {
  ResearchRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  /// Published forms at their current version, by project and code.
  Stream<List<ResearchFormItem>> watchForms() {
    final q =
        _db.select(_db.researchForms).join([
            innerJoin(
              _db.researchProjects,
              _db.researchProjects.id.equalsExp(_db.researchForms.projectId),
            ),
            innerJoin(
              _db.researchFormVersions,
              _db.researchFormVersions.formId.equalsExp(_db.researchForms.id) &
                  _db.researchFormVersions.version.equalsExp(
                    _db.researchForms.currentVersion,
                  ),
            ),
          ])
          ..where(_db.researchForms.status.equals('published'))
          ..orderBy([
            OrderingTerm.asc(_db.researchProjects.title),
            OrderingTerm.asc(_db.researchForms.code),
          ]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          () {
            final f = r.readTable(_db.researchForms);
            final p = r.readTable(_db.researchProjects);
            final v = r.readTable(_db.researchFormVersions);
            return (
              id: f.id,
              projectId: p.id,
              projectCode: p.code,
              projectTitle: p.title,
              code: f.code,
              title: f.title,
              description: f.description,
              version: v.version,
              definition: FormDefinition.fromJson(
                (jsonDecode(v.definition) as Map).cast(),
              ),
            );
          }(),
      ],
    );
  }

  /// Keeps only the forms this phone may still collect with (from the
  /// server after each sync): any other form leaves the phone with its
  /// unfinished drafts (2026-10-27). Its versions stay, so the collector's
  /// sent records still show; the form comes back with a sync if access
  /// returns. Returns how many forms were removed.
  Future<int> keepOnlyForms(Set<String> allowed) => _db.transaction(() async {
    final gone = [
      for (final f in await _db.select(_db.researchForms).get())
        if (!allowed.contains(f.id)) f.id,
    ];
    if (gone.isEmpty) return 0;
    await (_db.delete(
      _db.researchDrafts,
    )..where((d) => d.formId.isIn(gone))).go();
    await (_db.delete(_db.researchForms)..where((f) => f.id.isIn(gone))).go();
    return gone.length;
  });

  Future<FormDefinition?> definition(String formId, int version) async {
    final v =
        await (_db.select(_db.researchFormVersions)..where(
              (v) => v.formId.equals(formId) & v.version.equals(version),
            ))
            .getSingleOrNull();
    return v == null
        ? null
        : FormDefinition.fromJson((jsonDecode(v.definition) as Map).cast());
  }

  /// Starts a record at [at], the point of interview (null without a fix).
  Future<String> startDraft({
    required String formId,
    required int version,
    String? collectorKey,
    GeoFix? at,
  }) async {
    final id = ids.next();
    final now = clock();
    await _db.transaction(() async {
      await _db
          .into(_db.researchDrafts)
          .insert(
            ResearchDraftsCompanion.insert(
              id: id,
              formId: formId,
              formVersion: version,
              collectorKey: Value(collectorKey),
              answers: '{}',
              startedAt: now,
              updatedAt: now,
              lat: Value(at?.lat),
              lon: Value(at?.lon),
              accuracyM: Value(at?.accuracyM),
              altitudeM: Value(at?.altitudeM),
              locationSource: Value(at?.source.wire),
            ),
          );
      await _queueDraft(id);
    });
    return id;
  }

  /// Starts correcting a mistake in [record]: its answers, form version,
  /// number, time and point of interview, ready to change (ADR-034). Its
  /// open correction, if there already is one.
  Future<String> startCorrection(
    ResearchRecordRow record, {
    String? collectorKey,
  }) async {
    final open = await _openReplacement(record.id);
    if (open != null) return open;
    final id = ids.next();
    final now = clock();
    await _db.transaction(() async {
      await _db
          .into(_db.researchDrafts)
          .insert(
            ResearchDraftsCompanion.insert(
              id: id,
              formId: record.formId,
              formVersion: record.formVersion,
              number: Value(record.number),
              collectorKey: Value(collectorKey),
              answers: record.answers,
              startedAt: record.startedAt ?? now,
              updatedAt: now,
              lat: Value(record.lat),
              lon: Value(record.lon),
              accuracyM: Value(record.accuracyM),
              altitudeM: Value(record.altitudeM),
              locationSource: Value(record.locationSource),
              replaces: Value(record.id),
              replaceKind: const Value('correction'),
            ),
          );
      await _queueDraft(id);
    });
    return id;
  }

  /// Starts [record] again from nothing, with the same number, at the
  /// form's [version] (ADR-034). Its open second go, if there is one.
  Future<String> startRetake(
    ResearchRecordRow record, {
    required int version,
    String? collectorKey,
  }) async {
    final open = await _openReplacement(record.id);
    if (open != null) return open;
    final id = ids.next();
    final now = clock();
    await _db.transaction(() async {
      await _db
          .into(_db.researchDrafts)
          .insert(
            ResearchDraftsCompanion.insert(
              id: id,
              formId: record.formId,
              formVersion: version,
              number: Value(record.number),
              collectorKey: Value(collectorKey),
              answers: '{}',
              startedAt: now,
              updatedAt: now,
              replaces: Value(record.id),
              replaceKind: const Value('retake'),
            ),
          );
      await _queueDraft(id);
    });
    return id;
  }

  Future<String?> _openReplacement(String recordId) async =>
      (await (_db.select(_db.researchDrafts)
                ..where((d) => d.replaces.equals(recordId))
                ..limit(1))
              .getSingleOrNull())
          ?.id;

  /// The newest copy of a draft, once, for the server (ADR-034). An older
  /// copy still waiting is replaced, not updated: one being sent right now
  /// is then not mistaken for this one. Call inside the transaction that
  /// changes the draft.
  Future<void> _queueDraft(String id) async {
    final d = await draft(id);
    if (d == null) return;
    await _dropQueuedDraft(id);
    if (d.collectorKey == null) return;
    await enqueueOutbox(
      _db,
      entity: 'research_draft',
      entityId: id,
      op: OutboxOp.insert,
      payload: {
        ...d.toJson(serializer: syncSerializer),
        'answers': jsonDecode(d.answers),
        'media': jsonDecode(d.media),
      },
      at: clock(),
    );
  }

  Future<void> _dropQueuedDraft(String id) =>
      (_db.delete(_db.outbox)..where(
            (o) => o.entity.equals('research_draft') & o.entityId.equals(id),
          ))
          .go();

  /// The draft as it changes (its point arrives after it starts).
  Stream<ResearchDraftRow?> watchDraft(String id) => (_db.select(
    _db.researchDrafts,
  )..where((d) => d.id.equals(id))).watchSingleOrNull();

  Future<ResearchDraftRow?> draft(String id) => (_db.select(
    _db.researchDrafts,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Saves the answers so far (and the number, once given, and why a
  /// record is being replaced), and queues them for the server.
  Future<void> saveDraft(
    String id,
    Map<String, Object?> answers, {
    String? number,
    String? replaceReason,
  }) => _db.transaction(() async {
    await (_db.update(_db.researchDrafts)..where((d) => d.id.equals(id))).write(
      ResearchDraftsCompanion(
        answers: Value(jsonEncode(answers)),
        number: Value(number),
        replaceReason: replaceReason == null
            ? const Value.absent()
            : Value(replaceReason),
        updatedAt: Value(clock()),
      ),
    );
    await _queueDraft(id);
  });

  /// The point of interview, when the first fix arrives after starting.
  Future<void> placeDraft(String id, GeoFix at) => _db.transaction(() async {
    await (_db.update(
      _db.researchDrafts,
    )..where((d) => d.id.equals(id) & d.lat.isNull())).write(
      ResearchDraftsCompanion(
        lat: Value(at.lat),
        lon: Value(at.lon),
        accuracyM: Value(at.accuracyM),
        altitudeM: Value(at.altitudeM),
        locationSource: Value(at.source.wire),
      ),
    );
    await _queueDraft(id);
  });

  /// Keeps a picture with the draft and queues it for the server; returns
  /// its attachment id, which is the field's answer.
  Future<String> addDraftPicture(
    String draftId,
    String field,
    Uint8List jpeg,
    PhotoFiles files, {
    required AttachmentRepository attachments,
    required SubmissionOrigin origin,
    GeoFix? taken,
  }) async {
    final d = await draft(draftId);
    if (d == null) throw StateError('no_draft');
    final id = ids.next();
    final path = await files.save(id, jpeg);
    final media = (jsonDecode(d.media) as Map).cast<String, Object?>();
    media[id] = {
      'path': path,
      'field': field,
      if (taken != null) ...{
        'lat': taken.lat,
        'lon': taken.lon,
        'at': taken.at.toIso8601String(),
        'accuracy_m': taken.accuracyM,
        'altitude_m': taken.altitudeM,
      },
    };
    await _db.transaction(() async {
      await (_db.update(_db.researchDrafts)..where((r) => r.id.equals(draftId)))
          .write(ResearchDraftsCompanion(media: Value(jsonEncode(media))));
      await _queueDraft(draftId);
    });
    await attachments.addPhoto(
      owner: PhotoOwner.researchDraft,
      ownerId: draftId,
      jpeg: jpeg,
      origin: origin,
      taken: taken,
      id: id,
      fieldName: field,
    );
    return id;
  }

  /// Drafts of this collector that have never been queued (made before
  /// drafts were sent, or brought back from the server), with any picture
  /// still only on this device (ADR-034).
  Future<void> sendDraftsNeverSent(
    SubmissionOrigin origin,
    AttachmentRepository attachments,
    PhotoFiles files,
  ) async {
    final key = origin.collectorKey;
    if (key == null) return;
    final mine = await (_db.select(
      _db.researchDrafts,
    )..where((d) => d.collectorKey.equals(key))).get();
    for (final d in mine) {
      final queued =
          await (_db.select(_db.outbox)
                ..where(
                  (o) =>
                      o.entity.equals('research_draft') &
                      o.entityId.equals(d.id),
                )
                ..limit(1))
              .getSingleOrNull();
      if (queued == null) await _db.transaction(() => _queueDraft(d.id));
      for (final e in draftPictures(d).entries) {
        final known = await (_db.select(
          _db.attachments,
        )..where((a) => a.id.equals(e.key))).getSingleOrNull();
        if (known != null) continue;
        final bytes = await files.read(e.value.path);
        if (bytes == null) continue;
        await attachments.addPhoto(
          owner: PhotoOwner.researchDraft,
          ownerId: d.id,
          jpeg: bytes,
          origin: origin,
          taken: e.value.taken,
          id: e.key,
          fieldName: e.value.field,
        );
      }
    }
  }

  /// Where a picture is kept on this device, whichever record has it.
  Future<String?> picturePath(String id) async => (await (_db.select(
    _db.attachmentQueue,
  )..where((q) => q.attachmentId.equals(id))).getSingleOrNull())?.localPath;

  Map<String, DraftPicture> draftPictures(ResearchDraftRow d) =>
      parseDraftMedia(d.media);

  Stream<List<ResearchDraftItem>> watchDrafts(String? collectorKey) {
    final q = _db.select(_db.researchDrafts).join([
      innerJoin(
        _db.researchForms,
        _db.researchForms.id.equalsExp(_db.researchDrafts.formId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.researchDrafts.updatedAt)]);
    if (collectorKey != null) {
      q.where(_db.researchDrafts.collectorKey.equals(collectorKey));
    }
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          (
            id: r.readTable(_db.researchDrafts).id,
            formId: r.readTable(_db.researchDrafts).formId,
            formTitle: r.readTable(_db.researchForms).title,
            number: r.readTable(_db.researchDrafts).number,
            startedAt: r.readTable(_db.researchDrafts).startedAt,
            updatedAt: r.readTable(_db.researchDrafts).updatedAt,
            replaceKind: r.readTable(_db.researchDrafts).replaceKind,
          ),
      ],
    );
  }

  /// Discards a draft and its pictures, here and on the server.
  Future<void> deleteDraft(String id, PhotoFiles files) async {
    final d = await draft(id);
    if (d == null) return;
    final pictures = draftPictures(d);
    await _db.transaction(() async {
      await _dropQueuedDraft(id);
      if (d.collectorKey != null) {
        await enqueueOutbox(
          _db,
          entity: 'research_draft',
          entityId: id,
          op: OutboxOp.update,
          payload: {'discarded': true, 'collector_key': d.collectorKey},
          at: clock(),
        );
      }
      for (final picture in pictures.keys) {
        await forgetPicture(_db, picture);
      }
      await (_db.delete(
        _db.researchDrafts,
      )..where((r) => r.id.equals(id))).go();
    });
    for (final p in pictures.values) {
      await files.delete(p.path);
    }
  }

  /// The next generated number for a form on this device:
  /// `<project>-<form>-<device>-<sequence>`, e.g. `ENT-HQ-7Q2K-0007`.
  /// Unique without a connection: the device's short code is unique.
  Future<String> nextNumber({
    required String formId,
    required String projectCode,
    required String formCode,
    required String deviceCode,
  }) async {
    final prefix = '$projectCode-$formCode-$deviceCode-';
    final used =
        await (_db.select(_db.researchRecords)..where(
              (r) => r.formId.equals(formId) & r.number.like('$prefix%'),
            ))
            .map((r) => int.tryParse(r.number.substring(prefix.length)) ?? 0)
            .get();
    final drafts =
        await (_db.select(_db.researchDrafts)..where(
              (d) => d.formId.equals(formId) & d.number.like('$prefix%'),
            ))
            .map((d) => int.tryParse(d.number!.substring(prefix.length)) ?? 0)
            .get();
    var top = 0;
    for (final n in [...used, ...drafts]) {
      if (n > top) top = n;
    }
    return '$prefix${(top + 1).toString().padLeft(4, '0')}';
  }

  /// A number already used on this device in the same project (the server
  /// checks the whole project when the record arrives).
  Future<bool> numberUsed(String formId, String number) async {
    final form = await (_db.select(
      _db.researchForms,
    )..where((f) => f.id.equals(formId))).getSingleOrNull();
    if (form == null) return false;
    final forms = await (_db.select(
      _db.researchForms,
    )..where((f) => f.projectId.equals(form.projectId))).map((f) => f.id).get();
    final clean = number.trim().toUpperCase();
    final rows = await (_db.select(
      _db.researchRecords,
    )..where((r) => r.formId.isIn(forms))).get();
    return rows.any((r) => r.number.trim().toUpperCase() == clean);
  }

  /// Finishes a draft: the record is kept as made and queued, its pictures
  /// queued after it, and the draft removed.
  Future<String> finish({
    required String draftId,
    required String number,
    required Map<String, Object?> answers,
    required SubmissionOrigin origin,
    required AttachmentRepository attachments,
    required PhotoFiles files,
    GeoFix? end,
  }) async {
    final d = await draft(draftId);
    if (d == null) throw StateError('no_draft');
    final now = clock();
    final pictures = draftPictures(d);
    await _db.transaction(() async {
      final row = await _db
          .into(_db.researchRecords)
          .insertReturning(
            ResearchRecordsCompanion.insert(
              id: d.id,
              formId: d.formId,
              formVersion: d.formVersion,
              number: number.trim(),
              collectorKey: Value(origin.collectorKey),
              installationId: Value(origin.installationId),
              collectorSnapshot: Value(origin.snapshotJson),
              startedAt: Value(d.startedAt),
              finishedAt: Value(now),
              lat: Value(d.lat),
              lon: Value(d.lon),
              accuracyM: Value(d.accuracyM),
              altitudeM: Value(d.altitudeM),
              locationSource: Value(d.locationSource),
              replaces: Value(d.replaces),
              replaceKind: Value(d.replaceKind),
              replaceReason: Value(d.replaceReason?.trim()),
              endLat: Value(end?.lat),
              endLon: Value(end?.lon),
              endAccuracyM: Value(end?.accuracyM),
              answers: jsonEncode(answers),
            ),
          );
      await enqueueOutbox(
        _db,
        entity: 'research_record',
        entityId: row.id,
        op: OutboxOp.insert,
        payload: {
          ...row.toJson(serializer: syncSerializer),
          'answers': answers,
          'collector_key': origin.collectorKey,
          'collector_snapshot': origin.snapshotJson,
        },
        at: now,
      );
      await _dropQueuedDraft(draftId);
      await (_db.delete(
        _db.researchDrafts,
      )..where((r) => r.id.equals(draftId))).go();
    });
    // Only the pictures still answering a field are sent.
    final kept = <String>{
      for (final v in answers.values)
        if (v is String) v,
    };
    for (final e in pictures.entries) {
      // Already queued with the draft (ADR-034): it now belongs to the
      // record, or goes if it no longer answers anything.
      final known = await (_db.select(
        _db.attachments,
      )..where((a) => a.id.equals(e.key))).getSingleOrNull();
      if (known != null) {
        if (kept.contains(e.key)) {
          await movePictureTo(_db, e.key, PhotoOwner.research.wire, at: now);
        } else {
          await attachments.removePhoto(e.key, origin);
          await files.delete(e.value.path);
        }
        continue;
      }
      final bytes = await files.read(e.value.path);
      await files.delete(e.value.path);
      if (bytes == null || !kept.contains(e.key)) continue;
      await attachments.addPhoto(
        owner: PhotoOwner.research,
        ownerId: d.id,
        jpeg: bytes,
        origin: origin,
        taken: e.value.taken,
        id: e.key,
        fieldName: e.value.field,
      );
    }
    return d.id;
  }

  /// This device's testers' records (all, or one tester's), newest first.
  Stream<List<ResearchRecordItem>> watchRecords(String? collectorKey) {
    final q = _db.select(_db.researchRecords).join([
      innerJoin(
        _db.researchForms,
        _db.researchForms.id.equalsExp(_db.researchRecords.formId),
      ),
      leftOuterJoin(
        _db.outbox,
        _db.outbox.entityId.equalsExp(_db.researchRecords.id) &
            _db.outbox.entity.equals('research_record') &
            _db.outbox.status.equals('pending'),
      ),
    ])..orderBy([OrderingTerm.desc(_db.researchRecords.finishedAt)]);
    if (collectorKey != null) {
      q.where(_db.researchRecords.collectorKey.equals(collectorKey));
    }
    return q.watch().map((rows) {
      final replaced = {
        for (final r in rows) ?r.readTable(_db.researchRecords).replaces,
      };
      return [
        for (final r in rows)
          () {
            final rec = r.readTable(_db.researchRecords);
            final f = r.readTable(_db.researchForms);
            return (
              id: rec.id,
              formId: f.id,
              formCode: f.code,
              formTitle: f.title,
              number: rec.number,
              numberClash: rec.numberClash,
              finishedAt: rec.finishedAt,
              lat: rec.lat,
              lon: rec.lon,
              sent: r.readTableOrNull(_db.outbox) == null,
              replaceKind: rec.replaceKind,
              replaced: replaced.contains(rec.id),
            );
          }(),
      ];
    });
  }

  /// Whether a newer record already replaces this one.
  Future<bool> isReplaced(String id) async =>
      (await (_db.select(_db.researchRecords)
            ..where((r) => r.replaces.equals(id))
            ..limit(1))
          .getSingleOrNull()) !=
      null;

  Future<ResearchRecordRow?> record(String id) => (_db.select(
    _db.researchRecords,
  )..where((r) => r.id.equals(id))).getSingleOrNull();
}
