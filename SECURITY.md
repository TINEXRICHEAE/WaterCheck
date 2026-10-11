# Security policy

## Reporting

Report suspected vulnerabilities privately to the project lead (not in public issues). Include steps to reproduce. You will get an acknowledgement within 5 working days.

## Baseline

- No secrets in the repository. Local secrets live in `infra/.env` (git-ignored); CI uses the CI secret store. `gitleaks` runs in CI and should run before each commit.
- No personal data in seeds, logs or test fixtures. Logs record request path, status and timing only.
- Dependencies are locked (`pubspec.lock`, `uv.lock`) and audited in CI (`osv-scanner`, `pip-audit`).
- Standards: OWASP MASVS L1 (apps), ASVS L1–L2 and API Top 10 (backend). See SPEC §9.
