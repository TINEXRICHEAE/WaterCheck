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
| [015](ADR-015-reports-and-exports.md) | Reports, CSV export and community notices: made on the device, as collected, embedded fonts | Accepted |
| [016](ADR-016-admin-console-and-custom-limit-sets.md) | IT admin console and who changes limit sets (O2) | Accepted |
| [017](ADR-017-app-wide-ux-conventions.md) | App-wide UX conventions: back, errors, settings, loading, filters, icons | Accepted |
| [018](ADR-018-archive-and-edit-trail.md) | Archive with cascade (restorable), edit trails, refresh, clickable dashboard, area search, optional Console PIN | Accepted |
| [021](ADR-021-interactive-maps-and-routes.md) | Interactive maps (one search, fly-to, layers) and self-hosted road routes (Valhalla) | Accepted (on dev) |
| [020](ADR-020-collector-recovery-codes.md) | Collector recovery codes: the same person on any phone | Accepted (on dev) |
| [019](ADR-019-anywhere-in-uganda.md) | Anywhere in Uganda: random source codes, places added from phones, district sync, required location check | Accepted (in progress) |
| [022](ADR-022-devices-context-and-conversations.md) | Every device, linked pages, pictures with context, typed "Other", conversations in the app | Accepted (built, waiting for dev check) |
| [023](ADR-023-map-places-in-their-subcounty.md) | Names on the map placed in their sub-county: suggestions, map search, sub-county from GPS | Accepted (on dev) |
| [024](ADR-024-testers-not-devices.md) | Testers, not devices, are assigned to areas: self-registered devices, assignment codes, own sign-in codes, signing devices out | Accepted (on dev) |
| [025](ADR-025-own-profiles.md) | Profiles people manage themselves: details, confirmed contacts, area requests, sign out, close account | Accepted (on dev) |
| [026](ADR-026-privacy-policy-and-terms.md) | Privacy Policy and Terms of Use, bundled in both apps and accepted by version | Accepted (drafts awaiting details) |
| [027](ADR-027-screens-follow-the-device.md) | Screens follow the device: dark colours, controls folded on every screen, sizes relative to the screen | Accepted (built, waiting for dev check) |
| [028](ADR-028-added-places-and-routes-to-any-place.md) | Places added from the map, seen by everyone; routes to any source, place or area | Accepted (built, waiting for dev check) |
| [029](ADR-029-live-navigation-and-located-pictures.md) | Live navigation with trips kept on the device; pictures with where and when they were taken | Accepted (built, waiting for dev check) |
| [030](ADR-030-fieldquire-research-module.md) | FieldQuire: a research module (custom forms, records with location and media, analysis) beside water testing, on the same server | Accepted (R1 in progress) |
