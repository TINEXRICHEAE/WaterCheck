-- Archive (restorable soft delete, cascading) and change trails (the lead,
-- 2026-10-22; ADR-018).
--
-- Test records stay insert-only (SPEC §5.4), so an archive is not a flag on
-- the record: it is a mark here, and every read that lists records checks
-- it. Restoring clears the mark. Nothing is ever removed from the database.

CREATE TABLE archive_mark (
  entity text NOT NULL
    CHECK (entity IN ('installation', 'collector', 'water_source', 'test_session', 'alert')),
  record_id uuid NOT NULL,
  -- The area the record belongs to, so phones and stakeholders receive the
  -- marks for their own area (null: visible to IT admins only).
  village_id uuid REFERENCES admin_unit(id),
  archived boolean NOT NULL DEFAULT true,
  reason text NOT NULL,
  -- One archive action and everything it cascaded to share a batch, so a
  -- restore brings back exactly that.
  batch_id uuid NOT NULL,
  -- The record the admin chose (the rest of the batch followed from it).
  root boolean NOT NULL DEFAULT false,
  archived_by uuid NOT NULL REFERENCES app_user(id),
  archived_at timestamptz NOT NULL DEFAULT now(),
  restored_by uuid REFERENCES app_user(id),
  restored_at timestamptz,
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL,
  PRIMARY KEY (entity, record_id)
);
CREATE INDEX archive_mark_batch ON archive_mark(batch_id);
CREATE INDEX archive_mark_feed_idx ON archive_mark (server_xid, server_seq);
CREATE TRIGGER archive_mark_server_seq BEFORE INSERT OR UPDATE ON archive_mark
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();

ALTER TABLE archive_mark ENABLE ROW LEVEL SECURITY;
CREATE POLICY read ON archive_mark FOR SELECT
  USING (wc_is_admin() OR (village_id IS NOT NULL AND wc_in_scope(village_id)));
CREATE POLICY admin_insert ON archive_mark FOR INSERT WITH CHECK (wc_is_admin());
CREATE POLICY admin_update ON archive_mark FOR UPDATE USING (wc_is_admin());
GRANT SELECT, INSERT, UPDATE ON archive_mark TO watercheck_app;

-- Whether a record is archived; used by every listing query. Security
-- definer: a phone must be able to tell, even for marks outside its scope.
CREATE FUNCTION wc_archived(e text, id uuid) RETURNS boolean
  LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS
$$ SELECT EXISTS (
     SELECT 1 FROM archive_mark m WHERE m.entity = e AND m.record_id = id AND m.archived
   ) $$;
GRANT EXECUTE ON FUNCTION wc_archived(text, uuid) TO watercheck_app;

-- Field-level history of edits: who changed what from what to what, when.
CREATE TABLE change_trail (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity text NOT NULL CHECK (entity IN ('water_source', 'collector', 'installation')),
  record_id uuid NOT NULL,
  field text NOT NULL,
  old_value jsonb,
  new_value jsonb,
  reason text,
  village_id uuid REFERENCES admin_unit(id),
  actor_user_id uuid REFERENCES app_user(id),
  installation_id uuid REFERENCES installation(id),
  collector_key uuid,
  actor_name text,
  changed_at timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL
);
CREATE INDEX change_trail_record ON change_trail(entity, record_id, changed_at);
CREATE INDEX change_trail_feed_idx ON change_trail (server_xid, server_seq);
CREATE TRIGGER change_trail_server_seq BEFORE INSERT OR UPDATE ON change_trail
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();
CREATE TRIGGER change_trail_immutable BEFORE UPDATE OR DELETE ON change_trail
  FOR EACH ROW EXECUTE FUNCTION wc_immutable();

ALTER TABLE change_trail ENABLE ROW LEVEL SECURITY;
CREATE POLICY read ON change_trail FOR SELECT
  USING (wc_is_admin() OR (village_id IS NOT NULL AND wc_in_scope(village_id)));
-- Written by the server while it applies a phone's or a person's change.
CREATE POLICY append ON change_trail FOR INSERT WITH CHECK (true);
GRANT SELECT, INSERT ON change_trail TO watercheck_app;

-- The latest known details of each collector (they are people on a phone,
-- not accounts): for listing, archiving and the edit trail.
CREATE TABLE collector_profile (
  collector_key uuid PRIMARY KEY,
  installation_id uuid NOT NULL REFERENCES installation(id),
  snapshot jsonb NOT NULL,
  profile_version integer NOT NULL DEFAULT 1,
  first_seen_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE collector_profile ENABLE ROW LEVEL SECURITY;
CREATE POLICY read ON collector_profile FOR SELECT
  USING (wc_is_admin() OR wc_user_id() IS NOT NULL
         OR installation_id::text = wc_setting('app.installation_id'));
CREATE POLICY write ON collector_profile FOR INSERT
  WITH CHECK (installation_id::text = wc_setting('app.installation_id') OR wc_is_admin());
CREATE POLICY change ON collector_profile FOR UPDATE
  USING (installation_id::text = wc_setting('app.installation_id') OR wc_is_admin());
GRANT SELECT, INSERT, UPDATE ON collector_profile TO watercheck_app;

-- Who made a correction (a new result amending another): the person on the
-- phone at the time. Null for first results (the session says who).
ALTER TABLE test_result
  ADD COLUMN installation_id uuid REFERENCES installation(id),
  ADD COLUMN collector_key uuid,
  ADD COLUMN collector_snapshot jsonb;

-- A name the IT admin gives a phone ("Nalongo's phone").
ALTER TABLE installation ADD COLUMN label text;
