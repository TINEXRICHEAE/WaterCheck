-- A form a phone gains later (a code joined, access opened, a collector
-- added) comes with its project: the phone lists only forms whose project
-- it has, and its cursor may be past a project it could not see then
-- (2026-10-31, the CHS4102 forms that vanished after a correct code).

-- Any change to a form re-sends its project.
CREATE FUNCTION research.project_follows_form() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, research AS $$
BEGIN
  UPDATE research.project SET server_seq = 0 WHERE id = NEW.project_id;
  RETURN NULL;
END $$;

CREATE TRIGGER form_project_follows AFTER INSERT OR UPDATE ON research.form
  FOR EACH ROW EXECUTE FUNCTION research.project_follows_form();

-- Phones that missed a project get it at their next sync.
UPDATE research.project SET server_seq = 0;
