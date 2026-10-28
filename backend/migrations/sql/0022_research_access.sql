-- Research access kept up to date on phones, forms behind a code shown
-- locked, and collectors who choose to be found (2026-10-27).

-- Published, listed forms that need an access code, for every research
-- collector to see with a lock (the form itself comes only after the code).
-- Forms the calling device may already collect with are left out.
CREATE FUNCTION research.locked_forms()
RETURNS TABLE (id uuid, code text, title text, description text, project_title text)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, research AS $$
  SELECT f.id, f.code, f.title, f.description, p.title
  FROM research.form f JOIN research.project p ON p.id = f.project_id
  WHERE f.status = 'published' AND f.collect_access = 'code' AND NOT f.hidden
    AND f.current_version IS NOT NULL AND NOT research.can_collect(f.id)
  ORDER BY p.title, f.code
$$;
GRANT EXECUTE ON FUNCTION research.locked_forms() TO watercheck_app;

-- Research collectors are private unless they choose to be found by name or
-- phone; anyone can still add them with their own collector code.
ALTER TABLE collector_profile
  ADD COLUMN discoverable boolean NOT NULL DEFAULT false,
  ADD COLUMN share_code text GENERATED ALWAYS AS
    (upper(substr(md5(collector_key::text || 'fieldquire-collector'), 1, 8))) STORED;
CREATE UNIQUE INDEX collector_profile_share_code ON collector_profile (share_code);
