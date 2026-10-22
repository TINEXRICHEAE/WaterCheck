# ADR-018: Archive with cascade, edit trails, and the 2026-10-22 UX refinements

- Status: Accepted (2026-10-22)
- Covers: the lead's refinement request of 2026-10-22 (IT admin delete, edit by the creator with a trail, refresh, clickable dashboard, searchable reference data and areas, optional Console PIN)
- Amends: ADR-010 (PIN lock is optional for stakeholders), ADR-011 (archive marks travel in the change feed), SPEC immutability of test records (an archived test is removed from devices)

## Context

The lead asked that:

- IT admins can delete phones (devices), collectors, sources and tests, with what hangs below each removed in that order;
- the person who created a record can edit it, with each change kept (old value → new value, who, when);
- every page that loads data has a refresh button, in Console and Collect, on every platform;
- dashboard figures open lists that lead to the item;
- reference data is searchable, and area entry picks from the official list (to sub-county) with the levels above filled in, "Other" for new places, and only villages typed;
- the Console PIN is optional for stakeholders on shared office devices, and required for IT admins.

Test records are insert-only on the server and on devices (`wc_immutable`, local triggers), and readings are evidence. A hard delete would break the audit trail and the sync cursor.

## Decision

### 1. Delete means archive, and it can be restored (the lead, 2026-10-22)

- `POST /v1/admin/archive` with `{entity, record_id, reason}` (reason at least 5 characters). The entities are `installation`, `collector`, `water_source` and `test_session`. IT admins only.
- **Cascade, in order:**
  - phone → its collectors;
  - collector → their tests, and sources only they used;
  - source → its tests and alerts;
  - test → its alerts.
- **A source that another collector also used is kept** (the lead's choice). Archiving a phone also revokes it.
- One action is one **batch** (`archive_mark` rows sharing `batch_id`, one of them the `root`). Restore (`POST /v1/admin/archive/{batch}/restore`) brings the whole batch back. The audit log records `archive.created` and `archive.restored`.
- Nothing is deleted on the server. `wc_archived(entity, id)` hides archived rows from:
  - sync pull;
  - the dashboard and its summary;
  - escalation;
  - classification history;
  - listings.

  Pushes that add to an archived parent are refused (`archived`).
- **Devices:** archive marks travel in the area change feed. A device deletes the local rows when a mark arrives; the local delete triggers allow exactly this. It also marks waiting outbox rows as refused with "archived". When a mark is restored, the device pulls again from the start.
- **Console:**
  - "More actions" on phones and collectors;
  - an archive icon on source details and on each test;
  - Undo in the snackbar;
  - Admin › Archived, to restore later.

### 2. Edits keep a trail; tests are corrected as new versions

- `change_trail` (migration 0009) is immutable: entity, record, field, old value, new value, who (`actor_name`), when, and why. The server writes it for:
  - source edits;
  - collector profile changes, with `collector_profile` holding each collector's latest details;
  - phone names (`PATCH /v1/admin/installations/{id}` `{label}`).
- **Tests are not overwritten.** A correction is a new result that points to the one before (`amendment_of`), as before. The trail is worked out from the chain (`TrailQueries.forTest`): each reading whose value changed, with the corrector's name and reason. `test_result` now carries `installation_id`, `collector_key` and `collector_snapshot`.
- **Only the person who made a test can correct it.** The server refuses anyone else (`not_creator`). Collect offers "Correct a mistake" only to the collector who did the test, and tells others who did.
- **Where the trail shows:**
  - Console: Edit history on source details, on collectors and phones, and when a test is tapped;
  - Collect: source details and the result page.

### 3. Refresh everywhere

- **Console:** a refresh button in the top bar, on the web, Windows and Android. It syncs, then bumps the data version. Every server list follows the data version and so fetches again: admin lists, inbox, web dashboard summary, places, the alert chain.
- **Collect:** a refresh button on Home, source details, picking a source, the response card and reference data. It syncs, then reads the reference data again. Pull-to-sync on Home stays.

### 4. Dashboard figures open lists

Each card opens a list whose rows open the item:

| Card | List |
|------|------|
| Sources tested | Every source, latest test first |
| Tests unsafe | Unsafe tests in the period |
| Open alerts | Alerts not closed yet |
| Time to acknowledge | Alerts still waiting, oldest first |

The overdue card's title opens every overdue source, and a collector row opens their tests in the period. The lists come from the device's data. On the web, before the first sync, they say so.

### 5. Searchable reference data and area entry

- **Reference data** (both apps): one search box filters rules, limit sets (and the limits inside them), parameters by name, code or unit, tester kits and areas. Matching groups open by themselves. The area list shows at most 100 rows and asks you to type to narrow it.
- **Area entry** (the Collect collector form):
  - **Sub-county** is searched in the official list, by its own name or its district's. Picking one fills the district (read-only) and shows the region.
  - **Parish** and **village** suggest known places. Picking a known village fills everything above it.
  - **"Other"** takes a sub-county or parish that is not in the list. A new sub-county's district is then picked from the list.
  - Only the village is always typed.
- The Console already picks areas through a searchable picker (people, phones, places, alert chain).

### 6. Console PIN: optional for stakeholders, required for IT admins

- **Windows and Android only** (the web keeps no session).
- After sign-in, a stakeholder may choose "Skip: no PIN on this device". In Profile and settings, "Ask for a PIN on this device" turns it off (after a warning) or back on (choose a PIN).
- **Without a PIN:**
  - the saved session opens straight in;
  - the access token is refreshed on the first call;
  - the idle timeout does not lock.
- **IT admins** are never offered the skip, and the switch is shown as on and fixed ("Required for IT admins").
- A saved no-PIN session whose profile says IT admin is not opened without a PIN.
- Signing out clears the choice.

## Consequences

- **Deploy:** migration 0009 must run before the new API. Older phones keep working: they ignore marks and trails they do not know. Their pushes onto archived records are refused with a reason.
- **Archived data stays on the server** and counts toward storage. A permanent purge, if ever needed, is a separate admin operation with its own decision.
- **A stakeholder device without a PIN** shows that person's areas to anyone using it. The warning says so, and sign-out is the remedy.
- **Not decided here**, to be discussed with the lead:
  - email, phone and SMS settings;
  - password reset options;
  - over-the-air fixes for installed apps.
