-- Recovery codes (ADR-020): an IT admin, or a stakeholder whose areas the
-- collector works in, issues a one-time code; on any phone the collector
-- enters it and their details come back under the same collector key.
CREATE TABLE collector_recovery_code (
  id uuid PRIMARY KEY,
  code_hash text NOT NULL UNIQUE,
  collector_key uuid NOT NULL REFERENCES collector_profile(collector_key),
  created_by uuid NOT NULL REFERENCES app_user(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  used_by_installation uuid REFERENCES installation(id)
);
CREATE INDEX collector_recovery_code_key ON collector_recovery_code(collector_key);
ALTER TABLE collector_recovery_code ENABLE ROW LEVEL SECURITY;
-- Only the server's own (system) transactions touch codes; the API checks
-- who may issue or redeem them.
CREATE POLICY admin ON collector_recovery_code USING (wc_is_admin())
  WITH CHECK (wc_is_admin());
GRANT SELECT, INSERT, UPDATE ON collector_recovery_code TO watercheck_app;

-- A collector may now work on several phones: any phone keeps their latest
-- details (installation_id stays the first phone that sent them).
DROP POLICY read ON collector_profile;
DROP POLICY change ON collector_profile;
CREATE POLICY read ON collector_profile FOR SELECT
  USING (wc_is_admin() OR wc_user_id() IS NOT NULL
         OR wc_setting('app.installation_id') IS NOT NULL);
CREATE POLICY change ON collector_profile FOR UPDATE
  USING (wc_is_admin() OR wc_setting('app.installation_id') IS NOT NULL);
