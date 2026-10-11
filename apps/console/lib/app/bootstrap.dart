import 'package:data/data.dart';
import 'package:flutter/foundation.dart';

import 'auth_api.dart';
import 'perf.dart';
import 'session.dart';

class ConsoleBoot {
  const ConsoleBoot({
    required this.db,
    required this.api,
    required this.values,
    required this.restored,
  });

  final AppDatabase db;
  final ConsoleAuthApi api;
  final SecureValues values;
  final RestoredSession restored;
}

/// Opens the local cache, imports the bundled seed and restores the session
/// (web: refresh cookie; Windows/Android: saved session behind the PIN).
Future<ConsoleBoot> openConsole() async {
  final db = await openAppDatabase(
    keys: kIsWeb ? InMemoryKeyStore() : SecureStorageKeyStore(),
  );
  perfMark('db_open');
  // The bundled seed lets Windows and Android work offline from the first
  // start. The web keeps nothing between visits and gets the same reference
  // data from the first sync, showing the server summary meanwhile, so it
  // skips the import (0.7 s per load on 3G, 6.5 s on a first visit).
  if (!kIsWeb) {
    await SeedImporter(db).importBundle(await SeedBundle.fromAssets());
  }
  perfMark('seed_imported');
  final values = SecureStorageValues();
  final api = HttpConsoleAuthApi(baseUrl: defaultApiUrl(), cookieMode: kIsWeb);
  final restored = await restoreSession(
    api: api,
    store: SessionStore(values),
    lock: AppLock(values, key: consoleLockKey),
  );
  perfMark('session_restored');
  return ConsoleBoot(db: db, api: api, values: values, restored: restored);
}
