# ADR-015: Reports, CSV export and community notices

- Status: Accepted (2026-10-11)
- Covers: SPEC P10, F-RPT-3, F-RPT-4, F-RPT-6, F-ALR-5 (printing), F-RPT-7 (reports name the limit set)
- Amends: drops the notice's "Ethur placeholder" (English only, ADR-007)

## Context

Stakeholders need evidence:
- a report for an area and period;
- readings for analysis in a spreadsheet;
- a notice the community can read at the source.

Console runs on the web, Windows and Android. On Windows and Android it must work offline. The proposal names impact indicators that the report must carry.

## Decision

### 1. Made on the device, from the local data

- **`ReportQueries`** (packages/data) builds the report and the CSV from the local database, offline on Windows and Android. It uses the dashboard's rules:
  - results are judged **as collected** (the limit set used at collection);
  - a correction replaces what it corrects;
  - the server's classification wins.

  Reports therefore never re-judge results. The limit sets used are named, and custom ones list what they changed.
- **The PDFs** are made in the Console with `pdf` and `printing`. "Save" uses a browser download on the web, and the system "save as" dialog on Windows and Android. "Print" opens the system print dialog.

### 2. Impact indicators (F-RPT-6), defined

| Indicator | Definition |
|-----------|------------|
| Sources tested | Active sources with at least one test in the period, of all active sources in the area |
| Tests in the period | Tests in the period (corrections replace) |
| Abnormal tests with a documented action | Unsafe tests in the period whose alert records `action_taken`, `action_in_progress` or `closed` |
| Sources tested on schedule (reporting timeliness) | Sources tested at least once and not overdue now |
| Collectors active | Distinct collectors who submitted in the period |
| Median time to acknowledge | As on the dashboard |

### 3. CSV export (F-RPT-4)

- **Format:** one row per reading of each test in the period. UTF-8 with a byte-order mark, so spreadsheets detect the encoding. Dates are ISO 8601 in UTC. RFC 4180 quoting.
- **Columns:** source, village, collector, result, overall, `standard_code` + `standard_version` + `custom_limits` on every row, parameter, value, text value, detected, unit, reading result, derived, flagged.

### 4. Community notice (F-ALR-5)

- **Layout:** A4 or A5, large type:
  - a coloured banner with a symbol **and** words ("NOT SAFE to drink without boiling or treating", "NOT CONFIRMED SAFE…", "Safe on the last test");
  - "What to do" steps with icons;
  - the values against their safe range;
  - the limitation ("This test cannot detect germs…" unless E. coli was tested negative);
  - who to ask.
- **Wording:** plain language, written for the community. The response cards are written for collectors ("check the tester calibration"), so they are not reused.
- **English only (ADR-007).** All wording is in the Console's English text file.

### 5. Fonts and icons

- **Text:** Roboto Regular and Bold (Apache 2.0, from the Flutter SDK) are bundled and embedded, so PDFs look the same everywhere and work offline.
- **Icons:** drawn as vector paths (Material Icons, Apache 2.0). The PDF library reads Flutter's icon font without a Unicode map, so the font cannot be used.

## Consequences

- **Tested against SQL:**
  - the report's numbers equal independent queries over the 50-source fixture;
  - the CSV has exactly one row per reading in the filter;
  - pandas reads it back with dates, numbers and versions typed correctly (2,000 rows).
- **Deferred to P12:** printing a notice on a real printer and judging it at 1 m, like other checks that need people or devices.
- **Web:** a report covers what the browser has synced in this visit (all of the user's areas after the first sync).
