# ADR-030: FieldQuire: a research module beside water testing, on the same server

- Status: Accepted (2026-10-26); to be built in phases R1–R5 (docs/PLAN.md §3b)
- Covers: the lead's request of 2026-10-26 (DEVLOG entry 47)
- First use: Objective 5 of the CHS4102 proposal "Household water treatment to prevent diarrhoea, Entebbe village, Abim" (week-4 post-test). The baseline is the Year 3 community diagnosis (COBERS 2026).

## Context

The lead runs a WASH community project beside WaterCheck. Its impact assessment (Objective 5) needs three field tools:

- Appendix 1: a household demonstration and supply log;
- Appendix 2: a household questionnaire, with consent and sections A–F;
- Appendix 3: an observation checklist (H1–H10 per household, P1–P5 once per shared borehole).

These are used in 130 randomly sampled households of 193.

The lead wants the research part to be reusable by any researcher, in the way of ODK or KoBoToolbox:

- custom forms with skip logic and validation;
- GPS, photos, video, audio and barcodes;
- offline collection and later upload;
- analysis and exports.

Uses include health surveys and surveillance, agriculture, census, WASH, humanitarian work and conservation.

Every record must carry where and when it was made, so supervisors can confirm that investigators visited the field.

Constraints:

- the same low-budget VPS and containers;
- separate endpoints from water testing, but shared and cloned features;
- no participant names on maps.

The platform is renamed **FieldQuire**.

### The lead's decisions

- **Addresses:**
  - `watercheck.fieldquire.cooptconnect.app` stays for water testing;
  - `research.fieldquire.cooptconnect.app` serves research, from the same server.
- **Rename:** names, titles and logo become FieldQuire ("FieldQuire Collect", "FieldQuire Console"; WaterCheck becomes the water module). Android and Windows IDs are kept, so installed apps update in place.
- **Media:**
  - photos ≤ 300 KB;
  - audio ≤ 5 min, compressed;
  - video ≤ 60 s at 480p;
  - form authors may set lower limits;
  - uploads wait for Wi-Fi by default.
- **Forms:**
  - a builder in the Console;
  - XLSForm (.xlsx) import, and export back to it.
- **Authors:** anyone may sign up for a Console account and create research projects and forms. IT admins oversee everything.
- **Research numbers:** per form, either generated on the device (unique, offline) or typed from the team's list (checked unique in the project).
- **Map:**
  - a collector sees their own research points;
  - a project's owners and supervisors see all of the project's points;
  - nobody else sees them, and the water side shows none.
- **Outputs:** summaries and charts (with indicator tables against targets), cross-tabs, exports (CSV, Excel, a media zip, GeoJSON), and a visit audit.

## Decision

### 1. One platform, two modules

**Server:**

- The same API container, database, storage, worker and Caddy.
- Research lives in its own Postgres schema (`research`) and under `/v1/research/…`. Water endpoints and tables are untouched.
- It shares:
  - accounts, sign-in and roles;
  - tester profiles and devices (ADR-024/025);
  - the sync engine (new streams and entities);
  - attachments (owner `research_record`, media types widened);
  - messages (subject `research_record`);
  - the audit log and maps (tiles, routes, place names).

**Addresses:**

- `research.fieldquire.cooptconnect.app` is one more name on the same Caddy and API; it needs one more DNS record.
- The web apps open in Research mode on that host and in Water mode on `watercheck.`.

**Apps:**

- The same Collect and Console apps.
- Sign-in and registration say plainly: **Water testing** or **Research**.
- Each mode has its own menu. One account can use both.
- A shared Dart package (`packages/forms`) holds:
  - the form definition;
  - the expression engine for relevance, constraints and calculations;
  - the form renderer.
  Both apps use it.

### 2. Projects, forms and access (server)

- **`research.project`:** owner, title, description, number prefix.
  - **Members:** owner, supervisor or analyst.
  - **Collectors** join a project by assignment or with an access code.
- **`research.form`:** belongs to a project.
  - **Status:** draft, published or closed.
  - **Visibility to other authors:**
    - *public*: anyone may view and clone it;
    - *private*;
    - *shared*: clonable by named people.
  - **Who may collect:**
    - *assigned*: named collectors only;
    - *access code*: anyone with the code;
    - *open*: any signed-in collector.
  - **Hidden:** a published form can be hidden from browsing.
- **`research.form_version`:** an immutable JSON definition, numbered.
  - Records always point to the version they were filled with.
  - Editing a published form makes a new version.
- **Cloning** copies the latest version into the cloner's own project as a draft, noting the source.

### 3. Records

**`research.record`:**

- **Identity:** id; form and version; research number; collector key and device.
- **The point of interview:**
  - taken when the record is created, and again when it is finished;
  - accuracy, altitude and time, as for pictures in ADR-029.
- **Times:** started and finished.
- **Answers** (JSON, keyed by field name), and a status.
- **Media:** stored as attachments, with the field name.
- **Insert-only once sent.** Corrections are new versions with a reason, as for test results in ADR-018.

**Research numbers:**

- *Generated*: project prefix, form code, then device short code and sequence, for example `ENT-HQ-7Q2K-0007`. This is unique without a connection.
- *Typed*: checked against the device's records, then the server's. A clash is flagged for the supervisor, not lost.

**Privacy:** maps, lists and exports show research numbers. Fields marked *identifying* (a name, a phone number) are left out of maps and of default exports.

### 4. Forms

Our own JSON definition, close to XLSForm, so that import and export map one to one.

**Field types:**

| Group | Types |
|---|---|
| Text and notes | note, text, integer, decimal |
| Choices | yes/no, choose one, choose many, with "Other: specify" |
| Scales | Likert/scale, range |
| Dates | date, time, date-time |
| Place and media | GPS point, photo, audio, video, barcode/QR |
| Computed | calculated |
| Structure | consent (ends the form on "No"), group/section, repeat (rows, such as Appendix 1's log) |
| Identity | research number |

**Each field may have:**

- a label and a hint;
- required;
- relevance (skip logic);
- a constraint and its message;
- a default;
- choice lists, randomised or not.

The expression language is a safe XLSForm subset, for example `${B2} = 'boiling' and ${A2} > 0`. Its one evaluator is shared by the apps and the server, with the same test vectors (as in ADR-013).

**XLSForm:** an import on the server (`survey`, `choices` and `settings` sheets) reports anything it cannot map. Export writes the same sheets.

### 5. Collecting (Collect › Research)

- **Lists:** "My projects" and forms (assigned, by code, or open), drafts, and sent records.
- **Offline:** filling works without a connection, drafts are saved as you go, and records sync when online. Media upload on Wi-Fi by default.
- **The record's map:** the collector sees their own points, by research number, to confirm where they were.

### 6. Console › Research

- Projects and members.
- The form builder: every field type, skip logic, validation, preview and test-fill.
- Publishing and access: assigned collectors, codes, open or hidden.
- Visibility and cloning.
- Records: a table, the record, its media, and messages.
- The map of the project's points.
- Analysis:
  - summaries and charts;
  - indicator tables against targets;
  - cross-tabs;
  - filters by date, collector and area.
- Exports: CSV and Excel (codes and labels), a media zip, GeoJSON.
- The visit audit, per collector:
  - where and when each record was made, and how long it took;
  - records made too fast;
  - records far from the rest, or many at one point.
  Supervisors confirm these with their collectors.

### 7. First content

A sample admin, "FieldQuire Samples", owns a public project "Household water treatment, Entebbe (Abim), Objective 5". It holds:

- **Appendix 1**, the log, as one record per household visit, each with its own point and time (a repeat would put many visits at one point);
- **Appendix 2**, the questionnaire: consent first; Year 3 item numbers in the hints; tick-all and "Other" fields; Likert items;
- **Appendix 3**, the checklist: household items, and a borehole section filled once per borehole.

It also holds the indicator table (Table 6, with targets) as the project's analysis set-up. The lead clones it into their own account.

### 8. Resource care (low-budget VPS)

- No new containers.
- Research queries use the same API workers and connection pool.
- Media are capped, compressed on the device, and stored in the existing object storage.
- Exports are streamed, and large ones are made by the worker.
- Storage per project is shown to admins.

## Consequences

- Self sign-up needs a way to confirm emails. No email service is set up yet, so new accounts are active at once but limited to their own research. An IT admin can suspend them.
- One more DNS record (`research.fieldquire.cooptconnect.app`) and certificate. Caddy obtains the certificate itself.
- The Privacy Policy and Terms need a research section:
  - researchers are controllers of their projects' data;
  - participants' identifying fields;
  - consent recorded in the form.
  The legal version goes up again.
- Mobile releases (Android, Windows) are needed for media capture beyond the web.
- This is a large addition, about 6–8 weeks of work for one developer, delivered in phases R1–R5 so the Objective 5 forms can be used in the field early. The week-4 survey date is the deadline that matters.

## Amendment, 2026-10-27 (the lead's request, DEVLOG entry 49)

- **Addresses (the lead's DNS):**
  - `fieldquire.cooptconnect.app` is the platform's main name and serves both web apps (Console at `/`, Collect at `/collect/`); the mode is chosen at sign-in;
  - `watercheck.fieldquire.cooptconnect.app` (water testing), `research.fieldquire.cooptconnect.app` (research) and `api.watercheck.fieldquire.cooptconnect.app` (the API for installed apps) all reach the same server;
  - the old `*.cooptconnect.app` names stay in Caddy so installed apps keep working until they update.
- **Names:** the platform is FieldQuire everywhere it is named (titles, texts, legal documents, installers, logo). Installed apps keep the short names **Collect** and **Console** on home screens. App IDs are unchanged.
- **The Console's research part is laid out like water testing:** its own menu (Dashboard, Records, Forms, Collectors, Analysis, Admin for IT admins), the same frame and actions, a project picker in place of the area filter, and messages, profile and settings as on the water side. Forms are built, published and shared here; Collect is only for collecting.
- **Server additions (migration 0019):** a form's draft definition (publishing makes it the next version), its access code, the project's analysis set-up (indicators with targets), and messages on research records. Collectors join a form with its code from Collect (`POST /v1/research/join`).
- **Analysis is worked out in the Console** from a form's records (`GET /v1/research/forms/{id}/data`) with the same `packages/forms` engine the phones use: summaries, cross-tabs, indicators, the visit audit, and CSV, Excel, GeoJSON and picture exports. XLSForm import and export are in `packages/forms` too. The server stays small; one form's records are expected in the thousands, not millions.

