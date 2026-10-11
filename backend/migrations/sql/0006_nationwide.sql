-- Nationwide areas (docs/PLAN.md §3): a region level between country and
-- district, the official UBOS/OCHA P-code, and each unit's centre point
-- (the map moves to the chosen area).
ALTER TABLE admin_unit DROP CONSTRAINT admin_unit_level_check;
ALTER TABLE admin_unit ADD CONSTRAINT admin_unit_level_check
  CHECK (level IN ('country','region','district','subcounty','parish','village'));

ALTER TABLE admin_unit
  ADD COLUMN pcode text UNIQUE,
  ADD COLUMN center_lat double precision CHECK (center_lat BETWEEN -90 AND 90),
  ADD COLUMN center_lon double precision CHECK (center_lon BETWEEN -180 AND 180);
