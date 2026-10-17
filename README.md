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
- Getting started: [CONTRIBUTING.md](CONTRIBUTING.md) · Deployment: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

Status: proof of concept, P11 complete, P12 hardening and pilot release next.

## Environment status

The project currently uses three environments:

- **Development:** local Windows workstation and Docker Compose.
- **Test:** automated formatting, analysis, unit/widget tests and secret/dependency
  checks in GitHub Actions.
- **Production:** the Azure VM deployment documented in
  [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

The live production URLs are:

```text
https://watercheck.cooptconnect.app
https://api.watercheck.cooptconnect.app
```

The production Console is served at the first URL, and the API health check is
available at `/api/health` on the Console hostname and `/health` on the API
hostname. A separate staging environment is intentionally not running on the
current 4 GiB VM. Its future isolated design is documented in
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).
