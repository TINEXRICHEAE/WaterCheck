-- Places added from phones (ADR-019): a collector's village, parish or
-- sub-county that is not in the list is added at once, marked 'new', and
-- reviewed later by the IT admin (rename or merge in Places).
ALTER TABLE admin_unit
  ADD COLUMN review_status text NOT NULL DEFAULT 'official'
    CHECK (review_status IN ('official', 'new')),
  ADD COLUMN added_by_installation uuid REFERENCES installation(id),
  ADD COLUMN added_collector_snapshot jsonb,
  ADD COLUMN added_at timestamptz;

CREATE INDEX admin_unit_new ON admin_unit(added_at) WHERE review_status = 'new';
