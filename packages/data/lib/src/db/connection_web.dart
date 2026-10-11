import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

import 'database.dart';
import 'key_store.dart';

/// Web: an in-memory database that is never persisted (SPEC §10.2, errata
/// G8, ADR-006). The key store is unused. Needs `web/sqlite3.wasm`.
Future<AppDatabase> openAppDatabase({
  required DatabaseKeyStore keys,
  String fileName = 'watercheck.db',
}) async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return AppDatabase(WasmDatabase.inMemory(sqlite3));
}

/// Web keeps nothing on disk, so there is nothing to delete.
Future<void> deleteAppDatabase({String fileName = 'watercheck.db'}) async {}
