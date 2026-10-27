-- Console › Research (ADR-030 R2): forms are built and published in the
-- Console, collectors join with a form's access code, the project keeps its
-- analysis set-up (indicators with targets), and records have messages.

-- The definition being edited; publishing makes it a new version.
ALTER TABLE research.form ADD COLUMN draft jsonb;
-- Collectors type this in Collect to join the form (collect_access 'code').
ALTER TABLE research.form ADD COLUMN access_code text UNIQUE
  CHECK (access_code ~ '^[A-Z0-9]{6,12}$');
ALTER TABLE research.form ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();

-- Indicators against targets (ADR-030 §6), kept with the project.
ALTER TABLE research.project ADD COLUMN analysis jsonb;

-- Owners and members may remove what they made available; nothing else
-- is deleted (records stay).
GRANT DELETE ON research.form_share TO watercheck_app;

-- A collector joins a published form with its code from a device signed in
-- as them. The device cannot see the form before joining, so this looks it
-- up itself. Returns the form, or null for a wrong or closed code.
CREATE FUNCTION research.join_with_code(typed text, collector uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, research AS $$
DECLARE f uuid;
BEGIN
  IF collector NOT IN (SELECT research.device_collectors()) THEN
    RETURN NULL;
  END IF;
  SELECT form.id INTO f FROM research.form
   WHERE access_code = upper(btrim(typed)) AND status = 'published'
     AND collect_access IN ('code', 'open');
  IF f IS NULL THEN
    RETURN NULL;
  END IF;
  INSERT INTO research.form_collector (form_id, collector_key, via)
  VALUES (f, collector, 'code') ON CONFLICT DO NOTHING;
  -- The form and its versions reach the device with its next sync.
  UPDATE research.form SET server_seq = 0 WHERE id = f;
  UPDATE research.form_version SET server_seq = 0
   WHERE form_id = f AND published_at IS NOT NULL;
  RETURN f;
END $$;
GRANT EXECUTE ON FUNCTION research.join_with_code(text, uuid) TO watercheck_app;

-- People in a project (owner, members, people a form is shared with) are
-- shown by name; a Console user otherwise sees only their own account.
CREATE FUNCTION research.user_name(person uuid) RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT full_name FROM app_user WHERE id = person
$$;
-- An active account by its sign-in name (email), to add to a project or
-- share a form with. Only the id and name come back.
CREATE FUNCTION research.find_user(sign_in text) RETURNS TABLE (id uuid, full_name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT id, full_name FROM app_user
  WHERE lower(username) = lower(btrim(sign_in)) AND is_active AND wc_user_id() IS NOT NULL
$$;
GRANT EXECUTE ON FUNCTION research.user_name(uuid), research.find_user(text) TO watercheck_app;

-- Codes are unique across everyone's projects and forms, which a
-- researcher cannot see: these answer yes or no only.
CREATE FUNCTION research.project_code_used(wanted text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (SELECT 1 FROM research.project p WHERE p.code = upper(wanted))
$$;
CREATE FUNCTION research.access_code_used(wanted text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (SELECT 1 FROM research.form f WHERE f.access_code = upper(wanted))
$$;
GRANT EXECUTE ON FUNCTION research.project_code_used(text), research.access_code_used(text)
  TO watercheck_app;

-- Messages on a research record: between the project's team and the
-- collector, seen by whoever may see the record.
ALTER TABLE message DROP CONSTRAINT message_subject_type_check;
ALTER TABLE message ADD CONSTRAINT message_subject_type_check
  CHECK (subject_type IN ('test', 'source', 'collector', 'area', 'research_record'));
DROP POLICY read ON message;
CREATE POLICY read ON message FOR SELECT USING (
  wc_is_admin()
  OR (village_id IS NOT NULL AND wc_in_scope(village_id))
  OR (subject_type = 'research_record'
      AND EXISTS (SELECT 1 FROM research.record r WHERE r.id = subject_id))
);
DROP POLICY write ON message;
CREATE POLICY write ON message FOR INSERT WITH CHECK (
  wc_is_admin()
  OR (village_id IS NOT NULL AND wc_in_scope(village_id))
  OR (subject_type = 'research_record'
      AND EXISTS (SELECT 1 FROM research.record r WHERE r.id = subject_id))
);
