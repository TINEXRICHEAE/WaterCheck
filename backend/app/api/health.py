from fastapi import APIRouter

router = APIRouter(tags=["health"])


@router.get("/health")
async def health() -> dict[str, str]:
    """Liveness probe used by Caddy, uptime checks and the client sync ping."""
    return {"status": "ok"}
