import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

import 'database.dart';
import 'key_store.dart';

/// Web. With [persistOnWeb] (Collect, ADR-022) the database is kept in the
/// browser's IndexedDB, so a reload or an installed web app keeps its work
/// and works offline; it is not encrypted at rest (a browser limit, behind
/// the app PIN). Without it (the Console, shared office computers) the
/// database is in memory and nothing is kept (SPEC §10.2, errata G8,
/// ADR-006). The key store is unused. Needs `web/sqlite3.wasm`.
Future<AppDatabase> openAppDatabase({
  required DatabaseKeyStore keys,
  String fileName = 'watercheck.db',
  bool persistOnWeb = false,
}) async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  if (!persistOnWeb) {
    sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
    return AppDatabase(WasmDatabase.inMemory(sqlite3));
  }
  final fs = await IndexedDbFileSystem.open(dbName: _store(fileName));
  sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
  return AppDatabase(
    WasmDatabase(sqlite3: sqlite3, path: '/$fileName', fileSystem: fs),
  );
}

/// One IndexedDB store per database file (Collect and the Console share
/// the `localhost` origin in development).
String _store(String fileName) => 'watercheck-$fileName';

/// Erases the kept database (a revoked or reset device).
Future<void> deleteAppDatabase({String fileName = 'watercheck.db'}) =>
    IndexedDbFileSystem.deleteDatabase(_store(fileName));
