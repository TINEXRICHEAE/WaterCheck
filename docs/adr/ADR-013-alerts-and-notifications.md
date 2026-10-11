# ADR-013: Alerts, notifications, escalation and the SMS fallback

- Status: Accepted (2026-10-11). The project lead chose the job runner and to build with fakes until the accounts exist.
- Covers: SPEC P8, §4.7, §8.4–8.5, F-ALR-1/3/4, errata G7 and G14
- Amends: the plan's P8 [DECIDE] on jobs (★ procrastinate → own queue); the SMS format (6-character code instead of 4)

## Context

An abnormal result must reach the right stakeholders within minutes, keep reaching them until someone acts, and get through even when the phone cannot sync. The plan suggested procrastinate for jobs. Its jobs are queued over its own connection, so an alert could commit without its notification job, or the reverse.

## Decision

### 1. Alerts are raised by the server too, with one shared ID

- After each synced result is classified, the server raises the same alerts as the phone: E. coli detected, an unsafe result, or a baseline jump. The baseline uses the source's earlier safe results, newest first, ignoring results later corrected.
- **The alert ID is deterministic on both sides:** UUID v5 of `<result_id>/<trigger_rule>`. Whichever arrives first, phone or server, the other finds it already there: **one alert, never two** (errata G7). A shared test vector checks Python and Dart agree.

### 2. A small Postgres job queue (the lead's choice)

- The `job` table is filled **inside the transaction that creates the alert**, so an alert and its notification commit together.
- The worker container takes due jobs with `FOR UPDATE SKIP LOCKED` (several workers are safe). Each job runs in its own transaction.
- **Failures** roll back and retry with backoff: 30 s doubling to 1 h, 8 attempts. A delivery that finally fails is marked `failed`.
- A periodic escalation sweep re-queues itself every 5 minutes; a dedupe key keeps one at a time.
- **The clock is injectable,** so tests travel in time.

### 3. Who is told, and how

- **Recipients:** active stakeholders whose area covers the source and whose responsibilities match the routing rule for the trigger (`alert_routing_rule`, seeded "every trigger → every responsibility"). A stakeholder with no responsibilities set gets everything in their area, the spec's default.
- **Channels:**

  | Channel | When | Status |
  |---------|------|--------|
  | In-app inbox | Always (`GET /v1/notifications`; bell with unread count in Console) | Working |
  | Email | When an address is known (SMTP: Mailpit in dev) | Working |
  | Push | To registered devices (`POST /v1/push-tokens`, FCM HTTP v1; Android and web Console, not Windows, errata G14) | Server side built; device registration waits for the Firebase project |
  | SMS | For severities in `notifications.json` (default: critical) through the `SmsGateway` | Africa's Talking adapter built; waits for the sandbox key |

- **Each delivery is its own job,** so a failing channel never blocks the others. A person is notified at most once per alert, channel and escalation level (unique constraint).

### 4. Escalation (F-ALR-4)

- Configurable in `infra/seed/notifications.json` (`escalation_hours`, default 48 and 96).
- An alert still **open** (not acknowledged) after 48 h reaches level 1: the alert is re-sent, and everyone covering the source at district level or above is added.
- At 96 h, level 2 adds the IT admins.
- Each step is an `escalated` alert event. Acknowledged alerts never escalate.

### 5. Lifecycle

- Stakeholders act from the Console alert screen: acknowledge, action in progress, close (a note is required), false alarm (a note is required), request lab confirmation, add a note.
- These are queued `alert_event` records with the user as actor. The server's state machine (ADR-011) is authoritative.
- Every transition carries its actor and server time.

### 6. SMS fallback (§8.5)

- **When:** an alert unsynced for `sms_fallback.after_hours` (default 6), once the IT admin has set the gateway number. Collect then offers "Send by SMS" and opens the phone's own SMS app with the text filled in. No SMS permission is needed, and the collector presses send.
- **Format:** `WC1 I:<short code> ALERT <source> <yyyyMMddTHHmmZ> <readings…> UNSAFE|ECOLI|JUMP #<code>`, at most 160 characters.
  - The short code is 4 unambiguous characters per installation.
  - The code is the first **6** hex characters of HMAC-SHA256 with the installation secret. The spec's example shows 4; 6 gives 24 bits against guessing.
- **Inbound webhook:** `/v1/sms/inbound/{provider}?token=…`. Providers do not sign callbacks, so a secret token sits in the URL. The SMS must also verify with its installation's HMAC. Malformed, forged, unknown-installation, revoked-installation and unknown-source messages are refused and logged (`sms_message` plus the audit log). The sender's number is stored only as a hash plus its last 3 digits.
- **Accepted SMS:** a **provisional** alert is opened and notified at once.
- **Reconciliation:** when the full record syncs (same source and rule, within ±3 h), the provisional alert is closed and linked to it, and nobody is notified twice. An SMS arriving after the full record is only noted on that alert. Duplicate gateway deliveries are ignored.

## Consequences

- **Gate items pending accounts:** the SMS round trip in the provider sandbox, and push on real devices. Both are tested with fakes and the adapters are ready; the keys go in `infra/.env`.
- **Notification wording** is English plain text (ADR-007). Email links to the Console are P9/P11 polish.
- **New alert types** need a routing entry, a `TRIGGER_TEXT` line and a Console label.
- **Job and notification housekeeping** (pruning done jobs and old notifications) is a P12 cleanup job.
