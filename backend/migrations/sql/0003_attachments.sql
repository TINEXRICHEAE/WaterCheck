-- P7 attachments: resumable chunked upload through the API (ADR-012).

ALTER TABLE attachment
  ADD COLUMN received_bytes int NOT NULL DEFAULT 0,
  ADD COLUMN rejected_reason text,
  ADD COLUMN installation_id uuid,
  ADD COLUMN created_by uuid,
  ADD COLUMN created_at_server timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN uploaded_at timestamptz,
  ADD CONSTRAINT attachment_owner_type CHECK (owner_type IN ('water_source', 'test_session')),
  ADD CONSTRAINT attachment_status CHECK (upload_status IN ('pending', 'uploaded', 'rejected')),
  ADD CONSTRAINT attachment_size CHECK (bytes > 0 AND bytes <= 1048576),
  ADD CONSTRAINT attachment_hash CHECK (sha256 ~ '^[0-9a-f]{64}$');

-- Bytes received so far, until `complete` moves them to object storage.
CREATE TABLE attachment_chunk (
  attachment_id uuid NOT NULL REFERENCES attachment(id),
  "offset" int NOT NULL,
  data bytea NOT NULL,
  PRIMARY KEY (attachment_id, "offset")
);

-- An attachment is visible with its owner (a source or a test session).
CREATE FUNCTION wc_attachment_visible(owner_type text, owner_id uuid) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT CASE owner_type
    WHEN 'water_source' THEN EXISTS (SELECT 1 FROM water_source s WHERE s.id = owner_id)
    WHEN 'test_session' THEN EXISTS (SELECT 1 FROM test_session t WHERE t.id = owner_id)
    ELSE false
  END
$$;

DROP POLICY admin ON attachment;
CREATE POLICY owner ON attachment
  USING (wc_is_admin() OR wc_attachment_visible(owner_type, owner_id))
  WITH CHECK (wc_is_admin() OR wc_attachment_visible(owner_type, owner_id));

ALTER TABLE attachment_chunk ENABLE ROW LEVEL SECURITY;
CREATE POLICY owner ON attachment_chunk
  USING (EXISTS (SELECT 1 FROM attachment a WHERE a.id = attachment_id));

GRANT SELECT, INSERT, DELETE ON attachment_chunk TO watercheck_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO watercheck_app;
