import 'package:data/data.dart';
import 'package:flutter/foundation.dart';

import 'auth_api.dart';
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
  await SeedImporter(db).importBundle(await SeedBundle.fromAssets());
  final values = SecureStorageValues();
  final api = HttpConsoleAuthApi(baseUrl: defaultApiUrl(), cookieMode: kIsWeb);
  final restored = await restoreSession(
    api: api,
    store: SessionStore(values),
    lock: AppLock(values, key: consoleLockKey),
  );
  return ConsoleBoot(db: db, api: api, values: values, restored: restored);
}
