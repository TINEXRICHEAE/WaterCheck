-- Sides of FieldQuire (ADR-031): water testing and research, with more to
-- come. Each Console account and each tester profile belongs to one side;
-- IT admins work across all. A person on both sides has two linked
-- accounts (the same person_id) or two linked tester profiles. Sign-up is
-- open on both sides; areas are an official allocation, not a limit.

ALTER TABLE app_user
  ADD COLUMN side text NOT NULL DEFAULT 'water'
    CHECK (side IN ('water', 'research', 'all')),
  -- Accounts of the same person on different sides share it.
  ADD COLUMN person_id uuid,
  -- The version of each side's Privacy Policy and Terms accepted, e.g.
  -- {"water": 4}. The old combined version (legal_version) stays as history.
  ADD COLUMN legal jsonb NOT NULL DEFAULT '{}'::jsonb,
  -- How the account was made: by an IT admin, by sign-up, or by joining
  -- from the person's account on another side.
  ADD COLUMN created_via text NOT NULL DEFAULT 'admin'
    CHECK (created_via IN ('admin', 'signup', 'join'));
UPDATE app_user SET side = 'all' WHERE role = 'it_admin';
-- The owner of the sample research forms.
UPDATE app_user SET side = 'research' WHERE username = 'samples@fieldquire.app';
UPDATE app_user SET person_id = id;
ALTER TABLE app_user ALTER COLUMN person_id SET NOT NULL;

-- The same email may have one account per side.
ALTER TABLE app_user DROP CONSTRAINT app_user_username_key;
CREATE UNIQUE INDEX app_user_username_side ON app_user (lower(username), side);
CREATE INDEX app_user_person ON app_user (person_id);

-- The other sides a person has an account on (accounts see only their own
-- row, so this looks for them).
CREATE FUNCTION wc_linked_sides(account uuid) RETURNS text[]
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(array_agg(o.side ORDER BY o.side), '{}')
  FROM app_user me JOIN app_user o ON o.person_id = me.person_id
  WHERE me.id = account AND o.id <> me.id AND o.is_active AND o.side <> 'all'
$$;
GRANT EXECUTE ON FUNCTION wc_linked_sides(uuid) TO watercheck_app;

-- The caller's side ('water', 'research', 'all'; null for phones and jobs).
CREATE FUNCTION wc_side() RETURNS text LANGUAGE sql STABLE AS
$$ SELECT wc_setting('app.side') $$;

-- Areas no longer limit what water users see (the lead, 2026-10-27): every
-- water Console user sees all sources and results, like collectors; areas
-- decide whose alerts and notices they receive. Research users see none
-- of it. Phones keep their own scope.
CREATE OR REPLACE FUNCTION wc_in_scope(unit uuid) RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT wc_is_admin() OR wc_side() = 'water' OR EXISTS (
    WITH RECURSIVE up(id, parent_id) AS (
      SELECT a.id, a.parent_id FROM admin_unit a WHERE a.id = unit
      UNION ALL
      SELECT a.id, a.parent_id FROM admin_unit a JOIN up ON a.id = up.parent_id
    )
    SELECT 1 FROM up WHERE up.id = ANY (wc_scope())
  )
$$;

-- Tester profiles belong to one side too (set from the profile the phone
-- sends). Profiles already collecting for research are research testers.
ALTER TABLE collector_profile
  ADD COLUMN side text NOT NULL DEFAULT 'water' CHECK (side IN ('water', 'research'));
UPDATE collector_profile SET side = 'research'
 WHERE snapshot->>'side' = 'research'
    OR collector_key IN (SELECT collector_key FROM research.record WHERE collector_key IS NOT NULL)
    OR collector_key IN (SELECT collector_key FROM research.form_collector);

-- Only research collectors join research forms with a code.
CREATE OR REPLACE FUNCTION research.join_with_code(typed text, collector uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, research AS $$
DECLARE f uuid;
BEGIN
  IF collector NOT IN (SELECT research.device_collectors())
     OR NOT EXISTS (SELECT 1 FROM collector_profile p
                    WHERE p.collector_key = collector AND p.side = 'research') THEN
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
  UPDATE research.form SET server_seq = 0 WHERE id = f;
  UPDATE research.form_version SET server_seq = 0
   WHERE form_id = f AND published_at IS NOT NULL;
  RETURN f;
END $$;

-- Research accounts find people by email only on the research side.
CREATE OR REPLACE FUNCTION research.find_user(sign_in text) RETURNS TABLE (id uuid, full_name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT id, full_name FROM app_user
  WHERE lower(username) = lower(btrim(sign_in)) AND is_active
    AND side IN ('research', 'all') AND wc_user_id() IS NOT NULL
  ORDER BY side = 'research' DESC LIMIT 1
$$;
