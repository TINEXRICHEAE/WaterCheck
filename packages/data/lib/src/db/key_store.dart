import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the local database key (ADR-008).
abstract interface class DatabaseKeyStore {
  /// The key, created on first use: 32 random bytes as 64 hex characters.
  Future<String> readOrCreate();

  /// Forgets the key, which makes the database file unreadable (used by the
  /// revocation wipe, F-AUTH-4).
  Future<void> delete();
}

String generateDatabaseKey([Random? random]) {
  final rng = random ?? Random.secure();
  return List.generate(
    32,
    (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

/// Android Keystore / Windows DPAPI through `flutter_secure_storage`.
class SecureStorageKeyStore implements DatabaseKeyStore {
  SecureStorageKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _name = 'watercheck.db.key.v1';
  final FlutterSecureStorage _storage;

  @override
  Future<String> readOrCreate() async {
    final existing = await _storage.read(key: _name);
    if (existing != null) return existing;
    final key = generateDatabaseKey();
    await _storage.write(key: _name, value: key);
    return key;
  }

  @override
  Future<void> delete() => _storage.delete(key: _name);
}

/// For tests and the web preview.
class InMemoryKeyStore implements DatabaseKeyStore {
  InMemoryKeyStore([this._key]);

  String? _key;

  @override
  Future<String> readOrCreate() async => _key ??= generateDatabaseKey();

  @override
  Future<void> delete() async => _key = null;
}
