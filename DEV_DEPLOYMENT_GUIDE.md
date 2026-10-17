# WaterCheck Development Deployment Guide

This guide runs the complete WaterCheck development stack on a Windows or
Linux computer. It is intentionally separate from
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md), which describes the live Azure
production deployment.

The development stack includes:

- PostgreSQL/PostGIS;
- SeaweedFS object storage;
- API and worker;
- Caddy;
- Mailpit;
- tile server;
- seeded reference data;
- optional synthetic performance/demo data.

Development data and secrets must never be copied into production.

## 1. Prerequisites

Install:

- Git;
- Docker Engine and Compose on Linux, or Docker Desktop with Linux containers
  and WSL2 on Windows;
- Flutter at the version in `.fvmrc`;
- Chrome for web development;
- Android Studio and Android SDK for Android development;
- Visual Studio with Desktop development with C++ for Windows desktop builds;
- `uv` for backend tooling.

Run from any directory.

Windows PowerShell:

```powershell
git --version
docker --version
docker compose version
flutter doctor -v
uv --version
```

Linux Bash:

```bash
git --version
docker --version
docker compose version
flutter doctor -v
uv --version
```

## 2. Clone and install

Run from the directory where projects are stored.

Windows PowerShell:

```powershell
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
Set-Location .\WaterCheck
flutter pub get
```

Linux Bash:

```bash
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
cd ./WaterCheck
flutter pub get
```

Run from `.\WaterCheck\backend` on Windows or `./WaterCheck/backend` on Linux:

```sh
uv sync
```

## 3. Configure and start the stack

Copy the development template. Run from the repository root.

Windows PowerShell:

```powershell
Copy-Item infra\.env.example infra\.env
```

Linux Bash:

```bash
cp ./infra/.env.example ./infra/.env
```

Run from `.\WaterCheck\infra` on Windows or `./WaterCheck/infra` on Linux:

```sh
docker compose up -d --build
docker compose ps
```

The first start runs migrations, creates the restricted API role and loads the
versioned reference seed. Check the API:

Windows:

```powershell
curl.exe -i http://localhost/health
```

Linux:

```bash
curl -i http://localhost/health
```

Expected response:

```json
{"status":"ok"}
```

Mailpit is available at <http://localhost:8025>. Stop the stack without
deleting volumes:

Run from `.\WaterCheck\infra` or `./WaterCheck/infra`:

```sh
docker compose down
```

Do not use `docker compose down -v` unless intentionally deleting local
database, storage and Caddy data.

## 4. Create development users

The reference seed does not create login accounts. Create a development
administrator from the migration container.

Run from `.\WaterCheck\infra` or `./WaterCheck/infra`:

```sh
docker compose run --rm migrate \
  python -m app.cli create-admin \
  --username dev-admin@example.org \
  --full-name "Development IT Admin"
```

Create a stakeholder:

```sh
docker compose run --rm migrate \
  python -m app.cli create-stakeholder \
  --username dev-stakeholder@example.org \
  --full-name "Development Stakeholder" \
  --area UG-ABIM
```

Create a collector activation code:

```sh
docker compose run --rm migrate \
  python -m app.cli create-activation-code \
  --area ABIM-ENT \
  --max 5 \
  --days 30
```

Temporary passwords and activation codes are printed once. Collectors do not
sign in with usernames and passwords; they activate a Collect installation
with the code, then set a local PIN.

## 5. Add synthetic demo/performance data

The reference seed is safe in development. The performance fixture is
synthetic and must remain limited to `dev` and `test`.

Run from `.\WaterCheck\infra` or `./WaterCheck/infra`:

```sh
docker compose run --rm migrate \
  python -m app.cli seed-perf-fixture \
  --village ABIM-ENT \
  --sources 50 \
  --tests 10
```

This creates synthetic source and test history for dashboard and performance
testing. The command refuses to run when `WC_ENVIRONMENT=prod`; do not bypass
that guard.

## 6. Run the applications locally

### Console web

Run from `.\WaterCheck\apps\console` or `./WaterCheck/apps/console`:

```sh
flutter run -d chrome --dart-define=WC_API_URL=http://localhost/api
```

Open <http://localhost:xxxxx> using the URL printed by Flutter, or use the
web files through local Caddy after building them.

### Console Windows

Run from `.\WaterCheck\apps\console` on Windows:

```powershell
flutter run -d windows --dart-define=WC_API_URL=http://localhost/api
```

### Console Linux

Enable Linux desktop once, from any directory:

```bash
flutter config --enable-linux-desktop
```

Run from `./WaterCheck/apps/console`:

```bash
flutter run -d linux --dart-define=WC_API_URL=http://localhost/api
```

### Android emulator

The Android emulator maps the host computer to `10.0.2.2`.

Run from `.\WaterCheck\apps\console` or `./WaterCheck/apps/console`:

```sh
flutter devices
flutter run -d <android-device-id> \
  --dart-define=WC_API_URL=http://10.0.2.2/api
```

Run the same command from the corresponding Collect directory to run Collect.

For a physical phone, use the computer's LAN address instead of `10.0.2.2`.
The phone and computer must be on the same network, and the local firewall
must allow the development HTTP port.

## 7. Build local web assets and tiles

Build map tiles when the local map is needed.

Run from `.\WaterCheck` or `./WaterCheck`:

```powershell
.\tools\build_tiles.ps1
```

On Linux, run the PowerShell script with `pwsh`:

```bash
pwsh ./tools/build_tiles.ps1
```

Build Console web assets from `.\WaterCheck\apps\console` or
`./WaterCheck/apps/console`:

```sh
flutter build web --debug --base-href /
```

Build Collect web assets from `.\WaterCheck\apps\collect` or
`./WaterCheck/apps/collect`:

```sh
flutter build web --debug --base-href /
```

After building, recreate Caddy from `.\WaterCheck\infra` or
`./WaterCheck/infra`:

```sh
docker compose up -d --force-recreate caddy
```

The current production Caddy configuration serves the Console at the
production web hostname. The development Caddy configuration is the place for
the local `/collect/` route. A production Collect web route has not yet been
deployed.

## 8. Android APK using the production API

Collectors do not log in to the production web Console. To test a real
production collector on Android, build Collect as an APK with the public API
hostname.

Run from `.\WaterCheck\apps\collect` on Windows:

```powershell
flutter build apk --release `
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api
```

Run from `./WaterCheck/apps/collect` on Linux:

```bash
flutter build apk --release \
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api
```

The APK is under:

```text
apps/collect/build/app/outputs/flutter-apk/
```

Install it on a connected Android device:

Run from `.\WaterCheck\apps\collect` or `./WaterCheck/apps/collect`:

```sh
flutter devices
flutter install -d <android-device-id>
```

Then activate the app using a production activation code created by an IT
admin. The production activation flow is documented in
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#15a-production-accounts-and-collector-activation).

Use a dedicated production test device and clearly identified test records.
Do not use an administrator's credentials in the Collect app.

## 9. Common development errors

### `no configuration file provided`

Run Compose from `.\WaterCheck\infra` or `./WaterCheck/infra`, not the
repository parent directory.

### `Target file "lib/main.dart" not found`

Run Flutter from the specific app directory:

- `.\WaterCheck\apps\console` or `./WaterCheck/apps/console`;
- `.\WaterCheck\apps\collect` or `./WaterCheck/apps/collect`.

### API is unreachable from Android

Use `http://10.0.2.2/api` for an Android emulator. Use the computer's LAN IP
for a physical phone. Confirm Caddy is running and the firewall allows the
local port.

### `seed-perf-fixture` refuses to run

Confirm the environment is `dev` or `test`. Never change production to `dev`
just to load synthetic data.

### Android Gradle daemon disappears or JVM crash log is created

The project caps Gradle at `-Xmx2G` because a typical development laptop may
have only 8 GiB RAM. An older checkout or a manually overridden
`GRADLE_OPTS`/`org.gradle.jvmargs` setting may still request too much memory.
Check `apps/collect/android/gradle.properties` and keep the project value at
the documented limit.

Run from `.\WaterCheck\apps\collect\android` on Windows or
`./WaterCheck/apps/collect/android` on Linux:

```sh
./gradlew --stop
```

On Windows PowerShell use:

```powershell
.\gradlew.bat --stop
```

Then run the cleanup script from the repository root. It removes reproducible
Flutter and Android build outputs, stale Docker build cache, interrupted tile
work and JVM crash reports, but preserves source, dependency caches, Docker
volumes and the generated web preview unless `-Previews` is supplied.

Windows, from `.\WaterCheck`:

```powershell
.\tools\cleanup.ps1
```

Linux with PowerShell installed, from `./WaterCheck`:

```bash
pwsh ./tools/cleanup.ps1
```

If more space is needed, add `-Caches`. This removes regenerable Gradle
caches and temporary files but preserves the Gradle wrapper distributions,
Android SDK, Pub cache, Docker volumes and source code.

Windows, from `.\WaterCheck`:

```powershell
.\tools\cleanup.ps1 -Caches
```

Linux with PowerShell installed, from `./WaterCheck`:

```bash
pwsh ./tools/cleanup.ps1 -Caches
```

Retry the production-API APK build from the Collect app directory:

Windows, from `.\WaterCheck\apps\collect`:

```powershell
flutter build apk --release `
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api
```

Linux, from `./WaterCheck/apps/collect`:

```bash
flutter build apk --release \
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api
```

The `java.lang.System::load`, SDK XML version, deprecated Java source and
Kotlin built-in plugin messages are warnings. The fatal message is
`There is insufficient memory for the Java Runtime Environment` or
`Gradle build daemon disappeared unexpectedly`.

### Migration or API starts before PostgreSQL

Run:

```sh
docker compose logs --tail=100 migrate
docker compose ps
```

Then retry after the database becomes healthy:

```sh
docker compose run --rm migrate
docker compose up -d --build
```

## 10. Further documentation

- [README.md](README.md): product overview and platform summary;
- [CONTRIBUTING.md](CONTRIBUTING.md): coding, testing and repository workflow;
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md): Azure production deployment and
  production onboarding;
- [docs/PLAN.md](docs/PLAN.md): roadmap and operational decisions;
- [PROGRESS.md](PROGRESS.md): completed gates and deferred work.
