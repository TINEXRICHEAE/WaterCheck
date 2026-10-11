import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Encrypted export of unsynced data (F-SYN-5, ADR-010).
///
/// The key is derived from the installation secret, which the server also
/// holds (encrypted at rest), so an IT admin can import the file later while
/// anyone else who finds it cannot read it. Nobody has to remember a
/// passphrase.
///
/// File: a JSON envelope whose header is readable (which installation, when)
/// and whose `ciphertext` is AES-256-GCM over the UTF-8 JSON content, with
/// the tag appended and the installation ID as associated data.
/// Key = HKDF-SHA256(ikm = secret, salt = [exportSalt], info = [exportInfo]).
class ExportFile {
  const ExportFile._();

  static const format = 'watercheck-export';
  static const version = 1;
  static const exportSalt = 'watercheck-export-v1';
  static const exportInfo = 'unsynced-data';

  static Future<SecretKey> _key(String secret) =>
      Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
        secretKey: SecretKey(utf8.encode(secret)),
        nonce: utf8.encode(exportSalt),
        info: utf8.encode(exportInfo),
      );

  /// Returns the file contents. [nonce] and [createdAt] are for test vectors.
  static Future<String> encrypt({
    required String installationId,
    required String secret,
    required Map<String, Object?> content,
    required DateTime createdAt,
    List<int>? nonce,
  }) async {
    final n =
        nonce ?? List<int>.generate(12, (_) => Random.secure().nextInt(256));
    final box = await AesGcm.with256bits().encrypt(
      utf8.encode(jsonEncode(content)),
      secretKey: await _key(secret),
      nonce: n,
      aad: utf8.encode(installationId),
    );
    return const JsonEncoder.withIndent('  ').convert({
      'format': format,
      'version': version,
      'installation_id': installationId,
      'created_at': createdAt.toUtc().toIso8601String(),
      'alg': 'A256GCM+HKDF-SHA256',
      'nonce': base64.encode(n),
      'ciphertext': base64.encode([...box.cipherText, ...box.mac.bytes]),
    });
  }

  /// The reverse (used by tests; the server's import does the same).
  static Future<Map<String, Object?>> decrypt(
    String file,
    String secret,
  ) async {
    final env = (jsonDecode(file) as Map).cast<String, Object?>();
    if (env['format'] != format || env['version'] != version) {
      throw const FormatException('Not a WaterCheck export file');
    }
    final data = base64.decode(env['ciphertext']! as String);
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(
        data.sublist(0, data.length - 16),
        nonce: base64.decode(env['nonce']! as String),
        mac: Mac(data.sublist(data.length - 16)),
      ),
      secretKey: await _key(secret),
      aad: utf8.encode(env['installation_id']! as String),
    );
    return (jsonDecode(utf8.decode(clear)) as Map).cast();
  }
}
