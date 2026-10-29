@TestOn('vm')
library;

import 'package:data/data.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app/generated/schema.dart';

/// Migration harness (P2 gate). Each new schema version adds
/// `drift_schemas/app/drift_schema_vN.json` (`dart run drift_dev
/// make-migrations`) and a migrate-and-validate case below.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('a database created at v1 matches the saved v1 schema', () async {
    final db = AppDatabase(await verifier.startAt(1));
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('creating from empty produces exactly the declared schema', () async {
    final db = AppDatabase(
      DatabaseConnection(await verifier.startAt(localSchemaVersion)),
    );
    await db.validateDatabaseSchema();
    expect(db.schemaVersion, localSchemaVersion);
    await db.close();
  });

  test('every older version migrates to the current schema', () async {
    for (final from in GeneratedHelper.versions) {
      if (from == localSchemaVersion) continue;
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase(schema.newConnection());
      await verifier.migrateAndValidate(db, localSchemaVersion);
      await db.close();
    }
  });

  test('v1 → v2 keeps unsent records and adds the sync state', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(
      "INSERT INTO outbox (entity, entity_id, op, payload, created_at) "
      "VALUES ('water_source', 'src-1', 'insert', '{}', '2026-10-10T09:00:00Z')",
    );
    schema.rawDatabase.execute(
      "INSERT INTO sync_state (stream, cursor) VALUES ('reference', 0)",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, localSchemaVersion);
    final outbox = await db.select(db.outbox).get();
    expect(outbox.single.entityId, 'src-1');
    expect(outbox.single.status, 'pending');
    final state = await db.select(db.syncState).getSingle();
    expect(state.failures, 0);
    expect(state.cursorToken, isNull);
    expect(await db.select(db.syncLocks).get(), isEmpty);
    await db.close();
  });

  test('v2 → v3 keeps sync state and adds marks and flags', () async {
    final schema = await verifier.schemaAt(2);
    schema.rawDatabase.execute(
      "INSERT INTO sync_state (stream, cursor, cursor_token, failures) "
      "VALUES ('scope', 0, '5.9', 0)",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, localSchemaVersion);
    expect((await db.select(db.syncState).getSingle()).cursorToken, '5.9');
    expect(await db.select(db.collectorMarks).get(), isEmpty);
    await db.close();
  });

  test('v3 → v4 keeps areas and adds P-codes and centre points', () async {
    final schema = await verifier.schemaAt(3);
    schema.rawDatabase.execute(
      "INSERT INTO admin_units (id, level, name, code) "
      "VALUES ('u-1', 'district', 'Abim', 'UG-ABIM')",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, localSchemaVersion);
    final unit = await db.select(db.adminUnits).getSingle();
    expect(unit.code, 'UG-ABIM');
    expect(unit.pcode, isNull);
    expect(unit.centerLat, isNull);
    await db.close();
  });

  test('v10 → v11 keeps names and pictures, adds who added a place, where '
      'a picture was taken, and trips', () async {
    final schema = await verifier.schemaAt(10);
    schema.rawDatabase
      ..execute(
        "INSERT INTO place_names (id, name, kind, lat, lon, subcounty_id) "
        "VALUES ('p-1', 'Kabojja', 'village', 0.3, 32.5, 's-1')",
      )
      ..execute(
        "INSERT INTO attachments (id, owner_type, owner_id, sha256, bytes, mime) "
        "VALUES ('a-1', 'water_source', 'src-1', 'x', 10, 'image/jpeg')",
      );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, localSchemaVersion);
    final place = await db.select(db.placeNames).getSingle();
    expect((place.name, place.addedAt), ('Kabojja', null));
    final picture = await db.select(db.attachments).getSingle();
    expect((picture.id, picture.takenLat), ('a-1', null));
    expect(await db.select(db.trips).get(), isEmpty);
    await db.close();
  });

  test('v11 → v12 keeps pictures and adds research', () async {
    final schema = await verifier.schemaAt(11);
    schema.rawDatabase.execute(
      "INSERT INTO attachments (id, owner_type, owner_id, sha256, bytes, mime) "
      "VALUES ('a-1', 'water_source', 'src-1', 'x', 10, 'image/jpeg')",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, localSchemaVersion);
    final picture = await db.select(db.attachments).getSingle();
    expect((picture.id, picture.fieldName), ('a-1', null));
    expect(await db.select(db.researchForms).get(), isEmpty);
    await db.close();
  });

  test('v12 → v13: profiles that collected for research become research '
      'profiles; the rest test water (ADR-031)', () async {
    final schema = await verifier.schemaAt(12);
    for (final key in ['w', 'r']) {
      schema.rawDatabase.execute(
        "INSERT INTO collector_profiles (collector_key, profile_version, "
        "full_name, phone, collector_type, village, parish, subcounty, "
        "district, updated_at) VALUES ('$key', 1, 'P', '', 'vht', 'V', 'P', "
        "'S', 'D', '2026-10-27T09:00:00Z')",
      );
    }
    schema.rawDatabase.execute(
      "INSERT INTO research_drafts (id, form_id, form_version, collector_key, "
      "answers, started_at, updated_at) VALUES ('d', 'f', 1, 'r', '{}', "
      "'2026-10-27T09:00:00Z', '2026-10-27T09:00:00Z')",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, localSchemaVersion);
    final sides = {
      for (final p in await db.select(db.collectorProfiles).get())
        p.collectorKey: (p.side, p.legalVersion),
    };
    expect(sides, {'w': ('water', 0), 'r': ('research', 0)});
    await db.close();
  });

  test('v13 → v14 keeps drafts and records where a location came from '
      '(2026-10-29)', () async {
    final schema = await verifier.schemaAt(13);
    schema.rawDatabase.execute(
      "INSERT INTO research_drafts (id, form_id, form_version, answers, "
      "started_at, updated_at, lat, lon) VALUES ('d', 'f', 1, '{}', "
      "'2026-10-28T09:00:00Z', '2026-10-28T09:00:00Z', 2.69, 33.65)",
    );
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, localSchemaVersion);
    final draft = await db.select(db.researchDrafts).getSingle();
    // Kept, and measured on the device (no source given).
    expect((draft.lat, draft.locationSource), (2.69, null));
    await db.close();
  });
}
