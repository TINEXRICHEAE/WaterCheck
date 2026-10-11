# ADR-003: SeaweedFS instead of MinIO for S3-compatible storage

- Status: Accepted (2026-10-10)
- Amends: SPEC §10.1 ("MinIO locally") and the P0 task list

## Context

The spec names MinIO for local S3-compatible storage. In late 2025, MinIO stopped publishing free community images. As of 2026-10-10:

- `minio/minio` no longer exists on Docker Hub;
- `quay.io/minio/minio` requires authentication.

Photos (P7) need pre-signed URLs and resumable (multipart) uploads.

## Decision

Use **SeaweedFS** with its built-in S3 gateway in dev: image `chrislusf/seaweedfs`, Apache-2.0, pinned to 4.48. The backend talks only to the S3 API (via `boto3`/`aioboto3` in P7) and never to SeaweedFS-specific endpoints.

Alternatives considered:

- RustFS: MinIO-like, but a younger project;
- Garage: lightweight, but with fewer S3 features;
- pinning an old MinIO build: gets no security updates.

## Consequences

- Production can use SeaweedFS on the VPS, or any managed S3 service, without code changes.
- P7 must verify pre-signed PUT and multipart upload against SeaweedFS. If a feature is missing, revisit with RustFS.
- S3 credentials are configured in P7. Until then, dev runs without S3 auth, bound to 127.0.0.1 only. *Done in P7: SeaweedFS requires the key pair from `.env`; uploads go through the API instead of pre-signed URLs, so multipart was not needed (ADR-012).*
