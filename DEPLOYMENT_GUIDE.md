# WaterCheck Deployment Guide

This guide documents the WaterCheck deployment from local development to an
Azure VM. It is intended as a learning reference and as a repeatable procedure
when moving the project to another VM, host, region, or domain.

For a complete local Windows/Linux Docker setup, demo-data workflow and
platform testing guide, see [DEV_DEPLOYMENT_GUIDE.md](DEV_DEPLOYMENT_GUIDE.md).

## 1. Deployment architecture

The deployment uses one Ubuntu Azure VM running the complete Docker Compose
stack:

- **Caddy**: public HTTPS entry point and reverse proxy.
- **API**: FastAPI application on the internal Docker network at port `8000`.
- **Worker**: background jobs.
- **PostgreSQL/PostGIS**: application database.
- **SeaweedFS**: S3-compatible object storage for photos and other objects.
- **Tile server**: map tile service.
- **Mailpit**: development-only mail catcher.

Public names:

```text
https://watercheck.cooptconnect.app
https://api.watercheck.cooptconnect.app
```

The Console web application uses the first URL. Browser API requests use the
same-origin path `/api`; Android and Windows clients can use the API hostname
with the `/api` path.

The current production web deployment serves Console only. There is no
production `/collect/` browser route yet. Collectors should use the Android or
Windows Collect application, configured with:

```text
https://api.watercheck.cooptconnect.app/api
```

The Android APK procedure is documented in
[DEV_DEPLOYMENT_GUIDE.md](DEV_DEPLOYMENT_GUIDE.md#8-android-apk-using-the-production-api).

## 2. Azure subscription and region

Azure for Students applies an allowed-region policy. The deployment could not
use East US. The allowed regions were:

```text
India South Central
South Africa North
Poland Central
Spain Central
Italy North
```

South Africa North was selected because it is geographically suitable for the
project's expected users.

VM configuration:

- Resource group: `watercheck-azure-2026`
- VM name: `watercheck-VM`
- OS: Ubuntu Server 24.04 LTS x64 Gen2
- Size: `Standard_B2als_v2`
- CPU/RAM: 2 vCPU / 4 GiB
- OS disk: 30 GiB Standard SSD
- Public IP: static
- Inbound ports: SSH `22`, HTTP `80`, HTTPS `443`
- Azure Spot, backups, extra data disks, and unnecessary monitoring were
  disabled to control cost.

The selected VM is approximately `$35.62/month` at the time of setup. The
Azure for Students credit is limited, so stop/deallocate the VM when it is not
needed and configure a budget alert in Cost Management.

## 3. Domain and DNS

The domain was registered through Name.com:

```text
cooptconnect.app
```

DNS records point to the VM's static public IP:

```text
watercheck.cooptconnect.app      A      <VM_PUBLIC_IP>
api.watercheck.cooptconnect.app  A      <VM_PUBLIC_IP>
```

Verify DNS from Windows PowerShell:

```powershell
nslookup watercheck.cooptconnect.app
nslookup api.watercheck.cooptconnect.app
```

The `.app` top-level domain requires HTTPS. Caddy obtains and renews
Let's Encrypt certificates automatically after both DNS records resolve and
ports `80` and `443` are reachable.

## 4. SSH access from Windows

The Azure VM username is `azureuser`.

The private key is stored locally with restricted permissions:

```text
C:\Users\ocenr\.ssh\watercheck-VM_key.pem
```

Connect with:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP>
```

Common problems:

- Put a space between the closing key-path quote and `azureuser`.
- Azure created the user `azureuser`; do not substitute the VM resource name.
- OpenSSH rejects keys that are readable by broad Windows groups. Remove
  inheritance and broad permissions with `icacls`, or copy the key into
  `C:\Users\<user>\.ssh` and restrict it to the current user, Administrators,
  and SYSTEM.

## 5. Install Docker on Ubuntu

Docker Engine and Compose were installed from Docker's Ubuntu repository. The
installation was verified with:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

Add the login user to the Docker group, then start a new SSH session or reboot
before relying on passwordless Docker commands:

```bash
sudo usermod -aG docker "$USER"
```

Useful capacity checks:

```bash
df -h /
free -h
docker system df
```

The selected VM initially had approximately 29 GiB usable root disk space and
approximately 26 GiB free. The tile data and Docker images consume part of this
space, so monitor disk usage.

## 6. Clone the repository

On the VM:

```bash
cd ~
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
cd ~/WaterCheck
git status
```

The repository is deployed under:

```text
/home/azureuser/WaterCheck
```

## 7. Production environment file

The Compose stack reads its environment from:

```text
~/WaterCheck/infra/.env
```

Create it on the VM only. Never commit it or put it in the repository:

```bash
cd ~/WaterCheck/infra
cp .env.example .env
chmod 600 .env
nano .env
```

The production file must define these values:

```dotenv
POSTGRES_DB=watercheck
POSTGRES_USER=watercheck
POSTGRES_PASSWORD=<random-password>
API_DB_PASSWORD=<different-random-password>

WC_JWT_SECRET=<random-token>
WC_SECRET_KEY=<Fernet-key>

WC_ENVIRONMENT=prod
WC_LOG_LEVEL=INFO
HTTP_PORT=80
HTTPS_PORT=443

WC_S3_ACCESS_KEY=watercheck-prod
WC_S3_SECRET_KEY=<random-secret>
WC_SMS_WEBHOOK_TOKEN=<random-token>

WC_SMTP_HOST=mailpit
WC_SMTP_PORT=1025
WC_SMTP_FROM=WaterCheck <no-reply@cooptconnect.app>
```

Generate values on the VM without manually inventing them:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(48))"
python3 -c "import base64, os; print(base64.urlsafe_b64encode(os.urandom(32)).decode())"
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

Use different generated values for database passwords, JWT signing, S3
credentials, and webhook tokens. The Fernet value must be generated with the
base64 command above.

Check only the variable names without printing secrets:

```bash
grep -E '^[A-Z0-9_]+=' .env | sed 's/=.*$/=<configured>/'
chmod 600 .env
ls -l .env
```

The `3` in `WC_S3_*` is why the pattern includes `0-9`.

The backend environment setting is an enum. Use `prod`, not `production`;
`production` causes the API container to exit during settings validation.

For this learning deployment, Mailpit is acceptable for testing. It does not
deliver mail to real recipients. Before production use, replace it with an
authenticated SMTP provider and wire the provider's credentials into Compose
and the backend settings.

Do not use `docker compose config` output in a public issue or chat: Compose
expands and prints secrets.

## 8. Production Caddy configuration

Caddy has one file per environment, and `infra/.env` chooses it:

| File | Used by | Routing |
|------|---------|---------|
| `infra/caddy/Caddyfile.dev` | local workstations (the default) | plain HTTP on `localhost`: `/console/`, `/collect/`, `/api/`, `/tiles/` |
| `infra/caddy/Caddyfile.prod` | the Azure VM | HTTPS for the two hostnames below |

On the VM, `infra/.env` must contain:

```dotenv
WC_CADDYFILE=Caddyfile.prod
```

Without it, Compose falls back to the dev file and the public HTTPS sites stop
answering. The hostnames default to the live names; set `WC_WEB_HOST` and
`WC_API_HOST` only for another deployment (for example a future staging VM).

It provides:

- Flutter Console at `watercheck.cooptconnect.app`.
- `/api/*` routed to `api:8000`.
- `/tiles/*` routed to `tiles:8080`.
- API hostname routed to `api:8000`, except `/tiles/*`: Windows and Android
  derive the map address from their API address (`…/api` → `…/tiles`).
- Automatic HTTPS and HTTP-to-HTTPS redirects.
- Security headers.
- Flutter history fallback to `/index.html`.
- One-day caching for stable Flutter engine assets.

The development `/console/` and `/collect/` routes live only in
`Caddyfile.dev`.

Validate Caddy locally from the `infra` directory:

```powershell
docker run --rm `
  -v "${PWD}\caddy:/cfg:ro" `
  caddy:2.11 `
  caddy validate --config /cfg/Caddyfile.prod --adapter caddyfile
```

Repeat with `Caddyfile.dev` after changing the dev file.

Expected result:

```text
Valid configuration
```

## 9. Validate Compose before startup

From the repository's `infra` directory:

```bash
cd ~/WaterCheck/infra
docker compose config --quiet
```

Exit code `0` means Compose can parse the file and interpolate the environment.
This does not start containers and does not prove that every image or
application dependency is healthy.

## 10. Build the Flutter Console

Flutter must be run from the Console package directory, not from the monorepo
root. Running Flutter from the root produces:

```text
Target file "lib\main.dart" not found.
```

Build on the Windows development machine:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck\apps\console

flutter build web `
  --release `
  --base-href / `
  --dart-define=WC_API_URL=https://watercheck.cooptconnect.app/api `
  --no-web-resources-cdn `
  --no-pub
```

The API URL is a compile-time Flutter define. It is read by the shared data
package and embedded in the generated JavaScript.

To keep the local `/console/` preview (built by `tools\preview.ps1` into
`build\web`) intact, a release build can write elsewhere with
`-o C:\Users\ocenr\Desktop\Research\app\watercheck\apps\console\build\web-prod`
and be archived from there (see §17a).

Verify the local build:

```powershell
Test-Path .\build\web\index.html
Get-Item .\build\web\index.html
```

The command must finish with:

```text
Built build\web
```

## 11. Transfer the web build reliably

The web build is normally ignored by Git, so transfer it separately to the
VM. A recursive `scp` can be interrupted on large files such as
`canvaskit.wasm`. A compressed archive is more reliable.

Map tiles are handled separately. The repository intentionally ignores
`infra/tiles/` and `*.mbtiles` because the generated maps can be hundreds of
megabytes and are rebuilt from OpenStreetMap data. Production needs **two**
files in `~/WaterCheck/infra/tiles/`:

| File | Size | Served by | Purpose |
|------|------|-----------|---------|
| `uganda.mbtiles` | ~259 MB | `tiles` service at `/tiles/` | the labelled map of all of Uganda (vector data, drawn by the WaterCheck style) |
| `area.mbtiles` | ~8–106 MB | the API at `/api/v1/tiles` | the offline pack Windows and Android download for their area (map images) |

`infra/tiles-config/config.json` must name `uganda.mbtiles`: the style reads
vector data, so pointing it at the image-only `area.mbtiles` leaves the map
blank.

Build `uganda.mbtiles` on a machine with Docker and about 20 GB free
(`.\tools\build_map.ps1 -Vector`; it takes a long time) or reuse an existing
copy. Transfer it with the same `scp` pattern as below, to
`~/WaterCheck/infra/tiles/uganda.mbtiles`, then restart the tile server:

```bash
cd ~/WaterCheck/infra
docker compose up -d --force-recreate tiles
```

`--force-recreate` is required. The tile server reads `tiles-config/` and the
`.mbtiles` files only when it starts; when only those files change, a plain
`docker compose up -d` leaves the old process running (tiles then answer
`500`). Check a tile afterwards:

```bash
curl -s -o /dev/null -w "%{http_code} %{content_type}\n" \
  https://watercheck.cooptconnect.app/tiles/styles/watercheck-v2/256/10/607/504.png
```

Expect `200 image/png`.

Create `infra/tiles/area.mbtiles` on a machine with Docker and the required
map-build tools:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck
.\tools\build_tiles.ps1
```

Transfer the generated file to the VM:

```powershell
scp -C `
  -o IdentitiesOnly=yes `
  -o ServerAliveInterval=30 `
  -o ServerAliveCountMax=6 `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  ".\infra\tiles\area.mbtiles" `
  azureuser@<VM_PUBLIC_IP>:~/WaterCheck/infra/tiles/area.mbtiles
```

Verify it on the VM:

```bash
ls -lh ~/WaterCheck/infra/tiles/area.mbtiles
```

The destination directory must be writable by `azureuser`. If `scp` reports
`Permission denied`, repair only this deployment directory and retry:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP> `
  "sudo chown azureuser:azureuser ~/WaterCheck/infra/tiles"
```

Do not use `chmod 777`. The directory only needs to be writable by the
deployment user.

The API can run without map tiles, but the tile-server container will restart
continuously and map requests will fail until this file exists. Do not add the
generated MBTiles file to Git.

From the repository root on Windows:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck
tar -czf console-web.tar.gz -C apps\console\build web
```

Copy it:

```powershell
scp -C `
  -o IdentitiesOnly=yes `
  -o ServerAliveInterval=30 `
  -o ServerAliveCountMax=6 `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  ".\console-web.tar.gz" `
  azureuser@<VM_PUBLIC_IP>:~/console-web.tar.gz
```

Extract it on the VM beside the live files, then swap the folders and
recreate Caddy. Run on the VM:

```bash
sha256sum ~/console-web.tar.gz        # compare with the checksum from the build
cd ~/WaterCheck/apps/console/build
rm -rf web.new && mkdir web.new && tar -xzf ~/console-web.tar.gz -C web.new
ls web.new/index.html web.new/main.dart.js
rm -rf web.old && mv web web.old && mv web.new web
cd ~/WaterCheck/infra && docker compose up -d --force-recreate caddy
```

This expects an archive with the files at its top level, as made in §17a
(`tar -czf … -C build\web-prod .`). An archive made with `-C apps\console\build web`
holds a `web/` folder instead: extract it into `~/WaterCheck/apps/console/build`
directly, then recreate Caddy.

Caddy must be recreated after the swap: its bind mount keeps the folder it
started with, so it would keep serving the old (renamed) files. Recreating it
keeps the certificates (they live in the `caddy-data` volume). To roll back:
`mv web web.bad && mv web.old web`, then recreate Caddy again.

Verify the important artifacts:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP> `
  "ls -lh ~/WaterCheck/apps/console/build/web/index.html ~/WaterCheck/apps/console/build/web/main.dart.js ~/WaterCheck/apps/console/build/web/canvaskit/canvaskit.wasm"
```

Remove temporary archives after verification:

```powershell
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@<VM_PUBLIC_IP> `
  "rm -f ~/console-web.tar.gz"

Remove-Item -LiteralPath ".\console-web.tar.gz"
```

## 12. Commit source configuration, not deployment secrets

Review changes locally:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck
git status --short
git diff --check
git diff
```

Commit only the intended source/configuration files:

```powershell
git add infra/caddy/Caddyfile.prod
git commit -m "Configure production Caddy routing"
git push origin main
```

Never add:

```text
infra/.env
*.pem
console-web.tar.gz
apps/console/build/
```

If a build or archive is accidentally staged, unstage it before committing:

```powershell
git restore --staged <path>
```

After pushing source changes, update the VM:

```bash
cd ~/WaterCheck
git pull
```

The `.env` file remains on the VM and is not replaced by `git pull`.

## 13. Start the stack

Only start the stack after the environment, Caddy file, and web build are
ready:

```bash
cd ~/WaterCheck/infra
docker compose config --quiet
docker compose up -d --build
```

The first start builds the API image, runs migrations and seed data, starts
PostgreSQL and SeaweedFS, and then starts the API, worker, tile server, and
Caddy.

The migration command includes a small PostgreSQL connection retry using
SQLAlchemy, which understands the `postgresql+psycopg://` URL used by
Alembic. This is intentional because a database container can pass its
healthcheck just before it is ready to accept the migration connection.

## 14. Inspect startup and health

```bash
docker compose ps
docker compose logs --tail=100 api
docker compose logs --tail=100 caddy
docker compose logs --tail=100 migrate
docker compose logs --tail=100 worker
```

Local VM checks:

```bash
curl -i http://127.0.0.1/health
docker compose exec api python -c "import urllib.request; print(urllib.request.urlopen('http://127.0.0.1:8000/health').read().decode())"
df -h /
free -h
docker system df
```

Public checks after Caddy obtains certificates:

```powershell
curl.exe -I https://watercheck.cooptconnect.app
curl.exe -i https://watercheck.cooptconnect.app/health
curl.exe -i https://api.watercheck.cooptconnect.app/health
```

Expected API health responses should have HTTP status `200`.

Healthy request logs look like:

```text
GET /health ... status 200
GET /v1/sync/pull ... status 200
```

## 15. Client API configuration

The Console web build uses:

```text
https://watercheck.cooptconnect.app/api
```

Android and Windows clients should use:

```text
https://api.watercheck.cooptconnect.app/api
```

The Collect application generally receives its API URL during activation or
setup and persists it with its installation credentials.

## 15a. Production accounts and collector activation

The deployment seed loads reference data only. It does not create login
accounts, collector installations, sources, or test history. Create the first
production admin manually, then use the Console for normal onboarding.

SSH to the VM from the Windows development computer:

```powershell
# Run from any directory on the Windows development computer.
ssh -o IdentitiesOnly=yes `
  -i "C:\Users\ocenr\.ssh\watercheck-VM_key.pem" `
  azureuser@20.164.216.195
```

Run all production account commands on the VM from `~/WaterCheck/infra`:

```bash
cd ~/WaterCheck/infra
docker compose ps
```

Create the first IT administrator. Replace the username and full name:

```bash
docker compose run --rm migrate \
  python -m app.cli create-admin \
  --username admin@example.com \
  --full-name "Production IT Administrator"
```

The temporary password is printed once. Use it at
`https://watercheck.cooptconnect.app/#/sign-in`; the first sign-in requires a
password change. Do not put the password in Git, `.env`, screenshots, logs or
chat messages.

After signing in, create stakeholders through **Admin → People**. A
stakeholder can also be created from the VM:

```bash
docker compose run --rm migrate \
  python -m app.cli create-stakeholder \
  --username stakeholder@example.com \
  --full-name "Water Officer" \
  --area UG-ABIM
```

Repeat `--area` for additional areas and add responsibilities when needed:

```bash
docker compose run --rm migrate \
  python -m app.cli create-stakeholder \
  --username stakeholder@example.com \
  --full-name "Water Officer" \
  --area UG-ABIM \
  --responsibility water
```

The admin issues collector activation codes from **Admin → Collect phones**.
The CLI equivalent is:

```bash
docker compose run --rm migrate \
  python -m app.cli create-activation-code \
  --area ABIM-ENT \
  --max 5 \
  --days 30
```

Give the one-time code to the collector. The collector opens Collect, enters
or scans the code, enters identification details, sets the local PIN and
performs an initial online sync. Revoke an installation later from
**Admin → Collect phones**.

### Production onboarding checks

Use this order for a controlled smoke test:

1. Create the IT admin and change the temporary password.
2. Create a stakeholder and verify area scoping in a separate browser session.
3. Issue an activation code for a test area.
4. Activate one Collect Android or Windows device.
5. Submit one online and one offline test, then reconnect and sync.
6. Review the result and any alert as the stakeholder and admin.

The temporary password and activation code are one-time display values. If
they are lost, reset the password or issue a new activation code rather than
recovering them from the database.

### Demo data boundary

The normal deployment seed is safe and expected in production because it
contains versioned reference data without personal data. The performance
fixture is different: `seed-perf-fixture` is explicitly restricted to `dev`
and `test` and refuses to run with `WC_ENVIRONMENT=prod`.

Do not bypass that guard or load the full performance fixture into the live
database. It creates synthetic source and test history for load testing. Keep
production clean, or use a future isolated staging environment with its own
database, storage, credentials and Compose project. For a production smoke
test, create only a clearly identified test record and remove or archive it
according to the data policy.

## 16. Email configuration

The initial Compose setup uses Mailpit:

```dotenv
WC_SMTP_HOST=mailpit
WC_SMTP_PORT=1025
```

Mailpit is useful for inspecting test messages but is not a public mail
provider. For real email:

1. Create an account with an SMTP provider.
2. Obtain the SMTP host, port, username, password, and sender address.
3. Add the provider values to the VM's `infra/.env`.
4. Ensure Compose passes all corresponding SMTP settings to `api` and `worker`.
5. Restart the affected services.
6. Send a test message and inspect the API/worker logs.

Do not put SMTP credentials in Git, Flutter build arguments, or browser code.

## 17. Updating the deployment

For a normal source/configuration update:

```powershell
cd C:\Users\ocenr\Desktop\Research\app\watercheck
git pull
# make and validate changes
git add <intended-files>
git commit -m "<change>"
git push origin main
```

On the VM:

```bash
cd ~/WaterCheck
git pull
cd infra
docker compose config --quiet
docker compose up -d --build
docker compose ps
```

A plain `docker compose up -d` only recreates services whose Compose
settings changed. Two services read files that Git updates without changing
their settings, so recreate them explicitly after such a pull:

```bash
docker compose up -d --force-recreate tiles    # after map style or .mbtiles changes
docker compose --profile routing up -d --force-recreate routing  # after new routing data
docker compose up -d --force-recreate caddy    # after a Caddyfile or web-build change
```

Rebuild the API and worker images after a backend or `uv.lock` change (for
example a security update): `docker compose up -d --build api worker`.

For new client builds (web, Windows installers, Android APK) follow §17a.

### Migration 0009: archive and edit trails (2026-10-22, ADR-018)

The `migrate` service applies migrations; rebuild it with the API and worker:

```bash
cd ~/WaterCheck && git pull
cd infra
docker compose up -d --build migrate api worker
docker compose logs --tail=30 migrate   # look for "Running upgrade 0008 -> 0009"
curl -fsS https://api.watercheck.cooptconnect.app/v1/health
```

Then rebuild and ship the web Console (§10–§11), because the archive and trail
screens need the new API. Phones and Windows apps on 0.1.1 keep working; they
pick up archive marks and trails once updated.

**Migration 0010 (round 2, ADR-019)** comes the same way: it adds the review
columns for places that phones add (`admin_unit.review_status`). After it,
check what phones have added with:

```bash
docker compose exec db sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c   "SELECT level, name, added_at FROM admin_unit WHERE review_status = '"'"'new'"'"' ORDER BY added_at DESC LIMIT 20;"'
```

**Road routes (ADR-021).** The maps' "Route by road" layer needs the
`routing` service (Valhalla). Its data (`infra/routing/valhalla/`, about 260 MB,
git-ignored) is built from the Uganda OpenStreetMap extract. Build it on the
dev machine with `.	oolsuild_routes.ps1` (a few minutes; Docker needs about
2 GB free memory), then copy it to the VM like the map file:

```powershell
scp -r infra
outingalhalla azureuser@20.164.216.195:~/WaterCheck/infra/routing/
```

On the VM, start it (it uses about 60 MB of memory, limited to 512 MB) and
recreate Caddy so `/route/` is routed:

```bash
cd ~/WaterCheck/infra
docker compose --profile routing up -d routing
docker compose up -d --force-recreate caddy
curl -s "https://api.watercheck.cooptconnect.app/route/status"
```

Without the service, routes show "no route found"; straight-line distances
still work. Rebuild and copy the data again after a map update.

**Migration 0011 (ADR-020)** adds `collector_recovery_code` and lets any
phone update a collector's server details. It needs nothing by hand; codes
are issued in the Console (Collectors › ⋮ › "Sign-in code for another phone").

Archive and restore are done in the Console (Admin › Archived), not on the
VM. Nothing is deleted from the database: an archived record is hidden by an
`archive_mark` row and comes back when its batch is restored. To see what is
archived from the VM without secrets on screen:

```bash
docker compose exec db psql -U watercheck -d watercheck -c \
  "SELECT entity, count(*) FROM archive_mark WHERE archived GROUP BY 1;"
```

**Migrations 0012 and 0013 (round 3, ADR-022)** add picture authors and
removal, the no-picture reason, and message threads. They need nothing by
hand. Back up first, then rebuild as for 0009:

```bash
mkdir -p ~/backups && cd ~/WaterCheck/infra
docker compose exec -T db sh -c 'pg_dump -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc'   > ~/backups/watercheck-$(date +%Y%m%d-%H%M).dump
```

**Collect on the web (ADR-022)** is served at `/collect/` from
`~/WaterCheck/apps/collect/build/web`. Build it like the Console, with
`--base-href /collect/` and the same `WC_API_URL`, and ship it the same way
(§11). If that `build` folder was first created by Docker (owned by `root`),
fix it once with `sudo chown -R azureuser:azureuser ~/WaterCheck/apps/collect/build`.

**Names on the map (migration 0014, ADR-023).** Suggestions of villages,
trading centres and neighbourhoods need two generated files in
`~/WaterCheck/infra/places/` (git-ignored, about 17 MB together). Build them on
the dev machine:

```powershell
# Inputs: uga_admin4.geojson from https://data.humdata.org/dataset/cod-ab-uga
# (GeoJSON edition) and OpenStreetMap named places as Overpass JSON (the
# query is at the top of the script).
uv run --no-project --with shapely python -I tools/build_places.py <uga_admin4.geojson> <osm_places.json>
```

Copy `infra\places\subcounties.geojson` and `places.json` to the VM (as for the
map file), then run the migrate service; it loads a new build once and skips
an unchanged one:

```bash
cd ~/WaterCheck/infra
docker compose up -d --build migrate api worker
docker compose logs --tail=5 migrate   # "places: 1520 sub-county shapes, 64110 map places"
```

## 17a. Releasing a client version

The 0.1.1 release (2026-10-21) followed this procedure.

### 1. Set the version

Change it in all six places so the About boxes, the server's app-version
counts and the installers agree:

| File | Value |
|------|-------|
| `apps/console/pubspec.yaml`, `apps/collect/pubspec.yaml` | `version: 0.1.1+2`; raise the build number (`+N`) every release, because Android refuses an update with a lower one |
| `apps/console/lib/app/router.dart` | `consoleVersion` |
| `apps/collect/lib/features/settings/settings_screen.dart` | `appVersion` |
| `tools/windows/WaterCheck-Console.iss`, `WaterCheck-Collect.iss` | `#define AppVersion` |

### 2. Build against production

Run from `C:\Users\ocenr\Desktop\Research\app\watercheck`. The web Console
uses the same-origin API; Windows and Android use the API hostname.

```powershell
# Web Console (a separate output keeps the local /console/ preview intact)
Set-Location .\apps\console
flutter build web --release --base-href / --no-web-resources-cdn `
  --dart-define=WC_API_URL=https://watercheck.cooptconnect.app/api `
  -o "C:\Users\ocenr\Desktop\Research\app\watercheck\apps\console\build\web-prod"
New-Item -ItemType Directory -Force ..\..\dist\web | Out-Null
tar -czf ..\..\dist\web\console-web.tar.gz -C build\web-prod .

# Windows bundles
flutter build windows --release `
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api
Set-Location ..\collect
flutter build windows --release `
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api

# Offline installers (Visual C++ runtime bundled)
Set-Location ..\..
.\tools\windows\build-installers.ps1 `
  -VcRedist ".\tools\windows\prerequisites\Microsoft Visual C++ v14 Redistributable (x64)_14.51.36247.0_Machine_X64_burn_en-US.exe"

# Android APK
Set-Location .\apps\collect
flutter build apk --release `
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api
New-Item -ItemType Directory -Force ..\..\dist\android | Out-Null
Copy-Item build\app\outputs\flutter-apk\app-release.apk ..\..\dist\android\WaterCheck-Collect-0.1.1.apk
```

Windows PowerShell 5.1 reports Flutter's informational stderr notes (for
example "Wasm dry run succeeded") as errors under
`$ErrorActionPreference = "Stop"`. In a build script, judge each step by
`$LASTEXITCODE` instead.

Record a checksum for every file and keep it with the release notes:

```powershell
Get-ChildItem .\dist -Recurse -File | ForEach-Object {
  "{0}  {1}" -f $_.Name, (Get-FileHash $_.FullName -Algorithm SHA256).Hash }
```

Before shipping, check that the builds point at production:

- `main.dart.js` contains `https://watercheck.cooptconnect.app/api`;
- the Windows `data\app.so` and the APK's `lib/arm64-v8a/libapp.so` contain
  `api.watercheck.cooptconnect.app/api`;
- `aapt dump badging` on the APK shows the new `versionName`.

Then run `.\tools\cleanup.ps1`; it keeps `dist\`.

### 3. Ship, in this order

1. **Server configuration:** push, then on the VM `git pull` and recreate
   `tiles` and/or `caddy` as above.
2. **Web Console:** copy `dist\web\console-web.tar.gz`, check its SHA-256 on
   the VM, swap the folders and recreate Caddy (§11). Reload the browser with
   Ctrl+F5.
3. **Windows:** run the two `dist\windows\*-Setup.exe` files. They upgrade
   the previous version in place and keep its data. The Visual C++ step is
   skipped when the runtime is already installed.
4. **Android:** install `dist\android\WaterCheck-Collect-<version>.apk` over
   the old app. It updates in place only when signed with the same key and
   its build number is higher.

### Map style changes

Browsers and apps cache map tiles for a week (`Cache-Control` in the
Caddyfiles). When `infra/tiles-config/watercheck.json` changes, also change
the style id in `infra/tiles-config/config.json` (for example
`watercheck-v2` → `watercheck-v3`). The apps read the id from
`/tiles/styles.json`, so the new id makes them fetch fresh tiles without an
app rebuild.

## 18. Stop the deployment and control cost

Stop containers without deleting persistent volumes:

```bash
cd ~/WaterCheck/infra
docker compose down
```

Do not add `-v` unless intentionally deleting the database, object storage,
and Caddy certificate data.

To stop billing for VM compute when the project is inactive, deallocate the VM
from the Azure portal or CLI. Remember that a stopped/deallocated VM is not
reachable until started again.

## 19. Troubleshooting history

### Azure region policy error

`RequestDisallowedByAzure` means the subscription's allowed-region policy
rejected the selected region. Select one of the allowed regions listed above;
changing the resource name or disk type does not fix the policy.

### SSH private-key permission error

OpenSSH rejected the original key because a broad Windows group could read it.
Restrict the key ACL and use `IdentitiesOnly=yes`.

### SSH public-key authentication failure

The VM login user was `azureuser`, not `watercheck-user`.

### Docker repository command pasted twice

If a command is accidentally duplicated on one shell line, the shell may try
to resolve `curl` as a hostname. Re-run the intended command on a clean line.

### Compose configuration prints secrets

`docker compose config` is useful for diagnosis but expands secrets. Use
`docker compose config --quiet` for routine validation and do not share verbose
output.

### Interrupted web upload

If `scp -r` disconnects before `index.html` arrives, remove the incomplete
remote `build/web` directory and use the archive transfer procedure above.

### Tile upload permission denied

The tile directory may have been created by `root` during an earlier setup
step. Use `sudo chown azureuser:azureuser ~/WaterCheck/infra/tiles` and retry
the upload. Keep the generated MBTiles file out of Git.

### Account command says the service is unavailable

Run the account command from `~/WaterCheck/infra`, not from `~/WaterCheck` or
the home directory. Confirm `docker compose ps` shows the database and
migration dependencies available. The account commands use the migration
container's owner database connection and do not run through the public API.

### Temporary password or activation code was lost

These values are intentionally printed once and are not stored in plain text.
Create a password reset or issue a new activation code. Do not inspect or edit
database password hashes.

### Performance fixture refuses to run in production

This is intentional. The command is dev/test-only and the environment guard
protects production from synthetic load data. Do not change
`WC_ENVIRONMENT=prod` merely to bypass the guard.

### Flutter cannot find `lib/main.dart`

Run Flutter from `apps\console`, not from the repository root.

### Map tiles return 500 after a map change (2026-10-20)

`git pull` changed `tiles-config/` and a new `uganda.mbtiles` was copied, but
the tile server kept running with its old configuration. Recreate it:
`docker compose up -d --force-recreate tiles`.

### Map shows only a plain background (2026-10-20)

Three causes were found and fixed:

1. `tiles-config/config.json` pointed the vector WaterCheck style at the
   raster `area.mbtiles`, which it cannot draw. It must name `uganda.mbtiles`.
2. Windows and Android request `https://api.watercheck.cooptconnect.app/tiles/`,
   which the API hostname did not route. `Caddyfile.prod` now sends `/tiles/*`
   on that hostname to the tile server.
3. In rural areas at zoom 14 the old style's thin white roads disappeared on
   the beige land. The style now draws outlined, coloured roads
   (`watercheck-v2`), and single sources open at zoom 13.

A grey background means no tiles loaded; a beige one means tiles loaded.

### Installer stops at "Installing Microsoft Visual C++ runtime" (2026-10-20)

"Unable to execute file … vc_redist.x64.exe, CreateProcess failed: code 2":
the 0.1.0 installers bundled the runtime under its long downloaded name but
ran `vc_redist.x64.exe`. Fixed in 0.1.1 (`DestName: "vc_redist.x64.exe"`).
The step is also skipped when the runtime is already installed.

### CI security check fails on an unchanged dependency (2026-10-20)

`osv-scanner` failed on a newly published critical advisory for `certifi`
(GHSA-6q48-6c7w-9gw2) with no code change. Upgrade the package in the
lockfile (`uv lock --upgrade-package certifi` in `backend`), confirm with
`uvx pip-audit`, push, and rebuild the API and worker on the VM.

## 20. Current deployment status

Update (2026-10-25), ADR-027 to ADR-029:

- Backup `~/backups/watercheck-before-0017-20261025-1705.dump` (61 tables)
  taken first.
- The VM is at `d0a5bce`, with migration 0017 (places added from the map, and
  where pictures were taken). Nothing is needed by hand.
- Both web apps rebuilt against production, checksummed, swapped (`web.old`
  kept) and Caddy recreated. Smoke checks: both apps, Privacy Policy version
  3, health, tiles and routing answer; place search and rename ask for
  sign-in. No errors in the logs.
- **Build the web apps from Git Bash with `MSYS_NO_PATHCONV=1`.** Without it,
  `--base-href /` becomes a Windows path and the build stops.
- **On the dev machine:**
  - check free space before building;
  - delete old `apps/*/.dart_tool/flutter_build/*` folders and the `web-prod`
    outputs afterwards.

Update (2026-10-24, later), rounds ADR-023 to ADR-026:

- Backup `~/backups/watercheck-before-0016-*.dump` (52 tables) taken first.
- The VM is at `0a369c3`, migrations 0014–0016 applied. The two files copied
  by hand that morning (tile config, compose) were reset to git first.
- `infra/places/` copied (checksums matched) and loaded by `migrate`:
  1,520 sub-county shapes and 64,110 map place names.
- Both web apps rebuilt, checksummed, swapped (`web.old` kept) and Caddy
  recreated. Smoke checks: both apps, the legal documents, health, tiles and
  routing answer; the new endpoints ask for sign-in. No errors in the logs.
- Collect now opens without an activation code; everyone is asked to accept
  the Privacy Policy and Terms (version 2), which still contain
  [placeholders] to fill in before real data is collected.

Update (2026-10-24), round 3 (ADR-022):

- Backup `~/backups/watercheck-before-0013-20261023-2138.dump` taken first
  (47 tables of data, `pg_restore --list` checked).
- The VM is at `aa07c81`, migrations 0009–0013 applied, and the API and worker
  rebuilt.
- The routing service (Valhalla 3.5.1) is running with data copied from dev
  (checksum matched), and `/route/` answers on both hostnames.
- The web Console is at `/` and Collect on the web at `/collect/`; both are
  built against `https://watercheck.cooptconnect.app/api` and swapped in
  (`web.old` kept for rollback).
- Smoke checks returned 200 for both apps, their service workers, manifests,
  `sqlite3.wasm`, health on both hosts and a map tile. A road route was
  computed, and the new admin endpoint asks for sign-in (401).
- Windows installers and the Android APK were **not** rebuilt; devices on
  0.1.1 keep working and get the new features with the next client release
  (§17a).

Update (2026-10-21), release 0.1.1:

- `WC_CADDYFILE=Caddyfile.prod` is set in the VM `.env`; local machines use
  `Caddyfile.dev` by default.
- `uganda.mbtiles` (248 MB, SHA-256 checked) is on the VM. The tile server uses
  it with the `watercheck-v2` style, and map tiles answer `200 image/png` on
  both hostnames.
- The API and worker are rebuilt with `certifi` 2026.10.19.
- The 0.1.1 web Console, Windows installers and Android APK are built into
  `dist\` (§17a) for shipping.

Current status (2026-10-17):

- Azure VM is provisioned and reachable.
- DNS records resolve to the VM.
- Docker and Compose are installed and working.
- The repository is cloned at `~/WaterCheck`.
- The VM `infra/.env` exists with mode `600`.
- Production Caddy configuration is present in the Windows checkout and passed
  Caddy validation.
- Compose publishes Caddy on HTTP port `80` and HTTPS port `443` (TCP and UDP).
- The Console web build succeeded locally with the production API URL.
- The complete Console web build was transferred and verified on the VM.
- The full Compose stack is running and healthy.
- Database migrations and seed data completed successfully.
- The generated `uganda.mbtiles` (map) and `area.mbtiles` (offline pack) files
  are present and the tile server is healthy.
- Caddy obtained working HTTPS certificates for both production hostnames.
- Public smoke checks passed for the API hostname, same-origin API routes and
  the Console root.
- Browser confirmation passed: the Console sign-in page loads over HTTPS and
  `/api/health` returns `{"status":"ok"}`.

The supported environment model is:

```text
dev     local Windows workstation and local Compose
test    GitHub Actions and targeted local checks
prod    Azure VM and protected production data
```

Staging is future work and is not running on this VM. When added, use
`staging.watercheck.cooptconnect.app` and
`api-staging.watercheck.cooptconnect.app` on a separate host or a larger VM.
Staging must have its own Compose project, network, `.env`, database, object
storage, Caddy certificate volume, test data and SMTP configuration. Never
reuse production credentials or persistent volumes.

Before a future staging deployment:

1. Add the staging DNS records.
2. Create a separate deployment directory and Compose project name.
3. Create a separate staging `.env` with non-production secrets.
4. Build the Console with the staging API URL.
5. Transfer staging web assets and any generated map artifact separately.
6. Validate `docker compose config --quiet`.
7. Run migrations and seed test data.
8. Smoke-test staging before promoting changes to production.

Before starting Compose, confirm:

1. The intended Caddy change is committed and pushed.
2. The VM has pulled the latest source.
3. `docker compose config --quiet` returns exit code `0`.
4. The web files listed in the transfer section exist.
5. No secrets or private keys are staged for commit.
