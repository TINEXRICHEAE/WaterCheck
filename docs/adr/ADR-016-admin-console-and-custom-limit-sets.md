# ADR-016: IT admin console and who changes limit sets (O2)

- Status: Accepted (2026-10-12)
- Covers: SPEC P11, F-ADM-1 to F-ADM-9, F-AUTH-6; resolves open question O2
- Amends: SPEC O2 default ("all collectors"); D11 (area default reaches phones)

## Context

The IT admin must run the system from the Console without a developer: people, phones, configuration, security and health. SPEC left O2 open: who may create custom reference profiles (limit sets) in production.

## Decision

### 1. O2: only a stakeholder calibrates (the lead, 2026-10-12)

- A custom limit set is created only by a signed-in **user whose role is `stakeholder`**. One person may hold several duties; the stakeholder role is what counts. A phone alone, or an IT admin, is refused (`stakeholder_required`).
- **On a phone:** the collector opens the limits editor; saving asks the stakeholder to sign in on the spot. The set is pushed with the stakeholder's token, then the session ends. Offline, nothing is saved.
- **In the Console:** Account menu › Limit sets, for stakeholders.
- Every set records **who** (`created_by`), **why** (a comment of at least 5 characters) and **where** (audit `reference_profile.created`, platform collect or console).
- **History is kept:** a reading stays judged against the limit set it was collected with. Only tests from then on use the new set. Nothing is re-judged.

### 2. Area default limit set (D11)

- `admin_unit.default_standard_id` (migration 0007) carries the default with the area itself, so phones get it in the reference stream; `area_default_profile` keeps who set it and when.
- A new test starts with the nearest default up the area tree, else the rules default. Past tests keep theirs (gate test).

### 3. Admin console

| Area | What the IT admin does |
|------|------------------------|
| People | create (temporary password shown once), edit role, responsibilities and areas, disable, reset password; cannot lock themselves out |
| Collect phones | activation codes (QR + short code), list, revoke |
| Who covers an area | the alert chain per area, with gaps |
| System | health (database, worker, jobs, failures, phones, tests received, conflicts, photos, backup) and the audit log with filters and CSV export (itself audited) |
| Sign-in security | wrong passwords before lockout (3–20), lockout minutes (1–1440), shortest password (8–64), Console idle timeout (5–480). Stored as the `security` config document; read at each sign-in, so no restart. The idle timeout reaches the Console through `/v1/me`. |
| Alert routing | responsibilities (data) and which alert types reach them |
| Places | add sub-counties, parishes and villages below the official list; rename; default limit set |
| New parameters | approve, rename, merge (`merged_into`; readings keep their original code) or reject |
| Response cards | edit; each save is a new version; the seed loader no longer overwrites a higher version |

All of it is online only and audited.

## Consequences

- Calibration in the field needs a stakeholder present or reachable with a connection.
- Backups show "not set up" until deployment (P12).
- SMS/email provider choice stays in server configuration (deployment), not in the Console.
