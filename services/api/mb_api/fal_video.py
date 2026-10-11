"""PixVerse on fal.ai. One key, three inputs: text, image, or both.

The key never ships in the app. Submit returns immediately; the phone
polls our job route, which asks fal for the clip.
"""

from __future__ import annotations

import base64
from dataclasses import dataclass

import httpx

from mb_api.config import Settings

_QUEUE = "https://queue.fal.run"


@dataclass(frozen=True)
class FalSubmit:
    request_id: str
    status_url: str
    response_url: str


@dataclass(frozen=True)
class FalPoll:
    status: str
    video_url: str | None = None
    error: str | None = None


class FalVideo:
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
    ) -> FalSubmit:
        image = _data_uri(image_base64) if image_base64 else None
        model = self._settings.fal_image_model if image else self._settings.fal_text_model
        body: dict[str, object] = {
            "prompt": prompt,
            "duration": duration_sec,
            "resolution": "360p",
            "generate_audio_switch": False,
        }
        if image:
            body["image_url"] = image
        else:
            body["aspect_ratio"] = "9:16"
        response = self._http.post(
            f"{_QUEUE}/{model}",
            headers=_headers(self._settings.video_vendor_api_key),
            json=body,
        )
        payload = _json(response)
        if response.status_code >= 400:
            raise RuntimeError(_error_text(payload, response.status_code))
        request_id = str(payload.get("request_id") or "")
        if not request_id:
            raise RuntimeError("The video service did not accept the clip.")
        status_url = str(payload.get("status_url") or f"{_QUEUE}/{model}/requests/{request_id}/status")
        response_url = str(payload.get("response_url") or f"{_QUEUE}/{model}/requests/{request_id}")
        _require_fal_url(status_url)
        _require_fal_url(response_url)
        return FalSubmit(request_id, status_url, response_url)

    def poll(self, status_url: str, response_url: str) -> FalPoll:
        _require_fal_url(status_url)
        _require_fal_url(response_url)
        headers = _headers(self._settings.video_vendor_api_key)
        status_response = self._http.get(status_url, headers=headers)
        status_body = _json(status_response)
        if status_response.status_code >= 400:
            return FalPoll("failed", error=_error_text(status_body, status_response.status_code))
        status = str(status_body.get("status") or "IN_QUEUE")
        if status_body.get("error"):
            return FalPoll("failed", error=str(status_body["error"]))
        if status != "COMPLETED":
            return FalPoll("running")
        result_response = self._http.get(response_url, headers=headers)
        result = _json(result_response)
        if result_response.status_code >= 400:
            return FalPoll("failed", error=_error_text(result, result_response.status_code))
        url = _video_url(result)
        if not url:
            return FalPoll("failed", error="The clip finished without a video file.")
        return FalPoll("completed", video_url=url)


def _headers(key: str) -> dict[str, str]:
    return {
        "Authorization": f"Key {key}",
        "Content-Type": "application/json",
    }


def _json(response: httpx.Response) -> dict:
    try:
        body = response.json()
    except Exception:
        return {}
    return body if isinstance(body, dict) else {}


def _error_text(payload: dict, status: int) -> str:
    detail = payload.get("detail") or payload.get("message") or payload.get("error")
    if isinstance(detail, list) and detail:
        detail = detail[0]
    if isinstance(detail, dict):
        detail = detail.get("msg") or detail.get("message") or detail
    text = str(detail or f"Video service returned {status}")
    return text[:300]


def _require_fal_url(url: str) -> None:
    if not url.startswith(f"{_QUEUE}/"):
        raise RuntimeError("Refusing a video status address outside fal.")


def _data_uri(image_base64: str) -> str:
    raw = base64.b64decode(image_base64, validate=False)
    mime = "image/png" if raw.startswith(b"\x89PNG") else "image/jpeg"
    return f"data:{mime};base64,{image_base64}"


def _video_url(payload: dict) -> str | None:
    video = payload.get("video")
    if isinstance(video, dict) and isinstance(video.get("url"), str):
        return video["url"]
    data = payload.get("data")
    if isinstance(data, dict):
        return _video_url(data)
    return None
