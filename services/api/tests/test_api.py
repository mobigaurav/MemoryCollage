import os

import pytest
from fastapi.testclient import TestClient

from mb_api.community_store import reset_memory
from mb_api.household_store import MemoryHouseholds, reset_households
from mb_api.config import get_settings
from mb_api.main import app
from mb_api.store import store

os.environ.setdefault("ENV", "dev")


@pytest.fixture(autouse=True)
def _clean(monkeypatch):
    monkeypatch.setenv("ENV", "dev")
    monkeypatch.setenv("COMMUNITY_MEMORY", "1")
    monkeypatch.setenv("HOUSEHOLD_MEMORY", "1")
    monkeypatch.setenv("POSTHOG_API_KEY", "")
    monkeypatch.delenv("VIDEO_VENDOR", raising=False)
    monkeypatch.delenv("VIDEO_VENDOR_API_KEY", raising=False)
    monkeypatch.delenv("FAL_TEXT_MODEL", raising=False)
    monkeypatch.delenv("FAL_IMAGE_MODEL", raising=False)
    get_settings.cache_clear()
    store.reset()
    reset_memory()
    reset_households()
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


def test_text_without_a_vendor_does_not_spend():
    response = client.post(
        "/v1/ai/video",
        headers={"Authorization": "Bearer dev"},
        json={"prompt": "a paper boat on a quiet lake"},
    )
    body = response.json()
    assert response.status_code == 200
    assert body["status"] == "unavailable"
    assert body["fallbackToOnDevice"] is False
    assert body["balance"] == 3


def test_fal_queues_image_and_prompt_then_returns_the_clip(monkeypatch):
    from mb_api.fal_video import FalPoll, FalSubmit
    from mb_api.routers import ai as ai_router

    class FakeFal:
        def __init__(self, settings, http=None):
            pass

        def submit(self, **kwargs):
            assert kwargs["image_base64"]
            assert "lake" in kwargs["prompt"]
            return FalSubmit(
                "req-1",
                "https://queue.fal.run/fal-ai/pixverse/v6/image-to-video/requests/req-1/status",
                "https://queue.fal.run/fal-ai/pixverse/v6/image-to-video/requests/req-1",
            )

        def poll(self, status_url, response_url):
            assert status_url.startswith("https://queue.fal.run/")
            return FalPoll("completed", video_url="https://example.com/clip.mp4")

        def close(self):
            pass

    monkeypatch.setattr(ai_router, "FalVideo", FakeFal)
    monkeypatch.setenv("VIDEO_VENDOR", "fal")
    monkeypatch.setenv("VIDEO_VENDOR_API_KEY", "test-key")
    get_settings.cache_clear()
    response = client.post(
        "/v1/ai/video",
        headers={"Authorization": "Bearer dev"},
        json={
            "imageBase64": "aGVsbG8gd29ybGQ=",
            "prompt": "the lake ripples",
        },
    )
    body = response.json()
    assert response.status_code == 200
    assert body["status"] == "queued"
    assert body["balance"] == 2
    job = client.get(
        f"/v1/ai/jobs/{body['jobId']}",
        headers={"Authorization": "Bearer dev"},
    )
    finished = job.json()
    assert finished["status"] == "completed"
    assert finished["videoUrl"] == "https://example.com/clip.mp4"
    assert finished["balance"] == 2


def test_runway_sends_a_photo_to_gen4_turbo(monkeypatch):
    from mb_api.routers import ai as ai_router
    from mb_api.runway_video import RunwayPoll, RunwaySubmit

    class FakeRunway:
        def __init__(self, settings, http=None):
            pass

        def submit(self, **kwargs):
            assert kwargs["image_base64"]
            assert "lake" in kwargs["prompt"]
            return RunwaySubmit(
                "task-1",
                "https://api.dev.runwayml.com/v1/tasks/task-1",
                "https://api.dev.runwayml.com/v1/tasks/task-1",
            )

        def poll(self, status_url, response_url):
            assert status_url.startswith("https://api.dev.runwayml.com/v1/tasks/")
            return RunwayPoll("completed", video_url="https://example.com/runway.mp4")

        def close(self):
            pass

    monkeypatch.setattr(ai_router, "RunwayVideo", FakeRunway)
    monkeypatch.setenv("VIDEO_VENDOR", "runway")
    monkeypatch.setenv("VIDEO_VENDOR_API_KEY", "test-key")
    get_settings.cache_clear()
    response = client.post(
        "/v1/ai/video",
        headers={"Authorization": "Bearer dev"},
        json={
            "imageBase64": "aGVsbG8gd29ybGQ=",
            "prompt": "the lake ripples",
        },
    )
    body = response.json()
    assert response.status_code == 200
    assert body["status"] == "queued"
    assert body["balance"] == 2
    job = client.get(
        f"/v1/ai/jobs/{body['jobId']}",
        headers={"Authorization": "Bearer dev"},
    )
    finished = job.json()
    assert finished["videoUrl"] == "https://example.com/runway.mp4"
    assert finished["balance"] == 2


def test_world_feed_is_readable_without_an_account():
    response = client.get("/v1/community")
    assert response.status_code == 200
    assert response.json()["posts"] == []


def test_world_post_love_ignore_and_delete():
    created = client.post(
        "/v1/community",
        headers={"Authorization": "Bearer dev"},
        json={"title": "Sunday", "kind": "album", "count": 2},
    )
    assert created.status_code == 200
    body = created.json()
    keys = [item["key"] for item in body["uploads"]]
    published = client.post(
        f"/v1/community/{body['id']}/publish",
        headers={"Authorization": "Bearer dev"},
        json={"keys": keys},
    )
    assert published.status_code == 200
    assert published.json()["author"] == "Dev"
    feed = client.get("/v1/community").json()["posts"]
    assert feed[0]["title"] == "Sunday"
    assert feed[0]["mine"] is False
    loved = client.post(
        f"/v1/community/{body['id']}/love",
        headers={"Authorization": "Bearer dev"},
    )
    assert loved.json() == {"loved": True, "loves": 1}
    ignored = client.post(
        f"/v1/community/{body['id']}/ignore",
        headers={"Authorization": "Bearer dev"},
    )
    assert ignored.status_code == 200
    hidden = client.get(
        "/v1/community",
        headers={"Authorization": "Bearer dev"},
    ).json()["posts"]
    assert hidden == []
    still_there = client.get("/v1/community").json()["posts"]
    assert len(still_there) == 1
    removed = client.delete(
        f"/v1/community/{body['id']}",
        headers={"Authorization": "Bearer dev"},
    )
    assert removed.status_code == 200
    assert client.get("/v1/community").json()["posts"] == []


def test_push_token_registers_and_unregisters():
    denied = client.post(
        "/v1/notifications/register",
        json={"device_token": "token-12345678", "platform": "ios"},
    )
    assert denied.status_code == 401
    registered = client.post(
        "/v1/notifications/register",
        headers={"Authorization": "Bearer dev"},
        json={"device_token": "token-12345678", "platform": "ios"},
    )
    assert registered.status_code == 204
    assert store.device_tokens["token-12345678"][0] == "dev-local-user"
    removed = client.request(
        "DELETE",
        "/v1/notifications/register",
        headers={"Authorization": "Bearer dev"},
        json={"device_token": "token-12345678"},
    )
    assert removed.status_code == 204
    assert "token-12345678" not in store.device_tokens


def test_analytics_without_a_key_does_not_raise():
    from mb_api.analytics_service import track

    track("ai.clip.started", distinct_id="dev-local-user")


def test_world_post_requires_sign_in():
    response = client.post(
        "/v1/community",
        json={"title": "Sunday", "kind": "album", "count": 1},
    )
    assert response.status_code == 401


def test_family_book_stays_with_the_people_who_have_the_code():
    denied = client.post("/v1/households", json={"title": "The Kumars"})
    assert denied.status_code == 401
    created = client.post(
        "/v1/households",
        headers={"Authorization": "Bearer dev"},
        json={"title": "The Kumars"},
    )
    assert created.status_code == 200
    code = created.json()["code"]
    assert len(code) == 6
    listed = client.get(
        "/v1/households",
        headers={"Authorization": "Bearer dev"},
    )
    assert listed.json()["books"][0]["title"] == "The Kumars"
    missing = client.post(
        "/v1/households/join",
        headers={"Authorization": "Bearer dev"},
        json={"code": "NOBOOK"},
    )
    assert missing.status_code == 404
    reserved = client.post(
        f"/v1/households/{code}/photos",
        headers={"Authorization": "Bearer dev"},
        json={"count": 1},
    )
    assert reserved.status_code == 200
    key = reserved.json()["uploads"][0]["key"]
    assert key.startswith(f"households/{code}/")
    saved = client.post(
        f"/v1/households/{code}/photos/commit",
        headers={"Authorization": "Bearer dev"},
        json={"keys": [key]},
    )
    assert saved.status_code == 200
    assert saved.json()["photos"][0]["author"] == "Dev"
    books = MemoryHouseholds()
    owner = books.create(sub="owner", name="Asha", title="Sunday")
    books.join(sub="cousin", name="Ravi", code=owner.code)
    assert books.get(owner.code, "stranger") is None
    assert books.get(owner.code, "cousin") is not None
