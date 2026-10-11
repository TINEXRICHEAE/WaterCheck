# ADR-007: English only

- Status: Accepted (2026-10-10, project lead decision)
- Amends: SPEC §A0.6, P2, P10, P11, P13, §5.1, §10.1, §11.1
- Resolves: errata G10 (the `ett` locale code, which is Etruscan)

## Context

The spec plans English plus an Ethur placeholder file, an Ethur community notice, per-language response cards and a later full Ethur translation. The project lead has decided the app uses **English only**.

## Decision

- **One language: English.** There is no Ethur file, no language switcher and no per-language content.
- **User-facing text still lives in `app_en.arb`** through `intl`, not in Dart code. This keeps SPEC §A0.6 ("no hard-coded user-facing messages") and keeps a future translation a data task rather than a rewrite.
- Spec changes:
  - **P2:** only `app_en.arb`. The gate item "switching the language to the Ethur placeholder…" is dropped.
  - **P10:** the community notice is English only.
  - **P11:** the response-card editor edits one English text per card.
  - **P13:** "full Ethur translation and audio response cards" is removed.
  - **§5.1:** `ResponseCard` has no `language` field.
  - **§10.1:** i18n is English only.
  - **§11.1:** the Collect Settings screen has no language option.

## Consequences

- Less work in P2, P10 and P11; one fewer gate item.
- Field materials (the community notice, response cards) must be written in plain English for low literacy. Icons and the text + icon + colour status rule (SPEC §11) carry more weight.
- Adding a language later means adding an ARB file and a `language` column on response cards; no screen code changes.
