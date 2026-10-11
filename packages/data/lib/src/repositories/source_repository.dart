import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

class NewSource {
  const NewSource({
    required this.villageId,
    required this.code,
    required this.sourceType,
    this.name,
    this.location,
    this.householdsServed,
    this.functionalStatus = 'functional',
  });

  final String villageId;

  /// `VILLAGECODE-NNN`; see [SourceRepository.suggestCode].
  final String code;
  final String sourceType;
  final String? name;
  final GeoPoint? location;
  final int? householdsServed;
  final String functionalStatus;
}

/// Editable fields (F-SRC-2). Null means "unchanged".
class SourceChanges {
  const SourceChanges({
    this.name,
    this.householdsServed,
    this.functionalStatus,
  });

  final String? name;
  final int? householdsServed;
  final String? functionalStatus;
}

abstract interface class SourceRepository {
  Stream<List<WaterSource>> watchSources({
    String? villageId,
    bool includeInactive = false,
  });
  Future<WaterSource?> source(String id);

  /// Next free `VILLAGECODE-NNN` code in the village (F-SRC-1).
  Future<String> suggestCode({
    required String villageId,
    required String villageCode,
  });
  Future<WaterSource> create(NewSource source, SubmissionOrigin origin);
  Future<WaterSource> update(
    String id,
    SourceChanges changes,
    SubmissionOrigin origin,
  );

  /// Soft delete (F-SRC-5).
  Future<WaterSource> deactivate(String id, SubmissionOrigin origin);
}

class DriftSourceRepository implements SourceRepository {
  DriftSourceRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  static WaterSource toDomain(WaterSourceRow r) => WaterSource(
    id: r.id,
    villageId: r.villageId,
    code: r.code,
    name: r.name,
    sourceType: r.sourceType,
    location: r.lat == null || r.lon == null
        ? null
        : GeoPoint(lat: r.lat!, lon: r.lon!, accuracyM: r.locationAccuracyM),
    householdsServed: r.householdsServed,
    functionalStatus: r.functionalStatus,
    isActive: r.isActive,
    version: r.version,
  );

  @override
  Stream<List<WaterSource>> watchSources({
    String? villageId,
    bool includeInactive = false,
  }) {
    final query = _db.select(_db.waterSources)
      ..orderBy([(t) => OrderingTerm(expression: t.code)]);
    if (villageId != null) query.where((t) => t.villageId.equals(villageId));
    if (!includeInactive) query.where((t) => t.isActive.equals(true));
    return query.watch().map((rows) => rows.map(toDomain).toList());
  }

  Future<WaterSourceRow?> _row(String id) => (_db.select(
    _db.waterSources,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Future<WaterSource?> source(String id) async {
    final row = await _row(id);
    return row == null ? null : toDomain(row);
  }

  @override
  Future<String> suggestCode({
    required String villageId,
    required String villageCode,
  }) async {
    final rows = await (_db.select(
      _db.waterSources,
    )..where((t) => t.villageId.equals(villageId))).get();
    final pattern = RegExp('^${RegExp.escape(villageCode)}-(\\d+)\$');
    var highest = 0;
    for (final r in rows) {
      final n = int.tryParse(pattern.firstMatch(r.code)?.group(1) ?? '');
      if (n != null && n > highest) highest = n;
    }
    return '$villageCode-${(highest + 1).toString().padLeft(3, '0')}';
  }

  @override
  Future<WaterSource> create(NewSource source, SubmissionOrigin origin) =>
      _db.transaction(() async {
        final now = clock();
        final companion = WaterSourcesCompanion.insert(
          id: ids.next(),
          villageId: source.villageId,
          code: source.code.trim(),
          name: Value(source.name?.trim()),
          sourceType: source.sourceType,
          lat: Value(source.location?.lat),
          lon: Value(source.location?.lon),
          locationAccuracyM: Value(source.location?.accuracyM),
          householdsServed: Value(source.householdsServed),
          functionalStatus: Value(source.functionalStatus),
          createdBy: Value(origin.userId),
          installationId: Value(origin.installationId),
          collectorKey: Value(origin.collectorKey),
          collectorSnapshot: Value(origin.snapshotJson),
          createdAtDevice: now,
          updatedAtDevice: now,
        );
        final row = await _db.into(_db.waterSources).insertReturning(companion);
        await enqueueOutbox(
          _db,
          entity: 'water_source',
          entityId: row.id,
          op: OutboxOp.insert,
          payload: row.toJson(serializer: syncSerializer),
          at: now,
        );
        return toDomain(row);
      });

  Future<WaterSource> _change(
    String id,
    SubmissionOrigin origin,
    WaterSourcesCompanion Function(WaterSourceRow current) build,
  ) => _db.transaction(() async {
    final current = await _row(id);
    if (current == null) throw ArgumentError.value(id, 'id', 'Unknown source');
    final now = clock();
    final changes = build(current);
    final updated = changes.copyWith(
      version: Value(current.version + 1),
      updatedAtDevice: Value(now),
    );
    await (_db.update(
      _db.waterSources,
    )..where((t) => t.id.equals(id))).write(updated);
    final row = (await _row(id))!;
    // Only the changed fields travel; the server applies them on
    // `base_version` with the §8.4 conflict policy.
    final full = row.toJson(serializer: syncSerializer);
    final changed = changes.toColumns(false).keys.toSet();
    await enqueueOutbox(
      _db,
      entity: 'water_source',
      entityId: id,
      op: OutboxOp.update,
      payload: {
        for (final k in changed) k: full[k],
        'version': row.version,
        'updated_at_device': full['updated_at_device'],
        'installation_id': origin.installationId,
        'collector_key': origin.collectorKey,
        'collector_snapshot': origin.collector?.toJson(),
        'updated_by': origin.userId,
      },
      baseVersion: current.version,
      at: now,
    );
    return toDomain(row);
  });

  @override
  Future<WaterSource> update(
    String id,
    SourceChanges changes,
    SubmissionOrigin origin,
  ) => _change(
    id,
    origin,
    (_) => WaterSourcesCompanion(
      name: changes.name == null
          ? const Value.absent()
          : Value(changes.name!.trim()),
      householdsServed: changes.householdsServed == null
          ? const Value.absent()
          : Value(changes.householdsServed),
      functionalStatus: changes.functionalStatus == null
          ? const Value.absent()
          : Value(changes.functionalStatus!),
    ),
  );

  @override
  Future<WaterSource> deactivate(String id, SubmissionOrigin origin) => _change(
    id,
    origin,
    (_) => const WaterSourcesCompanion(isActive: Value(false)),
  );
}
