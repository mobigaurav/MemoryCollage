"""PostHog capture. Quiet when POSTHOG_API_KEY is empty.

A missing key or a slow host must never fail the request that triggered it.
"""

from __future__ import annotations

import logging

import httpx

from mb_api.config import get_settings

logger = logging.getLogger(__name__)


class Events:
    ai_clip_started = "ai.clip.started"
    world_posted = "world.posted"


def track(event: str, *, distinct_id: str, properties: dict | None = None) -> None:
    settings = get_settings()
    key = (settings.posthog_api_key or "").strip()
    if not key or not distinct_id:
        return
    host = (settings.posthog_host or "https://us.i.posthog.com").rstrip("/")
    body = {
        "api_key": key,
        "event": event,
        "distinct_id": distinct_id,
        "properties": {"source": "api", **(properties or {})},
    }
    try:
        httpx.post(f"{host}/capture/", json=body, timeout=2.0)
    except Exception as exc:
        logger.info("analytics skipped: %s", exc)
