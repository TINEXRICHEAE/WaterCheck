-- Testers, not devices, are assigned to areas (ADR-024). Any device opens
-- Collect and registers itself; an activation code now assigns a tester
-- (collector) to an area officially. A tester signs in on other devices
-- with a recovery code (from an admin, or made on their own device), and
-- every device they use, and every sign-in, is recorded.

-- Devices register themselves: no area until a tester on it is assigned.
ALTER TABLE installation ALTER COLUMN admin_unit_id DROP NOT NULL;
ALTER TABLE installation
  ADD COLUMN registered_via text NOT NULL DEFAULT 'code'
    CHECK (registered_via IN ('code', 'self')),
  ADD COLUMN device_label text,
  -- Hash of the address that registered it: limits mass sign-ups.
  ADD COLUMN registered_from text;
CREATE INDEX installation_registered_from ON installation (registered_from, activated_at)
  WHERE registered_via = 'self';
-- A device without an area still sees itself, and IT admins see it.
DROP POLICY area ON installation;
CREATE POLICY area ON installation
  USING (wc_auth_context() OR wc_is_admin()
         OR id::text = wc_setting('app.installation_id')
         OR wc_in_scope(admin_unit_id));

-- A tester officially covering an area, from an assignment code or given
-- by an IT admin. Ending it keeps the record.
CREATE TABLE collector_assignment (
  id uuid PRIMARY KEY,
  collector_key uuid NOT NULL,
  admin_unit_id uuid NOT NULL REFERENCES admin_unit(id),
  activation_code_id uuid REFERENCES activation_code(id),
  installation_id uuid REFERENCES installation(id),
  assigned_by uuid REFERENCES app_user(id),
  assigned_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  ended_by uuid REFERENCES app_user(id)
);
CREATE UNIQUE INDEX collector_assignment_current
  ON collector_assignment (collector_key, admin_unit_id) WHERE ended_at IS NULL;
CREATE INDEX collector_assignment_key ON collector_assignment (collector_key);

-- The devices a tester uses. Signed out here: their records from that
-- device are refused, and the device drops them.
CREATE TABLE collector_device (
  collector_key uuid NOT NULL,
  installation_id uuid NOT NULL REFERENCES installation(id),
  signed_in_via text NOT NULL
    CHECK (signed_in_via IN ('created', 'admin_code', 'own_code')),
  first_seen_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  signed_out_at timestamptz,
  signed_out_by_request uuid,
  PRIMARY KEY (collector_key, installation_id)
);

-- Every sign-in with a recovery code, with the device (the trail).
CREATE TABLE collector_signin (
  id uuid PRIMARY KEY,
  collector_key uuid NOT NULL,
  installation_id uuid NOT NULL REFERENCES installation(id),
  via text NOT NULL CHECK (via IN ('admin_code', 'own_code')),
  platform text,
  at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX collector_signin_key ON collector_signin (collector_key, at);

-- Recovery codes made on the tester's own device: no expiry until used.
ALTER TABLE collector_recovery_code
  ALTER COLUMN created_by DROP NOT NULL,
  ALTER COLUMN expires_at DROP NOT NULL,
  ADD COLUMN issued_by_installation uuid REFERENCES installation(id),
  ADD CONSTRAINT collector_recovery_code_issuer
    CHECK (created_by IS NOT NULL OR issued_by_installation IS NOT NULL);

-- Confirming a tester's request (signing other devices out). Until email
-- and SMS are set up the code is shown to IT admins on the tester's page,
-- who pass it on; it is kept in clear for that reason, for one day.
CREATE TABLE collector_confirmation (
  id uuid PRIMARY KEY,
  collector_key uuid NOT NULL,
  purpose text NOT NULL CHECK (purpose IN ('sign_out_devices')),
  installation_ids uuid[] NOT NULL,
  code text NOT NULL,
  requested_by_installation uuid NOT NULL REFERENCES installation(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  attempts integer NOT NULL DEFAULT 0,
  confirmed_at timestamptz
);
CREATE INDEX collector_confirmation_key ON collector_confirmation (collector_key, created_at);

-- Only the server's own (system) transactions touch these; the API checks
-- who may read or change them.
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'collector_assignment', 'collector_device', 'collector_signin', 'collector_confirmation'
  ] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
    EXECUTE format('CREATE POLICY admin ON %I USING (wc_is_admin()) WITH CHECK (wc_is_admin())', t);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE ON %I TO watercheck_app', t);
  END LOOP;
END $$;

-- A device keeps its own row current while it sends a tester's records.
CREATE POLICY own_device ON collector_device
  USING (installation_id::text = wc_setting('app.installation_id'))
  WITH CHECK (installation_id::text = wc_setting('app.installation_id'));

-- Devices in use before: each tester seen on a device was "created" there.
INSERT INTO collector_device (collector_key, installation_id, signed_in_via, first_seen_at, last_seen_at)
SELECT collector_key, installation_id, 'created', min(at), max(at) FROM (
  SELECT collector_key, installation_id, tested_at_device AS at FROM test_session
  UNION ALL SELECT collector_key, installation_id, created_at_device FROM water_source
) s WHERE collector_key IS NOT NULL AND installation_id IS NOT NULL AND at IS NOT NULL
GROUP BY collector_key, installation_id
ON CONFLICT DO NOTHING;
