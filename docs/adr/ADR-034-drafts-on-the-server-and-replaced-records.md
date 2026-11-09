# ADR-034: Unfinished forms on the server, and research records corrected or done again

- **Status:** Accepted (2026-11-09)
- **Context:** DEVLOG entries 72–73; follows ADR-018 (corrections), ADR-022 (pictures), ADR-030 (research) and ADR-033 (approval).

## Why

On the web, Collect keeps its work in the browser's IndexedDB. An unfinished form lived only there: saving never queued anything for the server. Safari may clear a site's storage after seven days of browser use without a visit to that site, unless it was added to the Home Screen; other browsers may clear it when space runs short. Finished records were already safe. Collectors could also not fix a research record once it was sent, though water testers can.

## Decision

### Unfinished forms

- **A copy on the server.** `research.draft` holds the latest copy of each unfinished form: answers, number, point of interview and a list of its pictures. There is one row per form, and the copy with the latest device time wins.
- **When it is sent.** About 30 seconds after a change, and at once on Save and close, on leaving the page, and when the app is hidden. Only the newest copy waits to be sent. It uses a quiet send that fetches nothing.
- **Pictures.** They are uploaded like any other (attachment `owner_type = 'research_draft'`), and still respect "Upload photos on mobile data".
- **Coming back.** Any device the collector is signed in on receives their open drafts with the `research` feed. A copy never overwrites newer work on the device, and a form already finished there does not return. Pictures no longer on the device are fetched from the server when shown.
- **Ending.** When the record arrives, or the collector discards the form, the row's answers are emptied and it is marked closed, so answers are never held twice. Pictures still answering a question move to the record; the others are marked removed, as any removed picture is (ADR-022).
- **Who sees them.** Only the collector, on their own devices. An unfinished form is not yet a record, so the team does not see or count it.
- **Waiting for approval.** Drafts are accepted while the team has still to approve the collector: a backup, not a record. Finished records still wait on the phone (ADR-033).
- **Existing drafts** are queued at the next sync.

### Water tests in progress

- **Kept the same way.** `water_test_draft` holds what the test screens hold: readings, limits, tester, the location check. Pictures are uploaded like research drafts'. Its id is the id the test session will have, so submitting ends it on the server and its pictures move to the session.
- **When.** Nothing is kept until a reading or picture is entered, so opening a test and going back leaves nothing. Then saved within a second, sent about 30 seconds later and on leaving the app.
- **Carrying on.** Home lists unfinished tests of sources on the device, to continue or discard.

### Coming back on a new device

A phone registers and syncs before anyone signs in on it, so its place in the research feed lies past what is theirs. On recovery it now reads that feed from the start, which brings joined forms, records, pictures, messages and drafts. The same person's linked profile on the other side is signed in too, and the districts they worked in are added to what the phone syncs. Trips stay on the device that recorded them.

### Correcting or doing a record again

Records stay as made (ADR-030 §3). A change is a new record pointing at the old one (`replaces`, `replace_kind`, `replace_reason`), as water corrections do (ADR-018).

- **Correct a mistake:** the answers, form version, number, start time and point of interview carried over, ready to change.
- **Do it again:** an empty form with the same number, at the form's current version, with a new time and point.
- **Rules.** Only the collector who made the record; a reason is required; only the newest record in a chain; the form must still be open to them. The same number is not a clash.
- **For the team.** Lists, counts, maps, analysis and exports use the newest record only. The Console links each version to the other and shows the reason. Earlier versions stay in the database and remain on the collector's list, marked as replaced.

### iPhone and iPad

Apple offers no way for a page to add itself to the Home Screen. The Settings row opens the steps for the current Safari, where Share sits behind "•••". Installing is also the dependable protection against Safari clearing storage. A Home Screen app has storage of its own, so it starts fresh and the collector signs in again there; their unfinished forms then come back.

Collect also asks the browser for persistent storage (`navigator.storage.persist`), which Safari may refuse.

## Consequences

- A collector's answers now reach the server before the form is finished, including from interviews they may later discard; discarding removes the answers from the server.
- The local database moves to v16: research records and drafts gain three columns (v15), and water tests in progress get a table (v16).
- A picture taken on mobile data with uploads limited to Wi-Fi stays only on the device until Wi-Fi.
