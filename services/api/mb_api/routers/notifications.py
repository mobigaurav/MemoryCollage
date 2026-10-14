from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse, Response
from pydantic import BaseModel, Field

from mb_api.store import store

router = APIRouter()


class DeviceTokenIn(BaseModel):
    device_token: str = Field(min_length=8, max_length=4096)
    platform: str = "unknown"


class DeviceTokenDeleteIn(BaseModel):
    device_token: str = Field(min_length=8, max_length=4096)


def _platform(raw: str) -> str:
    value = (raw or "unknown").strip().lower()
    if value not in {"ios", "android", "web", "unknown"}:
        return "unknown"
    return value


@router.post("/v1/notifications/register", status_code=204)
def register_device_token(body: DeviceTokenIn, request: Request) -> Response:
    token = body.device_token.strip()
    if not token:
        return JSONResponse(status_code=400, content={"message": "device_token required"})
    store.ensure_user(request.state.sub, request.state.email)
    store.save_device_token(request.state.sub, token, _platform(body.platform))
    return Response(status_code=204)


@router.delete("/v1/notifications/register", status_code=204)
def unregister_device_token(body: DeviceTokenDeleteIn, request: Request) -> Response:
    store.delete_device_token(request.state.sub, body.device_token.strip())
    return Response(status_code=204)
