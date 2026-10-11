@TestOn('vm')
library;

import 'dart:io';

import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'support/fixtures.dart';

/// P2 gate: the database file on disk is unreadable without the key.
void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('wc_enc_'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('app database file cannot be read without the key', () async {
    final file = File('${dir.path}/watercheck.db');
    final key = generateDatabaseKey();
    final db = AppDatabase(encryptedExecutor(file, key));
    await SeedImporter(db).importBundle(await seedFromInfra());
    final source = await DriftSourceRepository(db).create(
      const NewSource(
        villageId: 'village',
        code: 'ABIM-ENT-001',
        sourceType: 'borehole',
        name: 'Secret-named borehole',
      ),
      origin,
    );
    expect(source.code, 'ABIM-ENT-001');
    await db.close();

    final bytes = file.readAsBytesSync();
    expect(String.fromCharCodes(bytes.take(15)), isNot('SQLite format 3'));
    expect(String.fromCharCodes(bytes).contains('Secret-named'), isFalse);
    expect(String.fromCharCodes(bytes).contains('Example Collector'), isFalse);

    final raw = sqlite3.open(file.path);
    expect(
      () => raw.select('SELECT * FROM water_sources'),
      throwsA(isA<SqliteException>()),
    );
    raw.close();

    final wrong = sqlite3.open(file.path);
    expect(() => applyKey(wrong, generateDatabaseKey()), throwsA(anything));
    wrong.close();

    final reopened = AppDatabase(encryptedExecutor(file, key));
    final rows = await reopened.select(reopened.waterSources).get();
    expect(rows.single.name, 'Secret-named borehole');
    await reopened.close();
  });

  test('keys are 64 hex characters and malformed keys are refused', () async {
    expect(generateDatabaseKey(), matches(RegExp(r'^[0-9a-f]{64}$')));
    final store = InMemoryKeyStore();
    final first = await store.readOrCreate();
    expect(await store.readOrCreate(), first);
    await store.delete();
    expect(await store.readOrCreate(), isNot(first));

    final raw = sqlite3.openInMemory();
    expect(() => applyKey(raw, "x'; DROP TABLE t; --"), throwsArgumentError);
    raw.close();
  });
}
