# WaterCheck

Community drinking water monitoring and reporting for Abim District, Uganda.

| Part | Path | Platforms |
|------|------|-----------|
| **Collect** — field app for collectors (no account) | [apps/collect](apps/collect) | Android, Windows |
| **Console** — stakeholders and IT admin | [apps/console](apps/console) | Web, Windows, Android |
| Shared Dart packages | [packages/](packages) | `domain` (rules), `data` (local DB, sync), `ui_kit` |
| **Backend** — FastAPI + PostgreSQL/PostGIS | [backend](backend) | Docker |
| Dev stack | [infra](infra) | Docker Compose |

- Specification: [docs/SPEC.md](docs/SPEC.md) · Errata: [docs/spec-errata.md](docs/spec-errata.md)
- Progress: [PROGRESS.md](PROGRESS.md) · Decisions: [docs/adr/](docs/adr/)
- Getting started: [CONTRIBUTING.md](CONTRIBUTING.md)

Status: proof of concept, phase P0.
