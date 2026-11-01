# ADR-033: Shared form links, a guest view, and joining with the team's approval

- **Status:** Accepted (2026-11-01)
- **Context:** DEVLOG entry 66; follows ADR-030 (research), ADR-031 (sides) and ADR-032 (form editors).

## Decision

### Links

- **Two kinds.**
  - **For collectors:** made by anyone on the form's team, or by a collector who has the form (from Collect).
  - **For editors:** made by the project's owner only.
- **The address.** `https://<site>/f/<link>`: the Console answers it on any of the site's names. On the dev stack, `/f/*` goes to `/console/f/*`.
- **Life.** A link works until it is turned off. A collectors' link to a form behind a code works only while that code does; a new code needs a new link. Each maker keeps one working link of each kind, given back when they share again.
- **Seen by the team.** The Access tab lists every link, who made it, whether it still works, and turns any off.

### The guest view

- Anyone opening a link, signed in or not, sees the form's title, project, description and every question, read-only. No records or counts.
- Someone not signed in is a guest with a temporary name (`guest-1234`), kept for that visit only.

### Joining as a collector

- **From the Console page:** "Collect with this form" opens Collect at `/collect/#/research/link/<link>`.
- **In Collect:**
  - the link is kept on the device while the person is added (or switches to research), then shown on Research's home with "Join this form";
  - a link pasted in "Join with a code" works too, also in the Android app.
- **Approval (per form, the lead's choice).**
  - A form setting, "New collectors need approval": on for new forms, off for forms made before (migration 0027), so the CHS4102 codes keep working at once.
  - It applies to joining with a code or a link. Open forms need no joining; a form the team gives out itself (assigned) always waits.
  - A waiting collector gets the form and fills it. Their records, and the records' pictures, stay on the device until the team approves them. The server refuses them meanwhile with `awaiting_approval`, which the device keeps and sends again.
  - The team approves (or removes) them in the Access tab, where they are marked "Waiting for approval".

### Asking to edit

- **From an editor link:** sign in or create a research account, coming straight back to the form. Then "Ask to edit".
- **The owner** sees who is asking in the Access tab, and lets them edit (they become an editor, ADR-032) or declines.
- Someone who can already edit is told so and goes to the form.

### Coming back after signing in

- Any Console page asked for while signed out is carried as `next` through signing in, creating an account, and accepting the side's documents, then opened. Only addresses on the same site are followed.
- Creating an account already signs in; with `next`, it now also goes back to the page.

## Consequences

- **Server:**
  - migration 0027: `form.join_approval`; `form_collector.status`; `research.form_link`; `research.edit_request`;
  - `can_collect` counts approved collectors only; new `device_awaits`; `can_view_form` and `locked_forms` take waiting collectors into account;
  - `form_by_link` and `join_with_link`.
- **API:** `GET /v1/public/links/{token}` (no sign-in); the link, join, edit-request and approval endpoints in `app/api/form_links.py`.
- **Apps:** Console `/f/<link>` page and the Access tab's Share section; Collect's share button, link card and waiting forms; the sync service holds back records of waiting forms.
