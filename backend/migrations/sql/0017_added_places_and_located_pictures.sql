-- Places added from the map (ADR-028) and where pictures were taken
-- (ADR-029).

-- An added place sits with the map's names: no OpenStreetMap id, who added
-- it (a tester's phone or a Console user), and when an admin removed it.
-- The loader only touches rows with an OpenStreetMap id.
ALTER TABLE place_name
  ADD COLUMN added_by_installation uuid REFERENCES installation(id),
  ADD COLUMN added_collector_snapshot jsonb,
  ADD COLUMN added_by_user uuid REFERENCES app_user(id),
  -- Shown as "added by …" everywhere, without reading anyone's account.
  ADD COLUMN added_by_name text,
  ADD COLUMN added_at timestamptz,
  ADD COLUMN removed_at timestamptz,
  ADD CONSTRAINT place_name_origin CHECK (
    osm_id IS NOT NULL OR added_at IS NOT NULL
  );
GRANT INSERT, UPDATE ON place_name TO watercheck_app;

-- Where and when a picture was taken, from the device's GPS (all optional:
-- a picture is kept without a fix).
ALTER TABLE attachment
  ADD COLUMN taken_lat double precision,
  ADD COLUMN taken_lon double precision,
  ADD COLUMN taken_accuracy_m real,
  ADD COLUMN taken_altitude_m real,
  ADD COLUMN taken_speed_mps real,
  ADD COLUMN taken_heading_deg real,
  ADD COLUMN taken_at timestamptz,
  ADD CONSTRAINT attachment_taken_point CHECK (
    (taken_lat IS NULL) = (taken_lon IS NULL)
    AND (taken_lat IS NULL OR taken_lat BETWEEN -90 AND 90)
    AND (taken_lon IS NULL OR taken_lon BETWEEN -180 AND 180)
  );
