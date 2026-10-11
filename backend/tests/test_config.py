import asyncio

import pytest

from app import worker
from app.core.config import Settings, get_settings


def test_settings_read_prefixed_env(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("WC_ENVIRONMENT", "staging")
    monkeypatch.setenv("WC_LOG_LEVEL", "DEBUG")
    settings = Settings()
    assert settings.environment == "staging"
    assert settings.log_level == "DEBUG"


def test_worker_stops_when_signalled(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("WC_WORKER_POLL_SECONDS", "0.01")
    get_settings.cache_clear()

    async def scenario() -> None:
        stop = asyncio.Event()
        task = asyncio.create_task(worker.run(stop))
        await asyncio.sleep(0.05)
        stop.set()
        await asyncio.wait_for(task, timeout=1)

    asyncio.run(scenario())
    get_settings.cache_clear()
