-- Map place names placed in their sub-county (ADR-023). There is no
-- official parish or village list, but the map (OpenStreetMap) names about
-- 64,000 villages, hamlets, trading centres and neighbourhoods, each at a
-- point. Each point is put in the UBOS sub-county whose boundary contains
-- it, so the apps can suggest "Kabojja · Kyengera Town Council, Wakiso"
-- wherever a place is typed or searched. The official tree (admin_unit)
-- is not changed by this list.

-- Sub-county boundaries (UBOS via OCHA COD-AB, simplified to ~30 m), kept
-- on the server only: they answer "which sub-county is this point in?".
CREATE TABLE subcounty_shape (
  admin_unit_id uuid PRIMARY KEY REFERENCES admin_unit(id),
  geom geometry(MultiPolygon, 4326) NOT NULL
);
CREATE INDEX subcounty_shape_geom ON subcounty_shape USING gist(geom);
GRANT SELECT ON subcounty_shape TO watercheck_app;

-- Names from the map, with the sub-county they fall in. Read by everyone;
-- written only by the loader (python -m app.places_load).
CREATE TABLE place_name (
  id uuid PRIMARY KEY,
  osm_id bigint UNIQUE,
  name text NOT NULL,
  kind text NOT NULL,
  lat double precision NOT NULL,
  lon double precision NOT NULL,
  subcounty_id uuid NOT NULL REFERENCES admin_unit(id),
  server_seq bigint NOT NULL,
  server_xid xid8 NOT NULL
);
CREATE INDEX place_name_lower ON place_name (lower(name) text_pattern_ops);
CREATE INDEX place_name_subcounty ON place_name (subcounty_id);
CREATE INDEX place_name_feed_idx ON place_name (server_xid, server_seq);
CREATE TRIGGER place_name_server_seq BEFORE INSERT OR UPDATE ON place_name
  FOR EACH ROW EXECUTE FUNCTION wc_set_server_seq();
GRANT SELECT ON place_name TO watercheck_app;

-- The sub-county containing a point, or null (outside Uganda, or shapes
-- not loaded).
CREATE FUNCTION wc_subcounty_at(lat double precision, lon double precision)
  RETURNS uuid LANGUAGE sql STABLE AS
$$ SELECT admin_unit_id FROM subcounty_shape
   WHERE ST_Contains(geom, ST_SetSRID(ST_MakePoint(lon, lat), 4326))
   LIMIT 1 $$;
GRANT EXECUTE ON FUNCTION wc_subcounty_at(double precision, double precision) TO watercheck_app;

-- Which build of the two files is loaded, so the loader runs once per build.
CREATE TABLE places_import (
  checksum text PRIMARY KEY,
  places integer NOT NULL,
  loaded_at timestamptz NOT NULL DEFAULT now()
);
