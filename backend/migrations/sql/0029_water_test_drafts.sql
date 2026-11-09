-- Water tests in progress kept on the server (2026-11-10, ADR-034): the same
-- protection as research's unfinished forms.

CREATE TABLE water_test_draft (
  -- The id the test session will have once submitted.
  id uuid PRIMARY KEY,
  collector_key uuid NOT NULL,
  installation_id uuid REFERENCES installation(id),
  -- No foreign key: a source added offline may reach the server later.
  source_id uuid NOT NULL,
  -- What the test screens hold so far, readings included.
  state jsonb NOT NULL,
  media jsonb NOT NULL DEFAULT '{}',
  started_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz,
  closed_why text CHECK (closed_why IN ('finished', 'discarded')),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL
);
CREATE INDEX water_test_draft_feed_idx ON water_test_draft (server_xid, server_seq);
CREATE TRIGGER water_test_draft_server_seq BEFORE INSERT OR UPDATE ON water_test_draft
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();

-- A collector's own, on the devices they are signed in on.
ALTER TABLE water_test_draft ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON water_test_draft
  USING (collector_key IN (SELECT research.device_collectors()))
  WITH CHECK (collector_key IN (SELECT research.device_collectors()));
GRANT SELECT, INSERT, UPDATE ON water_test_draft TO watercheck_app;

ALTER TABLE attachment DROP CONSTRAINT attachment_owner_type;
ALTER TABLE attachment ADD CONSTRAINT attachment_owner_type CHECK (
  owner_type IN ('water_source', 'test_session', 'research_record', 'research_draft', 'water_draft')
);

CREATE OR REPLACE FUNCTION wc_attachment_visible(owner_type text, owner_id uuid) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT CASE owner_type
    WHEN 'water_source' THEN EXISTS (SELECT 1 FROM water_source s WHERE s.id = owner_id)
    WHEN 'test_session' THEN EXISTS (SELECT 1 FROM test_session t WHERE t.id = owner_id)
    WHEN 'research_record' THEN EXISTS (SELECT 1 FROM research.record r WHERE r.id = owner_id)
    WHEN 'research_draft' THEN EXISTS (SELECT 1 FROM research.draft d WHERE d.id = owner_id)
    WHEN 'water_draft' THEN EXISTS (SELECT 1 FROM water_test_draft d WHERE d.id = owner_id)
    ELSE false
  END
$$;

-- Ends a test in progress: what it held goes. Submitted, its pictures stay
-- with the test session of the same id; discarded, they are marked removed.
CREATE FUNCTION wc_close_water_draft(draft_id uuid, why text) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, research AS $$
BEGIN
  UPDATE water_test_draft
     SET closed_at = now(), closed_why = why, state = '{}', media = '{}'
   WHERE id = draft_id AND closed_at IS NULL
     AND collector_key IN (SELECT research.device_collectors());
  IF NOT FOUND THEN
    RETURN false;
  END IF;
  IF why = 'finished' THEN
    UPDATE attachment SET owner_type = 'test_session'
     WHERE owner_type = 'water_draft' AND owner_id = draft_id AND removed_at IS NULL;
  ELSE
    UPDATE attachment
       SET removed_at = now(), removed_by_installation = wc_setting('app.installation_id')::uuid
     WHERE owner_type = 'water_draft' AND owner_id = draft_id AND removed_at IS NULL;
  END IF;
  RETURN true;
END $$;
GRANT EXECUTE ON FUNCTION wc_close_water_draft(uuid, text) TO watercheck_app;
