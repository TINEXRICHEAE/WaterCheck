# ADR-010: Client access — Console sessions, app lock, revocation export

- Status: Accepted (2026-10-10)
- Covers: SPEC P5, F-AUTH-1/2/3/4/7, F-SYN-5, §10.2, §9.1 (account takeover, leaked codes)
- Builds on: ADR-009 (database roles, signing)

## Context

P5 connects both apps to the P4 backend. Three choices were open:

- how the web Console keeps a session across page reloads without exposing the refresh token to scripts (plan [DECIDE], §10.2);
- how a shared Collect phone and an offline Windows/Android Console are protected;
- how a revoked Collect phone saves unsent work before it is wiped (F-AUTH-4), in a file that is safe to hand around.

## Decision

### 1. Console tokens per platform

| Platform | Access token (15 min) | Refresh token |
|----------|-----------------------|---------------|
| Web | memory only | httpOnly cookie `wc_refresh`, `Secure`, `SameSite=Strict`, `Path=/api/v1/auth` |
| Windows, Android | memory only | secure storage (DPAPI / Keystore), with the cached profile |

- The web Console sends `X-Token-Transport: cookie` on sign-in and password change. The server then sets the cookie and leaves `refresh_token` out of the body.
- **CSRF:** refreshing or signing out with the cookie also needs the double-submit token: a readable `wc_csrf` cookie echoed in `X-CSRF-Token`. `SameSite=Strict` and the single origin (Caddy serves `/console/` and `/api/`) are further layers.
- Reuse detection (ADR-009) works the same for cookies: replaying an old cookie revokes the family.
- A temporary password cannot be finished after a page reload; the user signs in again.
- `refresh_cookie_path` and `cookie_secure` are settings. Browsers treat `http://localhost` as secure, so `Secure` stays on in development.

### 2. Idle timeout and PIN

- No input for 30 minutes (`--dart-define=WC_IDLE_MINUTES`) **signs the web Console out**. On Windows and Android it **locks** the Console instead.
- On Windows and Android, the first sign-in asks for a PIN. Later starts open at the PIN screen **without a network call**:
  - online: the saved refresh token is rotated;
  - offline: the cached profile and data are shown, with an offline banner;
  - refused (revoked, reset, reused): back to sign-in, and the saved session and PIN are deleted.
- "Forgot PIN" signs out. "Forgot password" leaves an audit-logged request for the IT admin (`POST /v1/auth/password-help`, `202` whether or not the account exists). Self-service reset by one-time code is F-AUTH-6 (S, P11).

### 3. Collect app lock

- **On by default.** After activation, a new installation is asked for a PIN and can turn the lock off there or later in Settings. Turning it off needs the current PIN.
- Fingerprint or face is offered when the phone supports it (`local_auth`; Android activity is a `FlutterFragmentActivity` with AppCompat themes so the prompt works on Android 8 and older).
- The lock shows on start and after 5 minutes in the background.
- **PIN storage:** PBKDF2-HMAC-SHA256 with a random salt, kept in secure storage.
  - A short PIN can be guessed offline whatever the hash, so the real defences are secure storage and the attempt limit.
  - After 5 wrong PINs every further mistake waits longer: 30 s, then doubling up to 15 min.
- "Forgot PIN?" leads to the reset flow below. Reset erases the phone and exports only a file the server can read, so it gives no way round the lock.

### 4. Activation and revocation on the phone

- **Activation** is the only step that needs the internet.
  - The code can be typed (case, spaces and dashes ignored) or scanned: QR `watercheck://activate?code=…&server=…` (Android, ML Kit via Play services, so the APK stays small).
  - The credentials and the clock offset go to secure storage.
  - The published rules, lists and reference profiles are imported if newer. The full versioned pull is P6.
- **Status check** (`GET /v1/installations/me`, signed) on start and on return to the app, at most every 5 minutes; offline changes nothing. The `Date` header keeps the clock offset fresh. A stale signature caused by a wrong phone clock is retried once with the corrected offset.
- **Revoked** (`403 installation_revoked`):
  - The flag is stored in secure storage, so a restart offline cannot get round it.
  - The app shows only the reset screen, before the PIN.
  - Steps: save unsent records → erase. Erasing deletes the credentials, the PIN, the database file and its key, then restarts at the privacy notice and activation.
  - Erasing without saving asks for confirmation and says how many records will be lost.

### 5. Encrypted export file (F-SYN-5)

- **Contents:** every outbox row not yet accepted (pending or rejected), with its full payload.
- **Format:** a JSON envelope whose header can be read (`format`, `version`, `installation_id`, `created_at`, `alg`, `nonce`), followed by the `ciphertext`.
  - Cipher: AES-256-GCM, tag appended, installation ID as associated data.
  - Key = HKDF-SHA256(installation secret, salt `watercheck-export-v1`, info `unsynced-data`).
- **Why the installation secret:** the server already keeps it (encrypted, ADR-009), so the IT admin import (P11, `app/services/export_file.py`) can open the file while nobody else can. No collector has to remember a passphrase.
- A shared test vector (`packages/data/test/vectors/export_v1.json`) is encrypted by Dart and decrypted by Python in the tests.

## Consequences

- Web Console sessions survive reloads, and scripts never see the refresh token. Clients must send `X-CSRF-Token` for cookie refresh and logout.
- Windows/Android Console data is only as safe as the device account plus the PIN; P6 must keep cached data in the encrypted database (ADR-008) and clear it on sign-out.
- If the server loses `WC_SECRET_KEY`, old export files can no longer be opened (same runbook as ADR-009, P12).
- Debug Android builds allow plain HTTP for the dev stack (`10.0.2.2`). Release builds keep Android's HTTPS-only default.
