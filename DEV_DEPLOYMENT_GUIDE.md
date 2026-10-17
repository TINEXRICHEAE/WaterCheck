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

### Windows release bundle

The Windows target currently produces a portable release directory, not an
MSI or MSIX installer. Copy the complete directory because the executable
depends on its adjacent `data` directory and runtime/plugin files.

For Collect, run from `.\WaterCheck\apps\collect`:

```powershell
flutter build windows --release `
  --dart-define=WC_API_URL=https://api.watercheck.cooptconnect.app/api
```

The executable and required files are in:

```text
.\WaterCheck\apps\collect\build\windows\x64\runner\Release
```

Start it from that directory:

```powershell
.\watercheck_collect.exe
```

For Console, run the equivalent command from
`.\WaterCheck\apps\console`; its executable is `watercheck_console.exe`.
For a pilot, distribute the complete `Release` directory as a ZIP. The
current project does not generate MSI or MSIX packages. If recipients must
receive one `.exe`, use an installer builder such as Inno Setup to embed the
complete `Release` directory in a self-extracting
`WaterCheck-Collect-Setup.exe`. It can install fully offline; it does not
make the Flutter application itself a single-file executable. After
installation, the application still has its DLLs and `data` directory in its
installed location. MSIX is the preferred future package for managed Windows
10/11 installation; MSI would require a separate installer tool and
configuration. Any wider distribution should sign the installer and test
login, synchronization, offline operation and photo uploads on the target
computer.

The installer should also bundle Microsoft's official x64 Visual C++
redistributable. Without it, a clean Windows computer may require a separate
runtime installation before the app starts. Bundling it adds approximately
25–30 MB to the installer. A web/bootstrapper variant is smaller but requires
internet access during installation, so it is not suitable for offline field
deployment. The final installer should verify or install the runtime before
launching WaterCheck.

Build both installers from the repository root, `.\WaterCheck`, after
building the two Windows release bundles:

```powershell
.\tools\windows\build-installers.ps1 `
  -VcRedist "C:\Path\To\vc_redist.x64.exe"
```

This requires Inno Setup (`iscc.exe`). The script fails rather than producing
an incomplete offline installer when a release bundle or supplied Visual C++
redistributable is missing. Outputs are written to
`.\WaterCheck\dist\windows\`.

### Updating installed clients

The installer is for initial installation and recovery. The recommended
update design is:

1. Publish a signed version manifest and release artifacts on the VPS.
2. Windows checks the manifest when online, prompts the user, closes, and
   launches the signed newer installer. It must not overwrite a running
   executable.
3. Android distributed through Google Play uses Play in-app updates.
4. Android distributed as a copied APK can check and download a signed APK,
   but Android requires user approval before installation.
5. The web Console updates through the VPS deployment, with cache-busting
   assets and service-worker versioning.

Offline clients continue using their installed version and synchronize when
connectivity returns. The current repository does not yet implement the
manifest, updater, or sideloaded APK update flow; those are a separate
release-channel feature requiring signing, rollback and downgrade policy.

The first locally generated installers were approximately 30.33 MB for
Collect and 32.71 MB for Console, including the x64 Visual C++ runtime.
Generated installers are written to `.\WaterCheck\dist\windows\` and are
excluded from Git.

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

### Additional disk cleanup choices

The routine cleanup intentionally does not delete global SDK and package
caches. Use the following order when more space is required:

1. Run `cleanup.ps1 -Caches` to remove the approximately 5 GB Gradle cache.
2. Inspect and remove unused Android SDK platforms/system images through
   Android Studio's SDK Manager. Do not delete the entire SDK directory.
3. Delete and regenerate the Dart/Flutter Pub cache only when necessary.
   This cache is smaller but all packages will be downloaded again.
4. Inspect the repository's remaining generated directories before deleting
   anything manually. Never delete `infra/.env`, Docker volumes, source files,
   or the generated production tile artifact without a replacement.

Inspect the largest repository directories from `.\WaterCheck` on Windows:

```powershell
Get-ChildItem . -Directory -Force | ForEach-Object {
  $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
    Measure-Object Length -Sum).Sum
  [PSCustomObject]@{Path = $_.FullName; GB = [math]::Round($size / 1GB, 2)}
} | Sort-Object GB -Descending
```

Inspect the largest global caches from any directory:

```powershell
$paths = @(
  "$env:USERPROFILE\.gradle",
  "$env:LOCALAPPDATA\Android\Sdk",
  "$env:LOCALAPPDATA\Pub\Cache"
)
$results = @()
foreach ($path in $paths) {
  $size = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue |
    Measure-Object Length -Sum).Sum
  $results += [PSCustomObject]@{
    Path = $path
    GB = [math]::Round($size / 1GB, 2)
  }
}
$results | Sort-Object GB -Descending
```

To remove the entire Pub cache, first ensure no Flutter or Dart command is
running, then run from any directory:

```powershell
dart pub cache clean
```

Confirm the prompt. The next `flutter pub get` from `.\WaterCheck` and the
next `uv sync` from `.\WaterCheck\backend` will repopulate their respective
dependency caches. Do not use this command as routine cleanup.

To remove individual unused Android SDK components, use Android Studio's
**SDK Manager** from the **SDK Platforms** and **SDK Tools** tabs. Keep the
Android platform and build-tools versions required by the current Flutter
doctor output. Removing emulator system images is safe only if those emulator
images are no longer used.

### Why an Android build can consume 10 GB

Android builds use several independent storage areas. A successful or failed
build can leave files in all of them:

| Location | Purpose | Safe action |
| --- | --- | --- |
| `apps/*/build` | APK, intermediates and native outputs | Delete; rebuilt automatically |
| `apps/*/.dart_tool` and root `.dart_tool` | Dart/Flutter package and tool state | Delete; run `flutter pub get` again |
| `%USERPROFILE%\.gradle\caches` | Gradle dependencies and transforms | Delete; dependencies redownload |
| `%USERPROFILE%\.gradle\wrapper` | Gradle distributions | Keep unless critically short of space |
| `%TEMP%\flutter_tools.*` | Flutter build temporary files | Delete after Flutter exits |
| `%TEMP%\hsperfdata_*` and `hs_err_pid*.log` | Java diagnostics after a crash | Delete after reviewing the crash |
| Android SDK | Platforms, NDKs, emulator images and tools | Remove individual unused items in SDK Manager |
| Docker Desktop disk image | Images, layers, builder cache and volumes | Inspect with Docker; volumes contain local data |

The Gradle cache is reusable, not a reservation of build memory. Gradle still
needs temporary working space and Java heap while transforming dependencies and
assembling the APK. If the same dependency is present in multiple Android/Gradle
versions, Gradle may retain multiple copies. A failed build can also leave
partial transforms until cleanup.

The project now caps Gradle at `-Xmx2G`; this limits Java heap but does not
limit native memory, Android tooling, Flutter, the IDE, Docker Desktop or
emulators. Keep at least 15–20% of the system drive free before starting a
release build. Stop the build if free space approaches 10 GB.

Inspect temporary files from any PowerShell directory:

```powershell
$tempPaths = @($env:TEMP, $env:TMP)
foreach ($path in ($tempPaths | Select-Object -Unique)) {
  $size = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue |
    Measure-Object Length -Sum).Sum
  [PSCustomObject]@{Path = $path; GB = [math]::Round($size / 1GB, 2)}
}
```

Inspect Docker storage from any directory:

```powershell
docker system df
docker builder prune -af
docker image prune -af
```

Do not run `docker volume prune` unless you intentionally want to delete local
database and object-storage data. The production database is on the VM, but
local development volumes may contain useful test state.

### Full local development reset

Deleting and recloning the repository is valid, but it only removes files
inside the repository. It does not remove Gradle caches, the Android SDK, Pub
cache, temporary files, Android emulator images, Docker Desktop's disk image,
or Docker volumes.

Use this reset only when local development data can be discarded. First stop
Flutter, Android Studio, VS Code tasks and Docker Compose. From
`.\WaterCheck\infra` on Windows or `./WaterCheck/infra` on Linux:

```sh
docker compose down
```

If local database, storage and Caddy data can be discarded too:

```sh
docker compose down -v
```

Then remove the repository directory and clone it again. On Windows, use
File Explorer or a specifically named PowerShell path; do not delete a
wildcard or an unresolved variable:

```powershell
Remove-Item -Recurse -Force .\WaterCheck
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
```

On Linux, from the parent directory of the repository:

```bash
rm -rf ./WaterCheck
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
```

After recloning, reinstall dependencies and recreate only local development
data. This does not affect the remote production VM, but a local `.env`,
generated tiles, local accounts, local volumes and local build outputs will be
gone unless backed up separately.

For a lower-risk reset, run `cleanup.ps1 -Caches`, remove the two app
`.dart_tool` directories, prune Docker builder/images, and keep the repository
and Docker volumes intact.

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
