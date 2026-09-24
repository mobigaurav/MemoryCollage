import os

import pytest
from fastapi.testclient import TestClient

from mb_api.config import get_settings
from mb_api.main import app
from mb_api.store import store

os.environ.setdefault("ENV", "dev")


@pytest.fixture(autouse=True)
def _clean(monkeypatch):
    monkeypatch.setenv("ENV", "dev")
    monkeypatch.delenv("VIDEO_VENDOR", raising=False)
    monkeypatch.delenv("VIDEO_VENDOR_API_KEY", raising=False)
    get_settings.cache_clear()
    store.reset()
    yield
    get_settings.cache_clear()


client = TestClient(app)


def test_health_is_public():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["service"] == "memory-book"


def test_video_requires_a_session():
    response = client.post(
        "/v1/ai/video",
        json={"imageBase64": "aGVsbG8gd29ybGQ="},
    )
    assert response.status_code == 401


def test_missing_vendor_falls_back_without_spending():
    response = client.post(
        "/v1/ai/video",
        headers={"Authorization": "Bearer dev"},
        json={"imageBase64": "aGVsbG8gd29ybGQ=", "style": "cinematic"},
    )
    body = response.json()
    assert response.status_code == 200
    assert body["fallbackToOnDevice"] is True
    assert body["balance"] == 3


def test_configured_vendor_queues_and_debits(monkeypatch):
    monkeypatch.setenv("VIDEO_VENDOR", "luma")
    monkeypatch.setenv("VIDEO_VENDOR_API_KEY", "test-key")
    get_settings.cache_clear()
    response = client.post(
        "/v1/ai/video",
        headers={"Authorization": "Bearer dev"},
        json={"imageBase64": "aGVsbG8gd29ybGQ="},
    )
    body = response.json()
    assert response.status_code == 200
    assert body["status"] == "queued"
    assert body["balance"] == 2
    job = client.get(
        f"/v1/ai/jobs/{body['jobId']}",
        headers={"Authorization": "Bearer dev"},
    )
    assert job.status_code == 200
    assert job.json()["status"] == "queued"
