-- Profiles people manage themselves (ADR-025): Console users and testers
-- edit their details; a new email or phone is confirmed with a code (shown
-- to IT admins until email and SMS are set up); a stakeholder's own area
-- change is a request an IT admin decides; "delete my account" closes it
-- and erases contact details, while submitted records stay.

ALTER TABLE app_user
  ADD COLUMN phone_confirmed_at timestamptz,
  ADD COLUMN email_confirmed_at timestamptz,
  ADD COLUMN closed_at timestamptz,
  -- The version of the Privacy Policy and Terms of Use last accepted
  -- (0: never); the Console asks again when the documents change.
  ADD COLUMN legal_version integer NOT NULL DEFAULT 0,
  ADD COLUMN legal_accepted_at timestamptz;

-- What a tester's contacts were confirmed as; their details live in the
-- profile snapshot the devices send.
ALTER TABLE collector_profile
  ADD COLUMN confirmed_phone text,
  ADD COLUMN confirmed_email text,
  ADD COLUMN closed_at timestamptz;

-- A code that confirms a new email or phone for a Console user or a
-- tester. Kept in clear for a day so an IT admin can read it out.
CREATE TABLE contact_confirmation (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES app_user(id),
  collector_key uuid,
  channel text NOT NULL CHECK (channel IN ('email', 'phone')),
  value text NOT NULL,
  code text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  attempts integer NOT NULL DEFAULT 0,
  confirmed_at timestamptz,
  CHECK ((user_id IS NULL) <> (collector_key IS NULL))
);
CREATE INDEX contact_confirmation_open ON contact_confirmation (created_at)
  WHERE confirmed_at IS NULL;

-- A stakeholder asks for different areas; an IT admin decides.
CREATE TABLE area_request (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_user(id),
  area_ids uuid[] NOT NULL,
  reason text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  decided_at timestamptz,
  decided_by uuid REFERENCES app_user(id),
  approved boolean
);
CREATE INDEX area_request_open ON area_request (created_at) WHERE decided_at IS NULL;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['contact_confirmation', 'area_request'] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY admin ON %I USING (wc_is_admin()) WITH CHECK (wc_is_admin())', t);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE ON %I TO watercheck_app', t);
  END LOOP;
END $$;
