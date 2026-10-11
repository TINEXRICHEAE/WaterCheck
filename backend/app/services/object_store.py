"""Where finished attachments live (ADR-003, ADR-012).

The API is the only client of object storage: phones upload to the API in
chunks, and the API writes the verified photo here. Storage is never exposed
to the internet.
"""

from __future__ import annotations

from typing import Protocol

import anyio
import boto3
from botocore.config import Config
from botocore.exceptions import ClientError

from app.core.config import Settings


class ObjectStore(Protocol):
    async def put(self, key: str, data: bytes, content_type: str) -> None: ...

    async def get(self, key: str) -> bytes | None: ...


class S3ObjectStore:
    """Any S3-compatible service (SeaweedFS in dev and on the VPS)."""

    def __init__(self, settings: Settings) -> None:
        self.bucket = settings.s3_bucket
        self._client = boto3.client(
            "s3",
            endpoint_url=settings.s3_endpoint_url,
            aws_access_key_id=settings.s3_access_key,
            aws_secret_access_key=settings.s3_secret_key.get_secret_value(),
            region_name="us-east-1",
            config=Config(s3={"addressing_style": "path"}, retries={"max_attempts": 3}),
        )
        self._bucket_ready = False

    def _ensure_bucket(self) -> None:
        if self._bucket_ready:
            return
        try:
            self._client.head_bucket(Bucket=self.bucket)
        except ClientError:
            self._client.create_bucket(Bucket=self.bucket)
        self._bucket_ready = True

    async def put(self, key: str, data: bytes, content_type: str) -> None:
        def run() -> None:
            self._ensure_bucket()
            self._client.put_object(
                Bucket=self.bucket, Key=key, Body=data, ContentType=content_type
            )

        await anyio.to_thread.run_sync(run)

    async def get(self, key: str) -> bytes | None:
        def run() -> bytes | None:
            try:
                body = self._client.get_object(Bucket=self.bucket, Key=key)["Body"]
                data: bytes = body.read()
                return data
            except ClientError as e:
                if e.response.get("Error", {}).get("Code") in ("NoSuchKey", "404"):
                    return None
                raise

        return await anyio.to_thread.run_sync(run)


class MemoryObjectStore:
    """For tests."""

    def __init__(self) -> None:
        self.objects: dict[str, tuple[bytes, str]] = {}

    async def put(self, key: str, data: bytes, content_type: str) -> None:
        self.objects[key] = (data, content_type)

    async def get(self, key: str) -> bytes | None:
        found = self.objects.get(key)
        return found[0] if found else None
