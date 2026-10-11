import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';
import 'key_store.dart';

/// Opens the encrypted app database in the app-private support directory.
Future<AppDatabase> openAppDatabase({
  required DatabaseKeyStore keys,
  String fileName = 'watercheck.db',
}) async {
  final dir = await getApplicationSupportDirectory();
  final key = await keys.readOrCreate();
  return AppDatabase(encryptedExecutor(File(p.join(dir.path, fileName)), key));
}

/// Deletes the database file (revocation wipe, F-AUTH-4). Close it first.
Future<void> deleteAppDatabase({String fileName = 'watercheck.db'}) async {
  final dir = await getApplicationSupportDirectory();
  for (final suffix in const ['', '-wal', '-shm', '-journal']) {
    final f = File(p.join(dir.path, '$fileName$suffix'));
    if (f.existsSync()) await f.delete();
  }
}

/// A background-isolate executor for an encrypted file (ADR-008).
QueryExecutor encryptedExecutor(File file, String key) =>
    NativeDatabase.createInBackground(file, setup: (db) => applyKey(db, key));

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// Unlocks [db] with [key] and fails fast if the key is wrong.
void applyKey(Database db, String key) {
  if (!_hexKey.hasMatch(key)) {
    throw ArgumentError('Database key must be 64 lowercase hex characters');
  }
  db
    ..execute("PRAGMA key = '$key';")
    ..select('SELECT count(*) FROM sqlite_master');
}
