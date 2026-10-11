# ADR-001: Custom FastAPI offline sync

- Status: Accepted (2026-10-10)
- Source: SPEC §A1, §8

## Context

Collect must work fully offline in a low-connectivity area (2G/EDGE) on low-end Android phones.

- Most data is append-only: sessions, readings, results, alert events and calibrations.
- Only `water_source` and `alert` status are mutable.
- The deployment is low-budget, on a single VPS.
- The design must be auditable for a public health grant.

## Decision

Build a custom sync layer:

- Drift (SQLite + SQLCipher) on the device;
- an outbox for writes and an idempotent `POST /v1/sync/push`;
- cursor-based `GET /v1/sync/pull` over a server change sequence (`server_seq`);
- a separate resumable attachment upload.

No third-party sync engine.

## Consequences

- Fewer services to run, and full control of 2G behaviour, SMS fallback and data residency.
- We own the correctness of sync. The P6 chaos tests are the safety net.
- **Guardrails, to keep the option to switch:**
  - screens talk only to repository interfaces backed by the local DB;
  - all network sync sits behind one `SyncService` in `features/sync/`;
  - backend write endpoints validate and persist independently of the sync transport.
- **Revisit** (consider self-hosted PowerSync for the read path) if either happens:
  - the P6 chaos tests cannot be made reliable within two iterations;
  - scope grows to many mutable records edited offline by several users.
- Electric is excluded because it has no maintained, write-capable Flutter client.
