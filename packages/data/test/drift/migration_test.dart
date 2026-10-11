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
    await verifier.migrateAndValidate(db, 2);
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
    await verifier.migrateAndValidate(db, 3);
    expect((await db.select(db.syncState).getSingle()).cursorToken, '5.9');
    expect(await db.select(db.collectorMarks).get(), isEmpty);
    await db.close();
  });
}
