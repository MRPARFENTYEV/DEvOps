from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_index_returns_page():
    response = client.get("/")
    assert response.status_code == 200
    assert "Дипломный проект" in response.text


def test_health_returns_ok():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_metrics_exposes_prometheus_format():
    client.get("/health")

    response = client.get("/metrics")
    assert response.status_code == 200
    assert "app_requests_total" in response.text


def test_unknown_path_returns_404():
    assert client.get("/no-such-page").status_code == 404
