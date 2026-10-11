# Architecture decision records

Format: context → decision → consequences. Number them sequentially. Never rewrite an accepted ADR; supersede it with a new one.

| ADR | Title | Status |
|-----|-------|--------|
| [001](ADR-001-custom-sync.md) | Custom FastAPI offline sync | Accepted |
| [002](ADR-002-stack.md) | Technology stack | Accepted |
| [003](ADR-003-object-storage.md) | SeaweedFS instead of MinIO for S3-compatible storage | Accepted |
| [004](ADR-004-monorepo-tooling.md) | Monorepo tooling: pub workspaces, Melos 8, FVM pin, uv | Accepted |
| [005](ADR-005-results-and-classification.md) | Result data model and classification details | Accepted |
| [006](ADR-006-collect-web-preview.md) | Dev-only web preview of Collect at localhost/collect | Accepted |
| [007](ADR-007-english-only.md) | English only | Accepted |
| [008](ADR-008-local-db-encryption.md) | Local database encryption with SQLite3 Multiple Ciphers | Accepted |
| [009](ADR-009-backend-access-and-signing.md) | Database roles, area isolation (RLS) and installation request signing | Accepted |
| [010](ADR-010-client-access.md) | Client access: web cookie sessions, PIN lock, revocation export file | Accepted |
| [011](ADR-011-sync-engine.md) | Sync engine: commit-safe cursor, per-record push, signing with nonce, conflicts, chaos tests | Accepted |
| [012](ADR-012-attachments.md) | Photo attachments: resumable chunked upload through the API, private storage | Accepted |
| [013](ADR-013-alerts-and-notifications.md) | Alerts, notifications, escalation and the SMS fallback (own job queue) | Accepted |
| [014](ADR-014-dashboard-and-map.md) | Stakeholder dashboard computed on the device, collector marks and flags, offline raster MBTiles map | Accepted |
