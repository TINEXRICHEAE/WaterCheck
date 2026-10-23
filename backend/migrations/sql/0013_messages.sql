-- Conversations in the app (ADR-022): threads on a test, a source, a
-- collector or an area, between collectors (Collect) and stakeholders and
-- IT admins (Console). No SMS, email or calls yet. Messages are
-- insert-only, like test records.

CREATE TABLE message (
  id uuid PRIMARY KEY,
  subject_type text NOT NULL CHECK (subject_type IN ('test', 'source', 'collector', 'area')),
  -- A test session, a water source, a collector key or an admin unit.
  subject_id uuid NOT NULL,
  body text NOT NULL CHECK (length(btrim(body)) BETWEEN 1 AND 2000),
  -- The area the thread belongs to, set by the server from the subject, so
  -- devices and stakeholders there receive it.
  village_id uuid REFERENCES admin_unit(id),
  author_user_id uuid REFERENCES app_user(id),
  installation_id uuid REFERENCES installation(id),
  collector_key uuid,
  collector_snapshot jsonb,
  author_name text,
  written_at_device timestamptz,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL
);
CREATE INDEX message_subject ON message(subject_type, subject_id, created_at_server);
CREATE INDEX message_feed_idx ON message (server_xid, server_seq);
CREATE TRIGGER message_server_seq BEFORE INSERT OR UPDATE ON message
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();
CREATE TRIGGER message_immutable BEFORE UPDATE OR DELETE ON message
  FOR EACH ROW EXECUTE FUNCTION wc_immutable();

ALTER TABLE message ENABLE ROW LEVEL SECURITY;
CREATE POLICY read ON message FOR SELECT
  USING (wc_is_admin() OR (village_id IS NOT NULL AND wc_in_scope(village_id)));
CREATE POLICY write ON message FOR INSERT
  WITH CHECK (wc_is_admin() OR (village_id IS NOT NULL AND wc_in_scope(village_id)));
GRANT SELECT, INSERT ON message TO watercheck_app;
