# Security policy

## Reporting

Report suspected vulnerabilities privately to the project lead (not in public issues). Include steps to reproduce. You will get an acknowledgement within 5 working days.

## Baseline

- No secrets in the repository. Local secrets live in `infra/.env` (git-ignored); CI uses the CI secret store. `gitleaks` runs in CI and should run before each commit.
- No personal data in seeds, logs or test fixtures. Logs record request path, status and timing only.
- Dependencies are locked (`pubspec.lock`, `uv.lock`) and audited in CI (`osv-scanner`, `pip-audit`).
- Standards: OWASP MASVS L1 (apps), ASVS L1–L2 and API Top 10 (backend). See SPEC §9.

## Deployment security baseline

- Development and test use non-production data and credentials.
- Production secrets remain only in the VM's `infra/.env`, with mode `600`.
- The production VM exposes only SSH, HTTP and HTTPS; database, storage and
  Mailpit ports are bound to loopback or the Docker network.
- Caddy terminates HTTPS and stores its ACME account and certificates in a
  persistent Docker volume.
- Generated map tiles and web archives are transferred separately and are not
  committed to Git.
- A future staging environment must have separate credentials, databases,
  object storage, certificate data and DNS names. It must never point at
  production services.
