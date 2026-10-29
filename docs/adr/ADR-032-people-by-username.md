# ADR-032: People by username, private by default; chats; form editors; computers without GPS

- **Status:** Accepted (2026-10-28)
- **Context:** DEVLOG entry 53; follows ADR-030 (research) and ADR-031 (sides).

## Decision

### Usernames, anonymous by default

- **Every person has a username.**
  - Every Console account and every tester profile has one.
  - It is generated like "quiet-heron-42": a word pair and a number.
  - Its owner can change it to 3–30 lower-case letters, digits, dots, dashes or underscores.
  - It is unique across accounts and tester profiles together, and checked as it is typed.
- **Everyone starts anonymous (migration 0023).**
  - Existing accounts and profiles were made anonymous too (the lead's choice).
  - Research collectors' earlier "find me by name" became the same public choice.
- **How people are shown.**
  - Everywhere, a person is shown by username.
  - Their real name follows in brackets, "quiet-heron-42 (Akello Grace)", only for viewers allowed to see it.
- **Who may see a real name** (`wc_sees_user`, `wc_sees_collector`):
  - IT admins;
  - everyone, when the person chose **Public**;
  - the person's own teams:
    - research project teams the collector works for;
    - members of the same research project;
    - water officers whose areas hold a tester's assigned area or sources they tested;
    - officers whose areas meet;
  - the phone the tester uses.
- **Where names are labelled.** The server labels names wherever they leave it:
  - research pages;
  - the water dashboard and collector list;
  - codes to pass on;
  - added places;
  - and the device sync, where testers' snapshots and message authors are relabelled.

  Contact details (phone, email, organisation) go only to those who may see the name.
- **Already-synced data.**
  - Sync cursors gained an epoch (`2:`), so every device pulls once more with names relabelled.
  - Changing a username or the public choice touches the person's rows, so they sync again.
  - Messages are append-only and keep what was sent.
- **Finding collectors.** "Find a collector" works by username or collector code for everyone. By real name or phone, it only finds people whose name the searcher may see.

### Chats between people

- **Who can write to whom.** Any two people on the same side can write to each other: accounts and testers, anonymous or public.
- **The people list.** The messages pages list chats, then everyone on the side, searchable with the page's own search box. Each person is shown by username, with the real name where it may be seen.
- **Online only.** Chats use their own tables and API (`/v1/chats`, `/v1/device/chats`), not the offline device sync.
- **Row-level security.** Only the two people in a chat can read it.

### Form editors and credits

- **Changing what is shared.** Only the owning project's team changes a form's access and sharing.
- **Editors.** The owner may add editors (by email or username). Editors can change the questions and publish new versions.
- **Credits.** Each version records who published it, shown by username. Tapping the name opens the person's card, with a way to write to them.
- **Copying.** "Copy to my project" shows only on someone else's form. Once copied, it opens the copy instead of copying again.

### Computers without GPS

- **Which devices.** On computers (Windows, macOS, Linux, in a browser or as an app), the browser's location guess is not used. It stayed on one place for weeks over a phone hotspot.
- **Where the location comes from.**
  - The server looks up the caller's public address in a city database it keeps: DB-IP Lite (CC BY 4.0), fetched by `tools/fetch_geoip.py`. No address is sent to a third party for the lookup.
  - Callers on the server's own network use the server's public address.
  - The answer is an area: a town centre, at least 25 km across.
- **Setting the point by hand.** The person may set their point by hand, but only inside that area, so nobody can place themselves elsewhere. Such a point counts as 100 m accurate; the area's centre counts as the whole area.
- **Phones and tablets** use GPS as before.

### Smaller changes

- The app lock is off until turned on in Settings.
- Copy buttons answer with a tick.
- Research wording never says testing.
- Research admin has its own codes page, showing only research people's codes.

## Consequences

- **Pseudonymity without hiding work.** Teams and IT admins still know who collected what. Strangers do not.
- **Real names already on devices.** Devices that synced before the epoch held real names. After the re-pull they hold labels, but copies seen before remain.
- **Chats need a connection.**
- **IP database.** The database (about 130 MB) is refreshed monthly on each server and mounted read-only into the API.

## Amendment, 2026-10-29 (DEVLOG entry 54): computers without GPS

The IP-only rule of 2026-10-28 is replaced.

- **Why.** Ugandan mobile data places a computer in Kampala wherever it is. Limiting hand placement to that circle locked field users out of their real place. The computer's own location, though sometimes stale, was right when it mattered.
- **The order on computers is now:**
  1. a point set by hand, anywhere, until "Read again";
  2. the computer's own location, read fresh, with its accuracy and age shown;
  3. the internet guess, only when the computer gives none.
- **Marked on records.** Records and tests keep where their location came from (`location_source`: none, `internet`, `hand`; migration 0024), and the pages say so. Teams can then see which points were not measured. Preventing false placement is no longer claimed: nothing on a computer can check it.

