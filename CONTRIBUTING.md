# Contributing

## Prerequisites

Flutter (version pinned in [.fvmrc](.fvmrc); use `fvm flutter …` or a global install of the same version), Android SDK, Visual Studio with *Desktop development with C++* (Windows builds), Chrome, Docker Desktop, [uv](https://docs.astral.sh/uv/), [gitleaks](https://github.com/gitleaks/gitleaks). Windows needs Developer Mode on.

## Flutter workspace (repo root)

```sh
flutter pub get                    # resolves every app and package (pub workspace)
dart run melos run format:check
dart run melos run analyze
dart run melos run test:dart       # pure Dart packages (domain)
dart run melos run test:flutter    # Flutter packages and apps
```

Run the apps:

```sh
cd apps/collect && flutter run -d windows        # or an Android emulator
cd apps/console && flutter run -d chrome          # or -d windows
```

## Generated code and seed copies

```powershell
cd packages\data; dart run build_runner build      # Drift database code
.\tools\sync_seed.ps1                                # after editing infra/seed (a test checks the copy)
flutter gen-l10n                                     # in an app or ui_kit, after editing *.arb (also runs on build)
```

Schema changes: bump `schemaVersion`, then `dart run drift_dev make-migrations` in `packages/data` and add a case to `test/drift/migration_test.dart`.

## Backend

```sh
cd backend
uv sync
uv run ruff format --check . && uv run ruff check .
uv run mypy
uv run pytest
```

Backend tests start a PostGIS container (testcontainers), so Docker must be running.

### Database, seed and admin CLI

Run from `./WaterCheck/infra` on Linux/macOS, or from `.\WaterCheck\infra` on
Windows PowerShell:

```sh
docker compose up -d --build
docker compose run --rm migrate python -m app.cli create-admin \
  --username you@example.org --full-name "IT Admin"
docker compose run --rm migrate python -m app.cli create-activation-code \
  --area ABIM-ENT
docker compose run --rm migrate python -m app.cli create-stakeholder \
  --username officer@example.org --full-name "Officer" --area UG-ABIM
```

Temporary passwords and activation codes are printed once. The versioned seed
loaded by Compose is reference data; it does not create user accounts or demo
history. `seed-perf-fixture` is restricted to `dev` and `test` and must not be
forced into production. For live onboarding, use the VM procedure in
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

Live client tests against the running stack (as an IT admin; skipped otherwise):

```powershell
$env:WC_LIVE_API='http://localhost/api'; $env:WC_LIVE_USER='you@example.org'; $env:WC_LIVE_PASSWORD='...'
cd apps\collect; flutter test test\live_test.dart        # activate, check, reference, revoke
cd packages\api_client; dart test
```

Alerts end to end (ADR-013): the worker emails Mailpit (inbox at http://localhost:8025):

```powershell
python tools/smoke_alerts.py --admin you@example.org --admin-password ... --stakeholder officer@example.org --stakeholder-password ...
```

SMS through Africa's Talking: put `WC_SMS_PROVIDER=africastalking`, `WC_SMS_USERNAME=sandbox` and `WC_SMS_API_KEY=...` in `infra/.env`, and point the provider's inbound callback at `https://<host>/api/v1/sms/inbound/africastalking?token=<WC_SMS_WEBHOOK_TOKEN>`.

Sync chaos tests (ADR-011) through a fault-injecting proxy, as an IT admin plus a stakeholder whose area covers `ABIM-ENT`:

```powershell
cd infra; docker compose --profile chaos up -d       # Toxiproxy on 8474 / 18080
$env:WC_CHAOS='1'; $env:WC_LIVE_USER='…'; $env:WC_LIVE_PASSWORD='…'
$env:WC_STAKEHOLDER_USER='…'; $env:WC_STAKEHOLDER_PASSWORD='…'
cd ..\packages\data; flutter test test\chaos_test.dart
```

Local schema changes: edit `tables.dart`, bump `schemaVersion`, `dart run build_runner build`, `dart run drift_dev make-migrations`, write the `onUpgrade` step and a case in `test/drift/migration_test.dart`.

To activate the Collect web preview or a phone, issue a code with `create-activation-code`. On the Android emulator, the default server address is `http://10.0.2.2/api`; a real phone needs the machine's LAN address or a release build with `--dart-define=WC_API_URL=https://…/api`.

Regenerate the API spec and Dart client after changing the API:

```sh
cd backend && uv run python -m app.openapi          # writes docs/api/openapi.{json,yaml}
cd packages/api_client && dart run swagger_parser && dart run build_runner build && dart format lib
```

## Dev stack

```sh
cd infra
cp .env.example .env               # edit values; never commit .env
docker compose up -d --build
curl http://localhost/health       # {"status":"ok"} through Caddy
```

Development uses the local Compose stack and must not reuse production
secrets, volumes, or hostnames. The production deployment uses a VM-only
`infra/.env`, a generated Flutter web build, Caddy-managed HTTPS, and the
procedure in [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## Environment workflow

The supported workflow is:

```text
dev     local workstation and local Compose
test    GitHub Actions and local targeted test commands
prod    Azure VM, protected production secrets and persistent volumes
```

Before merging or deploying:

```powershell
dart run melos run format:check
dart run melos run analyze
dart run melos run test:dart
dart run melos run test:flutter
```

Production source changes are deployed by pushing reviewed changes to `main`,
pulling them on the VM, validating with `docker compose config --quiet`, and
recreating only the affected services. Never commit `infra/.env`, private keys,
generated MBTiles, or Flutter build archives.

### Future staging environment

Staging is not currently deployed because the production VM has 4 GiB RAM and
the full stack already includes PostgreSQL/PostGIS, SeaweedFS, a worker, Caddy,
and a tile server. When staging is added, it must use a separate host or a
larger VM, and separate:

- `staging.watercheck.fieldquire.cooptconnect.app` and `api-staging.watercheck.fieldquire.cooptconnect.app`;
- Compose project name, network, containers and ports;
- `.env` and all database, storage and Caddy certificate volumes;
- Flutter build with the staging API URL;
- non-production email provider and test data.

Staging must be smoke-tested before production and must never share production
database or object-storage credentials.

## Viewing the frontend in a browser (no emulator)

With the dev stack running, rebuild the web previews and open them:

```powershell
.\tools\preview.ps1            # or: -App collect / -App console
```

- Console: http://localhost/console/
- Collect (dev-only preview, ADR-006): http://localhost/collect/

These routes come from `infra/caddy/Caddyfile.dev`, the default. Do not set
`WC_CADDYFILE=Caddyfile.prod` locally: that file serves only the production
HTTPS hostnames (see DEPLOYMENT_GUIDE.md §8).

Refresh the tab after each rebuild. For hot reload while editing, run `flutter run -d chrome` in `apps/collect` or `apps/console`.

## Workflow

- Branch per phase: `phase/PN-short-name`; PR into `main`; merge when CI is green and the gate is ticked; tag `pN-done`.
- Before committing: `gitleaks git --staged` (or `gitleaks protect --staged` on older versions).
- Definition of Done: formatted, analysed with no warnings, tests passing, docs/ADR updated, acceptance checks for the touched requirement IDs pass (SPEC §A0.7).
- No secrets, and no personal data in seeds, logs or test fixtures.
- Before pushing, run the same commands as CI (`.github/workflows/`), not
  narrower ones. `uv run mypy` also checks the tests (`mypy app` once missed
  an error), and `dart run melos run format:check` is the Flutter format gate.
- A failing `osv-scanner` with no code change is usually a newly published
  advisory. Upgrade the package in the lockfile (`uv lock --upgrade-package
  <name>`), check with `uvx pip-audit`, and rebuild the API image on the VM.
- UX conventions (ADR-017): use the `ui_kit` pieces. Show times with
  `WcTime.local`. Decide "today" with `WcTime.isToday`, never by comparing a
  converted time with `DateTime.now()`: CI runs in UTC, and East Africa Time
  is UTC+3.
- Map style: when `infra/tiles-config/watercheck.json` changes, also change
  the style id in `infra/tiles-config/config.json`; otherwise cached tiles
  stay for a week. See DEPLOYMENT_GUIDE.md §17a.
