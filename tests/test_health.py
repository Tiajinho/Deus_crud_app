from fastapi.testclient import TestClient


def test_health_returns_ok(client: TestClient) -> None:
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_health_includes_candidate_review_header(client: TestClient) -> None:
    resp = client.get("/health")
    assert resp.headers["X-Candidate-Review"] == "auto-generated-skip"
