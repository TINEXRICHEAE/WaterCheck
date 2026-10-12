-- The default limit set per area (D11, F-ADM-2; P11) travels to devices with
-- the area itself, so a new test on a phone starts with it. The
-- area_default_profile table keeps who set it and when.
ALTER TABLE admin_unit
  ADD COLUMN default_standard_id uuid REFERENCES reference_standard(id);

UPDATE admin_unit a SET default_standard_id = d.standard_id
  FROM area_default_profile d WHERE d.admin_unit_id = a.id;
