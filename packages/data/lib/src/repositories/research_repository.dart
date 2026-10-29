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
});

/// A picture taken while filling a draft: kept as a file until the record
/// is finished (ADR-030 R1).
typedef DraftPicture = ({String path, String field, GeoFix? taken});

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
    return id;
  }

  /// The draft as it changes (its point arrives after it starts).
  Stream<ResearchDraftRow?> watchDraft(String id) => (_db.select(
    _db.researchDrafts,
  )..where((d) => d.id.equals(id))).watchSingleOrNull();

  Future<ResearchDraftRow?> draft(String id) => (_db.select(
    _db.researchDrafts,
  )..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Saves the answers so far (and the number, once given).
  Future<void> saveDraft(
    String id,
    Map<String, Object?> answers, {
    String? number,
  }) => (_db.update(_db.researchDrafts)..where((d) => d.id.equals(id))).write(
    ResearchDraftsCompanion(
      answers: Value(jsonEncode(answers)),
      number: Value(number),
      updatedAt: Value(clock()),
    ),
  );

  /// The point of interview, when the first fix arrives after starting.
  Future<void> placeDraft(String id, GeoFix at) =>
      (_db.update(
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

  /// Keeps a picture with the draft; returns its attachment id, which is
  /// the field's answer.
  Future<String> addDraftPicture(
    String draftId,
    String field,
    Uint8List jpeg,
    PhotoFiles files, {
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
    await (_db.update(_db.researchDrafts)..where((r) => r.id.equals(draftId)))
        .write(ResearchDraftsCompanion(media: Value(jsonEncode(media))));
    return id;
  }

  Map<String, DraftPicture> draftPictures(ResearchDraftRow d) => {
    for (final e
        in (jsonDecode(d.media) as Map).cast<String, Object?>().entries)
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
          ),
      ],
    );
  }

  /// Discards a draft and its pictures.
  Future<void> deleteDraft(String id, PhotoFiles files) async {
    final d = await draft(id);
    if (d == null) return;
    for (final p in draftPictures(d).values) {
      await files.delete(p.path);
    }
    await (_db.delete(_db.researchDrafts)..where((r) => r.id.equals(id))).go();
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
    return q.watch().map(
      (rows) => [
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
            );
          }(),
      ],
    );
  }

  Future<ResearchRecordRow?> record(String id) => (_db.select(
    _db.researchRecords,
  )..where((r) => r.id.equals(id))).getSingleOrNull();
}
