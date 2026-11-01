-- Shared form links (2026-11-01): a link to a research form that anyone
-- can open read-only as a guest, then join as a collector (with the team's
-- approval where the form asks for it) or ask to edit it from the Console.

-- Whether new collectors wait for the team's approval before their records
-- are accepted. New forms ask for it; forms made before keep joining at once.
ALTER TABLE research.form ADD COLUMN join_approval boolean NOT NULL DEFAULT true;
UPDATE research.form SET join_approval = false;

-- A collector waiting for approval has the form on the phone and fills it;
-- the records stay there until approved.
ALTER TABLE research.form_collector
  ADD COLUMN status text NOT NULL DEFAULT 'approved' CHECK (status IN ('approved', 'pending')),
  ADD COLUMN decided_by uuid REFERENCES app_user(id),
  ADD COLUMN decided_at timestamptz;
ALTER TABLE research.form_collector DROP CONSTRAINT form_collector_via_check;
ALTER TABLE research.form_collector
  ADD CONSTRAINT form_collector_via_check CHECK (via IN ('assigned', 'code', 'link'));
GRANT UPDATE ON research.form_collector TO watercheck_app;

-- The links themselves: for collectors, or for editors (owner only). A
-- link to a form behind a code works only while that code does.
CREATE TABLE research.form_link (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token text NOT NULL UNIQUE,
  form_id uuid NOT NULL REFERENCES research.form(id),
  kind text NOT NULL CHECK (kind IN ('collect', 'edit')),
  code_at_creation text,
  created_by uuid REFERENCES app_user(id),
  created_by_collector uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz
);
CREATE INDEX form_link_form ON research.form_link (form_id);
ALTER TABLE research.form_link ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.form_link USING (
  EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id AND research.can_manage(f.project_id))
  OR created_by = wc_user_id()
  OR created_by_collector IN (SELECT research.device_collectors())
);
GRANT SELECT, INSERT, UPDATE ON research.form_link TO watercheck_app;

-- Console users who opened an editor link and asked to edit.
CREATE TABLE research.edit_request (
  form_id uuid NOT NULL REFERENCES research.form(id),
  user_id uuid NOT NULL REFERENCES app_user(id),
  link_id uuid REFERENCES research.form_link(id),
  requested_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (form_id, user_id)
);
ALTER TABLE research.edit_request ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.edit_request USING (
  user_id = wc_user_id()
  OR EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id AND research.can_manage(f.project_id))
);
GRANT SELECT, INSERT, DELETE ON research.edit_request TO watercheck_app;

-- Only approved collectors collect.
CREATE OR REPLACE FUNCTION research.can_collect(form uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (
    SELECT 1 FROM research.form f WHERE f.id = form AND f.status = 'published' AND (
      (f.collect_access = 'open' AND NOT f.hidden)
      OR EXISTS (
        SELECT 1 FROM research.form_collector c
        WHERE c.form_id = f.id AND c.status = 'approved'
          AND c.collector_key IN (SELECT research.device_collectors())
      )
    )
  )
$$;

-- A form one of this phone's testers is waiting to be approved for.
CREATE FUNCTION research.device_awaits(form uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT wc_setting('app.installation_id') IS NOT NULL AND EXISTS (
    SELECT 1 FROM research.form_collector c JOIN research.form f ON f.id = c.form_id
    WHERE c.form_id = form AND c.status = 'pending' AND f.status = 'published'
      AND c.collector_key IN (SELECT research.device_collectors())
  )
$$;
GRANT EXECUTE ON FUNCTION research.device_awaits(uuid) TO watercheck_app;

-- Phones waiting for approval still get the form, to fill it meanwhile.
CREATE OR REPLACE FUNCTION research.can_view_form(form uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (
    SELECT 1 FROM research.form f WHERE f.id = form AND (
      research.can_manage(f.project_id)
      OR (wc_user_id() IS NOT NULL AND f.visibility = 'public')
      OR EXISTS (SELECT 1 FROM research.form_share s
                 WHERE s.form_id = f.id AND s.user_id = wc_user_id())
      OR EXISTS (SELECT 1 FROM research.form_editor e
                 WHERE e.form_id = f.id AND e.user_id = wc_user_id())
      OR (wc_setting('app.installation_id') IS NOT NULL
          AND (research.can_collect(f.id) OR research.device_awaits(f.id)))
    )
  )
$$;

-- Locked forms leave out those already joined and waiting.
CREATE OR REPLACE FUNCTION research.locked_forms()
RETURNS TABLE (id uuid, code text, title text, description text, project_title text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT f.id, f.code, f.title, f.description, p.title
  FROM research.form f JOIN research.project p ON p.id = f.project_id
  WHERE f.status = 'published' AND f.collect_access = 'code' AND NOT f.hidden
    AND f.current_version IS NOT NULL AND NOT research.can_collect(f.id)
    AND NOT research.device_awaits(f.id)
  ORDER BY p.title, f.code
$$;

-- Joining with a code waits for approval where the form asks for it.
CREATE OR REPLACE FUNCTION research.join_with_code(typed text, collector uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, research AS $$
DECLARE f research.form;
BEGIN
  IF collector NOT IN (SELECT research.device_collectors())
     OR NOT EXISTS (SELECT 1 FROM collector_profile p
                    WHERE p.collector_key = collector AND p.side = 'research') THEN
    RETURN NULL;
  END IF;
  SELECT * INTO f FROM research.form
   WHERE access_code = upper(btrim(typed)) AND status = 'published'
     AND collect_access IN ('code', 'open');
  IF f.id IS NULL THEN
    RETURN NULL;
  END IF;
  INSERT INTO research.form_collector (form_id, collector_key, via, status)
  VALUES (f.id, collector, 'code',
          CASE WHEN f.join_approval AND f.collect_access = 'code' THEN 'pending' ELSE 'approved' END)
  ON CONFLICT DO NOTHING;
  UPDATE research.form SET server_seq = 0 WHERE id = f.id;
  UPDATE research.form_version SET server_seq = 0
   WHERE form_id = f.id AND published_at IS NOT NULL;
  RETURN f.id;
END $$;

-- What a link shows to anyone, signed in or not: the form's questions,
-- never its records. Null for a link turned off or no longer valid.
CREATE FUNCTION research.form_by_link(link text)
RETURNS TABLE (link_id uuid, kind text, form_id uuid, code text, title text,
               description text, project_title text, definition jsonb,
               collect_access text, open_for_collection boolean, version int)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT l.id, l.kind, f.id, f.code, f.title, f.description, p.title, v.definition,
         f.collect_access, f.status = 'published', f.current_version
  FROM research.form_link l
  JOIN research.form f ON f.id = l.form_id
  JOIN research.project p ON p.id = f.project_id
  LEFT JOIN research.form_version v ON v.form_id = f.id AND v.version = f.current_version
  WHERE l.token = link AND l.revoked_at IS NULL AND f.current_version IS NOT NULL
    AND f.status <> 'draft'
    AND (f.collect_access <> 'code' OR l.kind = 'edit'
         OR f.access_code IS NOT DISTINCT FROM l.code_at_creation)
$$;
GRANT EXECUTE ON FUNCTION research.form_by_link(text) TO watercheck_app;

-- Joining from a link: like a code, waiting for approval where the form
-- asks for it, and always for a form the team gives out itself.
CREATE FUNCTION research.join_with_link(link text, collector uuid)
RETURNS TABLE (form_id uuid, status text)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, research AS $$
DECLARE l record; f research.form; st text;
BEGIN
  IF collector NOT IN (SELECT research.device_collectors())
     OR NOT EXISTS (SELECT 1 FROM collector_profile p
                    WHERE p.collector_key = collector AND p.side = 'research') THEN
    RETURN;
  END IF;
  SELECT * INTO l FROM research.form_by_link(link) WHERE kind = 'collect';
  IF l.form_id IS NULL OR NOT l.open_for_collection THEN
    RETURN;
  END IF;
  SELECT * INTO f FROM research.form WHERE id = l.form_id;
  st := CASE WHEN f.collect_access = 'open' AND NOT f.hidden THEN 'approved'
             WHEN f.join_approval OR f.collect_access = 'assigned' THEN 'pending'
             ELSE 'approved' END;
  INSERT INTO research.form_collector (form_id, collector_key, via, status)
  VALUES (f.id, collector, 'link', st) ON CONFLICT DO NOTHING;
  UPDATE research.form SET server_seq = 0 WHERE id = f.id;
  UPDATE research.form_version SET server_seq = 0
   WHERE research.form_version.form_id = f.id AND published_at IS NOT NULL;
  RETURN QUERY SELECT c.form_id, c.status FROM research.form_collector c
   WHERE c.form_id = f.id AND c.collector_key = collector;
END $$;
GRANT EXECUTE ON FUNCTION research.join_with_link(text, uuid) TO watercheck_app;
