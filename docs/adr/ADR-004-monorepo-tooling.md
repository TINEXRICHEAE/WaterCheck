# ADR-004: Monorepo tooling

- Status: Accepted (2026-10-10)

## Context

- Two apps and three shared packages must resolve to one consistent set of dependency versions.
- They must be checked with one command, locally and in CI.
- The Flutter version must be pinned (SPEC P0).

## Decision

- **Dart pub workspaces:** the root `pubspec.yaml` lists every app and package, and there is one `pubspec.lock` at the root. Internal packages are referenced by path.
- **Melos 8** (a dev dependency at the root) provides the scripts `format:check`, `analyze`, `test:dart` and `test:flutter`. Run them with `dart run melos run <script>`.
- **FVM:** `.fvmrc` pins Flutter 3.47.6. Developers may use FVM or a global Flutter of the same version; CI reads the version from `.fvmrc`.
- **uv** manages the backend: `uv.lock`, and `uv sync --frozen` in Docker and CI.

## Consequences

- `flutter pub get` at the root resolves everything. Package-level lockfiles are not used.
- Upgrading Flutter means editing `.fvmrc` and the ADR-002 table.
