-- Account security in the Console profile (2026-10-29): where a person is
-- signed in, and resetting a forgotten password with a code.

-- Each sign-in (a refresh-token family) keeps the browser or app it came
-- from and its latest address, so its owner can see and end it.
ALTER TABLE refresh_token
  ADD COLUMN user_agent text,
  ADD COLUMN ip inet,
  -- 'web' (the browser Console) or 'app' (Windows, Android).
  ADD COLUMN client text;
CREATE INDEX refresh_token_user_open ON refresh_token (user_id) WHERE revoked_at IS NULL;

-- A code to set a new password without the old one. Kept in clear (as
-- other codes) so an IT admin can read it out until email is set up;
-- emailed when it is.
CREATE TABLE password_reset (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_user(id),
  code text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  attempts integer NOT NULL DEFAULT 0,
  used_at timestamptz,
  ip inet
);
CREATE INDEX password_reset_open ON password_reset (user_id, created_at) WHERE used_at IS NULL;
ALTER TABLE password_reset ENABLE ROW LEVEL SECURITY;
CREATE POLICY auth ON password_reset USING (wc_auth_context() OR wc_is_admin())
  WITH CHECK (wc_auth_context() OR wc_is_admin());
GRANT SELECT, INSERT, UPDATE ON password_reset TO watercheck_app;
