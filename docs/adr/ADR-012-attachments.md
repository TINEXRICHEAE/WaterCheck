# ADR-012: Photo attachments, uploaded in chunks through the API

- Status: Accepted (2026-10-10). The project lead chose this option.
- Covers: SPEC P7, §8.3, F-TST-6, F-SRC-1 (photo), chaos test §12.3 #7
- Amends: SPEC §8.3 ("pre-signed URL"), the plan's P7 [DECIDE], ADR-003 (S3 credentials)

## Context

Photos of the tester display and of sources are optional evidence (§9.1 "fake readings"). They must work offline, upload reliably over poor links, and never delay readings.

The spec says to upload the binary to MinIO/S3 through a pre-signed URL, with chunked, resumable upload. The plan's ★ option was S3 multipart with pre-signed part URLs. It does not fit:

- S3 multipart parts must be at least 5 MB, except the last. A photo compressed to ≤ 300 KB is therefore a single part, so an upload cut at 50% cannot resume. That is a P7 gate item.
- Pre-signed URLs only work if phones can reach the object store at the signed host. Storage would have to be exposed through Caddy, with Host headers matching per network (localhost, 10.0.2.2, a LAN address, the production domain).

## Decision

**Phones upload photos to the API in chunks; the API verifies each photo and writes it to object storage.** Storage stays private.

### 1. Metadata first, by sync

- The `attachment` record (id, owner, SHA-256, size, MIME) travels in the normal sync push.
- **Owners:** a source (`water_source`) or a test (`test_session`). The record is visible to whoever can see the owner (row-level security, migration 0003).
- **Limits:** JPEG only; 1 MB maximum (phones aim for 300 KB); the hash must be 64 hex characters.

### 2. Resumable upload

| Call | What it does |
|------|--------------|
| `GET /v1/attachments/{id}/upload` | Returns how many bytes the server holds. The phone resumes from there. |
| `PUT /v1/attachments/{id}/upload?offset=N` | Appends a chunk of up to 256 KB (the phone sends 64 KB). It must start exactly where the server is; otherwise the answer is `409 offset_mismatch` with the right offset. Requests are signed like any other Collect request (ADR-009/011), so the chunk's hash is covered by the signature. |
| `POST /v1/attachments/{id}/complete` | Checks size, magic bytes and SHA-256. Valid: the photo is stored as `attachments/<id>.jpg`, the staged chunks are dropped, and the status becomes `uploaded`. Invalid: `rejected` with the reason (`hash_mismatch`, `not_an_image`, …). Calling it again returns the same result. |
| `GET /v1/attachments/{id}/content` | The photo, for anyone who can see its owner (the Console viewer is P9). |

- Chunks are staged in Postgres (`attachment_chunk`) until `complete`. Photos are small, so this keeps the upload transactional with no extra service.
- If storage fails during `complete`, the transaction rolls back and the phone retries.

### 3. On the phone (Collect)

- **Compression:** the image is decoded, its orientation applied to the pixels, scaled down and re-encoded until it is ≤ 300 KB. No EXIF is written, so GPS position, device model and capture time never leave the phone in a photo; the record has its own GPS fix. Compression runs in a background isolate.
- **Storage:** photos are kept in the app-private support folder, never the shared gallery. The file, the metadata row, the upload-queue row and the outbox entry are written together.
- **Upload** runs after a successful sync. It only starts once the metadata has reached the server (outbox `sent`) and resumes from the server's byte count.
  - **Wi-Fi only by default.** On mobile data, readings sync and photos wait. Settings → "Upload photos on mobile data" allows it.
  - The Android background worker does the same after its sync.
- **Low-storage guard (chaos #7):** below 100 MB free (Android `StatFs`, Windows `GetDiskFreeSpaceExW`), adding a photo is refused with a message and the camera is not even opened. Readings, sources and inspections are not affected.
- **Wipe:** a revocation wipe also deletes stored photos (F-AUTH-4).
- **Platforms:** Android takes or chooses a photo; Windows and the web preview choose a file. On the web, photos are kept in memory only.

### 4. Object storage (ADR-003 follow-up)

- SeaweedFS now requires an S3 key pair (`WC_S3_ACCESS_KEY` / `WC_S3_SECRET_KEY` in `.env`); anonymous access answers 403.
- Only the API has the keys. The bucket `watercheck-attachments` is created on first use.
- The API refuses to start in staging or production with the development storage secret.

## Consequences

- **Spec deviation:** no pre-signed URLs. The API carries photo bytes, which is about 300 KB per photo and well within the VPS budget. Large files (if ever) would need another path.
- **Resume within a photo works** (live test: a 282 KB photo cut at 128 KB resumed, and the hash matched in SeaweedFS). The P7 gate item holds.
- Staged chunks of abandoned uploads stay in `attachment_chunk`; a cleanup job (P12) removes chunks older than 30 days.
- The Console photo viewer, and photos in reports, come in P9/P10.
