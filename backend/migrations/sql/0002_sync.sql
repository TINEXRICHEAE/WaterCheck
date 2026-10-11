-- P6 sync engine (SPEC §8, ADR-011).

-- ------------------------------------------- commit-order-safe change feed
-- `server_seq` is assigned when a row is written, not when its transaction
-- commits. A transaction that took seq 10 can commit after one that took 11.
-- A puller that already moved past 11 would then miss row 10 for good. Every
-- synced row therefore also records its writer's transaction ID.
-- `pg_snapshot_xmin()` gives the oldest transaction that may still commit.
-- A pull only returns rows written before it, ordered by (server_xid,
-- server_seq). Nothing can appear behind the cursor later.

-- Admin units become part of the reference stream.
ALTER TABLE admin_unit ADD COLUMN server_seq bigint;
UPDATE admin_unit SET server_seq = nextval('change_seq');
ALTER TABLE admin_unit ALTER COLUMN server_seq SET NOT NULL;
CREATE TRIGGER admin_unit_server_seq BEFORE INSERT OR UPDATE ON admin_unit
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();

CREATE OR REPLACE FUNCTION wc_set_server_seq() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.server_seq := nextval('change_seq');
  NEW.server_xid := pg_current_xact_id();
  RETURN NEW;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'config_document','parameter_category','parameter_definition','tester_profile',
    'reference_standard','response_card','water_source','sanitary_inspection',
    'calibration','test_session','test_result','reading','classification','alert',
    'alert_event','attachment','admin_unit'
  ] LOOP
    -- Existing rows count as committed long ago.
    EXECUTE format('ALTER TABLE %I ADD COLUMN server_xid xid8 NOT NULL DEFAULT ''1''::xid8', t);
    EXECUTE format('ALTER TABLE %I ALTER COLUMN server_xid DROP DEFAULT', t);
    EXECUTE format('CREATE INDEX %I ON %I (server_xid, server_seq)', t || '_feed_idx', t);
  END LOOP;
END $$;

-- Tester profile parameters live in a child table: a change there must move
-- the parent profile forward in the feed.
CREATE FUNCTION wc_touch_tester_profile() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE tester_profile SET name = name
    WHERE id = COALESCE(NEW.tester_profile_id, OLD.tester_profile_id);
  RETURN NULL;
END $$;
CREATE TRIGGER tester_profile_parameter_touch
  AFTER INSERT OR UPDATE OR DELETE ON tester_profile_parameter
  FOR EACH ROW EXECUTE FUNCTION wc_touch_tester_profile();

-- --------------------------------------------------------------- helpers
-- True when `unit` is `area` or lies below it in the admin hierarchy.
CREATE FUNCTION wc_under(unit uuid, area uuid) RETURNS boolean LANGUAGE sql STABLE AS $$
  WITH RECURSIVE up(id, parent_id) AS (
    SELECT a.id, a.parent_id FROM admin_unit a WHERE a.id = unit
    UNION ALL
    SELECT a.id, a.parent_id FROM admin_unit a JOIN up ON a.id = up.parent_id
  )
  SELECT EXISTS (SELECT 1 FROM up WHERE up.id = area)
$$;

-- ------------------------------------------------------------- conflicts
-- Collect and Console record conflicts during a push; stakeholders review
-- the ones for sources in their area (SPEC §8.4).
DROP POLICY admin ON sync_conflict;
CREATE POLICY record ON sync_conflict FOR INSERT
  WITH CHECK (wc_is_admin() OR wc_user_id() IS NOT NULL
              OR wc_setting('app.installation_id') IS NOT NULL);
CREATE POLICY review ON sync_conflict FOR SELECT USING (
  wc_is_admin() OR (
    entity = 'water_source'
    AND EXISTS (SELECT 1 FROM water_source s WHERE s.id = entity_id)
    AND wc_user_id() IS NOT NULL
  )
);
CREATE POLICY resolve ON sync_conflict FOR UPDATE USING (
  wc_is_admin() OR (
    entity = 'water_source'
    AND EXISTS (SELECT 1 FROM water_source s WHERE s.id = entity_id)
    AND wc_user_id() IS NOT NULL
  )
);

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO watercheck_app;
