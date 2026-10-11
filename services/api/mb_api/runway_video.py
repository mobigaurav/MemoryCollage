"""Runway video. The key stays on the server.

A photo uses Gen-4 Turbo (image, or image plus words). Words alone use
Gen-4.5, because Turbo will not start without a picture. Submit returns
immediately; the phone polls our job route.
"""

from __future__ import annotations

import base64
from dataclasses import dataclass

import httpx

from mb_api.config import Settings

_API = "https://api.dev.runwayml.com/v1"
_VERSION = "2024-11-06"


@dataclass(frozen=True)
class RunwaySubmit:
    request_id: str
    status_url: str
    response_url: str


@dataclass(frozen=True)
class RunwayPoll:
    status: str
    video_url: str | None = None
    error: str | None = None


class RunwayVideo:
    def __init__(self, settings: Settings, http: httpx.Client | None = None) -> None:
        self._settings = settings
        self._http = http or httpx.Client(timeout=20.0)
        self._owns_client = http is None

    def close(self) -> None:
        if self._owns_client:
            self._http.close()

    def submit(
        self,
        *,
        prompt: str,
        image_base64: str | None,
        duration_sec: int,
    ) -> RunwaySubmit:
        text = prompt.strip()[:1000]
        duration = 5 if duration_sec <= 5 else 10
        if image_base64:
            path = "/image_to_video"
            body: dict[str, object] = {
                "model": "gen4_turbo",
                "promptImage": _data_uri(image_base64),
                "promptText": text,
                "ratio": "720:1280",
                "duration": duration,
            }
        else:
            path = "/text_to_video"
            body = {
                "model": "gen4.5",
                "promptText": text,
                "ratio": "720:1280",
                "duration": duration,
            }
        response = self._http.post(
            f"{_API}{path}",
            headers=_headers(self._settings.video_vendor_api_key),
            json=body,
        )
        payload = _json(response)
        if response.status_code >= 400:
            raise RuntimeError(_error_text(payload, response.status_code))
        task_id = str(payload.get("id") or "")
        if not task_id:
            raise RuntimeError("Runway did not accept the clip.")
        status_url = f"{_API}/tasks/{task_id}"
        return RunwaySubmit(task_id, status_url, status_url)

    def poll(self, status_url: str, response_url: str) -> RunwayPoll:
        del response_url
        _require_runway_url(status_url)
        response = self._http.get(
            status_url,
            headers=_headers(self._settings.video_vendor_api_key),
        )
        payload = _json(response)
        if response.status_code >= 400:
            return RunwayPoll("failed", error=_error_text(payload, response.status_code))
        status = str(payload.get("status") or "PENDING").upper()
        if status == "FAILED":
            return RunwayPoll("failed", error=_failure_text(payload))
        if status != "SUCCEEDED":
            return RunwayPoll("running")
        output = payload.get("output")
        url = output[0] if isinstance(output, list) and output else None
        if not isinstance(url, str) or not url:
            return RunwayPoll("failed", error="The clip finished without a video file.")
        return RunwayPoll("completed", video_url=url)


def _headers(key: str) -> dict[str, str]:
    return {
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "X-Runway-Version": _VERSION,
    }


def _json(response: httpx.Response) -> dict:
    try:
        body = response.json()
    except Exception:
        return {}
    return body if isinstance(body, dict) else {}


def _error_text(payload: dict, status: int) -> str:
    detail = payload.get("error") or payload.get("message") or payload.get("failure")
    if isinstance(detail, dict):
        detail = detail.get("message") or detail.get("msg") or detail
    return str(detail or f"Runway returned {status}")[:300]


def _failure_text(payload: dict) -> str:
    failure = payload.get("failure") or payload.get("failureCode") or "The clip failed."
    if isinstance(failure, dict):
        failure = failure.get("message") or failure
    return str(failure)[:300]


def _require_runway_url(url: str) -> None:
    if not url.startswith(f"{_API}/tasks/"):
        raise RuntimeError("Refusing a video status address outside Runway.")


def _data_uri(image_base64: str) -> str:
    raw = base64.b64decode(image_base64, validate=False)
    mime = "image/png" if raw.startswith(b"\x89PNG") else "image/jpeg"
    return f"data:{mime};base64,{image_base64}"
