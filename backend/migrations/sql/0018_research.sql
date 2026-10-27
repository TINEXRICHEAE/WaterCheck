-- FieldQuire research module (ADR-030): projects, forms with immutable
-- versions, collectors assigned to forms, and records made in the field
-- with the point and time of the interview. Its own schema, beside water
-- testing; accounts, devices, testers, attachments and the change feed
-- are shared.

CREATE SCHEMA research;
GRANT USAGE ON SCHEMA research TO watercheck_app;

CREATE TABLE research.project (
  id uuid PRIMARY KEY,
  -- The prefix of generated research numbers, e.g. ENT.
  code text NOT NULL UNIQUE CHECK (code ~ '^[A-Z0-9]{2,8}$'),
  title text NOT NULL CHECK (length(btrim(title)) BETWEEN 1 AND 200),
  description text,
  owner_user_id uuid NOT NULL REFERENCES app_user(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL
);

CREATE TABLE research.project_member (
  project_id uuid NOT NULL REFERENCES research.project(id),
  user_id uuid NOT NULL REFERENCES app_user(id),
  role text NOT NULL CHECK (role IN ('supervisor', 'analyst')),
  added_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (project_id, user_id)
);

CREATE TABLE research.form (
  id uuid PRIMARY KEY,
  project_id uuid NOT NULL REFERENCES research.project(id),
  -- Short code in research numbers, e.g. HQ for the household questionnaire.
  code text NOT NULL CHECK (code ~ '^[A-Z0-9]{1,6}$'),
  title text NOT NULL CHECK (length(btrim(title)) BETWEEN 1 AND 200),
  description text,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'closed')),
  -- To other authors: public (view and clone), private, shared (named people).
  visibility text NOT NULL DEFAULT 'private'
    CHECK (visibility IN ('public', 'private', 'shared')),
  -- Who may collect: assigned collectors, anyone with the code, or anyone.
  collect_access text NOT NULL DEFAULT 'assigned'
    CHECK (collect_access IN ('assigned', 'code', 'open')),
  -- Not listed for browsing; assigned collectors still get it.
  hidden boolean NOT NULL DEFAULT false,
  numbering text NOT NULL DEFAULT 'generated' CHECK (numbering IN ('generated', 'typed')),
  current_version integer,
  cloned_from uuid REFERENCES research.form(id),
  created_by uuid REFERENCES app_user(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL,
  UNIQUE (project_id, code)
);

-- A form's definition (ADR-030 §4), never changed once made: records point
-- to the version they were filled with.
CREATE TABLE research.form_version (
  form_id uuid NOT NULL REFERENCES research.form(id),
  version integer NOT NULL CHECK (version > 0),
  definition jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  published_at timestamptz,
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL,
  PRIMARY KEY (form_id, version)
);

CREATE TABLE research.form_collector (
  form_id uuid NOT NULL REFERENCES research.form(id),
  collector_key uuid NOT NULL,
  -- How they came: named by the owner, or joined with the form's code.
  via text NOT NULL DEFAULT 'assigned' CHECK (via IN ('assigned', 'code')),
  added_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (form_id, collector_key)
);

-- Shared with named people for cloning (visibility 'shared').
CREATE TABLE research.form_share (
  form_id uuid NOT NULL REFERENCES research.form(id),
  user_id uuid NOT NULL REFERENCES app_user(id),
  PRIMARY KEY (form_id, user_id)
);

CREATE TABLE research.record (
  id uuid PRIMARY KEY,
  form_id uuid NOT NULL,
  form_version integer NOT NULL,
  -- The research number shown on maps and lists, never a name.
  number text NOT NULL CHECK (length(btrim(number)) BETWEEN 1 AND 60),
  -- The same number already used in the project: kept, flagged.
  number_clash boolean NOT NULL DEFAULT false,
  collector_key uuid,
  installation_id uuid REFERENCES installation(id),
  author_user_id uuid REFERENCES app_user(id),
  collector_snapshot jsonb,
  started_at timestamptz,
  finished_at timestamptz,
  -- The point of the interview, when the record was started, and where it
  -- was finished.
  lat double precision,
  lon double precision,
  accuracy_m real,
  altitude_m real,
  end_lat double precision,
  end_lon double precision,
  end_accuracy_m real,
  answers jsonb NOT NULL,
  created_at_server timestamptz NOT NULL DEFAULT now(),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL,
  FOREIGN KEY (form_id, form_version) REFERENCES research.form_version(form_id, version),
  CHECK ((lat IS NULL) = (lon IS NULL)),
  CHECK (lat IS NULL OR (lat BETWEEN -90 AND 90 AND lon BETWEEN -180 AND 180))
);
CREATE INDEX record_form ON research.record (form_id, created_at_server);
CREATE INDEX record_number ON research.record (form_id, number);
CREATE INDEX record_collector ON research.record (collector_key);

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['project', 'form', 'form_version', 'record'] LOOP
    EXECUTE format(
      'CREATE TRIGGER %I BEFORE INSERT OR UPDATE ON research.%I '
      'FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq()', t || '_server_seq', t);
    EXECUTE format(
      'CREATE INDEX %I ON research.%I (server_xid, server_seq)', t || '_feed_idx', t);
  END LOOP;
END $$;

-- Records are kept as made (ADR-030 §3).
CREATE TRIGGER record_no_update BEFORE UPDATE OF answers, number, lat, lon, started_at
  ON research.record FOR EACH ROW EXECUTE FUNCTION wc_immutable();
CREATE TRIGGER form_version_no_update BEFORE UPDATE OF definition
  ON research.form_version FOR EACH ROW EXECUTE FUNCTION wc_immutable();

-- ------------------------------------------------------------- who sees what
-- Helpers read the tables directly (SECURITY DEFINER) so the policies below
-- do not call themselves.

-- The project's owner, a member, or an IT admin.
CREATE FUNCTION research.can_manage(project uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT wc_is_admin() OR EXISTS (
    SELECT 1 FROM research.project p WHERE p.id = project AND p.owner_user_id = wc_user_id()
  ) OR EXISTS (
    SELECT 1 FROM research.project_member m
    WHERE m.project_id = project AND m.user_id = wc_user_id()
  )
$$;

-- Testers signed in on the calling device (ADR-024).
CREATE FUNCTION research.device_collectors() RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT collector_key FROM collector_device
  WHERE installation_id = wc_setting('app.installation_id')::uuid AND signed_out_at IS NULL
$$;

-- A form the calling device may collect with: published, and open to all
-- (unless hidden) or given to one of its testers.
CREATE FUNCTION research.can_collect(form uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (
    SELECT 1 FROM research.form f WHERE f.id = form AND f.status = 'published' AND (
      (f.collect_access = 'open' AND NOT f.hidden)
      OR EXISTS (
        SELECT 1 FROM research.form_collector c
        WHERE c.form_id = f.id AND c.collector_key IN (SELECT research.device_collectors())
      )
    )
  )
$$;

-- Other authors may see (to clone) a public form, or one shared with them.
CREATE FUNCTION research.can_view_form(form uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (
    SELECT 1 FROM research.form f WHERE f.id = form AND (
      research.can_manage(f.project_id)
      OR (wc_user_id() IS NOT NULL AND f.visibility = 'public')
      OR EXISTS (SELECT 1 FROM research.form_share s
                 WHERE s.form_id = f.id AND s.user_id = wc_user_id())
      OR (wc_setting('app.installation_id') IS NOT NULL AND research.can_collect(f.id))
    )
  )
$$;

ALTER TABLE research.project ENABLE ROW LEVEL SECURITY;
-- `project.id`: a bare `id` inside the subquery would be the form's own.
CREATE POLICY see ON research.project USING (
  research.can_manage(project.id)
  OR EXISTS (SELECT 1 FROM research.form f WHERE f.project_id = project.id
             AND research.can_view_form(f.id))
) WITH CHECK (wc_is_admin() OR owner_user_id = wc_user_id());

ALTER TABLE research.project_member ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.project_member USING (research.can_manage(project_id));

ALTER TABLE research.form ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.form USING (research.can_view_form(id))
  WITH CHECK (research.can_manage(project_id));

ALTER TABLE research.form_version ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.form_version USING (research.can_view_form(form_id))
  WITH CHECK (EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id
                      AND research.can_manage(f.project_id)));

ALTER TABLE research.form_collector ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.form_collector USING (
  EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id AND research.can_manage(f.project_id))
  OR collector_key IN (SELECT research.device_collectors())
);

ALTER TABLE research.form_share ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.form_share USING (
  user_id = wc_user_id()
  OR EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id AND research.can_manage(f.project_id))
);

-- Records: the project's team sees all; a device sees its testers' own.
ALTER TABLE research.record ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.record USING (
  EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id AND research.can_manage(f.project_id))
  OR collector_key IN (SELECT research.device_collectors())
) WITH CHECK (
  research.can_collect(form_id) AND collector_key IN (SELECT research.device_collectors())
  OR EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id AND research.can_manage(f.project_id))
);

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA research TO watercheck_app;
GRANT DELETE ON research.project_member, research.form_collector, research.form_share
  TO watercheck_app;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA research TO watercheck_app;

-- Pictures (and later audio and video) of a record, with the field they
-- answer; visible with their record.
ALTER TABLE attachment DROP CONSTRAINT attachment_owner_type;
ALTER TABLE attachment ADD CONSTRAINT attachment_owner_type
  CHECK (owner_type IN ('water_source', 'test_session', 'research_record'));
ALTER TABLE attachment ADD COLUMN field_name text;

CREATE OR REPLACE FUNCTION wc_attachment_visible(owner_type text, owner_id uuid) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT CASE owner_type
    WHEN 'water_source' THEN EXISTS (SELECT 1 FROM water_source s WHERE s.id = owner_id)
    WHEN 'test_session' THEN EXISTS (SELECT 1 FROM test_session t WHERE t.id = owner_id)
    WHEN 'research_record' THEN EXISTS (SELECT 1 FROM research.record r WHERE r.id = owner_id)
    ELSE false
  END
$$;

-- Is this research number already used in the project? A device sees only
-- its own testers' records, so the server asks across the project
-- (numbers only; nothing else is revealed).
CREATE FUNCTION research.number_used(project uuid, num text, except_record uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (
    SELECT 1 FROM research.record r JOIN research.form f ON f.id = r.form_id
    WHERE f.project_id = project AND r.number = num AND r.id <> except_record
  )
$$;
GRANT EXECUTE ON FUNCTION research.number_used(uuid, text, uuid) TO watercheck_app;
