# ADR-025: Profiles people manage themselves

- Status: Accepted (2026-10-24); built, on dev
- Covers: the lead's request of 2026-10-24 (DEVLOG entry 38)
- Amends:
  - PLAN slice D ("editable profile with confirmations" waited for email and SMS);
  - ADR-024 (confirmation codes passed on by an IT admin).

## Context

The lead asked for a proper profile for each kind of user (IT admin, stakeholder, tester), separate from general settings. It should cover editable name, email and phone (and area, when one was set by mistake), other relevant details, signing out, switching account, removing an account from a device, and deleting one's account.

The lead's choices:

- **Own area:** a stakeholder's areas decide what data they see, so changing them is a request an IT admin approves. A tester's area is only where they say they live, so they change it directly.
- **Delete:** close for good and erase contact details. Records already made stay, under the person's name. The last IT admin cannot close their account.
- **Contacts:** a new email or phone is confirmed with a code. Until email and SMS are set up, an IT admin sees the code and passes it on, as for signing devices out (ADR-024).

## Decision

1. **Console:**
   - "My profile" holds:
     - details: name, organisation and position, edited at once;
     - email and phone: change and confirm;
     - areas, with "Ask for different areas" (a reason is required, one open request at a time);
     - account actions: Settings, Sign out, Sign in as someone else, Remove this account from this device (signs out and erases the data, saved sign-in and PIN kept here), and Close my account (password required).
   - "Settings" is a separate page with appearance and time, alert channels, the app lock and installing the app. The account menu has both.
2. **Collect:**
   - "My profile" opens from the Home bar and Settings. It holds:
     - details (Edit opens the tester form; area changed directly);
     - phone and email, each marked confirmed or not, with Confirm;
     - the area assignment, sign-in code and devices (ADR-024);
     - Switch person, Sign out of this device, and Delete my profile.
   - Signing out and deleting first send everything of the tester's; with anything unsent, they wait.
3. **Server, migration 0016:**
   - App users get confirmation times for phone and email, and a closed time.
   - Tester profiles get the confirmed phone and email, and a closed time.
   - `contact_confirmation` holds six-digit codes, valid for a day, with at most 5 tries, kept in clear so an admin can read them out.
   - `area_request` holds area change requests.
4. **Endpoints:**
   - Console users: `PUT /v1/me/profile`, `POST /v1/me/contacts` (and `…/confirm`), `POST`/`GET /v1/me/area-requests`, `POST /v1/me/close`.
   - Testers: `POST /v1/collectors/{key}/contacts` (and `…/confirm`, `…/status`), `POST …/sign-out-here`, `POST …/close`.
   - IT admins: `GET /v1/admin/codes-to-pass` (contact and device codes together), `GET /v1/admin/area-requests`, and `POST …/decide` (approving replaces the person's areas).
   - `/v1/me` reports whether the phone and email are confirmed.
   - Phone numbers are checked on the server with the same Ugandan rule as the apps.
5. **Closing an account:**
   - For a Console user, it sets the account inactive (sign-in refused), erases phone, email and organisation, and revokes every refresh token. An access token already issued lapses within its 15 minutes.
   - For a tester, it signs out every device (their records are then refused), ends their assignments, and erases phone, email and organisation from the server's copy of their profile.

## Consequences

- **Codes in clear:** confirmation codes are stored in clear for a day, so an admin can read them. When email and SMS are set up, they should be sent and stored hashed. "Codes to pass on" is the only place they appear.
- **Contacts not yet confirmed:** they stay on file. Alerts should go only to confirmed contacts once email and SMS sending exists.
- **Closing keeps the name:** names stay on the records a person made, because the water history depends on them. Erasing names would need a separate decision.
- **New areas apply late:** an approved area change takes effect at the person's next token refresh (at most 15 minutes) or sign-in.
