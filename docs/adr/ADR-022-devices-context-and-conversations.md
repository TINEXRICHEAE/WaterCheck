# ADR-022: Every device, linked pages, pictures with context, typed "Other", and conversations

- Status: Accepted (2026-10-22); built in sprints 3.1–3.6, waiting for the lead's check on dev
- Covers: the lead's round 3 request of 2026-10-22 (DEVLOG entries 22–28)
- Amends:
  - SPEC §3.1 (a test needs a picture, or a named reason);
  - SPEC §8 (two new synced records: picture removals and messages);
  - ADR-012 (pictures were add-only);
  - ADR-017 (lists with "Other").

## Context

After round 2 the lead asked for:

- both apps to work on every screen, from a small phone to a very large display, and to install as web apps;
- Collect to be a real web app;
- "device" instead of "phone";
- every page linked to what it mentions;
- a way to cover an area with people and to see every code and account given out;
- pictures that open full screen and can be replaced by whoever took them;
- a required test picture;
- each test's location and surroundings on every result view;
- "Other" lists that take a typed value;
- conversations between collectors and the office inside the apps, without SMS or email yet.

The lead's answers to the open questions:

- **Collect on the web:** keep its data in the browser.
- **Messages:** threads on anything.
- **Test picture:** required, or a listed reason.
- **Checkpoint:** commit before starting.

## Decision

1. **Every screen (3.1):**
   - Layouts follow width: a bottom bar or a navigation rail, and a capped page width (Collect 1280, Console 1440).
   - Collect on the web keeps its database in the browser (sqlite3 WASM with an IndexedDB file system) and is served at `/collect/`.
   - Both web apps have a manifest, an offline shell (service worker) and "Install app" where the browser offers it.
   - "Device" replaces "phone" wherever the app may run on a computer.
   - Maps take touch, wheel, keys (R/F to zoom) and on-screen buttons. The world does not repeat sideways.
2. **Everything linked (3.2):**
   - Pages for devices, collectors, places added from devices, and a parameter's first use.
   - Reference data opens what it names.
   - "Show on map" on sources and areas, and back again.
3. **Who covers an area, and the ledger (3.3):**
   - From an area: add an existing person, a new stakeholder, or an activation code for a new device.
   - Admin › Codes and accounts lists every code (with the devices it activated, and withdrawal) and every account (with first and last use).
4. **Pictures and test context (3.4):**
   - A picture records the collector who added it (`attachment.collector_key`). Only that collector can remove it.
   - An unsent picture is simply dropped. A sent one is marked `removed_at` on the server (never deleted), and pull tells other devices to drop it.
   - A test needs a picture of the kit or reading, or a reason: `camera_broken`, `not_allowed`, `too_dark`, or typed words (`test_session.no_photo_reason`). Corrections need neither.
   - The Collect result and the new Console test page show:
     - location and accuracy;
     - distance from the source and the reason if away;
     - the no-picture reason;
     - the surroundings check nearest the test, with the risks seen.
   - Source pages show only the source's own pictures; each test's pictures are on the test.
   - A shared full-screen viewer has zoom, swipe, keys, and remove where allowed.
5. **"Other" means type it (3.5):**
   - Source and collector types take a typed value, stored as typed and offered again on that device.
   - Admin › Typed list values lists what is in use and not yet in the shared list. "Add to the list" puts it before "Other" with the typed value as its code, so existing records match. It is marked `added` and kept when a newer seed list arrives.
6. **Conversations (3.6):**
   - A `message` is insert-only, about a `test` (session), `source`, `collector` (key) or `area`.
   - The server sets its area from the subject, so the area feed carries it to the devices and Console users there. Row-level security limits it to the caller's scope.
   - Both apps write messages through the outbox. Collect: on the source and the result, plus a Messages inbox with an unread badge. Console: on the source, the test, the collector, the area (Places) and the alert, plus a Messages page with a badge.
   - "Read" is kept per device and never synced.
   - Response cards remain the automatic guidance after an unsafe result; a stakeholder's answer goes in the test's thread.

## Consequences

- **Server:**
  - Migrations 0012 (pictures and test context) and 0013 (messages).
  - The sync API gains `attachment` update (removal) and `message` insert.
  - New admin endpoints for typed values.
- **Devices:** local schema v7 (picture author, no-picture reason) and v8 (messages).
- **Messages:**
  - Nobody is told outside the apps: a reply is seen at the next sync and open. Email and SMS come with slice D.
  - Threads about a whole district reach devices whose area is that district or larger, not a village below it.
- **Pictures:** removal is final for the collector. The IT admin still has the file, marked removed, for audit.
- **Typed values:** they are free text until the IT admin adds them. Spelling variants appear as separate entries, and there is no merge yet.
- **Collect on the web:**
  - The browser database is not encrypted at rest, and the privacy notice says so.
  - Two open tabs share one store.
