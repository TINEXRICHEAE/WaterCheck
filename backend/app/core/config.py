"""Settings loaded from environment variables (prefix ``WC_``)."""

from functools import lru_cache
from typing import Literal

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="WC_", env_file=".env", extra="ignore")

    environment: Literal["dev", "test", "staging", "prod"] = "dev"
    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR"] = "INFO"

    # API connection: the restricted `watercheck_api` role (ADR-009).
    database_url: str | None = None
    # Migrations and admin CLI: the owner role.
    migration_database_url: str | None = None

    # Signs access tokens. Must be set (≥ 32 chars) outside dev and test.
    jwt_secret: SecretStr = SecretStr("dev-only-jwt-secret-change-me-0123456789")
    # Encrypts installation secrets at rest (Fernet key, urlsafe base64).
    secret_key: SecretStr = SecretStr("ZGV2LW9ubHktc2VjcmV0LWtleS1jaGFuZ2UtbWUtMDA=")

    access_token_minutes: int = 15
    refresh_token_days: int = 30
    max_failed_logins: int = 5
    lockout_minutes: int = 15
    activation_code_days: int = 7
    # Devices that register themselves (ADR-024), per address and hour.
    self_registrations_per_hour: int = 20
    signature_window_seconds: int = 300

    # Web Console keeps its refresh token in an httpOnly cookie (ADR-010).
    # The path is the browser-visible one, including the proxy's /api prefix.
    refresh_cookie_path: str = "/api/v1/auth"
    # Browsers treat http://localhost as secure, so this stays on in dev.
    cookie_secure: bool = True

    # Object storage for attachments (ADR-003, ADR-012). Unset: uploads are
    # refused with 503 (tests use an in-memory store).
    s3_endpoint_url: str | None = None
    s3_bucket: str = "watercheck-attachments"
    s3_access_key: str = "watercheck"
    s3_secret_key: SecretStr = SecretStr("dev-only-s3-secret")
    # Largest photo accepted after the phone compresses it (≤ 300 KB aimed).
    max_attachment_bytes: int = 1024 * 1024

    # Notifications (ADR-013). Unset channels are simply not used.
    smtp_host: str | None = None
    smtp_port: int = 1025
    smtp_username: str = ""
    smtp_password: SecretStr = SecretStr("")
    smtp_starttls: bool = False
    smtp_from: str = "WaterCheck <no-reply@watercheck.local>"
    fcm_service_account_file: str | None = None
    # SMS gateway (SPEC §8.5): "africastalking" or none.
    sms_provider: str | None = None
    sms_username: str = ""
    sms_api_key: SecretStr = SecretStr("")
    sms_sender_id: str = ""
    # Shared secret in the inbound webhook URL (the provider does not sign).
    sms_webhook_token: SecretStr = SecretStr("dev-only-sms-webhook-token")
    # Where links in emails point.
    console_url: str = "http://localhost/console/"

    seed_dir: str = "../infra/seed"
    # Raster MBTiles of the pilot area (tools/build_tiles.ps1, ADR-014).
    tiles_path: str = "../infra/tiles/area.mbtiles"
    # How often an idle worker looks for due jobs (alerts notify ≤ 5 min).
    worker_poll_seconds: float = 5.0

    def migration_url(self) -> str:
        url = self.migration_database_url or self.database_url
        if url is None:
            raise RuntimeError("WC_MIGRATION_DATABASE_URL is not set")
        return url.replace("+asyncpg", "+psycopg")


@lru_cache
def get_settings() -> Settings:
    return Settings()
