-- Unfinished forms kept on the server (2026-11-09), and research records
-- corrected or done again by their collector (ADR-034).

-- A record that replaces an earlier one. The earlier one is kept as made;
-- analysis counts the newest.
ALTER TABLE research.record
  ADD COLUMN replaces uuid REFERENCES research.record(id),
  ADD COLUMN replace_kind text CHECK (replace_kind IN ('correction', 'retake')),
  ADD COLUMN replace_reason text,
  ADD CONSTRAINT record_replacement_complete CHECK (
    (replaces IS NULL AND replace_kind IS NULL AND replace_reason IS NULL)
    OR (replaces IS NOT NULL AND replace_kind IS NOT NULL
        AND length(btrim(replace_reason)) BETWEEN 1 AND 500)
  );
CREATE INDEX record_replaces ON research.record (replaces) WHERE replaces IS NOT NULL;

-- The latest copy of each unfinished form. Browsers may clear what a phone
-- keeps; this brings it back. Emptied when finished or discarded, so
-- answers are never held twice.
CREATE TABLE research.draft (
  id uuid PRIMARY KEY,
  form_id uuid NOT NULL,
  form_version integer NOT NULL,
  number text CHECK (number IS NULL OR length(number) <= 60),
  collector_key uuid NOT NULL,
  installation_id uuid REFERENCES installation(id),
  answers jsonb NOT NULL,
  media jsonb NOT NULL DEFAULT '{}',
  started_at timestamptz NOT NULL,
  updated_at timestamptz NOT NULL,
  lat double precision,
  lon double precision,
  accuracy_m real,
  altitude_m real,
  location_source text,
  replaces uuid REFERENCES research.record(id),
  replace_kind text CHECK (replace_kind IN ('correction', 'retake')),
  replace_reason text CHECK (replace_reason IS NULL OR length(replace_reason) <= 500),
  created_at_server timestamptz NOT NULL DEFAULT now(),
  closed_at timestamptz,
  closed_why text CHECK (closed_why IN ('finished', 'discarded')),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL,
  FOREIGN KEY (form_id, form_version) REFERENCES research.form_version(form_id, version),
  CHECK ((lat IS NULL) = (lon IS NULL)),
  CHECK (lat IS NULL OR (lat BETWEEN -90 AND 90 AND lon BETWEEN -180 AND 180))
);
CREATE INDEX draft_collector ON research.draft (collector_key) WHERE closed_at IS NULL;
CREATE INDEX draft_feed_idx ON research.draft (server_xid, server_seq);
CREATE TRIGGER draft_server_seq BEFORE INSERT OR UPDATE ON research.draft
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();

-- A collector's own, on the devices they are signed in on; not the team's:
-- an unfinished form is not yet a record.
ALTER TABLE research.draft ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.draft
  USING (collector_key IN (SELECT research.device_collectors()))
  WITH CHECK (collector_key IN (SELECT research.device_collectors()));
GRANT SELECT, INSERT, UPDATE ON research.draft TO watercheck_app;

-- Pictures taken while filling, kept with the unfinished form.
ALTER TABLE attachment DROP CONSTRAINT attachment_owner_type;
ALTER TABLE attachment ADD CONSTRAINT attachment_owner_type
  CHECK (owner_type IN ('water_source', 'test_session', 'research_record', 'research_draft'));

CREATE OR REPLACE FUNCTION wc_attachment_visible(owner_type text, owner_id uuid) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT CASE owner_type
    WHEN 'water_source' THEN EXISTS (SELECT 1 FROM water_source s WHERE s.id = owner_id)
    WHEN 'test_session' THEN EXISTS (SELECT 1 FROM test_session t WHERE t.id = owner_id)
    WHEN 'research_record' THEN EXISTS (SELECT 1 FROM research.record r WHERE r.id = owner_id)
    WHEN 'research_draft' THEN EXISTS (SELECT 1 FROM research.draft d WHERE d.id = owner_id)
    ELSE false
  END
$$;

-- Ends an unfinished form: its answers go; pictures in [keep] move to the
-- finished record, the others are marked removed as any removed picture is
-- (ADR-022). False if there was nothing of this device's to close.
CREATE FUNCTION research.close_draft(draft_id uuid, why text, keep text[]) RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, research AS $$
BEGIN
  UPDATE research.draft
     SET closed_at = now(), closed_why = why, answers = '{}', media = '{}'
   WHERE id = draft_id AND closed_at IS NULL
     AND collector_key IN (SELECT research.device_collectors());
  IF NOT FOUND THEN
    RETURN false;
  END IF;
  UPDATE attachment SET owner_type = 'research_record'
   WHERE owner_type = 'research_draft' AND owner_id = draft_id AND id::text = ANY(keep);
  UPDATE attachment
     SET removed_at = now(), removed_by_installation = wc_setting('app.installation_id')::uuid
   WHERE owner_type = 'research_draft' AND owner_id = draft_id AND removed_at IS NULL;
  RETURN true;
END $$;
GRANT EXECUTE ON FUNCTION research.close_draft(uuid, text, text[]) TO watercheck_app;
