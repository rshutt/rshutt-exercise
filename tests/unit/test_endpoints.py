import time

from fastapi.testclient import TestClient

from automater_ws.main import app

client = TestClient(app)


def test_endpoint_healtz():
    """Testing the endpoints"""

    # Testing Healthz
    r = client.get("/healthz")
    assert r.status_code == 200
    data = r.json()
    assert data["ok"] is True

    # Testing Readyz
    r = client.get("/readyz")
    assert r.status_code == 200
    data = r.json()
    assert data["ready"] is True

    # Testing Root
    testtime = int(time.time())
    r = client.get("/")
    assert r.status_code == 200
    data = r.json()
    assert data["message"] == "Automate all the things!"
    assert data["timestamp"] == testtime
