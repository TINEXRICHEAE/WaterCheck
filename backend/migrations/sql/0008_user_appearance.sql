-- Each person's theme and time zone (the lead, 2026-10-13): follow them to
-- any device. Times are stored in UTC; the zone only changes how they show.
ALTER TABLE app_user
  ADD COLUMN theme text NOT NULL DEFAULT 'system'
    CHECK (theme IN ('system', 'light', 'dark')),
  ADD COLUMN time_zone text NOT NULL DEFAULT 'Africa/Kampala'
    CHECK (time_zone IN ('auto', 'Africa/Kampala', 'Africa/Nairobi', 'UTC'));
