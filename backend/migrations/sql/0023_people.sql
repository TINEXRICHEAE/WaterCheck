-- People by username, private by default (2026-10-28, ADR-032).
--
-- Every Console account and tester profile has a username, made up from a
-- word pair and a number ("quiet-heron-42") and changeable by its owner.
-- People are anonymous unless they choose public: others see the username
-- only. IT admins, and the teams a person works with, also see the real
-- name, written after it: "quiet-heron-42 (Akello Grace)".

CREATE FUNCTION wc_new_handle() RETURNS text
LANGUAGE plpgsql VOLATILE SET search_path = public AS $$
DECLARE
  adjectives text[] := ARRAY[
    'amber', 'bold', 'brave', 'bright', 'calm', 'clever', 'cool', 'eager',
    'fair', 'gentle', 'glad', 'golden', 'happy', 'humble', 'jolly', 'keen',
    'kind', 'lively', 'lucky', 'merry', 'mild', 'neat', 'noble', 'patient',
    'proud', 'quick', 'quiet', 'rapid', 'ready', 'silver', 'sharp', 'shy',
    'smart', 'steady', 'sunny', 'swift', 'tidy', 'true', 'warm', 'wise'];
  nouns text[] := ARRAY[
    'antelope', 'baobab', 'beetle', 'buffalo', 'canoe', 'cedar', 'cheetah',
    'cobra', 'crane', 'crow', 'drum', 'eagle', 'egret', 'falcon', 'gazelle',
    'giraffe', 'gorilla', 'heron', 'hippo', 'hornbill', 'ibis', 'impala',
    'jackal', 'kestrel', 'kite', 'kob', 'leopard', 'lion', 'lizard', 'mango',
    'meerkat', 'mongoose', 'nile', 'okapi', 'oryx', 'otter', 'owl',
    'pangolin', 'papyrus', 'parrot', 'pelican', 'python', 'river', 'robin',
    'shoebill', 'sparrow', 'stork', 'sunbird', 'tamarind', 'tilapia',
    'tortoise', 'turaco', 'warthog', 'weaver', 'zebra'];
  h text;
BEGIN
  LOOP
    h := adjectives[1 + floor(random() * array_length(adjectives, 1))::int]
      || '-' || nouns[1 + floor(random() * array_length(nouns, 1))::int]
      || '-' || (10 + floor(random() * 90))::int;
    EXIT WHEN NOT EXISTS (SELECT 1 FROM app_user WHERE lower(handle) = h)
      AND NOT EXISTS (SELECT 1 FROM collector_profile WHERE lower(handle) = h);
  END LOOP;
  RETURN h;
END
$$;

-- Columns first (the generator reads them), then fill, then require.
ALTER TABLE app_user
  ADD COLUMN handle text,
  ADD COLUMN public_profile boolean NOT NULL DEFAULT false;
ALTER TABLE collector_profile ADD COLUMN handle text;
-- Research collectors' "find me by name" becomes the same public choice
-- as everyone's; everyone starts anonymous (the lead, 2026-10-28).
ALTER TABLE collector_profile RENAME COLUMN discoverable TO public_profile;
UPDATE collector_profile SET public_profile = false;

UPDATE app_user SET handle = wc_new_handle();
UPDATE collector_profile SET handle = wc_new_handle();

ALTER TABLE app_user
  ALTER COLUMN handle SET DEFAULT wc_new_handle(),
  ALTER COLUMN handle SET NOT NULL,
  ADD CONSTRAINT app_user_handle_form CHECK (handle ~ '^[a-z0-9][a-z0-9._-]{2,29}$');
ALTER TABLE collector_profile
  ALTER COLUMN handle SET DEFAULT wc_new_handle(),
  ALTER COLUMN handle SET NOT NULL,
  ADD CONSTRAINT collector_profile_handle_form
    CHECK (handle ~ '^[a-z0-9][a-z0-9._-]{2,29}$');
CREATE UNIQUE INDEX app_user_handle ON app_user (lower(handle));
CREATE UNIQUE INDEX collector_profile_handle ON collector_profile (lower(handle));

-- A username is free when no account and no tester profile has it (the
-- one changing it aside).
CREATE FUNCTION wc_handle_free(h text, own_user uuid, own_collector uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT NOT EXISTS (SELECT 1 FROM app_user
                     WHERE lower(handle) = lower(h) AND id IS DISTINCT FROM own_user)
     AND NOT EXISTS (SELECT 1 FROM collector_profile
                     WHERE lower(handle) = lower(h)
                       AND collector_key IS DISTINCT FROM own_collector)
$$;

-- Whether the caller may see a tester's real name: IT admins; anyone, when
-- the tester chose public; the research teams they collect for; water
-- officers whose areas hold the tester's assigned area or sources they
-- tested; and the phone they use.
CREATE FUNCTION wc_sees_collector(k uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT wc_is_admin()
    OR EXISTS (SELECT 1 FROM collector_profile p
               WHERE p.collector_key = k AND p.public_profile)
    OR k IN (SELECT research.device_collectors())
    OR (wc_user_id() IS NOT NULL AND (
      EXISTS (SELECT 1 FROM research.form_collector c
              JOIN research.form f ON f.id = c.form_id
              WHERE c.collector_key = k AND research.can_manage(f.project_id))
      OR EXISTS (SELECT 1 FROM research.record r
                 JOIN research.form f ON f.id = r.form_id
                 WHERE r.collector_key = k AND research.can_manage(f.project_id))
      OR EXISTS (SELECT 1 FROM collector_assignment a, unnest(wc_scope()) s(unit)
                 WHERE a.collector_key = k AND a.ended_at IS NULL
                   AND wc_under(a.admin_unit_id, s.unit))
      -- Testers who tested sources in the officer's areas.
      OR EXISTS (SELECT 1 FROM test_session t
                 JOIN water_source w ON w.id = t.source_id, unnest(wc_scope()) s(unit)
                 WHERE t.collector_key = k AND wc_under(w.village_id, s.unit))))
$$;

-- Whether the caller may see an account's real name: IT admins; the
-- person; anyone, when public; people on the same research project; water
-- officers whose areas meet; and phones whose testers collect for a
-- project the account runs.
CREATE FUNCTION wc_sees_user(u uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT wc_is_admin()
    OR u = wc_user_id()
    OR EXISTS (SELECT 1 FROM app_user a WHERE a.id = u AND a.public_profile)
    OR (wc_user_id() IS NOT NULL AND (
      EXISTS (
        SELECT 1 FROM research.project p
        WHERE (p.owner_user_id = u
               OR EXISTS (SELECT 1 FROM research.project_member m
                          WHERE m.project_id = p.id AND m.user_id = u))
          AND (p.owner_user_id = wc_user_id()
               OR EXISTS (SELECT 1 FROM research.project_member m
                          WHERE m.project_id = p.id AND m.user_id = wc_user_id())))
      OR EXISTS (SELECT 1 FROM user_scope us, unnest(wc_scope()) s(unit)
                 WHERE us.user_id = u
                   AND (wc_under(us.admin_unit_id, s.unit)
                        OR wc_under(s.unit, us.admin_unit_id)))))
    OR EXISTS (
      SELECT 1 FROM research.form_collector c
      JOIN research.form f ON f.id = c.form_id
      JOIN research.project p ON p.id = f.project_id
      WHERE c.collector_key IN (SELECT research.device_collectors())
        AND (p.owner_user_id = u
             OR EXISTS (SELECT 1 FROM research.project_member m
                        WHERE m.project_id = p.id AND m.user_id = u)))
$$;

-- How a person is named to the caller.
CREATE FUNCTION wc_collector_label(k uuid) RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT p.handle || CASE
    WHEN wc_sees_collector(k) AND nullif(btrim(p.snapshot->>'full_name'), '') IS NOT NULL
    THEN ' (' || btrim(p.snapshot->>'full_name') || ')' ELSE '' END
  FROM collector_profile p WHERE p.collector_key = k
$$;

CREATE FUNCTION wc_user_label(u uuid) RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT a.handle || CASE WHEN wc_sees_user(u) THEN ' (' || a.full_name || ')' ELSE '' END
  FROM app_user a WHERE a.id = u
$$;

GRANT EXECUTE ON FUNCTION wc_new_handle(), wc_handle_free(text, uuid, uuid),
  wc_sees_collector(uuid), wc_sees_user(uuid), wc_collector_label(uuid),
  wc_user_label(uuid) TO watercheck_app;

-- ------------------------------------------------------------ form editors
-- People the owner lets edit a form and publish new versions; access and
-- sharing stay with the owning project's team.
CREATE TABLE research.form_editor (
  form_id uuid NOT NULL REFERENCES research.form(id),
  user_id uuid NOT NULL REFERENCES app_user(id),
  added_by uuid REFERENCES app_user(id),
  added_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (form_id, user_id)
);
ALTER TABLE research.form_editor ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON research.form_editor USING (
  user_id = wc_user_id()
  OR EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id
             AND research.can_manage(f.project_id))
) WITH CHECK (
  EXISTS (SELECT 1 FROM research.form f WHERE f.id = form_id
          AND research.can_manage(f.project_id))
);
GRANT SELECT, INSERT, DELETE ON research.form_editor TO watercheck_app;

CREATE FUNCTION research.can_edit_form(form uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (
    SELECT 1 FROM research.form f WHERE f.id = form AND (
      research.can_manage(f.project_id)
      OR EXISTS (SELECT 1 FROM research.form_editor e
                 WHERE e.form_id = f.id AND e.user_id = wc_user_id())))
$$;
GRANT EXECUTE ON FUNCTION research.can_edit_form(uuid) TO watercheck_app;

-- Editors see the form, and save its draft and versions.
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
      OR (wc_setting('app.installation_id') IS NOT NULL AND research.can_collect(f.id))
    )
  )
$$;
DROP POLICY see ON research.form;
CREATE POLICY see ON research.form USING (research.can_view_form(id))
  WITH CHECK (research.can_manage(project_id) OR research.can_edit_form(id));
DROP POLICY see ON research.form_version;
CREATE POLICY see ON research.form_version USING (research.can_view_form(form_id))
  WITH CHECK (research.can_edit_form(form_id));

-- Who published each version, credited by username.
ALTER TABLE research.form_version ADD COLUMN published_by uuid REFERENCES app_user(id);
UPDATE research.form_version v SET published_by = f.created_by
FROM research.form f WHERE f.id = v.form_id AND v.published_at IS NOT NULL;

-- ------------------------------------------------------- direct messages
-- Two people writing to each other, on one side: accounts and testers
-- alike. Online only (not in the device sync).
CREATE TABLE chat (
  id uuid PRIMARY KEY,
  side text NOT NULL CHECK (side IN ('water', 'research')),
  -- Each end is an account or a tester profile, never both.
  a_user uuid REFERENCES app_user(id),
  a_collector uuid,
  b_user uuid REFERENCES app_user(id),
  b_collector uuid,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_at timestamptz NOT NULL DEFAULT now(),
  CHECK ((a_user IS NULL) <> (a_collector IS NULL)),
  CHECK ((b_user IS NULL) <> (b_collector IS NULL))
);
-- One chat per pair and side, whichever end began it.
CREATE UNIQUE INDEX chat_pair ON chat (
  side,
  least(coalesce(a_user, a_collector), coalesce(b_user, b_collector)),
  greatest(coalesce(a_user, a_collector), coalesce(b_user, b_collector)));

CREATE TABLE chat_message (
  id uuid PRIMARY KEY,
  chat_id uuid NOT NULL REFERENCES chat(id),
  from_user uuid REFERENCES app_user(id),
  from_collector uuid,
  body text NOT NULL CHECK (length(btrim(body)) BETWEEN 1 AND 2000),
  sent_at timestamptz NOT NULL DEFAULT now(),
  read_at timestamptz,
  CHECK ((from_user IS NULL) <> (from_collector IS NULL))
);
CREATE INDEX chat_message_chat ON chat_message (chat_id, sent_at);

-- The caller is one end of the chat (an account, or a tester on the
-- calling phone).
CREATE FUNCTION wc_in_chat(c uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT EXISTS (
    SELECT 1 FROM chat x WHERE x.id = c AND (
      wc_user_id() IN (x.a_user, x.b_user)
      OR x.a_collector IN (SELECT research.device_collectors())
      OR x.b_collector IN (SELECT research.device_collectors())))
$$;
GRANT EXECUTE ON FUNCTION wc_in_chat(uuid) TO watercheck_app;

-- Rows are checked by their own ends (a new chat is not there to look
-- up yet).
ALTER TABLE chat ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON chat USING (
  wc_user_id() IN (a_user, b_user)
  OR a_collector IN (SELECT research.device_collectors())
  OR b_collector IN (SELECT research.device_collectors()));
ALTER TABLE chat_message ENABLE ROW LEVEL SECURITY;
CREATE POLICY see ON chat_message FOR SELECT USING (wc_in_chat(chat_id));
-- Marking the other's messages read.
CREATE POLICY mark ON chat_message FOR UPDATE USING (wc_in_chat(chat_id));
CREATE POLICY write ON chat_message FOR INSERT WITH CHECK (
  wc_in_chat(chat_id) AND (
    from_user = wc_user_id()
    OR from_collector IN (SELECT research.device_collectors())));
GRANT SELECT, INSERT, UPDATE ON chat, chat_message TO watercheck_app;

-- A person as the caller may know them (every profile is read; the real
-- name only where it may be seen).
CREATE FUNCTION wc_person(kind text, pid uuid)
RETURNS TABLE (kind text, id uuid, handle text, full_name text, public boolean)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT 'user', a.id, a.handle,
         CASE WHEN wc_sees_user(a.id) THEN a.full_name END, a.public_profile
  FROM app_user a WHERE wc_person.kind = 'user' AND a.id = pid
  UNION ALL
  SELECT 'collector', p.collector_key, p.handle,
         CASE WHEN wc_sees_collector(p.collector_key) THEN p.snapshot->>'full_name' END,
         p.public_profile
  FROM collector_profile p WHERE wc_person.kind = 'collector' AND p.collector_key = pid
$$;

-- People on a side to write to: anyone by username, by real name only
-- where it may be seen; public people first.
CREATE FUNCTION wc_people(side text, q text, me_kind text, me uuid, n int)
RETURNS TABLE (kind text, id uuid, handle text, full_name text, public boolean)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT x.kind, x.id, x.handle, x.full_name, x.public FROM (
    SELECT 'user' AS kind, a.id, a.handle,
           CASE WHEN wc_sees_user(a.id) THEN a.full_name END AS full_name,
           a.public_profile AS public
    FROM app_user a WHERE a.is_active AND a.side IN (wc_people.side, 'all')
    UNION ALL
    SELECT 'collector', p.collector_key, p.handle,
           CASE WHEN wc_sees_collector(p.collector_key) THEN p.snapshot->>'full_name' END,
           p.public_profile
    FROM collector_profile p WHERE p.side = wc_people.side
  ) x
  WHERE NOT (x.kind = me_kind AND x.id = me)
    AND (btrim(q) = '' OR x.handle ILIKE '%' || btrim(q) || '%'
         OR x.full_name ILIKE '%' || btrim(q) || '%')
  ORDER BY x.public DESC, x.handle
  LIMIT n
$$;
GRANT EXECUTE ON FUNCTION wc_person(text, uuid), wc_people(text, text, text, uuid, int)
  TO watercheck_app;

-- Research pages name accounts by username (real name where it may be
-- seen), and find them by email or username.
CREATE OR REPLACE FUNCTION research.user_name(person uuid) RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT wc_user_label(person)
$$;
CREATE OR REPLACE FUNCTION research.find_user(sign_in text) RETURNS TABLE (id uuid, full_name text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT id, wc_user_label(id) FROM app_user
  WHERE (lower(username) = lower(btrim(sign_in)) OR lower(handle) = lower(btrim(sign_in)))
    AND is_active AND side IN ('research', 'all') AND wc_user_id() IS NOT NULL
  ORDER BY side = 'research' DESC LIMIT 1
$$;

-- Who wrote a message, as the caller may know them.
CREATE FUNCTION wc_author_label(u uuid, k uuid) RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce(wc_user_label(u), wc_collector_label(k))
$$;
GRANT EXECUTE ON FUNCTION wc_author_label(uuid, uuid) TO watercheck_app;
