from fastapi.testclient import TestClient

from app.main import create_app


def test_health_returns_ok() -> None:
    client = TestClient(create_app())
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_request_id_is_echoed() -> None:
    client = TestClient(create_app())
    response = client.get("/health", headers={"x-request-id": "abc-123"})
    assert response.headers["x-request-id"] == "abc-123"
