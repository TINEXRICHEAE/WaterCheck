# ADR-029: Live navigation, trip tracks and located pictures

- Status: Accepted (2026-10-25)
- Covers: the lead's request of 2026-10-25 (DEVLOG entry 42)
- Amends: the photo compressor's "no EXIF" rule (P7); the Privacy Policy (ADR-026), version 3

## Context

Routes were drawn once, from where the device was when asked. The lead asked for:

- live movement, as in Google Maps or SafeBoda: position, speed, altitude and time while travelling, with the route kept up to date;
- the same location details added to the pictures of sources and tests.

The lead chose:

- **live navigation without voice**, with the trip kept as a track on the device;
- **location on pictures saved both with the record and inside the image file.**

## Decision

1. **Live navigation** (UI kit `LiveTrip`, both apps). A **Go** button on the chosen source or place starts it.
   - **Following:** the map follows the device, using a stream of fixes (about every 5 m).
   - **A small panel:** speed, altitude, direction, accuracy, the time of the last fix, the distance left and the arrival time.
   - **Off the route:** more than 50 m off it, the route is fetched again, at most every 20 seconds.
   - **Arrival:** within 30 m it says "You have arrived". **Stop** ends the trip.
   - **The travelled path** is drawn in a second colour.
   - **No voice.**
2. **Trip tracks, kept on the device only.**
   - **Collect:**
     - Each trip and its fixes are saved in two local tables, `trips` and `trip_points` (device schema 11), and are never synced.
     - **My trips** under My profile lists each trip:
       - where to, the date and the distance;
       - how long it took, the top speed and the altitude range;
       - and its map.
     - The tester can delete trips, and removing their profile from the device deletes them too.
   - **Console:** the web Console navigates live but does not keep tracks.
3. **Location on pictures.**
   - **When a picture is taken or chosen,** the app takes a fix: up to 15 s, or the latest live fix. A picture is still saved without one.
   - **The details:** position, accuracy, altitude, speed, direction and time.
   - **Where they are kept:**
     - on the picture's record, on the device and on the server (attachment columns, migration 0017), sent with the picture;
     - in the JPEG file's EXIF GPS tags, with the time taken.
   - **What is never written:** the device's make, model or other metadata.
   - **Shown:** under the picture in both apps.
4. **Privacy.**
   - The Privacy Policy (version 3) says that pictures carry where and when they were taken, and that trip tracks stay on the device.
   - Everyone accepts again.

## Satellite view (not built)

- It needs an imagery provider (Esri, MapTiler, Mapbox or Google), which means an account, terms and possibly cost.
- It works online only, and it sends the area viewed to that provider.
- The lead will choose a provider. Then the layers button gets a "Satellite" choice, with the provider's credit and a key restricted to our domains.

## Consequences

- **Battery and data:** following uses the GPS continuously and fetches routes again, so it is meant for the trip only and stops when the person stops it or leaves the map.
- **Pictures once shared:** they reveal where they were taken, which is the point for a water source. Testers are told not to photograph people (Terms).
- **On the web:** the browser often gives no altitude or speed; the panel then shows "—".
