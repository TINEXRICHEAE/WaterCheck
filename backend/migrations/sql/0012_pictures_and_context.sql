-- Pictures and test context (ADR-022).
-- Who added a picture, so only they can remove it; a removed picture is
-- kept (marked), and devices drop their copy.
ALTER TABLE attachment
  ADD COLUMN collector_key uuid,
  ADD COLUMN removed_at timestamptz,
  ADD COLUMN removed_by_installation uuid REFERENCES installation(id);

-- A test needs a picture of the kit or reading, unless the collector gave
-- a reason (camera not working, not allowed, no light, or typed).
ALTER TABLE test_session ADD COLUMN no_photo_reason text;
