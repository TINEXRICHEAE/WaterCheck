"""FastAPI application factory."""

import time
import uuid
from collections.abc import AsyncIterator, Awaitable, Callable
from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI, Request, Response
from starlette.middleware.gzip import GZipMiddleware

from app import __version__
from app.api import (
    admin,
    admin_archive,
    admin_config,
    attachments,
    auth,
    conflicts,
    dashboard,
    health,
    installations,
    notifications,
    profile,
    recovery,
    reference,
    sync,
    testers,
    tiles,
)
from app.core.config import Settings, get_settings
from app.core.gzip_request import GzipRequestMiddleware
from app.core.logging import configure_logging
from app.db.database import Database
from app.services.object_store import S3ObjectStore

log = structlog.get_logger()

_DEV_SECRETS = {
    Settings.model_fields["jwt_secret"].default.get_secret_value(),
    Settings.model_fields["secret_key"].default.get_secret_value(),
    Settings.model_fields["s3_secret_key"].default.get_secret_value(),
    Settings.model_fields["sms_webhook_token"].default.get_secret_value(),
}


def _check_secrets(settings: Settings) -> None:
    """Refuse to start staging/prod with the development secrets."""
    if settings.environment in ("staging", "prod"):
        secrets = [settings.jwt_secret, settings.secret_key, settings.sms_webhook_token]
        if settings.s3_endpoint_url:
            secrets.append(settings.s3_secret_key)
        for secret in secrets:
            value = secret.get_secret_value()
            if value in _DEV_SECRETS or len(value) < 32:
                raise RuntimeError(
                    "Production secrets are not configured "
                    "(WC_JWT_SECRET, WC_SECRET_KEY, WC_S3_SECRET_KEY)"
                )


def create_app(settings: Settings | None = None) -> FastAPI:
    settings = settings or get_settings()
    configure_logging(settings.log_level)
    _check_secrets(settings)

    @asynccontextmanager
    async def lifespan(app: FastAPI) -> AsyncIterator[None]:
        app.state.db = Database(settings.database_url) if settings.database_url else None
        if settings.s3_endpoint_url:
            app.state.store = S3ObjectStore(settings)
        try:
            yield
        finally:
            if app.state.db is not None:
                await app.state.db.dispose()

    app = FastAPI(
        title="WaterCheck API",
        version=__version__,
        lifespan=lifespan,
        # Operation IDs are the route function names: readable client methods.
        generate_unique_id_function=lambda route: route.name,
    )
    app.state.settings = settings
    app.state.db = None
    app.state.store = None
    app.include_router(health.router)
    app.include_router(auth.router)
    app.include_router(installations.router)
    app.include_router(reference.router)
    app.include_router(sync.router)
    app.include_router(attachments.router)
    app.include_router(notifications.router)
    app.include_router(tiles.router)
    app.include_router(conflicts.router)
    app.include_router(dashboard.router)
    app.include_router(admin.router)
    app.include_router(admin_config.router)
    app.include_router(admin_archive.router)
    app.include_router(profile.router)
    app.include_router(testers.router)
    app.include_router(recovery.router)
    # Small links (SPEC §8.1): compressed requests in, compressed responses out.
    app.add_middleware(GZipMiddleware, minimum_size=1024)
    app.add_middleware(GzipRequestMiddleware)

    @app.middleware("http")
    async def request_context(
        request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response:
        request_id = request.headers.get("x-request-id") or str(uuid.uuid4())
        structlog.contextvars.bind_contextvars(request_id=request_id)
        start = time.perf_counter()
        try:
            response = await call_next(request)
        finally:
            structlog.contextvars.clear_contextvars()
        response.headers["x-request-id"] = request_id
        # Path and status only: no query strings or bodies (they may hold PII).
        log.info(
            "request",
            request_id=request_id,
            method=request.method,
            path=request.url.path,
            status=response.status_code,
            ms=round((time.perf_counter() - start) * 1000, 1),
        )
        return response

    log.info("api_started", environment=settings.environment, version=__version__)
    return app


app = create_app()
