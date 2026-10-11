-- P9 stakeholder dashboard (ADR-014).

-- ---------------------------------------------- collector marks and flags
-- A stakeholder marks a collector "known" (or flags them), or flags one
-- suspicious submission (SPEC P9, §9.1 fake readings). Both sync to every
-- stakeholder device in the area.
ALTER TABLE collector_mark
  ADD COLUMN version int NOT NULL DEFAULT 1,
  ADD COLUMN server_seq bigint,
  ADD COLUMN server_xid xid8;
UPDATE collector_mark SET server_seq = nextval('change_seq'), server_xid = '1'::xid8;
ALTER TABLE collector_mark ALTER COLUMN server_seq SET NOT NULL,
  ALTER COLUMN server_xid SET NOT NULL;
CREATE TRIGGER collector_mark_server_seq BEFORE INSERT OR UPDATE ON collector_mark
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();
CREATE INDEX collector_mark_feed_idx ON collector_mark (server_xid, server_seq);

-- Marks follow the area: a stakeholder sees (and sets) marks only for
-- collectors who submitted in their area. Phones never see them.
DROP POLICY staff ON collector_mark;
CREATE POLICY area ON collector_mark
  USING (wc_is_admin() OR (wc_user_id() IS NOT NULL AND EXISTS (
    SELECT 1 FROM test_session t WHERE t.collector_key = collector_mark.collector_key)))
  WITH CHECK (wc_is_admin() OR (wc_user_id() IS NOT NULL AND EXISTS (
    SELECT 1 FROM test_session t WHERE t.collector_key = collector_mark.collector_key)));

CREATE TABLE submission_flag (
  id uuid PRIMARY KEY,
  result_id uuid NOT NULL REFERENCES test_result(id),
  reason text NOT NULL CHECK (length(reason) BETWEEN 1 AND 500),
  flagged_by uuid NOT NULL REFERENCES app_user(id),
  created_at_device timestamptz,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL
);
CREATE TRIGGER submission_flag_server_seq BEFORE INSERT OR UPDATE ON submission_flag
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();
CREATE INDEX submission_flag_feed_idx ON submission_flag (server_xid, server_seq);
CREATE TRIGGER submission_flag_immutable BEFORE UPDATE OR DELETE ON submission_flag
  FOR EACH ROW EXECUTE FUNCTION wc_immutable();

ALTER TABLE submission_flag ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON submission_flag
  USING (wc_is_admin() OR (wc_user_id() IS NOT NULL
         AND EXISTS (SELECT 1 FROM test_result r WHERE r.id = result_id)))
  WITH CHECK (EXISTS (SELECT 1 FROM test_result r WHERE r.id = result_id)
              AND wc_user_id() IS NOT NULL);

-- ------------------------------------------- notification preferences
-- In-app notifications cannot be switched off (they are the record).
ALTER TABLE app_user
  ADD COLUMN notify_email boolean NOT NULL DEFAULT true,
  ADD COLUMN notify_push boolean NOT NULL DEFAULT true,
  ADD COLUMN notify_sms boolean NOT NULL DEFAULT true;

GRANT SELECT, INSERT ON submission_flag TO watercheck_app;
