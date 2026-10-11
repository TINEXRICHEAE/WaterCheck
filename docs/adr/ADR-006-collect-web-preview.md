# ADR-006: Dev-only web preview of Collect

- Status: Accepted (2026-10-10, project lead request)

## Context

The project lead wants to follow frontend progress in a browser at `http://localhost/…` without starting the Android emulator, which is heavy on the development laptop. Console already has a web target. Collect targets only Android and Windows (SPEC D9).

## Decision

- Add a **web platform to `apps/collect` for development preview only**. Caddy serves it at `http://localhost/collect/`, next to the Console at `http://localhost/console/`. `http://localhost/` redirects to the Console.
- `tools/preview.ps1` rebuilds both previews (`flutter build web --base-href /<app>/`). Caddy serves the build folders directly, so refreshing the browser shows the new build.
- For live editing, `flutter run -d chrome` in an app folder gives hot reload.
- **The Collect web build is never released.** The release pipeline (P12) builds Collect for Android and Windows only.

## Consequences

- From P2, Collect's data layer must open on web with a **non-persistent (in-memory) database** in preview, the same approach as web Console (errata G8). SQLCipher is used only on Android and Windows.
- Plugins without web support (`workmanager`, `flutter_secure_storage` behaviour, GPS accuracy) need a stub or fallback on web, behind the same interfaces. Field behaviour is still tested on Android and Windows.
- The preview shows layout and flows, not real device behaviour. The gate checks for low-end phones, offline use and GPS still run on Android.
