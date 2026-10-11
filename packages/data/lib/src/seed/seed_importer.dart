import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../repositories/support.dart';
import 'seed_bundle.dart';

/// Imports the bundled seed on first run, and again whenever a document's
/// `version` increases (until sync delivers reference data, F-SYN-4).
/// User-created custom parameters and profiles are never overwritten.
class SeedImporter {
  SeedImporter(this._db, {this.clock = systemClock});

  final AppDatabase _db;
  final Clock clock;

  /// Returns the names of the documents that were (re)imported.
  Future<List<String>> importBundle(
    SeedBundle seed,
  ) => _db.transaction(() async {
    final imported = <String>[];
    Future<void> step(String name, JsonMap doc, Future<void> Function() run) =>
        _step(name, doc, run, imported);

    await step('catalogue', seed.catalogue, () => _catalogue(seed.catalogue));
    await step('rules', seed.rules, () => _config('rules', seed.rules));
    await step('lists', seed.lists, () => _config('lists', seed.lists));
    await step(
      'tester_profiles',
      seed.testerProfiles,
      () => _testerProfiles(seed.testerProfiles),
    );
    for (final profile in seed.referenceProfiles) {
      await step(
        'reference_profile:${profile['code']}',
        profile,
        () => _referenceProfile(profile),
      );
    }
    await step(
      'response_cards',
      seed.responseCards,
      () => _responseCards(seed.responseCards),
    );
    await step(
      'responsibilities',
      seed.responsibilities,
      () => _responsibilities(seed.responsibilities),
    );
    await step(
      'admin_units',
      seed.adminUnits,
      () => _adminUnits(seed.adminUnits),
    );
    return imported;
  });

  /// Imports server-published documents that use the seed format (rules,
  /// lists, reference profiles), e.g. right after activation (P5). The full
  /// versioned reference pull is the sync engine's job (P6, F-SYN-4).
  Future<List<String>> importPublished({
    JsonMap? rules,
    JsonMap? lists,
    List<JsonMap> profiles = const [],
  }) => _db.transaction(() async {
    final imported = <String>[];
    if (rules != null) {
      await _step('rules', rules, () => _config('rules', rules), imported);
    }
    if (lists != null) {
      await _step('lists', lists, () => _config('lists', lists), imported);
    }
    for (final profile in profiles) {
      await _step(
        'reference_profile:${profile['code']}',
        profile,
        () => _referenceProfile(profile),
        imported,
      );
    }
    return imported;
  });

  /// Runs [run] if [doc] is newer than what was imported under [name].
  Future<void> _step(
    String name,
    JsonMap doc,
    Future<void> Function() run,
    List<String> imported,
  ) async {
    final version = doc['version']! as int;
    final existing = await (_db.select(
      _db.seedImports,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    if (existing != null && existing.version >= version) return;
    await run();
    await _db
        .into(_db.seedImports)
        .insertOnConflictUpdate(
          SeedImportsCompanion.insert(
            name: name,
            version: version,
            importedAt: clock(),
          ),
        );
    imported.add(name);
  }

  Future<void> _catalogue(JsonMap json) async {
    // Validate with the domain parser before writing anything.
    final catalogue = ParameterCatalogue.fromJson(json);
    for (final c in catalogue.categories) {
      await _db
          .into(_db.parameterCategories)
          .insertOnConflictUpdate(
            ParameterCategoriesCompanion.insert(
              code: c.code,
              name: c.name,
              displayOrder: c.displayOrder,
            ),
          );
    }
    for (final p in catalogue.parameters) {
      await _db
          .into(_db.parameterDefinitions)
          .insertOnConflictUpdate(
            ParameterDefinitionsCompanion.insert(
              code: p.code,
              name: p.name,
              categoryCode: p.categoryCode,
              defaultUnit: p.defaultUnit,
              valueType: p.valueType.name,
              isCore: Value(p.isCore),
              displayOrder: Value(p.displayOrder),
              plausibleMin: Value(p.plausibleMin?.toString()),
              plausibleMax: Value(p.plausibleMax?.toString()),
            ),
          );
    }
  }

  Future<void> _config(String key, JsonMap json) async {
    if (key == 'rules') DomainRules.fromJson(json); // validate
    await _db
        .into(_db.configDocuments)
        .insertOnConflictUpdate(
          ConfigDocumentsCompanion.insert(
            key: key,
            document: jsonEncode(json),
            version: json['version']! as int,
          ),
        );
  }

  Future<void> _testerProfiles(JsonMap json) async {
    for (final p in TesterProfile.listFromJson(json)) {
      await _db
          .into(_db.testerProfiles)
          .insertOnConflictUpdate(
            TesterProfilesCompanion.insert(
              id: p.id,
              name: p.name,
              manufacturer: Value(p.manufacturer),
              model: Value(p.model),
              tdsFactor: Value(p.tdsFactor?.toString()),
              parameters: jsonEncode([
                for (final x in p.parameters)
                  {'parameter_code': x.code, 'unit': x.unit},
              ]),
            ),
          );
    }
  }

  Future<void> _referenceProfile(JsonMap json) async {
    final p = ReferenceProfile.fromJson(json); // validate
    await _db
        .into(_db.referenceProfiles)
        .insertOnConflictUpdate(
          ReferenceProfilesCompanion.insert(
            id: p.id,
            code: p.code,
            title: p.title,
            version: p.version,
            basedOnId: Value(p.basedOnId),
            isCustom: Value(p.isCustom),
            customReason: Value(p.customReason),
            isProvisional: Value(p.isProvisional),
            publishedAt: Value(
              DateTime.tryParse(json['published_at'] as String? ?? ''),
            ),
            document: jsonEncode(json),
          ),
        );
  }

  Future<void> _responseCards(JsonMap json) async {
    for (final c
        in (json['response_cards']! as List).cast<Map<String, Object?>>()) {
      await _db
          .into(_db.responseCards)
          .insertOnConflictUpdate(
            ResponseCardsCompanion.insert(
              id: c['id']! as String,
              triggerRule: c['trigger_rule']! as String,
              audience: c['audience']! as String,
              version: c['version']! as int,
              content: jsonEncode(c),
            ),
          );
    }
  }

  Future<void> _responsibilities(JsonMap json) async {
    for (final r
        in (json['responsibilities']! as List).cast<Map<String, Object?>>()) {
      await _db
          .into(_db.responsibilities)
          .insertOnConflictUpdate(
            ResponsibilitiesCompanion.insert(
              code: r['code']! as String,
              name: r['name']! as String,
            ),
          );
    }
  }

  Future<void> _adminUnits(JsonMap json) async {
    // Parents are listed before children in the seed.
    for (final u
        in (json['admin_units']! as List).cast<Map<String, Object?>>()) {
      await _db
          .into(_db.adminUnits)
          .insertOnConflictUpdate(
            AdminUnitsCompanion.insert(
              id: u['id']! as String,
              level: u['level']! as String,
              name: u['name']! as String,
              code: u['code']! as String,
              parentId: Value(u['parent_id'] as String?),
            ),
          );
    }
  }
}
