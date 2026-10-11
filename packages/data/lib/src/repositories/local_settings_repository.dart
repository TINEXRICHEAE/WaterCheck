import 'dart:convert';

import '../db/database.dart';
import 'support.dart';

/// Small device-local settings (never synced), stored as `local.*` config
/// documents next to the seeded configuration.
abstract interface class LocalSettingsRepository {
  Future<String?> read(String key);
  Future<void> write(String key, String? value);

  /// This installation's ID. Until activation (P5) it is a local UUID; the
  /// activation flow replaces it with the server-issued one.
  Future<String> installationId();

  /// Version of the privacy notice the user agreed to, if any (SPEC §9.3).
  Future<int?> consentVersion();
  Future<void> recordConsent(int version);
}

class DriftLocalSettingsRepository implements LocalSettingsRepository {
  DriftLocalSettingsRepository(
    this._db, {
    this.clock = systemClock,
    this.ids = const IdGenerator(),
  });

  static const _prefix = 'local.';
  static const installationKey = 'installation.id';
  static const consentKey = 'privacy.consent';

  final AppDatabase _db;
  final Clock clock;
  final IdGenerator ids;

  @override
  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.configDocuments,
    )..where((t) => t.key.equals('$_prefix$key'))).getSingleOrNull();
    return row == null ? null : jsonDecode(row.document) as String?;
  }

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      await (_db.delete(
        _db.configDocuments,
      )..where((t) => t.key.equals('$_prefix$key'))).go();
      return;
    }
    await _db
        .into(_db.configDocuments)
        .insertOnConflictUpdate(
          ConfigDocumentsCompanion.insert(
            key: '$_prefix$key',
            document: jsonEncode(value),
            version: 1,
          ),
        );
  }

  @override
  Future<String> installationId() => _db.transaction(() async {
    final existing = await read(installationKey);
    if (existing != null) return existing;
    final id = ids.next();
    await write(installationKey, id);
    return id;
  });

  @override
  Future<int?> consentVersion() async {
    final raw = await read(consentKey);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map)['version'] as int?;
  }

  @override
  Future<void> recordConsent(int version) => write(
    consentKey,
    jsonEncode({'version': version, 'at': clock().toIso8601String()}),
  );
}
