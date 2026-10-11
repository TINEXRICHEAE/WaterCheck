# ADR-005: Result data model and classification details

- Status: Accepted (2026-10-10). Defaults chosen by the developer; the project lead may revise.
- Resolves errata G1, G2, G3 and G11, and confirms G12. Clarifies SPEC §6.0–6.2.

## Context

- **G1:** SPEC §5.3 makes `test_result.session_id` unique, but amendments (§5.4) add a second result for the same session.
- **G2:** There is nowhere to store the server recompute or the area-default-profile result.
- **G3:** Flags, the "derived" mark on TDS and the limitation message have no columns.

§6.2 also leaves several edge cases open: unbounded limits, implausible values without a limit, units, and the minimum history for the baseline check.

## Decision

### 1. Results and amendments (G1)

- **Each `test_result` owns a complete, immutable set of readings.** `reading` gains `result_id` (not null), alongside `session_id`.
- **The original submission** is the result with `amendment_of = null`. It is unique per session: `unique (session_id) where amendment_of is null`.
- **An amendment** is a new `test_result` with these properties:
  - `amendment_of` points to the result it corrects;
  - `amendment_reason` is required;
  - it carries a **full new set of readings**: the unchanged ones are copied and the corrected ones replaced.
- **The effective result** of a session is the newest result in its amendment chain. Dashboards mark it "amended".

**Why:** every result can be classified, displayed and audited on its own, and nothing is ever updated in place. The cost is a few duplicated reading rows per amendment, which is negligible.

### 2. Classifications (G2)

- `test_result.overall` and `reading.result` hold the **device's** classification, under the session's profile.
- A new table holds the other classifications:

  ```
  classification(result_id, standard_id, computed_by, overall, reading_results jsonb, flags text[], computed_at)
  unique (result_id, standard_id, computed_by)
  ```

- The server writes one row for the session's profile (`computed_by = 'server'`) and one for the area's default profile when it differs.
- Re-evaluating under another profile (F-RPT-7) is computed on the fly and never stored.

### 3. Flags, derived values, limitation (G3)

- `test_result.flags text[]` holds `uncalibrated` and `baseline_jump:<parameter>` from the device. The server adds clock flags (`clock_future`, `clock_stale`) to its `classification` row.
- `reading.is_derived boolean` marks, for example, TDS computed from EC. `reading.source_device text` is reserved for BLE import (P13).
- `test_result.limitation_code text` stores a message **code** (`no_germ_test` or `ecoli_negative_reminder`), never the text. The text lives in ARB files and on the response cards, which keeps user-facing text out of code (SPEC §A0.6).

### 4. Classification rules (refines §6.2)

The rules are applied to each reading in this order:

1. **Value missing or of the wrong type** for the parameter → `invalid`.
2. **Implausible value**, outside the catalogue's plausible range in the parameter's default unit → `invalid`.
   - *Deviation from §6.2, which checks "no limit" first.* Without this, an impossible temperature (which has no limit) would be stored silently as `not_assessed`. A plausibility warning is still shown on entry, and the value is not blocked.
3. **No assessable limit** → `not_assessed`. A limit is assessable when it has `min`, `max`, `must_be_absent` or `must_be_acceptable`; "recorded, no limit" rows, such as temperature, are not. **Unit mismatch** → `not_assessed`. **Text values** → `not_assessed`.
4. `must_be_absent` and detected → `detected`. A numeric count above 0 counts as detected.
5. `must_be_acceptable` and not acceptable → `unacceptable`.
6. `value < min` → `low`; `value > max` → `high`. **A value equal to the limit is `ok`.**
7. Otherwise → `ok`.

**Overall result:**

| Condition | Overall |
|-----------|---------|
| Any `detected`, `unacceptable`, `high` or `low` | `unsafe` |
| Otherwise, any `invalid`, or any required parameter **missing** | `inconclusive` |
| Otherwise | `safe` |

- A required parameter counts as **missing** when it has no reading, when its reading is `invalid`, or when its reading is `not_assessed` because of a unit mismatch.
- A required parameter that is `not_assessed` only because the profile has no limit for it (temperature) is **not** missing.
- The required parameters come from config; the default is the core four.

**Numbers:** all comparisons use exact decimals (Dart `decimal`, Python `Decimal`). Floating point is never used.

**Units:** units are compared after normalising through an alias table in `infra/seed/rules.json`, for example `uS/cm` = `µS/cm` and `C` = `°C`. **`ppm` is accepted as `mg/L`**, because common TDS pens display ppm, which equals mg/L for dilute water. There is no other unit conversion in the PoC.

**Baseline jump:**

- The baseline is the median of the last 3 values of that parameter taken from `safe` results.
- No flag is raised with fewer than 3 such values; the minimum is configurable.
- Thresholds come from config: TDS and EC 30% (relative), pH 1.0 (absolute).
- The flag is raised when the difference is **greater than** the threshold.

**Limitation:**

- A `safe` result gets `no_germ_test`, unless an E. coli reading was assessed `ok`; then it gets `ecoli_negative_reminder`.
- Results that are not `safe` get no limitation code.

### 5. Seed values (G11, G12)

Every limit in `infra/seed/reference_profiles/*.json` was checked against the printed US 201:2008 (ref7), and each file cites the table and page. The values marked "verify" in SPEC §6.1 match the print:

- Class I pH 5.5–8.5 (Table 1, p. 7);
- manganese Class I 1.0 and Class II 0.1 (Table 2, p. 8).

**The manganese pair looks transposed**, since the untreated class is stricter than the treated one. It is seeded **as printed** with a note. See plan option D-MN.

The rainy season is March to November, confirmed by the Abim District COBERS report 2026 (ref1).

## Consequences

- The P2 Drift schema and the P4 Alembic migration follow this model (`reading.result_id`, the `classification` table, `flags`, `is_derived`, `limitation_code`).
- Both the Dart and Python classifiers implement section 4 exactly; the shared vectors enforce it.
