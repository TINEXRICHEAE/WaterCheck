import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A small key-value store for secrets: credentials, the app-lock PIN hash.
/// Native: Android Keystore / Windows DPAPI via `flutter_secure_storage`.
abstract interface class SecureValues {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureStorageValues implements SecureValues {
  SecureStorageValues([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// For tests.
class MemoryValues implements SecureValues {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
