# ADR-009: Database roles, area isolation and installation request signing

- Status: Accepted (2026-10-10)
- Covers: SPEC §9.1 (scope isolation, leaked codes, account takeover), F-AUTH-1/3/4/5/7, P4

## Context

Stakeholders must see only their areas, and Collect installations only their village. This must hold **in the database as well as in the API** (SPEC §4.1 F-AUTH-5). Collectors have no accounts; installations act for them, and every Collect request must be signed with the installation credential (SPEC P4). The server also needs the installation secret later, to verify SMS HMAC codes (P8).

## Decision

### 1. Two database roles

- **Owner** (`WC_MIGRATION_DATABASE_URL`): runs Alembic migrations, the seed loader (`python -m app.seed`) and the admin CLI (`python -m app.cli`). It owns the tables.
- **`watercheck_api`** (`WC_DATABASE_URL`): the only role the API connects as. It is a login role, `NOBYPASSRLS`, not the owner, and a member of `watercheck_app`.
  - The migration grants `watercheck_app` exactly the DML it needs.
  - `DELETE` is granted only on token, scope and nonce tables.
- The one-shot `migrate` service in Docker Compose runs the migrations, creates or updates `watercheck_api` with `API_DB_PASSWORD`, and loads the seed. The API starts only after it succeeds.

### 2. Area isolation by row-level security

Every transaction declares who is acting (`app/db/database.py`) through transaction-local settings, so they never leak to the next request on a pooled connection:

| Setting | Meaning |
|---------|---------|
| `app.user_id` | the signed-in Console user |
| `app.installation_id` | the signed Collect installation |
| `app.scope_units` | the caller's areas |
| `app.is_admin` | an IT admin, or a server job |
| `app.auth_context` | the sign-in and activation flows only |

How the policies work:

- `wc_in_scope(unit)` walks up the area hierarchy, so a district scope covers its villages and national scope covers everything.
- Area tables follow the source's village: `water_source`, then sessions, results, readings, classifications, alerts, events and inspections.
- People and credential tables are visible only to the user themselves, to IT admins, or within the sign-in flow.
- With no context set, nothing is visible (tested). Inserts outside the caller's scope are refused.
- Insert-only tables also have `BEFORE UPDATE OR DELETE` triggers that hold even for the owner.

### 3. Console sign-in

- Passwords: argon2id.
- New users get a temporary password and must change it before any other endpoint works (`403 password_change_required`).
- Access tokens: HS256 JWT, 15 minutes, carrying the role and the scope units.
- Refresh tokens: opaque, stored only as SHA-256 hashes, and rotated on every use.
  - A second use of a token revokes its whole family (assumed theft).
  - A password change ends all existing sessions.
- Five failed attempts lock the account for 15 minutes. Failures are committed before the error is returned, and unknown users get the same response and timing as wrong passwords.
- The app refuses to start in staging or prod with the development secrets.

### 4. Installation activation and signed requests

- **Activation codes** look like `K7QM-RT4W-9XHB`: an unambiguous alphabet, about 59 bits, bound to an area, with an expiry (default 7 days) and a maximum number of installations. Only the SHA-256 hash is stored. Case and spacing are ignored when typed.
- **Activation** returns an installation ID and a random secret once. The server stores the secret **encrypted with `WC_SECRET_KEY`** (Fernet), because it needs the plain value to verify signatures and SMS codes.
- **Signed requests** carry three headers: `X-Installation-Id`, `X-Timestamp` (Unix seconds) and `X-Signature`.
  - The signature is `HMAC-SHA256(secret, METHOD\npath\ntimestamp\nsha256(body))`.
  - `path` is the API path **without** the proxy prefix (Caddy strips `/api`).
  - Known test vectors are shared by the Python and Dart tests.
- **Freshness:** requests must be within ±300 s. Collect signs with server-corrected time: it learns the offset from `server_time` at activation and from response `Date` headers, so wrong phone clocks still work (SPEC §5.2).
- **Replay:** a nonce table rejects a reused signature.
- **Revocation** is checked on every request. A revoked installation gets `403 installation_revoked`, which tells Collect to offer an export and then wipe (F-AUTH-4, P5).

## Consequences

- Forgetting to set the context yields **no data**, never all data.
- New area tables need a policy in their migration; the RLS tests list the covered tables.
- `WC_JWT_SECRET`, `WC_SECRET_KEY` and `API_DB_PASSWORD` must be set per environment. Rotating `WC_SECRET_KEY` means re-encrypting installation secrets (runbook, P12).
- **Rate limiting:** for now this is per-account lockout only. IP rate limiting at Caddy is added in P12.
