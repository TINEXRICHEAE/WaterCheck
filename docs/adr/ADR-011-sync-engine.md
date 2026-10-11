# ADR-011: Sync engine

- Status: Accepted (2026-10-10)
- Covers: SPEC §8.1–8.4 and §8.6, F-SYN-1/2/3/4, §5.2 (clock sanity), chaos tests §12.3 #1–#5, P6
- Builds on: ADR-001 (custom sync), ADR-005 (result model), ADR-009 (signing), ADR-010 (client access)

## Context

Collect works offline for days and sends over 2G. The Console caches area data on Windows/Android. Everything captured must reach the server **exactly once**, every device must receive its area's data, and nothing may be lost to a dropped connection, a killed app, a wrong clock or a failing server. This was the plan's riskiest gate. The ADR-001 escape hatch (two failed iterations → PowerSync) was not needed.

## Decision

### 1. Push: `POST /v1/sync/push`

- **Idempotent by client ID.**
  - Every record has a client UUID; custom parameters use their `custom:<uuid>` code.
  - Re-sending a record answers `duplicate` and changes nothing.
  - Tested: a batch sent 4 times creates its rows once.
- **Per-record answers**, in request order: `applied`, `duplicate`, `conflict` or `rejected`, with `server_version` and `reason`.
- **Parents before children, each record in a savepoint.**
  - The server applies a batch in entity order: source → calibration → session → result → reading → alert → event → inspection. Within one entity it keeps the client's own order, so an edit follows its insert.
  - Each record runs in a savepoint, so one bad record cannot sink the batch.
  - *This replaces the spec's deferred foreign keys.* Deferred checks only fail at commit, so they could not say which record was at fault.
  - A child of a refused or invisible parent gets `missing_parent`, which reveals nothing about other areas.
- **Never taken from the client:**
  - who sent it (the installation from its signature, or the user from the token);
  - server times and versions;
  - the server classification, run once a result's readings are in, even if they arrive in a later batch;
  - clock flags.
- **Who may push what:** phones may push all field records. Console users may push only source edits and alert events (acknowledge, close, notes).
- **Source code clash:** two phones in a village can pick the same `ENT-001` offline. The server keeps both and renames the second (`ENT-001-0B9E`); the new code flows back on pull.
- **Size:** at most 200 changes per request.
  - Clients send 50 records or 256 KB, gzipped.
  - Clients sign the uncompressed JSON, then compress it. The server middleware decompresses before checking the signature, and caps the inflated size at 8 MB.

### 2. Conflict policy (SPEC §8.4)

- **Insert-only entities** (sessions, results, readings, calibrations, events, inspections) cannot conflict.
- **`water_source`:** optimistic concurrency on `version`.
  - On a stale base, name, households, type and location are last-writer-wins.
  - `functional_status` and `is_active` keep the **server's** value. The client's value goes to `sync_conflict`, which stakeholders in the area can read and resolve.
  - The client is told `conflict` (`kept_server:<fields>`) and gets the server state on its next pull.
- **`alert`:** the server's state machine decides.
  - `open → acknowledged → action_in_progress → closed`, and `false_alarm` from any open state.
  - An invalid transition is recorded as an event but answers `conflict` (`invalid_transition:<from>-><to>`).
  - `reopened` on a closed alert opens a **new alert** linked to the old one.

### 3. Pull: `GET /v1/sync/pull?stream=…&cursor=…&limit=…`

- **Streams:** `reference` (catalogue, testers, profiles, response cards, rules and lists, admin units), `area:<id>` (Collect: its village) and `scope` (Console: all its areas). Row-level security still applies (ADR-009). Errata G9 is settled: `village:<id>` is not used.
- **Commit-order-safe cursor (a change from the spec).**
  - `server_seq` is assigned when a row is *written*, not when its transaction *commits*. A transaction holding seq 10 can commit after one holding seq 11. A device that had already pulled past 11 would then miss row 10 for ever.
  - Every synced row therefore also stores its writer's transaction ID (`server_xid`, migration 0002).
  - A pull returns only rows from transactions older than the oldest one still running (`pg_snapshot_xmin`), ordered by `(server_xid, server_seq)`.
  - The cursor is opaque text: `<xid>.<seq>`.
  - Tested: a slow transaction keeps the cursor back until it commits, and its row is then delivered.
- **Tombstones:** deactivated sources come as `op: tombstone`, with their data. Nothing is hard-deleted.
- **Privacy:** a phone receives collector details (name, phone) only for its **own** installation's records. Console stakeholders see them, for the collector registry.
- **Deferred to P8:** the `user:<id>` stream (notifications).

### 4. Request signing, revised

Two identical signed GETs in the same second had the same signature, so the replay guard refused the second. The query string (stream, cursor) was not signed at all. Now:

- the signed path includes the query string;
- clients send a random `X-Nonce`, which is added as a fifth line of the signed message.

Requests without a nonce still verify, so the P4 test vectors stay valid; a new vector is shared by Dart and Python.

### 5. Client `SyncService` (data package, shared by both apps)

- **Order:** push before pull. If the push fails, there is no pull, so local edits the server has not seen are never overwritten.
- **Outbox:** oldest first. `sent` after `applied`, `duplicate` or `conflict`; `rejected` keeps the reason. Rows are never deleted.
- **Backoff:** exponential with jitter, 5 s doubling to 15 min. Kept in `sync_state` (local schema v2) so it survives restarts and holds for the background worker. "Sync now" and a returning connection skip the wait.
- **One run at a time:** an in-process single-flight plus a database lease row (`sync_lock`, 10 min) shared with the Android worker. A lease left by a killed process expires.
- **Pull:** each page is applied in one transaction with `PRAGMA defer_foreign_keys`. Insert-only rows already held are kept (local triggers forbid updating them). Rows of unknown entities are skipped, so older apps keep working.
- **Triggers:**

  | | Collect | Console |
  |---|---|---|
  | Start | ✓ | after sign-in or unlock |
  | Return to the app | ✓ | ✓ |
  | Network comes back | ✓ (resets the backoff) | |
  | 20 s after new records | ✓ | |
  | Every 15 min while open | ✓ | ✓ |
  | Closed app | WorkManager on Android (network required) | none |
  | "Sync now" | ✓ | ✓ |

- **Revocation:** `installation_revoked` during sync marks the phone revoked → export-then-wipe (ADR-010).
- **Console tokens:** an interceptor supplies the access token, refreshing it near expiry and once after a 401.
- **Web Console:** pulls into its in-memory database. There is no background sync.

### 6. Chaos tests and throughput

- **Setup:** Toxiproxy in Docker Compose (`--profile chaos`) in front of Caddy. `packages/data/test/chaos_test.dart` drives it against the dev stack, gated by `WC_CHAOS`.
- **Scenarios covered:**
  - **#1** a week offline;
  - **#2** response cut mid-sync, then the app restarts;
  - **#3** two phones edit one source;
  - **#4** clocks ±1 year (flagged `device_time_in_future` or `device_time_too_old`, stored);
  - **#5** hanging, then reset connections, with growing waits and no attempts inside the wait;
  - Collect → Console → Collect.
- **2G profile** (plan [DECIDE], ★ taken): Toxiproxy `bandwidth` 6 KB/s each way plus 500 ms latency. 203 records synced in about 9–10 s, against a target of under 2 minutes.

## Consequences

- Every new synced table needs the `server_seq`/`server_xid` trigger, a query in `sync_pull.py`, a push handler if clients write it, and an applier entry on the client.
- A long-running transaction on the server holds pulls back until it ends. Keep server transactions short; batch jobs commit in chunks.
- The chaos run on a **real phone** (gate item) moves to P12 with the other device checks.
- Stakeholder screens that queue source edits and alert actions are built in P8/P9. P6 delivers and tests the queue and the server side.
