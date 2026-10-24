# ADR-024: Testers, not devices, are assigned to areas

- Status: Accepted (2026-10-24); built, on dev
- Covers: the lead's request of 2026-10-24 (DEVLOG entry 36)
- Amends:
  - ADR-009 and F-AUTH-7 (a device was activated with a code for an area);
  - ADR-020 (recovery codes came only from the Console and expired after a day).

## Context

Collect opened on an activation code: nothing worked until an IT admin had given one, and a code tied the device to an area. The lead found this blocks onboarding, and makes people who already have a profile ask for a code every time they change device. People should be free to use any device and still be recognised as themselves. What is official is the tester's assignment to an area, not the device.

The lead's answers:

- **No code:** a device registers itself and works fully; its testers are "not yet assigned" until an assignment code.
- **Another device:** keep recovery codes (email or SMS later). A tester can also make their own code in Collect: one use, no expiry until used, usable for extra devices at the same time.
- **Signing devices out:**
  - A tester can sign out other devices that use their profile.
  - A confirmation code is needed: by email or SMS later; for now it is shown on the tester's page in the Console, and the admin passes it on.
- **Contact details:** phone and email are optional on a tester's profile, added after onboarding.
- **Visibility:** an unassigned device sees where it works, like any device.

## Decision

1. **Self-registration:** `POST /v1/installations/register` needs no code.
   - The device gets its signing secret and no area (`installation.admin_unit_id` may be null; `registered_via = 'self'`).
   - Registrations are limited to 20 an hour per address (`X-Forwarded-For` from Caddy, stored hashed).
   - A device's row is visible to itself and to IT admins whatever its area.
2. **Collect:**
   - There is no activation step.
   - The device registers at startup when online, and again before a sync or a sign-in if it was offline. Meanwhile everything is kept on the device.
   - The old `/installations/activate` stays for older apps.
3. **Assignment codes:** the former activation codes now assign testers.
   - `POST /v1/collectors/{key}/assign` with a code records a `collector_assignment` for the code's area. It counts one use per tester, and gives an area-less device its first tester's area.
   - IT admins can also assign directly or end an assignment from the tester's page.
4. **Devices and sign-ins:**
   - `collector_device` records each device a tester uses: `created` when their records first come from it, or `admin_code` / `own_code` when they sign in with a code.
   - `collector_signin` logs every sign-in with the device.
   - Every push keeps the row current.
5. **Own codes:** `POST /v1/collectors/{key}/recovery-code/own`, from a device the tester is signed in on, makes a one-use code with no expiry. Admin codes still expire after 24 hours.
6. **Signing devices out:**
   - `POST …/devices/sign-out` creates a six-digit confirmation, valid for a day, with at most 5 tries.
   - IT admins see the code on the tester's page and pass it on.
   - `POST …/sign-out/{id}/confirm` signs the devices out. From then on the server refuses that tester's records from those devices (`collector_signed_out`), and the device removes the tester locally.
7. **Profile:** phone and email are optional (local schema v10 adds email).
8. **Console:**
   - The tester's page shows their areas (assign, end), devices, sign-ins and any confirmation code to pass on.
   - The collectors list marks "not yet assigned".
   - Codes and accounts lists the testers each code assigned.
   - The wording is "assignment code" throughout.

## Consequences

- **Anyone can register a device and send records.** That is the lead's choice. Records from testers not yet assigned are visible as such, and stakeholders judge them as before (flags, marks). The rate limit stops bulk sign-ups, not a determined person.
- **The confirmation code is stored in clear for a day,** because an admin must read it out. When email and SMS exist, it should be sent and stored hashed.
- **Identity:** a tester's identity is still their collector key. Anyone holding a valid sign-in code becomes that tester on a device, which is why codes are single-use and every sign-in is recorded.
- **Older apps:** devices activated with a code (0.1.1) keep working. Their area stays as it was.
