import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import 'support.dart';

/// An administrative unit (country → district → … → village).
typedef AdminUnit = ({
  String id,
  String code,
  String level,
  String name,
  String? parentId,

  /// Centre point (regions, districts, sub-counties), for the map.
  double? lat,
  double? lon,
});

/// Read access to reference data, and the two user-created kinds of it
/// (custom profiles F-TST-9, custom parameters F-TST-8).
abstract interface class ReferenceDataRepository {
  Future<ParameterCatalogue> catalogue();
  Future<DomainRules> rules();

  /// Pick lists from `lists.json` (collector types, source types, …).
  Future<JsonMap> lists();

  /// A configuration document pulled from the server (e.g.
  /// `notifications`), or null before the first sync.
  Future<JsonMap?> configOrNull(String key);
  Future<List<ReferenceProfile>> referenceProfiles();
  Future<ReferenceProfile?> referenceProfile(String id);
  Future<List<TesterProfile>> testerProfiles();
  Future<List<AdminUnit>> adminUnits();

  /// The response card for an alert trigger (SPEC §6.3), as seeded JSON:
  /// `title`, `actions`, `report_to`, `report_note`.
  Future<JsonMap?> responseCard(String triggerRule);

  /// Stores a custom profile created at calibration and queues it for sync.
  Future<void> saveCustomProfile(
    ReferenceProfile profile,
    SubmissionOrigin origin,
  );

  /// Stores a user-defined parameter and queues it for sync.
  Future<void> saveCustomParameter(
    ParameterDefinition parameter,
    SubmissionOrigin origin, {
    String? scopeAdminUnitId,
  });
}

class DriftReferenceDataRepository implements ReferenceDataRepository {
  DriftReferenceDataRepository(this._db, {this.clock = systemClock});

  final AppDatabase _db;
  final Clock clock;

  @override
  Future<ParameterCatalogue> catalogue() async {
    final categories = await (_db.select(
      _db.parameterCategories,
    )..orderBy([(t) => OrderingTerm(expression: t.displayOrder)])).get();
    final parameters = await _db.select(_db.parameterDefinitions).get();
    return ParameterCatalogue(
      categories: [
        for (final c in categories)
          ParameterCategory(
            code: c.code,
            name: c.name,
            displayOrder: c.displayOrder,
          ),
      ],
      parameters: [
        for (final p in parameters)
          ParameterDefinition(
            code: p.code,
            name: p.name,
            categoryCode: p.categoryCode,
            defaultUnit: p.defaultUnit,
            valueType: ValueType.fromCode(p.valueType),
            isCore: p.isCore,
            displayOrder: p.displayOrder,
            plausibleMin: decimalOrNull(p.plausibleMin),
            plausibleMax: decimalOrNull(p.plausibleMax),
            isCustom: p.isCustom,
          ),
      ],
    );
  }

  Future<JsonMap> _config(String key) async {
    final row = await (_db.select(
      _db.configDocuments,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    if (row == null) {
      throw StateError('Config "$key" missing: seed not imported');
    }
    return (jsonDecode(row.document) as Map).cast<String, Object?>();
  }

  @override
  Future<DomainRules> rules() async =>
      DomainRules.fromJson(await _config('rules'));

  @override
  Future<JsonMap> lists() => _config('lists');

  @override
  Future<JsonMap?> configOrNull(String key) async {
    final row = await (_db.select(
      _db.configDocuments,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row == null
        ? null
        : (jsonDecode(row.document) as Map).cast<String, Object?>();
  }

  @override
  Future<List<ReferenceProfile>> referenceProfiles() async {
    final rows = await (_db.select(
      _db.referenceProfiles,
    )..orderBy([(t) => OrderingTerm(expression: t.code)])).get();
    return [for (final r in rows) _profile(r)];
  }

  @override
  Future<ReferenceProfile?> referenceProfile(String id) async {
    final row = await (_db.select(
      _db.referenceProfiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _profile(row);
  }

  ReferenceProfile _profile(ReferenceProfileRow r) => ReferenceProfile.fromJson(
    (jsonDecode(r.document) as Map).cast<String, Object?>(),
  );

  @override
  Future<List<TesterProfile>> testerProfiles() async {
    final rows = await _db.select(_db.testerProfiles).get();
    return [
      for (final r in rows)
        TesterProfile.fromJson({
          'id': r.id,
          'name': r.name,
          'manufacturer': r.manufacturer,
          'model': r.model,
          'tds_factor': r.tdsFactor,
          'parameters': jsonDecode(r.parameters),
        }),
    ];
  }

  @override
  Future<List<AdminUnit>> adminUnits() async {
    final rows = await _db.select(_db.adminUnits).get();
    return [
      for (final r in rows)
        (
          id: r.id,
          code: r.code,
          level: r.level,
          name: r.name,
          parentId: r.parentId,
          lat: r.centerLat,
          lon: r.centerLon,
        ),
    ];
  }

  @override
  Future<JsonMap?> responseCard(String triggerRule) async {
    final row =
        await (_db.select(_db.responseCards)
              ..where(
                (c) =>
                    c.triggerRule.equals(triggerRule) &
                    c.audience.equals('collector'),
              )
              ..orderBy([(c) => OrderingTerm.desc(c.version)])
              ..limit(1))
            .getSingleOrNull();
    return row == null
        ? null
        : (jsonDecode(row.content) as Map).cast<String, Object?>();
  }

  @override
  Future<void> saveCustomProfile(
    ReferenceProfile profile,
    SubmissionOrigin origin,
  ) {
    if (!profile.isCustom) {
      throw ArgumentError.value(
        profile.code,
        'profile',
        'Not a custom profile',
      );
    }
    return _db.transaction(() async {
      final row = ReferenceProfilesCompanion.insert(
        id: profile.id,
        code: profile.code,
        title: profile.title,
        version: profile.version,
        basedOnId: Value(profile.basedOnId),
        isCustom: const Value(true),
        customReason: Value(profile.customReason),
        document: jsonEncode(profile.toJson()),
        installationId: Value(origin.installationId),
        collectorKey: Value(origin.collectorKey),
        collectorSnapshot: Value(origin.snapshotJson),
      );
      await _db.into(_db.referenceProfiles).insert(row);
      await enqueueOutbox(
        _db,
        entity: 'reference_standard',
        entityId: profile.id,
        op: OutboxOp.insert,
        payload: {
          ...profile.toJson(),
          'installation_id': origin.installationId,
          'collector_key': origin.collectorKey,
          'collector_snapshot': origin.collector?.toJson(),
          'created_by': origin.userId,
        },
        at: clock(),
      );
    });
  }

  @override
  Future<void> saveCustomParameter(
    ParameterDefinition parameter,
    SubmissionOrigin origin, {
    String? scopeAdminUnitId,
  }) {
    if (!parameter.isCustom ||
        !parameter.code.startsWith(ParameterDefinition.customPrefix)) {
      throw ArgumentError.value(parameter.code, 'parameter', 'Not custom');
    }
    return _db.transaction(() async {
      await _db
          .into(_db.parameterDefinitions)
          .insert(
            ParameterDefinitionsCompanion.insert(
              code: parameter.code,
              name: parameter.name,
              categoryCode: parameter.categoryCode,
              defaultUnit: parameter.defaultUnit,
              valueType: parameter.valueType.name,
              isCustom: const Value(true),
              plausibleMin: Value(parameter.plausibleMin?.toString()),
              plausibleMax: Value(parameter.plausibleMax?.toString()),
              scopeAdminUnitId: Value(scopeAdminUnitId),
              reviewStatus: const Value('pending'),
              installationId: Value(origin.installationId),
              collectorKey: Value(origin.collectorKey),
              collectorSnapshot: Value(origin.snapshotJson),
            ),
          );
      await enqueueOutbox(
        _db,
        entity: 'parameter_definition',
        entityId: parameter.code,
        op: OutboxOp.insert,
        payload: {
          ...parameter.toJson(),
          'scope_admin_unit_id': scopeAdminUnitId,
          'review_status': 'pending',
          'installation_id': origin.installationId,
          'collector_key': origin.collectorKey,
          'collector_snapshot': origin.collector?.toJson(),
          'created_by': origin.userId,
        },
        at: clock(),
      );
    });
  }
}
