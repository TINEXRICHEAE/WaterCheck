# ADR-026: Privacy Policy and Terms of Use, accepted by version

- Status: Accepted (2026-10-24); texts are drafts awaiting the lead's details and PDPO review
- Covers: the lead's request of 2026-10-24 (DEVLOG entry 39)
- Amends: SPEC §9.3 (the Collect welcome note, version 1, was the only notice)

## Context

The only notice was a short paragraph on Collect's welcome screen (version 1). It was out of date:

- the phone is now optional;
- pictures, messages, map searches, self-registered devices and browser storage are new;
- profiles can be deleted.

There were no terms, and the Console showed nothing. SPEC §9.3 requires compliance with the Data Protection and Privacy Act, 2019. That includes stating where data is stored: the server is in Azure South Africa North, outside Uganda.

The lead's choices:

- **Controller and contact:** placeholders until the lead gives them.
- **Retention:** results are kept for the life of the project. Contacts are erased when an account closes. Unused accounts are flagged after 2 years. Logs are kept 1 year.
- **Acceptance:** everyone accepts, by version, in both apps.

## Decision

1. **The documents:** one copy each, `packages/ui_kit/assets/legal/privacy-policy.md` (version 2) and `terms.md` (version 1), bundled with both apps.
   - **Privacy Policy:** what is collected for testers and Console users, and what is not; purposes and legal basis; who sees what; where it is kept (device, Azure South Africa North, map and routing on our own server); retention; security; rights under the Act, and how to use them in the app; young people; changes; complaints to PDPO.
   - **Terms of Use:** who may use WaterCheck; keeping accounts and codes safe; proper use (true readings, no pictures of people, respectful messages); results are screening, not a guarantee; what users submit; availability; responsibility; leaving; changes; Ugandan law.
   - Parts only the lead can fill are in [square brackets]. Both say they are drafts for review.
2. **One version to accept:** `legalVersion` (2) in `ui_kit/lib/src/legal.dart`. Raising it asks everyone again.
3. **Collect:**
   - The welcome screen gives a plain-language summary, links to both documents and "I agree to the Terms of Use and the Privacy Policy". The consent setting records `legalVersion`, so testers who agreed to version 1 are asked again, with a note that the documents changed.
   - Both are also under My profile and Settings.
4. **Console:**
   - `app_user.legal_version` and `legal_accepted_at` (migration 0016); `POST /v1/me/legal` records it, and `/v1/me` reports it.
   - After sign-in, anyone below the current version sees "Before you continue" (a summary, both documents, Accept or Sign out) before anything else.
   - The sign-in page links both documents, and My profile lists them.
5. **The reader:** a small viewer in the UI kit shows the documents' headings, paragraphs, lists, notes and bold text, with no new dependency.

## Consequences

- **Before real data:** the lead fills in the controller, contact, effective date and transfer safeguards, confirms retention with the ethics committee and PDPO, and raises `legalVersion` if the substance changes.
- **Acceptance is recorded:**
  - Console: per account, also in the audit log.
  - Collect: per device (local setting).
  - The server does not yet record a tester's acceptance; if needed, it can be sent with their profile.
- **The 2-year flag:** flagging unused accounts after 2 years is promised in the policy but not built yet. It belongs with the slice D housekeeping jobs.
