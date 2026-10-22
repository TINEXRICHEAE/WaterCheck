# ADR-020: Collector recovery codes: the same person on any phone

- Status: Accepted (2026-10-22); built, waiting for the lead's check on dev
- Covers: the lead's request of 2026-10-22 (DEVLOG entry 18)
- Amends:
  - SPEC §2.1 (a collector profile was local to one phone);
  - ADR-018 (`collector_profile` could only be changed by the phone that first sent it)

## Context

Collectors have no password; their profile lived on the phone that created it. After a lost phone, or on a second device, "Who is testing?" could only add a new person. A new person gets a new collector key, so their earlier work no longer counted as theirs. The lead asked for:

- an "existing person" option on "Who is testing?";
- a code generated in the Console on request, passed on by other means for now (email or SMS once those exist);
- the code also working for a collector moving to another device, with several collectors, new and existing, on one phone;
- IT admins and stakeholders able to let someone back in, from any district, during supervision. Collectors and stakeholders may both test once at the source.

## Decision

1. **Issuing a code:**
   - `POST /v1/collectors/{collector_key}/recovery-code` is open to IT admins, and to stakeholders whose areas the collector works in (one of the collector's tests or sources is visible to them; otherwise `403 not_in_your_areas`).
   - It returns a 10-character code shown as `XXXXX-XXXXX`, from `23456789ABCDEFGHJKLMNPQRSTUVWXYZ` so it can be read aloud.
   - The code is valid for **24 hours** and works **once**. Only its SHA-256 is stored (migration 0011, `collector_recovery_code`). Issuing it is audited (`collector.recovery_code_issued`).
   - In the Console it is under Collectors › ⋮ › "Sign-in code for another phone". A dialog shows it once with Copy; the issuer passes it on by phone or text.
2. **Redeeming a code:**
   - `POST /v1/collectors/recover` (signed phone only) takes the code, ignoring case and the dash, marks it used by that installation, and returns the collector key with the server's latest details (`collector_profile.snapshot`). It is audited (`collector.recovered`). A wrong, used or expired code gives `404 invalid_code`.
   - In Collect: "Who is testing?" › "I already have a profile" › code.
   - The details are restored under the same key with at least the server's profile version (`CollectorProfileRepository.restore`). The person is selected, and a sync brings their district.
   - A phone may hold any number of people, new and recovered.
3. **Any phone keeps a collector's details current:** the `collector_profile` read and update policies now allow any phone, not only the first one. `installation_id` stays the first phone that sent the details.

## Consequences

- **A lost phone no longer splits a collector's history:** the same key continues on the new phone. The old phone should still be revoked (Admin › Collect phones).
- **The code is a bearer secret for 24 hours:**
  - anyone holding it can act as that collector on an activated phone;
  - it is one-time and audited, and only the hash is kept;
  - sending it by email or SMS comes with the notifications work (slice D).
- **Stakeholders:** they can issue codes only for collectors in their areas. IT admins can issue for anyone.
- **Older phones:** details from phones before the full snapshot may be incomplete. Missing fields come back empty, for the collector to fill in with "Edit".
- **Console sign-in on another device** needs nothing new: Console users already sign in anywhere with their username and password, and a forgotten password goes to the IT admin (a better reset is among the open discussions in PLAN.md §3a).
