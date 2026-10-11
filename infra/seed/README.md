# Seed data

Versioned JSON, loaded through parsers (never compiled in as constants).

| File | Content | Source |
|------|---------|--------|
| `catalogue.json` | Parameter categories and definitions (SPEC §6.0) | spec; plausible ranges are engineering defaults |
| `tester_profiles.json` | Generic 4-in-1 pen (Temp, pH, EC, TDS) | spec §6.0 |
| `reference_profiles/US201-2008-ClassI.json` | US 201:2008 Class I (treated) | printed standard, each limit cites table/page |
| `reference_profiles/US201-2008-ClassII.json` | US 201:2008 Class II (untreated) — **pilot default** | printed standard, each limit cites table/page |
| `rules.json` | Required parameters, baseline-jump rules, TDS factor, limitation codes, testing schedule, unit aliases | spec §6.2, §7; ADR-005 |

Rules:

- No real personal data, ever.
- Each limit cites its source document, table and page.
- Profile IDs are UUIDv5 of the profile code, so they are stable across machines.

Responsibilities, response cards, admin units and the demo dataset arrive in P2.
