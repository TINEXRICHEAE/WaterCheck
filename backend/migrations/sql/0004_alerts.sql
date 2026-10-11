-- P8 alerts and notifications (ADR-013).

-- ------------------------------------------------------------- job queue
-- Background jobs, queued in the same transaction as the change that needs
-- them (an alert and its notify job commit together). The worker takes jobs
-- with FOR UPDATE SKIP LOCKED, so several workers never run one job twice.
CREATE TABLE job (
  id bigserial PRIMARY KEY,
  kind text NOT NULL,
  payload jsonb NOT NULL DEFAULT '{}',
  run_at timestamptz NOT NULL DEFAULT now(),
  attempts int NOT NULL DEFAULT 0,
  max_attempts int NOT NULL DEFAULT 8,
  status text NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'done', 'failed')),
  last_error text,
  -- One queued job per key (e.g. one escalation sweep at a time).
  dedupe_key text,
  created_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz
);
CREATE INDEX job_due ON job (run_at) WHERE status = 'queued';
CREATE UNIQUE INDEX job_dedupe ON job (dedupe_key) WHERE status = 'queued' AND dedupe_key IS NOT NULL;

-- --------------------------------------------------------- notifications
-- One row per recipient and channel. In-app rows are the user's inbox.
CREATE TABLE notification (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES app_user(id),
  alert_id uuid REFERENCES alert(id),
  kind text NOT NULL CHECK (kind IN ('alert', 'escalation', 'reminder')),
  channel text NOT NULL CHECK (channel IN ('in_app', 'email', 'push', 'sms')),
  title text NOT NULL,
  body text NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed', 'skipped')),
  error text,
  created_at timestamptz NOT NULL DEFAULT now(),
  sent_at timestamptz,
  read_at timestamptz,
  -- Never notify the same person twice about the same alert and level.
  UNIQUE (user_id, alert_id, kind, channel, escalation_level),
  escalation_level int NOT NULL DEFAULT 0
);
CREATE INDEX notification_inbox ON notification (user_id, created_at DESC) WHERE channel = 'in_app';

-- Device tokens for push (FCM: Android and web Console, errata G14).
CREATE TABLE push_token (
  token text PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_user(id),
  platform text NOT NULL CHECK (platform IN ('android', 'web')),
  created_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------- alerts
ALTER TABLE alert
  ADD COLUMN escalation_level int NOT NULL DEFAULT 0,
  ADD COLUMN escalated_at timestamptz,
  ADD COLUMN created_at_server timestamptz NOT NULL DEFAULT now(),
  -- Created from an SMS before the full record synced (SPEC §8.5).
  ADD COLUMN provisional boolean NOT NULL DEFAULT false,
  ADD COLUMN sms_code text;

-- ------------------------------------------------------------------- SMS
-- Short installation ID used in SMS (`I:7Q2K`), unique, unambiguous letters.
ALTER TABLE installation ADD COLUMN short_code text UNIQUE;

-- Every SMS in and out, for audit (forged ones included, with the reason).
-- The sender's number is kept only as a hash plus its last 3 digits.
CREATE TABLE sms_message (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  direction text NOT NULL CHECK (direction IN ('inbound', 'outbound')),
  provider text NOT NULL,
  provider_id text,
  phone_hash text,
  phone_last3 text,
  body text NOT NULL,
  status text NOT NULL CHECK (status IN ('accepted', 'rejected', 'duplicate', 'sent', 'failed')),
  reason text,
  installation_id uuid REFERENCES installation(id),
  alert_id uuid REFERENCES alert(id),
  received_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX sms_inbound_once ON sms_message (provider, provider_id)
  WHERE direction = 'inbound' AND provider_id IS NOT NULL;

-- ------------------------------------------------------------------- RLS
-- Jobs and SMS logs are server-side only (worker and webhooks run as the
-- system principal); users see their own notifications and tokens.
ALTER TABLE job ENABLE ROW LEVEL SECURITY;
CREATE POLICY system ON job USING (wc_is_admin());
-- Anyone may queue a job as part of their own change (e.g. a pushed alert).
CREATE POLICY enqueue ON job FOR INSERT WITH CHECK (true);

ALTER TABLE notification ENABLE ROW LEVEL SECURITY;
CREATE POLICY own ON notification USING (wc_is_admin() OR user_id = wc_user_id());

ALTER TABLE push_token ENABLE ROW LEVEL SECURITY;
CREATE POLICY own ON push_token USING (wc_is_admin() OR user_id = wc_user_id());

ALTER TABLE sms_message ENABLE ROW LEVEL SECURITY;
CREATE POLICY admin ON sms_message USING (wc_is_admin());

GRANT SELECT, INSERT, UPDATE ON job, notification, push_token, sms_message TO watercheck_app;
GRANT DELETE ON push_token TO watercheck_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO watercheck_app;
