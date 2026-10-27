# ADR-031: Sides of FieldQuire: separate accounts, open sign-up, consent per side

- Status: Accepted (2026-10-27)
- Covers: the lead's request of 2026-10-27 (DEVLOG entry 50)
- Changes: ADR-024 (areas), ADR-026 (consent), ADR-030 (water and research in one app)

## Context

FieldQuire now serves more than water testing: research (ADR-030), with other kinds of field data collection, monitoring and reporting to come.

The lead found these problems:

- one consent page for everything, shown on every new browser;
- research and water pages mixed;
- a research collector who could not get back in, because recovery codes were set up only on the water side;
- switching sides open to everyone.

## Decisions (the lead's)

1. **Sides.** Water testing and research are separate sides, each with its own people, pages, records, Terms of Use and Privacy Policy. Only IT admins manage both and switch freely between them.
2. **Separate accounts and profiles.**
   - A Console account belongs to one side. A Collect profile does too.
   - A person on both sides has two accounts (or profiles), linked to each other.
   - They join the second side from inside the first one, using the first side's credentials:
     - in the Console: their password, which the new account keeps;
     - in Collect: their details, copied into the new profile.
   - Before joining, they tick that side's documents.
   - The switch button appears only after they have joined.
3. **Open sign-up on both sides, working at once.** This applies to Console accounts and Collect profiles alike.
   - Activation codes and email confirmation come later.
   - Recovery codes work now, for both sides.
4. **Areas are an official allocation, not a limit.** Anyone collects anywhere.
   - Every water Console user sees all water sources and results.
   - Areas decide whose alerts and notices a user receives.
   - Research users see only the projects they take part in, and the forms others made public or shared.
5. **Consent per side, ticked once.** People tick the usual two boxes when they sign up: "I accept the … Terms of Use" and "I have read the … Privacy Policy".
   - Collect has no device-wide consent page any more.
   - People from before sides (and anyone after a side's documents change) are asked once: at their next Console sign-in, or when their Collect profile is next chosen.
6. **General descriptions.**
   - The apps describe FieldQuire in general: field data collection, monitoring, analysis and reporting.
   - Water-only wording stays on the water side.
   - A short "About FieldQuire" text links to each side's documents.

## Design

### Server (migration 0020)

**Console accounts:**

- `app_user.side` is `water`, `research` or `all` (IT admins).
- `person_id` links the accounts of the same person.
- `legal` records each side's accepted version as JSON; `created_via` records how the account was made.
- The email is unique per side.
- Sign-in names a side: an IT admin's account works on every side.
- New endpoints:
  - `POST /v1/auth/register`: open sign-up, with the documents' version ticked;
  - `POST /v1/auth/join`: the password again and the other side's documents; it makes or reuses the linked account and returns its tokens;
  - `POST /v1/auth/switch`: changes to the linked account without a password.
- `/v1/me` reports the side, the documents accepted, the sides still due, and the linked sides.
- `POST /v1/me/legal` takes a side.

**Collector profiles:**

- `collector_profile.side` is set from the profile the phone sends. It never changes, except in one case: from the research pages, a code given to a profile made before sides that never tested water claims it for research.
- The side comes back with a recovery code.

**What each account sees:**

- `wc_in_scope` lets water accounts see every area. Phones keep their own scope.
- Research endpoints accept research accounts and IT admins only.
- Recovery codes for research collectors come from an IT admin or the team of a project they collect for.

**Documents:**

- `LEGAL_VERSIONS` holds the server's copy of each side's current version: water 4, research 1.

### Apps

**Shared packages:**

- The domain package has `AppSide` and `legalVersions`.
- Tester profiles on the device carry their side, the version of the documents accepted, and the linked profile (device schema 13).
- The UI kit has:
  - `LegalDocument` for the general text and each side's two documents;
  - `LegalConsentChecks` for the ticks;
  - `LegalAcceptView` for the one-time acceptance.

**Console:**

- The sign-in page has a "Create an account" link that goes to the sign-up page.
- The side chosen at the top is the side the person signs in to.
- An account sees only its own side's pages. IT admins see both.
- The account menu and profile page offer one of two things:
  - "Switch to …", for someone already on the other side;
  - "Join …", for someone not yet on it.
- Research › Collectors has a "Find a collector" search and a page for each collector, with a recovery code.
- Research pages below the menu pages have back buttons. An unknown address goes back to the home of the side in use.

**Collect:**

- "Who is collecting?" lists the people of the side chosen there. New people sign up with the side's ticks.
- An older profile, when chosen, accepts its side's documents once.
- The side switch, in the app bar and in Settings, appears only for people with a linked profile. Others see "Also collect for …".
- Each side's profile page is its own:
  - water shows official areas;
  - research shows the forms this person may fill;
  - both keep sign-in codes and devices.

## Consequences

- People who use both sides keep two accounts. Linking keeps switching simple, but a password change applies to one account only.
- Older water users are asked once to accept the water documents (version 4). IT admins are asked for both sides.
- Water Console users without areas see the whole country's water data. Alert routing still follows areas and responsibilities.
- More sides can be added by extending `AppSide`, the server's side checks and the documents.

## Amendment, 2026-10-27 (the lead's follow-up, DEVLOG entry 51)

- **The sides run in parallel and never share a page.**
  - **Console:** research has its own administration under `/research/admin`: people (research accounts), collectors' devices, the accounts and codes ledger, security and system. The water admin pages are reused there, reading their side from the address, and lists are filtered by side on the server (`?side=`). The water Admin shows only water people and devices. IT admins appear on both. Research accounts never reach `/admin`.
  - **Collect:** research has its own menu and pages under `/research`: home, map, sync, settings, profile and messages. Water keeps `/`. A guard keeps each side on its own pages; only "Who is collecting?", the lock and reset belong to the device. Reference data is water's.
- **Codes on the research side.** A research collector's page shows IT admins the same confirmation codes, devices and sign-ins as a water tester's page, without areas. That includes the code to sign another device out.
- **The full switch is always visible.**
  - **People with an account or profile on the other side** confirm and switch.
  - **Everyone else** chooses how to go there:
    - sign in with an account they have there;
    - use their current details to make a linked account or profile;
    - come back with a recovery or sign-in code (Collect);
    - pick someone already on this phone for that side (Collect);
    - create a new account or profile.
  - **IT admins** switch view.
- **Acceptances are kept** (migration 0021, `legal_acceptance`).
  - **What is recorded:** every acceptance of a side's Terms of Use and Privacy Policy:
    - who (account or tester);
    - side and version;
    - both documents ticked;
    - how (sign-up, join, the one-time prompt, or a profile on a phone);
    - device or IP address;
    - time.
  - **Never changed.** Rows cannot be edited or deleted.
  - **Who reads them:** IT admins, on people's and collectors' pages.
