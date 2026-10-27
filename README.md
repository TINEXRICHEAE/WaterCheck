# FieldQuire

FieldQuire is a platform for field data collection, monitoring, analysis and
reporting, built for Uganda.

- **FieldQuire Collect** is the app for people who collect, and it works
  without a connection.
- **FieldQuire Console** is where stakeholders and researchers plan, review,
  analyse and report.

It has separate sides for different kinds of work (ADR-031), each with its own
people, pages, records, Terms of Use and Privacy Policy. More sides may be
added later.

- **Water testing** (WaterCheck, where FieldQuire began): community
  drinking-water monitoring. Testers record water-source tests, and
  stakeholders follow up results, alerts and reports.
- **Research** (ADR-030): researchers build forms, and collectors fill them in
  the field. Records keep where and when they were made, then are analysed
  and exported.

The water pilot started in Abim District, but the data model, area hierarchy
and map scope support Uganda-wide operation: regions, districts, sub-counties,
parishes and villages. The code keeps the `watercheck` names of its folders and
packages.

## Quick start for a new computer

This is the shortest reliable path for a new Windows or Linux developer or a
future maintainer. Every command below states the directory where it must be
run. Windows examples use PowerShell; Linux examples use Bash. Windows users
may also use Git Bash or WSL, but must use the matching shell syntax.

### 1. Install the prerequisites

Install the following before cloning or building:

- Git;
- Docker Engine and Docker Compose on Linux, or Docker Desktop with Linux
  containers and WSL2 enabled on Windows;
- Flutter at the version pinned in [.fvmrc](.fvmrc), using
  [FVM](https://fvm.app/) or a matching global Flutter installation;
- Android Studio and an Android SDK if Android testing is needed;
- Visual Studio with **Desktop development with C++** if Windows apps are
  needed (Windows only);
- Chrome if running the web apps;
- [uv](https://docs.astral.sh/uv/) for backend development.

After installation, verify the tools:

Run from any directory:

```powershell
git --version
docker --version
docker compose version
flutter doctor -v
uv --version
```

On Linux, run the same checks from any directory in Bash:

```bash
git --version
docker --version
docker compose version
flutter doctor -v
uv --version
```

For Linux desktop builds, also enable the Linux desktop target:

Run from any directory:

```bash
flutter config --enable-linux-desktop
```

For Windows desktop builds, use Windows with Visual Studio. Linux cannot
produce a Windows desktop executable without a separate Windows build
environment.

Windows Developer Mode should be enabled for Flutter plugins and symlinks.
On Linux, install the distribution's required Flutter desktop libraries if
building Linux desktop apps. Docker must be running before starting the
backend or running backend tests.

### 2. Clone and install project dependencies

Run from the directory where you keep projects, before the repository exists:

```powershell
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
Set-Location .\WaterCheck
```

Run from the directory where you keep projects, before the repository exists,
in Linux Bash:

```bash
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
cd ./WaterCheck
```

Run from the repository root, `.\WaterCheck`:

```powershell
# Use "fvm flutter" instead of "flutter" when FVM is installed.
flutter pub get
```

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\backend
uv sync
```

Run from `./WaterCheck/backend` in Linux Bash:

```bash
uv sync
```

The repository is a Dart workspace, so the root `flutter pub get` resolves the
apps and shared packages. Do not run Flutter commands from a parent directory;
run app commands from `apps\collect` or `apps\console`.

### 3. Create the local development environment

Copy the safe development template. Never copy production secrets from the
Azure VM and never commit the resulting `.env` file.

```powershell
Copy-Item infra\.env.example infra\.env
```

Run from the repository root, `./WaterCheck`, in Linux Bash:

```bash
cp ./infra/.env.example ./infra/.env
```

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\infra
docker compose up -d --build
```

The first build downloads Docker images, runs database migrations, creates the
restricted API role and loads seed data. It can take several minutes. Check
the stack and API:

```powershell
Set-Location .\infra
docker compose ps
curl.exe http://localhost/health
```

The health request should return:

```json
{"status":"ok"}
```

Development email is captured by Mailpit at
[http://localhost:8025](http://localhost:8025). The database and object
storage are local Docker volumes. To stop the stack without deleting data:

```powershell
Set-Location .\infra
docker compose down
```

### 4. Prepare map and web assets

The map artifact is generated and ignored by Git. Build it when the map is
needed on a fresh machine:

Run from the repository root, `.\WaterCheck`:

```powershell
.\tools\build_tiles.ps1
```

The tile builder is a PowerShell script. On Linux, install PowerShell and run
it from `./WaterCheck`:

```bash
pwsh ./tools/build_tiles.ps1
```

For the Console web files served through local Caddy, build the Console from
its own directory:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\console
flutter build web --debug --base-href /
```

The Collect web build is optional for normal Android/Windows development. If
you need it:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\collect
flutter build web --debug --base-href /
```

Recreate Caddy after adding or replacing web assets:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\infra
docker compose up -d --force-recreate caddy
```

### 5. Create a local admin and run an app

Create a throwaway local IT-admin account inside the migration container:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\infra
docker compose run --rm migrate python -m app.cli create-admin `
  --username you@example.org `
  --full-name "IT Admin"
```

Use the temporary password printed by the command to sign in to the Console.
An admin can then create stakeholders under **Admin → People** and create
collector activation codes under **Admin → Collect phones**. For a complete
user workflow, see [Users and access model](#users-and-access-model) and
[docs/demos/P11.md](docs/demos/P11.md).

Run the Console directly in Chrome:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\console
flutter run -d chrome --dart-define=WC_API_URL=http://localhost/api
```

Run Collect on Windows:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\collect
flutter run -d windows --dart-define=WC_API_URL=http://localhost/api
```

Start an Android emulator first and identify its device ID.

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\console
flutter devices
flutter run -d <android-device-id> `
  --dart-define=WC_API_URL=http://10.0.2.2/api
```

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\collect
flutter devices
flutter run -d <android-device-id> `
  --dart-define=WC_API_URL=http://10.0.2.2/api
```

The Android emulator reaches the local API through `http://10.0.2.2/api`.
A physical phone needs the computer's LAN address:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\collect
flutter run -d <android-device-id> `
  --dart-define=WC_API_URL=http://<computer-lan-ip>/api
```

### Linux Bash equivalents

Run these from the repository root, `./WaterCheck`, unless another directory
is shown:

```bash
# Run from ./WaterCheck/infra
cd ./infra
docker compose up -d --build
docker compose ps
curl http://localhost/health
```

Run from `./WaterCheck/infra`:

```bash
docker compose run --rm migrate python -m app.cli create-admin \
  --username you@example.org \
  --full-name "IT Admin"
```

Run from `./WaterCheck/apps/console`:

```bash
flutter run -d chrome --dart-define=WC_API_URL=http://localhost/api
```

Run from `./WaterCheck/apps/collect`:

```bash
flutter run -d chrome --dart-define=WC_API_URL=http://localhost/api
```

Run from `./WaterCheck/apps/collect`:

```bash
flutter run -d linux --dart-define=WC_API_URL=http://localhost/api
```

Run from `./WaterCheck/apps/console` or `./WaterCheck/apps/collect` for an
Android emulator:

```bash
flutter devices
flutter run -d <android-device-id> \
  --dart-define=WC_API_URL=http://10.0.2.2/api
```

Linux does not build Windows desktop binaries. Build those on Windows or in a
dedicated Windows CI runner. Linux can build Android and web artifacts when
the Android SDK and Chrome are installed.

### 6. Confirm the installation

Run from the repository root, `.\WaterCheck`:

```powershell
dart run melos run format:check
dart run melos run analyze
dart run melos run test:dart
dart run melos run test:flutter
```

For backend checks:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location backend
uv run ruff format --check .
uv run ruff check .
uv run mypy
uv run pytest
```

Run from `./WaterCheck` in Linux Bash:

```bash
dart run melos run format:check
dart run melos run analyze
dart run melos run test:dart
dart run melos run test:flutter
```

Run from `./WaterCheck/backend` in Linux Bash:

```bash
uv run ruff format --check .
uv run ruff check .
uv run mypy
uv run pytest
```

If a command fails, first confirm that Docker Desktop is running, the command
is being run from the directory shown above, and the Flutter version matches
[.fvmrc](.fvmrc). More complete troubleshooting and deployment instructions
are in [CONTRIBUTING.md](CONTRIBUTING.md) and
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## VPS setup relationship

The local Docker setup is deliberately close to the production VPS setup. A
new Ubuntu VPS needs the same repository, Docker Engine/Compose, production
`.env`, generated web build and `area.mbtiles` artifact. The differences are
the hostname, DNS records, HTTPS certificate, firewall rules, persistent
production secrets and production data. Do not copy the local development
`.env` or local Docker volumes to production.

On a fresh VPS, after Docker and DNS/firewall setup, the operational sequence
is:

Run from the VPS home directory, before the repository exists:

```bash
git clone https://github.com/TINEXRICHEAE/WaterCheck.git
cd WaterCheck
```

Run from `~/WaterCheck/infra`:

```bash
cp .env.example .env
chmod 600 .env
docker compose config --quiet
docker compose up -d --build
curl -k -i https://<production-api-host>/health
```

The `.env` values, Caddy hostnames, Flutter artifact transfer, tile
generation/transfer, migrations, HTTPS verification, backups, updates and
cost controls are intentionally covered in
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md). Use that guide rather than
inventing production values from this README.

## Platform build and production API options

The same backend can serve the web, Windows and Android clients. The
`WC_API_URL` Dart define selects the API endpoint at build/run time:

| Client | Local development | Production |
| --- | --- | --- |
| Console web | `http://localhost/api` through local Caddy | `https://watercheck.fieldquire.cooptconnect.app/api` |
| Console Windows | `http://localhost/api` or the computer LAN URL | `https://api.watercheck.fieldquire.cooptconnect.app/api` |
| Console Android | `http://10.0.2.2/api` on an emulator | `https://api.watercheck.fieldquire.cooptconnect.app/api` |
| Collect Windows | `http://localhost/api` or the computer LAN URL | `https://api.watercheck.fieldquire.cooptconnect.app/api` |
| Collect Android | `http://10.0.2.2/api` on an emulator | `https://api.watercheck.fieldquire.cooptconnect.app/api` |

Native clients use the API hostname because they are not served from the web
hostname and therefore cannot rely on same-origin `/api` routing. Production
native clients need Internet access and a valid HTTPS certificate; they do not
need Docker, Caddy or the production VM installed locally.

### Production web Console

Build the release web files with the web hostname API path.

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\console
flutter build web --release `
  --base-href / `
  --dart-define=WC_API_URL=https://watercheck.fieldquire.cooptconnect.app/api `
  --no-web-resources-cdn `
  --no-pub
```

Transfer `.\apps\console\build\web` to the production host and recreate Caddy
as described in [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md). For a release,
add `-o <absolute path>\apps\console\build\web-prod` so the local `/console/`
preview is not overwritten. The complete release procedure (versions, web,
Windows installers, APK, checksums, shipping order) is in
[DEPLOYMENT_GUIDE.md §17a](DEPLOYMENT_GUIDE.md#17a-releasing-a-client-version). Do not commit the
build output or transfer the production `.env` to the development computer.

On Linux, run the equivalent build from `./WaterCheck/apps/console`:

```bash
flutter build web --release \
  --base-href / \
  --dart-define=WC_API_URL=https://watercheck.fieldquire.cooptconnect.app/api \
  --no-web-resources-cdn \
  --no-pub
```

### Production Windows Console or Collect

Build a signed or otherwise controlled Windows release that talks to the
public API.

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\console
flutter build windows --release `
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\collect
flutter build windows --release `
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

The resulting executables are under
`apps\console\build\windows\x64\runner\Release` and
`apps\collect\build\windows\x64\runner\Release`. Package them for Windows
distribution and test sign-in, synchronization, offline behavior and photo
uploads against production before giving them to users. Windows releases do
not get installed inside the web/API Docker stack.

The current Flutter build is a **portable Windows release bundle**, not an
MSI installer. The bundle contains the application `.exe`, `data` and
runtime/plugin files, so copy the entire `Release` directory rather than only
the `.exe`. The current executable names are `watercheck_console.exe` and
`watercheck_collect.exe`. An MSI or MSIX package is a later distribution
layer; neither installer format is currently generated by this repository.

A single downloadable `.exe` is still possible as an **offline installer**.
An installer such as Inno Setup can embed the complete Flutter `Release`
directory inside one `WaterCheck-Collect-Setup.exe` or
`WaterCheck-Console-Setup.exe`. The user downloads one file, runs it, and the
installer extracts the bundled DLLs and `data` files locally. It does not need
to download application files from the internet. This is different from
`watercheck_collect.exe`, which is the application executable and still needs
its Flutter runtime files beside it after installation. The installer is not
yet configured in this repository.

Installer definitions are in
[`tools/windows/`](tools/windows/). After installing Inno Setup, build both
offline installers from the repository root, `.\WaterCheck`:

```powershell
.\tools\windows\build-installers.ps1 `
  -VcRedist "C:\Path\To\vc_redist.x64.exe"
```

Passing the official x64 Visual C++ redistributable embeds it in both
installers. The installers copy it as `vc_redist.x64.exe` and skip it when the
runtime is already installed. The 0.1.0 installers stopped with
"CreateProcess failed: code 2"; this is fixed in 0.1.1. The resulting files are written to `.\dist\windows\`. Do not
distribute an installer built without the runtime unless every target
computer is already known to have the compatible runtime.

### Application updates

The offline installer is the initial installation and recovery package; it
is not itself an update service. Each client platform has different update
rules:

- **Windows:** publish a signed newer installer and have the app check a
  version manifest on the API. It can notify the user and launch the installer
  after the app closes. A running Windows process cannot safely replace its
  own executable.
- **Android through Google Play:** publish an AAB and use Play's in-app update
  flow. Play handles download, signature and installation.
- **Android sideloaded APK:** the app may check the API, notify the user and
  download a signed APK, but Android requires the user to approve
  installation. It cannot silently replace itself.
- **Web Console:** users receive the latest deployed web assets after the VPS
  deployment; cache headers and service-worker versioning must prevent stale
  assets.

The current code does not yet implement a version manifest, Windows updater,
or sideloaded Android update flow. These should be added as a signed,
versioned release channel rather than allowing clients to download arbitrary
executables from the API.

The first locally generated offline installer sizes were approximately
30.33 MB for Collect and 32.71 MB for Console, including the x64 Visual C++
redistributable. Sizes vary with application assets and compression. Generated
installers are local release artifacts under `.\dist\windows\` and are
intentionally excluded from Git.

The target computer also needs Microsoft's x64 Visual C++ runtime. The
installer can include the official x64 redistributable, so a non-technical
user does not need a separate prerequisite step. Expect roughly 25–30 MB of
additional installer size for the current x64 runtime, subject to Microsoft's
current release size. A web/bootstrapper installer can be much smaller, but
would require internet access during installation. Bundling the runtime is
therefore the appropriate choice for offline or unreliable-connectivity
deployment.

To make a local production-API Collect bundle, run from
`C:\Users\ocenr\Desktop\Research\app\watercheck\apps\collect`:

```powershell
flutter build windows --release `
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

The runnable bundle is:

```text
C:\Users\ocenr\Desktop\Research\app\watercheck\apps\collect\build\windows\x64\runner\Release
```

Launch it from that bundle directory with:

```powershell
.\watercheck_collect.exe
```

For Console, use the same command and API define from
`C:\Users\ocenr\Desktop\Research\app\watercheck\apps\console`; its bundle is
under `apps\console\build\windows\x64\runner\Release`.

An **MSIX** is the preferred future Windows 10/11 package because it supports
clean installation and removal, but it requires package identity, a
certificate and signing (a self-signed certificate is suitable only for a
controlled pilot). An **MSI** is a traditional installer and requires a
separate installer tool/configuration. Building either package does not
change the Flutter application or the production API.

Run the Windows builds on Windows from the indicated app directories. A Linux
machine cannot produce these Windows binaries directly.

### Production Android Console or Collect

Build an Android release using the API hostname. Android signing, keystore
storage and Play/internal distribution are separate from the web deployment.

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\console
flutter build apk --release `
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\collect
flutter build apk --release `
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

The APKs are under each app's `build\app\outputs\flutter-apk` directory.
For release distribution, prefer an app bundle where supported:

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\console
flutter build appbundle --release `
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

On Linux, run the Android Console build from `./WaterCheck/apps/console`:

```bash
flutter build apk --release \
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

On Linux, run the Android Collect build from `./WaterCheck/apps/collect`:

```bash
flutter build apk --release \
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

For Linux app bundles, run from `./WaterCheck/apps/console` or
`./WaterCheck/apps/collect`:

```bash
flutter build appbundle --release \
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

Run from the repository root, `.\WaterCheck`:

```powershell
Set-Location .\apps\collect
flutter build appbundle --release `
  --dart-define=WC_API_URL=https://api.watercheck.fieldquire.cooptconnect.app/api
```

Install a test APK directly on a connected device:

Run from `.\WaterCheck\apps\console` or `.\WaterCheck\apps\collect`:

```powershell
flutter devices
flutter install -d <android-device-id>
```

If repeated Android builds fill the SSD or Gradle crashes, stop Gradle and run
the repository cleanup script. It removes reproducible Flutter/Android build
outputs and stale build caches but does not remove source or Docker data.

Run from `.\WaterCheck` on Windows:

```powershell
.\tools\cleanup.ps1
```

Run from `./WaterCheck` on Linux with PowerShell installed:

```bash
pwsh ./tools/cleanup.ps1
```

If more space is needed, use `-Caches` to remove regenerable Gradle caches.
This keeps the Android SDK, Pub cache, source and Docker volumes:

Run from `.\WaterCheck` on Windows or `./WaterCheck` on Linux:

Windows PowerShell:

```powershell
.\tools\cleanup.ps1 -Caches
```

Linux Bash with PowerShell installed:

```bash
pwsh ./tools/cleanup.ps1 -Caches
```

This is intentionally a tiered cleanup. The routine script may free less than
the repository's total disk footprint because it preserves reusable global
caches. The approximate 5 GB Gradle cache is the largest safe global cleanup.
Use Android Studio's SDK Manager to remove unused Android platforms or emulator
images; do not delete the entire Android SDK. The Pub cache can be removed
only when necessary:

Run from any directory after closing Flutter/Dart processes:

```powershell
dart pub cache clean
```

The next dependency restore downloads the packages again. For directory size
inspection and a complete cleanup decision tree, see
[DEV_DEPLOYMENT_GUIDE.md](DEV_DEPLOYMENT_GUIDE.md#additional-disk-cleanup-choices).

An Android build can temporarily consume several gigabytes outside the
repository: Gradle transforms, Flutter temporary directories, Java crash
reports, Android SDK components, emulator images and Docker Desktop's virtual
disk are separate from the project cache. Reusable caches reduce download
time; they do not prevent memory use or temporary expansion during a build.
Keep at least 15–20% of the system drive free before release builds.

Deleting and recloning `WaterCheck` removes only repository files. It does not
remove `%USERPROFILE%\.gradle`, the Android SDK, Pub cache, temporary files,
emulator images, Docker images, Docker builder cache or Docker volumes. A full
local reset and the safe Docker-volume distinction are documented in
[DEV_DEPLOYMENT_GUIDE.md](DEV_DEPLOYMENT_GUIDE.md#full-local-development-reset).

Use a dedicated production test account and test data. Do not use the
production IT-admin account for ordinary field-device testing. Native
production clients should be released only after the API health check,
authentication, area scoping, offline sync and revocation workflows pass.

## Applications and services

| Component | Purpose | Platforms |
| --- | --- | --- |
| **WaterCheck Collect** | Offline-first field app used by collectors to identify themselves, record sources, capture readings and submit tests. Collectors use an activated phone; they do not need Console accounts. | Android, Windows |
| **WaterCheck Console** | Online/offline-capable dashboard for stakeholders and the IT administration team. | Web, Windows, Android |
| **Backend API** | Authentication, synchronization, scoped data access, classifications, alerts, reports and administration. | FastAPI in Docker |
| **Database** | PostgreSQL/PostGIS for operational data, spatial areas and row-level access control. | Docker |
| **Object storage** | SeaweedFS/S3-compatible storage for private photos and uploaded artifacts. | Docker |
| **Tile service** | Serves generated map tiles for the Console and field workflows. | Docker |
| **Worker and mail service** | Processes alert notifications and development/test email. | Docker |

Shared Dart packages contain the domain rules, encrypted local database and
sync implementation, API client and UI components. See the
[development instructions](CONTRIBUTING.md) for the repository layout and
setup commands.

## Users and access model

### Field collectors

Collectors use **Collect**, not the Console. An IT admin creates an activation
code for an area in **Console → Admin → Collect phones**. The collector scans
or enters the code, supplies their collector identification, and uses the
activated phone to work offline. Their identification is attached to submitted
records so results remain traceable.

Collectors can:

- view assigned water sources and their latest status;
- add or select a source;
- calibrate or identify the tester;
- enter readings manually or from a tester;
- record sanitary inspections, location and optional photos;
- review limitations and the classification result;
- save and submit tests offline;
- sync readings and photos later, with retry and resumable uploads;
- use a local PIN after activation.

Collectors do not receive Console usernames and passwords. An admin can revoke
an activated phone from **Admin → Collect phones**.

### Stakeholders

Stakeholders sign in to the Console and see data scoped to their assigned
areas and responsibilities. They can:

- review dashboard KPIs and recent activity;
- browse sources, map locations, histories and collector activity;
- review, acknowledge and act on alerts;
- view and update source details and inspections;
- receive in-app and configured notification channels;
- create reports as PDF or CSV;
- manage their profile, notification preferences and visible limit sets;
- approve stakeholder-only custom limit changes when required.

An IT admin creates stakeholder accounts in **Console → Admin → People**.
The temporary password is displayed once and must be changed at first sign-in.

### IT administrators

IT administrators have the stakeholder features plus the **Admin** area. They
can manage:

- **People:** stakeholders and IT admins, roles, area assignments,
  responsibilities, activation status and password resets;
- **Collect phones:** activation codes, QR codes, activated installations and
  revocation;
- **Coverage chain:** which users cover which areas and how alerts route;
- **System:** health, service status and operational diagnostics;
- **Sign-in security:** password, lockout and session policy;
- **Alert routing:** responsibilities, rules and alert types;
- **Places:** additional places below the official administrative hierarchy;
- **Parameters:** catalogue additions and parameter merges;
- **Response cards:** localized guidance shown after results;
- **Reference data:** operational defaults and seeded reference data.

The detailed acceptance walkthrough is in [docs/demos/P11.md](docs/demos/P11.md).

## Navigation

### Collect navigation

Collect has three primary destinations:

- **Home:** assigned sources, current statuses, due/overdue tests, sync state
  and **Test a source**;
- **Sync:** queued readings/photos, sync status, errors and **Sync now**;
- **Settings:** collector/profile information, tester and calibration settings,
  offline/PIN controls, photo upload policy, appearance and time zone.

The normal test flow is:

```text
Home → choose or add source → identify tester/calibrate
     → enter readings and inspection → review result → save/submit
     → Sync when connected
```

### Console navigation

Stakeholders see these primary sections:

- **Dashboard:** KPIs, latest issues, status summaries and collector activity;
- **Sources:** source list, filters, map, source details, history, inspections
  and submitted collector information;
- **Alerts:** notification inbox, alert details, acknowledgement, action,
  lab-confirmation request, closure or false-alarm notes;
- **Collectors:** collector activity and submitted-record summaries;
- **Reports:** filtered PDF reports and readings CSV exports.

The account menu contains:

- **Limit sets**, where applicable;
- **Profile**, including areas, responsibilities and notification preferences;
- **About** and sign-out.

IT administrators additionally see:

```text
Admin
├── People
├── Collect phones
├── Coverage chain
├── System
├── Sign-in security
├── Alert routing
├── Places
├── Parameters
├── Response cards
└── Reference data
```

## Currently working

The automated P0–P11 implementation gates are complete, with selected
real-device, printer and field checks intentionally deferred to P12. Working
capabilities include:

- offline-first Collect workflows after phone activation;
- local encrypted client data and PIN protection;
- source creation, source history and test scheduling;
- tester calibration, manual/tester readings and sanitary inspections;
- domain classification against configurable reference profiles;
- limitation messages, including the inability of routine testing to detect
  germs when no germ test was performed;
- background and manual synchronization with retries and conflict handling;
- resumable private photo uploads;
- stakeholder area scoping and backend row-level security;
- Console dashboard, source map, filters and collector activity;
- alerts for unsafe results, E. coli and baseline changes;
- in-app notifications, email adapter, push adapter and SMS fallback adapters;
- configurable alert escalation and routing through the area chain;
- PDF reports and typed CSV exports;
- user, phone, area-chain, place, parameter, response-card and security
  administration;
- accessible UX conventions, safe error pages, password visibility controls,
  loading states, filters, themes and time-zone preferences;
- web Console deployment with HTTPS and same-origin API routing;
- the labelled map of all of Uganda on the web, Windows and Android in
  production (release 0.1.1, 2026-10-21): outlined, coloured roads, tracks
  and village names. Windows and Android reach the map through the API
  hostname.

The current client release is **0.1.1**: the web Console, Windows installers
for Console and Collect, and the Android Collect APK. Local development uses
`infra/caddy/Caddyfile.dev` (`http://localhost/console/`, `/collect/`);
production uses `Caddyfile.prod`, selected by `WC_CADDYFILE` in the VM's
`.env`.

The current production smoke checks pass:

```text
https://api.watercheck.fieldquire.cooptconnect.app/health
https://watercheck.fieldquire.cooptconnect.app/health
https://watercheck.fieldquire.cooptconnect.app/api/health
https://watercheck.fieldquire.cooptconnect.app/
```

The Console root and sign-in page load publicly, and the health endpoints
return `{"status":"ok"}`. The production infrastructure is running on an
Azure Ubuntu VM with Docker Compose, Caddy, PostgreSQL/PostGIS, SeaweedFS, the
worker and tile service. The first production IT-admin account still needs to
be created before administrators can use the browser-based management screens.
The local/test account commands are in
[CONTRIBUTING.md](CONTRIBUTING.md#database-seed-and-admin-cli); production
account creation should be performed on the VM using the protected deployment
procedure in [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

Production onboarding is intentionally separate from reference-data seeding:
the deployment seed does not create people, collector phones, sources or test
history. Run the first-admin, stakeholder and collector activation commands
from `~/WaterCheck/infra` on the VM, as documented in
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#15a-production-accounts-and-collector-activation).
The performance/demo fixture is dev/test-only and must not be forced into
production.

## Upcoming work

The next milestone is **P12: hardening and pilot release**. Remaining or
deferred work includes:

- real-phone airplane-mode and low-end-device checks;
- a non-developer field walkthrough;
- real Windows click-through verification;
- real-printer readability verification for the community notice;
- final long-term web asset caching verification;
- cleanup jobs for abandoned uploads, completed jobs and old notifications;
- production first-admin setup and operational account onboarding;
- replacement of Mailpit with a real production SMTP provider if external
  email delivery is required;
- secret rotation before real users or sensitive data are introduced;
- backups, restore drills, budget alerts and routine VM cost controls;
- production pilot hardening and release sign-off.

Staging is **not currently deployed** because the production VM has only 4 GiB
of RAM. Future staging must be isolated with its own host or larger VM,
domains, Compose project, network, secrets, database, object-storage volumes,
Caddy certificate data, builds and test data. The design is documented in
[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md).

## Environment status

The active environment workflow is:

```text
dev   local Windows workstation and local Docker Compose
test  GitHub Actions and targeted local checks
prod  Azure VM with protected persistent data
```

Production domains:

```text
https://watercheck.fieldquire.cooptconnect.app
https://api.watercheck.fieldquire.cooptconnect.app
```

## Documentation map

Use this README for the product overview and current status. Use the following
documents for section-specific detail:

- [CONTRIBUTING.md](CONTRIBUTING.md): workstation setup, commands, tests,
  repository workflow and development conventions;
- [DEV_DEPLOYMENT_GUIDE.md](DEV_DEPLOYMENT_GUIDE.md): complete local Windows
  and Linux Docker deployment, demo data, platform testing and production-API
  Android APK testing, Gradle memory failures and disk cleanup;
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md): Azure, Docker, DNS, HTTPS,
  production environment, first admin, updates and troubleshooting;
- [PROGRESS.md](PROGRESS.md): phase gates, completed work, evidence and
  deferred checks;
- [docs/PLAN.md](docs/PLAN.md): roadmap, planning assumptions and durable
  decisions still being tracked (status at a glance, refinement rounds in §3a);
- [docs/DEVLOG.md](docs/DEVLOG.md): every request from the project lead and its
  outcome, with decisions and points to watch (from 2026-10-20);
- [docs/SPEC.md](docs/SPEC.md): product requirements and acceptance criteria;
- [docs/adr/](docs/adr/): architecture decision records;
- [SECURITY.md](SECURITY.md): security baseline and reporting expectations;
- [docs/demos/P11.md](docs/demos/P11.md): IT admin and phone-activation
  acceptance walkthrough.
