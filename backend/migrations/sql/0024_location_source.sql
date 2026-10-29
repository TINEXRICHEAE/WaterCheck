-- Where a record's or test's location came from (2026-10-29): null for the
-- device itself (GPS, or a computer's own location), 'internet' for a
-- computer's rough guess from its connection, 'hand' when set on the map.
-- Teams see which points were not measured.
ALTER TABLE research.record
  ADD COLUMN location_source text CHECK (location_source IN ('internet', 'hand'));
ALTER TABLE test_session
  ADD COLUMN location_source text CHECK (location_source IN ('internet', 'hand'));
