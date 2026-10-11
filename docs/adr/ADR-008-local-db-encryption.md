# ADR-008: Local database encryption with SQLite3 Multiple Ciphers

- Status: Accepted (2026-10-10)
- Amends: SPEC §5.5 and §10.1 (`sqlcipher_flutter_libs`), P2 task "SQLCipher encryption"

## Context

The spec asks for Drift on SQLCipher via `sqlcipher_flutter_libs`. Since early 2026, `package:sqlite3` 3.x bundles SQLite itself through Dart build hooks, and `sqlcipher_flutter_libs` / `sqlite3_flutter_libs` are end-of-life (`+eol` releases). The new package offers three builds, chosen with a hook user-define:

- plain SQLite;
- **SQLite3 Multiple Ciphers (`sqlite3mc`)**;
- SQLCipher, which links OpenSSL on Windows and Android and may trail upstream SQLite.

## Decision

Use **`source: sqlite3mc`**, set in the workspace root `pubspec.yaml` (`hooks.user_defines.sqlite3`).

- The whole file is encrypted with the default cipher (ChaCha20-Poly1305), using `PRAGMA key`.
- A 256-bit random key is generated on first run and kept in `flutter_secure_storage` (Android Keystore, Windows DPAPI).
- On web (Console, and the Collect preview of ADR-006) the database is in-memory and never persisted, as G8 and ADR-006 require.

Spike evidence (2026-10-10, Windows): `packages/data/test/encryption_spike_test.dart` shows that a keyed file has no `SQLite format 3` header and no readable content, fails without the key, and opens with it.

## Consequences

- There is no OpenSSL in the app, which helps the APK size target (< 30 MB) and avoids OpenSSL licensing notices.
- If SQLCipher file compatibility is ever needed (e.g. tooling that only reads SQLCipher), sqlite3mc can switch to its SQLCipher scheme with `PRAGMA cipher = 'sqlcipher'`, or the user-define can change to `sqlcipher`. Both are configuration only.
- Release builds download prebuilt, hash-verified binaries from the `sqlite3.dart` GitHub releases at build time. The SBOM (P12) must include them.
- Android must be verified as well. The P2 gate's "unreadable without the key" test runs on the host VM; it is repeated on Android at the P3 device check.
