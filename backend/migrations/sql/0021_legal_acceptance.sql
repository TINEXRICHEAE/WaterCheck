-- Every acceptance of a side's Terms of Use and Privacy Policy (ADR-031),
-- kept for accountability: who (a Console account or a tester profile),
-- which side and version, how (sign-up, joining from the other side, the
-- one-time prompt, or a profile on a phone), from where and when. Rows
-- are never changed or removed.
CREATE TABLE legal_acceptance (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  side text NOT NULL CHECK (side IN ('water', 'research')),
  version integer NOT NULL CHECK (version > 0),
  -- Both documents are ticked together; kept apart for the record.
  terms_accepted boolean NOT NULL DEFAULT true,
  privacy_accepted boolean NOT NULL DEFAULT true,
  user_id uuid REFERENCES app_user(id),
  collector_key uuid,
  how text NOT NULL CHECK (how IN ('signup', 'join', 'prompt', 'profile')),
  installation_id uuid REFERENCES installation(id),
  ip inet,
  accepted_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((user_id IS NULL) <> (collector_key IS NULL))
);
CREATE INDEX legal_acceptance_user ON legal_acceptance (user_id, accepted_at);
CREATE INDEX legal_acceptance_collector ON legal_acceptance (collector_key, accepted_at);
CREATE TRIGGER legal_acceptance_immutable BEFORE UPDATE OR DELETE ON legal_acceptance
  FOR EACH ROW EXECUTE FUNCTION wc_immutable();

ALTER TABLE legal_acceptance ENABLE ROW LEVEL SECURITY;
-- IT admins read them; the server writes them (system and sign-in work).
CREATE POLICY read ON legal_acceptance FOR SELECT USING (wc_is_admin());
CREATE POLICY write ON legal_acceptance FOR INSERT
  WITH CHECK (wc_is_admin() OR wc_auth_context());
GRANT SELECT, INSERT ON legal_acceptance TO watercheck_app;

-- A tester accepted on a phone: recorded when their profile reaches the
-- server with a higher accepted version than before.
CREATE FUNCTION record_collector_acceptance(collector uuid, side_ text, version_ integer,
                                            installation uuid)
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  INSERT INTO legal_acceptance (side, version, collector_key, how, installation_id)
  VALUES (side_, version_, collector, 'profile', installation)
$$;
GRANT EXECUTE ON FUNCTION record_collector_acceptance(uuid, text, integer, uuid)
  TO watercheck_app;

-- The same for accounts that accepted before this table: one row from what
-- the account recorded.
INSERT INTO legal_acceptance (side, version, user_id, how, accepted_at)
SELECT s.key, s.value::int, u.id, 'prompt', coalesce(u.legal_accepted_at, now())
FROM app_user u, jsonb_each_text(u.legal) s
WHERE s.value ~ '^[0-9]+$' AND s.value::int > 0;
