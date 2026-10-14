"""FCM send stays off until a service account is configured.

Device tokens are stored either way, so a later sender can use them.
"""

from __future__ import annotations

import os


def fcm_configured() -> bool:
    raw = os.environ.get("FIREBASE_SERVICE_ACCOUNT_JSON", "").strip()
    path = os.environ.get("FIREBASE_SERVICE_ACCOUNT_PATH", "").strip()
    return bool(raw) or bool(path)


def send_push(tokens: list[str], *, title: str, body: str, data: dict | None = None) -> dict:
    del title, body, data
    if not tokens:
        return {"success": 0, "failure": 0, "errors": []}
    if not fcm_configured():
        return {"success": 0, "failure": 0, "errors": ["fcm_not_configured"]}
    return {
        "success": 0,
        "failure": len(tokens),
        "errors": ["fcm_sender_not_enabled"],
    }
