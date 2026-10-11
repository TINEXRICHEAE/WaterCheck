-- WaterCheck initial schema (SPEC §5.3 + ADR-005 + errata G2–G7, ADR-009).
-- Runs as the database owner. The API connects as `watercheck_api`, a member
-- of `watercheck_app`, which never owns tables and cannot bypass RLS.

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'watercheck_app') THEN
    CREATE ROLE watercheck_app NOLOGIN NOBYPASSRLS;
  END IF;
END $$;

CREATE SEQUENCE change_seq;

-- ------------------------------------------------------------ scope helpers
-- Request context, set with SET LOCAL by the API in every transaction.
CREATE FUNCTION wc_setting(name text) RETURNS text LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting(name, true), '') $$;

CREATE FUNCTION wc_is_admin() RETURNS boolean LANGUAGE sql STABLE AS
$$ SELECT coalesce(wc_setting('app.is_admin'), 'false')::boolean $$;

CREATE FUNCTION wc_auth_context() RETURNS boolean LANGUAGE sql STABLE AS
$$ SELECT coalesce(wc_setting('app.auth_context'), 'false')::boolean $$;

CREATE FUNCTION wc_user_id() RETURNS uuid LANGUAGE sql STABLE AS
$$ SELECT wc_setting('app.user_id')::uuid $$;

CREATE FUNCTION wc_scope() RETURNS uuid[] LANGUAGE sql STABLE AS
$$ SELECT coalesce(wc_setting('app.scope_units'), '{}')::uuid[] $$;

-- ------------------------------------------------------------------ areas
CREATE TABLE admin_unit (
  id uuid PRIMARY KEY,
  level text NOT NULL CHECK (level IN ('country','district','subcounty','parish','village')),
  name text NOT NULL,
  code text UNIQUE NOT NULL,
  parent_id uuid REFERENCES admin_unit(id),
  geom geometry(MultiPolygon, 4326)
);

-- True when `unit` is one of the scope units or lies below one of them.
CREATE FUNCTION wc_in_scope(unit uuid) RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT wc_is_admin() OR EXISTS (
    WITH RECURSIVE up(id, parent_id) AS (
      SELECT a.id, a.parent_id FROM admin_unit a WHERE a.id = unit
      UNION ALL
      SELECT a.id, a.parent_id FROM admin_unit a JOIN up ON a.id = up.parent_id
    )
    SELECT 1 FROM up WHERE up.id = ANY (wc_scope())
  )
$$;

-- --------------------------------------------------------- people & access
CREATE TABLE app_user (
  id uuid PRIMARY KEY,
  username text UNIQUE NOT NULL,
  full_name text NOT NULL,
  organisation text,
  position text,
  phone text,
  email text,
  password_hash text NOT NULL,
  must_change_password boolean NOT NULL DEFAULT true,
  role text NOT NULL CHECK (role IN ('stakeholder','it_admin')),
  is_active boolean NOT NULL DEFAULT true,
  failed_attempts int NOT NULL DEFAULT 0,
  locked_until timestamptz,
  last_sign_in_at timestamptz,
  password_changed_at timestamptz,
  created_by uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE responsibility (code text PRIMARY KEY, name text NOT NULL);

CREATE TABLE user_responsibility (
  user_id uuid REFERENCES app_user(id),
  responsibility_code text REFERENCES responsibility(code),
  PRIMARY KEY (user_id, responsibility_code)
);

CREATE TABLE user_scope (
  user_id uuid REFERENCES app_user(id),
  admin_unit_id uuid REFERENCES admin_unit(id),
  PRIMARY KEY (user_id, admin_unit_id)
);

-- Permissions held as data (SPEC §7); the two system roles are fixed.
CREATE TABLE role_permission (
  role text NOT NULL CHECK (role IN ('stakeholder','it_admin')),
  permission text NOT NULL,
  PRIMARY KEY (role, permission)
);

CREATE TABLE refresh_token (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES app_user(id),
  family_id uuid NOT NULL,
  token_hash text UNIQUE NOT NULL,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  used_at timestamptz,
  revoked_at timestamptz
);
CREATE INDEX refresh_token_family ON refresh_token(family_id);

CREATE TABLE activation_code (
  id uuid PRIMARY KEY,
  code_hash text UNIQUE NOT NULL,
  admin_unit_id uuid NOT NULL REFERENCES admin_unit(id),
  expires_at timestamptz NOT NULL,
  max_installations int NOT NULL DEFAULT 5 CHECK (max_installations > 0),
  used_count int NOT NULL DEFAULT 0,
  created_by uuid REFERENCES app_user(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz
);

CREATE TABLE installation (
  id uuid PRIMARY KEY,
  activation_code_id uuid REFERENCES activation_code(id),
  admin_unit_id uuid NOT NULL REFERENCES admin_unit(id),
  secret_encrypted text NOT NULL,
  platform text,
  app_version text,
  activated_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz,
  revoked_at timestamptz
);

-- Replay protection for signed installation requests.
CREATE TABLE request_nonce (
  installation_id uuid NOT NULL REFERENCES installation(id),
  signature text NOT NULL,
  seen_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (installation_id, signature)
);

CREATE TABLE alert_routing_rule (
  trigger_rule text NOT NULL,
  responsibility_code text REFERENCES responsibility(code),
  PRIMARY KEY (trigger_rule, responsibility_code)
);

-- --------------------------------------------------------- reference data
CREATE TABLE config_document (
  key text PRIMARY KEY,
  document jsonb NOT NULL,
  version int NOT NULL,
  server_seq bigint NOT NULL
);

CREATE TABLE parameter_category (
  code text PRIMARY KEY,
  name text NOT NULL,
  display_order int NOT NULL,
  server_seq bigint NOT NULL
);

CREATE TABLE parameter_definition (
  code text PRIMARY KEY,
  name text NOT NULL,
  category_code text NOT NULL REFERENCES parameter_category(code),
  default_unit text NOT NULL,
  value_type text NOT NULL CHECK (value_type IN ('numeric','presence','acceptability','text')),
  is_core boolean NOT NULL DEFAULT false,
  display_order int NOT NULL DEFAULT 0,
  plausible_min numeric,
  plausible_max numeric,
  is_custom boolean NOT NULL DEFAULT false,
  created_by uuid,
  installation_id uuid,
  collector_key uuid,
  collector_snapshot jsonb,
  scope_admin_unit_id uuid REFERENCES admin_unit(id),
  review_status text NOT NULL DEFAULT 'approved',
  merged_into text REFERENCES parameter_definition(code),
  server_seq bigint NOT NULL
);

CREATE TABLE tester_profile (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  manufacturer text,
  model text,
  tds_factor numeric,
  created_by uuid,
  installation_id uuid,
  server_seq bigint NOT NULL
);

CREATE TABLE tester_profile_parameter (
  tester_profile_id uuid REFERENCES tester_profile(id),
  parameter_code text REFERENCES parameter_definition(code),
  unit text NOT NULL,
  PRIMARY KEY (tester_profile_id, parameter_code)
);

CREATE TABLE reference_standard (
  id uuid PRIMARY KEY,
  code text NOT NULL,
  title text NOT NULL,
  version int NOT NULL,
  based_on_id uuid REFERENCES reference_standard(id),
  is_custom boolean NOT NULL DEFAULT false,
  custom_reason text,
  is_provisional boolean NOT NULL DEFAULT false,
  created_by uuid,
  installation_id uuid,
  collector_key uuid,
  collector_snapshot jsonb,
  published_at timestamptz,
  document jsonb NOT NULL,
  server_seq bigint NOT NULL,
  CHECK (NOT is_custom OR (custom_reason IS NOT NULL AND based_on_id IS NOT NULL))
);

CREATE TABLE parameter_limit (
  standard_id uuid REFERENCES reference_standard(id),
  parameter_code text NOT NULL REFERENCES parameter_definition(code),
  unit text NOT NULL,
  min_value numeric,
  max_value numeric,
  must_be_absent boolean NOT NULL DEFAULT false,
  must_be_acceptable boolean NOT NULL DEFAULT false,
  note text,
  source text,
  PRIMARY KEY (standard_id, parameter_code)
);

-- Default profile per area (D11, F-ADM-2); falls back to rules.json.
CREATE TABLE area_default_profile (
  admin_unit_id uuid PRIMARY KEY REFERENCES admin_unit(id),
  standard_id uuid NOT NULL REFERENCES reference_standard(id),
  set_by uuid REFERENCES app_user(id),
  set_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE response_card (
  id uuid PRIMARY KEY,
  trigger_rule text NOT NULL,
  audience text NOT NULL,
  version int NOT NULL,
  content jsonb NOT NULL,
  server_seq bigint NOT NULL
);

-- ------------------------------------------------------------ field data
CREATE TABLE water_source (
  id uuid PRIMARY KEY,
  village_id uuid NOT NULL REFERENCES admin_unit(id),
  code text NOT NULL,
  name text,
  source_type text NOT NULL,
  location geography(Point, 4326),
  location_accuracy_m real,
  households_served int,
  functional_status text NOT NULL DEFAULT 'functional',
  is_active boolean NOT NULL DEFAULT true,
  version int NOT NULL DEFAULT 1,
  created_by uuid,
  installation_id uuid,
  collector_key uuid,
  collector_snapshot jsonb,
  created_at_device timestamptz,
  updated_at_device timestamptz,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  updated_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  UNIQUE (village_id, code)
);
CREATE INDEX water_source_village ON water_source(village_id);
CREATE INDEX water_source_location ON water_source USING gist(location);

-- Conflicts kept for stakeholders to resolve (SPEC §8.4).
CREATE TABLE sync_conflict (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity text NOT NULL,
  entity_id uuid NOT NULL,
  field text NOT NULL,
  server_value jsonb,
  client_value jsonb,
  installation_id uuid,
  user_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  resolved_by uuid
);

CREATE TABLE sanitary_inspection (
  id uuid PRIMARY KEY,
  source_id uuid NOT NULL REFERENCES water_source(id),
  answers jsonb NOT NULL,
  inspected_at_device timestamptz NOT NULL,
  installation_id uuid,
  collector_key uuid,
  collector_snapshot jsonb,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL
);

CREATE TABLE calibration (
  id uuid PRIMARY KEY,
  tester_serial text,
  tester_profile_id uuid REFERENCES tester_profile(id),
  reference_standard_id uuid NOT NULL REFERENCES reference_standard(id),
  buffers jsonb,
  passed boolean NOT NULL,
  installation_id uuid NOT NULL REFERENCES installation(id),
  collector_key uuid,
  collector_snapshot jsonb,
  performed_at_device timestamptz NOT NULL,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL
);

CREATE TABLE test_session (
  id uuid PRIMARY KEY,
  source_id uuid NOT NULL REFERENCES water_source(id),
  installation_id uuid NOT NULL REFERENCES installation(id),
  collector_key uuid NOT NULL,
  collector_snapshot jsonb NOT NULL,
  calibration_id uuid REFERENCES calibration(id),
  tester_profile_id uuid REFERENCES tester_profile(id),
  reference_standard_id uuid NOT NULL REFERENCES reference_standard(id),
  calibrated boolean NOT NULL,
  location geography(Point, 4326),
  location_accuracy_m real,
  distance_from_source_m real,
  distance_override_reason text,
  notes text,
  tested_at_device timestamptz NOT NULL,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  clock_flags text[] NOT NULL DEFAULT '{}',
  server_seq bigint NOT NULL
);
CREATE INDEX test_session_source_time ON test_session(source_id, tested_at_device DESC);
CREATE INDEX test_session_collector ON test_session(collector_key);

-- ADR-005 §1: each result owns its readings; amendments are new results.
CREATE TABLE test_result (
  id uuid PRIMARY KEY,
  session_id uuid NOT NULL REFERENCES test_session(id),
  overall text NOT NULL CHECK (overall IN ('safe','unsafe','inconclusive')),
  standard_id uuid NOT NULL REFERENCES reference_standard(id),
  computed_by text NOT NULL DEFAULT 'device' CHECK (computed_by IN ('device','server')),
  retest_of uuid REFERENCES test_result(id),
  amendment_of uuid REFERENCES test_result(id),
  amendment_reason text,
  flags text[] NOT NULL DEFAULT '{}',
  limitation_code text,
  created_at_device timestamptz NOT NULL,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  CHECK (amendment_of IS NULL OR amendment_reason IS NOT NULL)
);
CREATE UNIQUE INDEX test_result_one_original ON test_result(session_id) WHERE amendment_of IS NULL;

CREATE TABLE reading (
  id uuid PRIMARY KEY,
  session_id uuid NOT NULL REFERENCES test_session(id),
  result_id uuid NOT NULL REFERENCES test_result(id),
  parameter_code text NOT NULL REFERENCES parameter_definition(code),
  value numeric,
  detected boolean,
  acceptable boolean,
  value_text text,
  unit text,
  result text NOT NULL CHECK (result IN ('ok','low','high','detected','unacceptable','invalid','not_assessed')),
  is_derived boolean NOT NULL DEFAULT false,
  source_device text,
  server_seq bigint NOT NULL
);
CREATE INDEX reading_result ON reading(result_id);

-- ADR-005 §2: server and alternative-profile classifications.
CREATE TABLE classification (
  result_id uuid NOT NULL REFERENCES test_result(id),
  standard_id uuid NOT NULL REFERENCES reference_standard(id),
  computed_by text NOT NULL CHECK (computed_by IN ('device','server')),
  overall text NOT NULL CHECK (overall IN ('safe','unsafe','inconclusive')),
  reading_results jsonb NOT NULL,
  flags text[] NOT NULL DEFAULT '{}',
  limitation_code text,
  computed_at timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  PRIMARY KEY (result_id, standard_id, computed_by)
);

CREATE TABLE alert (
  id uuid PRIMARY KEY,
  source_id uuid NOT NULL REFERENCES water_source(id),
  trigger_result_id uuid REFERENCES test_result(id),
  trigger_rule text NOT NULL,
  severity text NOT NULL DEFAULT 'high' CHECK (severity IN ('critical','high','medium','low')),
  status text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','acknowledged','action_in_progress','closed','false_alarm')),
  opened_at timestamptz NOT NULL,
  acknowledged_at timestamptz,
  closed_at timestamptz,
  linked_alert_id uuid REFERENCES alert(id),
  installation_id uuid,
  collector_key uuid,
  collector_snapshot jsonb,
  version int NOT NULL DEFAULT 1,
  server_seq bigint NOT NULL,
  UNIQUE (trigger_result_id, trigger_rule)
);

CREATE TABLE alert_event (
  id uuid PRIMARY KEY,
  alert_id uuid NOT NULL REFERENCES alert(id),
  actor_id uuid REFERENCES app_user(id),
  installation_id uuid,
  collector_key uuid,
  collector_snapshot jsonb,
  event_type text NOT NULL,
  note text,
  occurred_at_device timestamptz,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL
);

CREATE TABLE attachment (
  id uuid PRIMARY KEY,
  owner_type text NOT NULL,
  owner_id uuid NOT NULL,
  object_key text,
  sha256 text NOT NULL,
  bytes int NOT NULL,
  mime text NOT NULL,
  upload_status text NOT NULL DEFAULT 'pending',
  server_seq bigint NOT NULL
);

-- Stakeholder marks on collectors (P9: "known" / flagged submissions).
CREATE TABLE collector_mark (
  collector_key uuid PRIMARY KEY,
  status text NOT NULL CHECK (status IN ('known','flagged')),
  note text,
  marked_by uuid REFERENCES app_user(id),
  marked_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audit_log (
  id bigserial PRIMARY KEY,
  actor_id uuid,
  installation_id uuid,
  collector_key uuid,
  platform text,
  action text NOT NULL,
  entity text NOT NULL,
  entity_id uuid,
  before jsonb,
  after jsonb,
  at timestamptz NOT NULL DEFAULT now(),
  ip inet
);

-- ------------------------------------------------------ change feed (§8.2)
CREATE FUNCTION wc_set_server_seq() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.server_seq := nextval('change_seq');
  RETURN NEW;
END $$;

CREATE FUNCTION wc_touch_updated() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at_server := now();
  RETURN NEW;
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'config_document','parameter_category','parameter_definition','tester_profile',
    'reference_standard','response_card','water_source','sanitary_inspection',
    'calibration','test_session','test_result','reading','classification','alert',
    'alert_event','attachment'
  ] LOOP
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE INSERT OR UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq()',
      t || '_server_seq', t);
    EXECUTE format('CREATE INDEX %I ON %I(server_seq)', t || '_seq_idx', t);
  END LOOP;
END $$;

CREATE TRIGGER water_source_touch BEFORE UPDATE ON water_source
  FOR EACH ROW EXECUTE FUNCTION wc_touch_updated();

-- ---------------------------------------------- immutability (SPEC §5.4)
CREATE FUNCTION wc_immutable() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% is insert-only', TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'test_session','test_result','reading','alert_event','calibration',
    'sanitary_inspection','audit_log'
  ] LOOP
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE UPDATE OR DELETE ON %I FOR EACH ROW EXECUTE FUNCTION wc_immutable()',
      t || '_immutable', t);
  END LOOP;
END $$;

CREATE FUNCTION wc_no_delete() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% rows are deactivated, never deleted', TG_TABLE_NAME
    USING ERRCODE = 'restrict_violation';
END $$;
CREATE TRIGGER water_source_no_delete BEFORE DELETE ON water_source
  FOR EACH ROW EXECUTE FUNCTION wc_no_delete();

-- ---------------------------------------------------- row-level security
-- Area data: visible when its source's village is in the caller's scope.
ALTER TABLE water_source ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON water_source USING (wc_in_scope(village_id)) WITH CHECK (wc_in_scope(village_id));

ALTER TABLE sanitary_inspection ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON sanitary_inspection
  USING (EXISTS (SELECT 1 FROM water_source s WHERE s.id = source_id));

ALTER TABLE test_session ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON test_session
  USING (EXISTS (SELECT 1 FROM water_source s WHERE s.id = source_id));

ALTER TABLE test_result ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON test_result
  USING (EXISTS (SELECT 1 FROM test_session t WHERE t.id = session_id));

ALTER TABLE reading ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON reading
  USING (EXISTS (SELECT 1 FROM test_session t WHERE t.id = session_id));

ALTER TABLE classification ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON classification
  USING (EXISTS (SELECT 1 FROM test_result r WHERE r.id = result_id));

ALTER TABLE alert ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON alert
  USING (EXISTS (SELECT 1 FROM water_source s WHERE s.id = source_id));

ALTER TABLE alert_event ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON alert_event
  USING (EXISTS (SELECT 1 FROM alert a WHERE a.id = alert_id));

ALTER TABLE installation ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON installation
  USING (wc_auth_context() OR wc_in_scope(admin_unit_id));

ALTER TABLE calibration ENABLE ROW LEVEL SECURITY;
CREATE POLICY area ON calibration
  USING (EXISTS (SELECT 1 FROM installation i WHERE i.id = installation_id));

-- Attachments get their owner-based policy in P7; admin only until then.
ALTER TABLE attachment ENABLE ROW LEVEL SECURITY;
CREATE POLICY admin ON attachment USING (wc_is_admin());

-- People and credentials: yourself, an IT admin, or the sign-in flow.
ALTER TABLE app_user ENABLE ROW LEVEL SECURITY;
CREATE POLICY self ON app_user
  USING (wc_is_admin() OR wc_auth_context() OR id = wc_user_id());
ALTER TABLE user_scope ENABLE ROW LEVEL SECURITY;
CREATE POLICY self ON user_scope
  USING (wc_is_admin() OR wc_auth_context() OR user_id = wc_user_id());
ALTER TABLE user_responsibility ENABLE ROW LEVEL SECURITY;
CREATE POLICY self ON user_responsibility
  USING (wc_is_admin() OR wc_auth_context() OR user_id = wc_user_id());
ALTER TABLE refresh_token ENABLE ROW LEVEL SECURITY;
CREATE POLICY auth ON refresh_token USING (wc_auth_context() OR wc_is_admin());
ALTER TABLE activation_code ENABLE ROW LEVEL SECURITY;
CREATE POLICY auth ON activation_code USING (wc_auth_context() OR wc_is_admin());
ALTER TABLE request_nonce ENABLE ROW LEVEL SECURITY;
CREATE POLICY auth ON request_nonce USING (wc_auth_context());
ALTER TABLE sync_conflict ENABLE ROW LEVEL SECURITY;
CREATE POLICY admin ON sync_conflict USING (wc_is_admin());
ALTER TABLE collector_mark ENABLE ROW LEVEL SECURITY;
CREATE POLICY staff ON collector_mark USING (wc_user_id() IS NOT NULL OR wc_is_admin());

-- Audit: anyone may append; only IT admins read.
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY append ON audit_log FOR INSERT WITH CHECK (true);
CREATE POLICY read ON audit_log FOR SELECT USING (wc_is_admin());

-- -------------------------------------------------------------- grants
GRANT USAGE ON SCHEMA public TO watercheck_app;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO watercheck_app;
GRANT DELETE ON refresh_token, request_nonce, user_scope, user_responsibility,
  area_default_profile, alert_routing_rule TO watercheck_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO watercheck_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO watercheck_app;
