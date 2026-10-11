# ADR-002: Technology stack

- Status: Accepted (2026-10-10)
- Source: SPEC §10.1

## Context

There are two Flutter apps:

- **Collect:** Android and Windows;
- **Console:** web, Windows and Android.

They share the domain rules and a data layer. One developer must build and run everything on a low budget.

## Decision

| Layer | Choice |
|-------|--------|
| Frontend | Flutter 3.47.x stable (pinned in `.fvmrc`), Dart 3.13 |
| State and routing | `flutter_riverpod` (+ `riverpod_generator`), `go_router` |
| Local DB | `drift` + `sqlcipher_flutter_libs` on Android and Windows; in-memory on web (errata G8) |
| Models and HTTP | `freezed`, `json_serializable`, `dio` |
| Background, location and media | `workmanager`, `connectivity_plus`, `geolocator`, `image_picker`, `flutter_image_compress` |
| Maps, charts and PDF | `flutter_map` (self-hosted tiles), `fl_chart`, `pdf` + `printing` |
| Secure storage and app lock | `flutter_secure_storage`, `local_auth` |
| i18n | `flutter_localizations`, `intl` (ARB) |
| Backend | Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2 (async) + Alembic, structlog |
| DB | PostgreSQL 16 + PostGIS 3.5, with RLS for scope isolation |
| Object storage | S3-compatible; SeaweedFS in dev (ADR-003) |
| Edge | Caddy 2: TLS, security headers, web Console under `/console`, API under `/api` |
| Infra | Docker Compose for dev, staging and prod (on a VPS) |

Each package is added in the phase that first needs it, not up front.

## Consequences

- There is one language per tier. The classification rules are written twice (Dart and Python) and kept equal by shared test vectors (P1).
- The web Console and the API share one origin, which keeps cookie-based refresh tokens simple (plan D-H).
