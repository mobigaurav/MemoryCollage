import os

from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, ValidationError

from mb_api.community_store import author_label
from mb_api.household_store import get_households

router = APIRouter()


class CreateHousehold(BaseModel):
    title: str = Field(min_length=1, max_length=80)
    kind: str = "book"
    layout: dict | None = None


class JoinHousehold(BaseModel):
    code: str = Field(min_length=4, max_length=8)


class ReservePhotos(BaseModel):
    count: int = Field(ge=1, le=12)


class CommitPhotos(BaseModel):
    keys: list[str] = Field(min_length=1, max_length=12)
    slots: list[int] | None = None


class CollageLayout(BaseModel):
    templateId: str = Field(default="grid_3x3", min_length=1, max_length=40)
    background: int = 0xFFF3E6D0
    paper: str = Field(default="plain", min_length=1, max_length=24)
    frames: int = Field(default=9, ge=1, le=20)
    packId: str | None = Field(default=None, max_length=40)


def _layout(raw: CollageLayout | dict | None) -> dict:
    if isinstance(raw, CollageLayout):
        body = raw
    else:
        body = CollageLayout.model_validate(raw or {})
    layout = {
        "templateId": body.templateId.strip(),
        "background": body.background & 0xFFFFFFFF,
        "paper": body.paper.strip(),
        "frames": body.frames,
    }
    if body.packId and body.packId.strip():
        layout["packId"] = body.packId.strip()
    return layout


def _store_or_503():
    households = get_households()
    if households is None:
        return None, JSONResponse(
            status_code=503,
            content={"message": "Family books are not on this server yet."},
        )
    return households, None


def _name(request: Request) -> str:
    return author_label(getattr(request.state, "name", ""), request.state.email)


def _sign_put(key: str) -> str:
    if os.environ.get("HOUSEHOLD_MEMORY") == "1":
        return f"https://memory.invalid/{key}"
    from mb_api.config import get_settings
    import boto3

    bucket = get_settings().media_bucket
    return boto3.client("s3").generate_presigned_url(
        "put_object",
        Params={"Bucket": bucket, "Key": key, "ContentType": "image/jpeg"},
        ExpiresIn=900,
    )


def _sign_get(key: str) -> str:
    if os.environ.get("HOUSEHOLD_MEMORY") == "1":
        return f"https://memory.invalid/{key}"
    from mb_api.config import get_settings
    import boto3

    bucket = get_settings().media_bucket
    return boto3.client("s3").generate_presigned_url(
        "get_object",
        Params={"Bucket": bucket, "Key": key},
        ExpiresIn=3600,
    )


def _view(book, viewer: str) -> dict:
    body = book.view(viewer)
    for photo in body["photos"]:
        photo["url"] = _sign_get(photo.pop("key"))
    return body


@router.get("/v1/households")
def list_households(request: Request):
    households, error = _store_or_503()
    if error is not None:
        return error
    viewer = request.state.sub
    return {"books": [_view(book, viewer) for book in households.list_for(viewer)]}


@router.post("/v1/households")
def create_household(body: CreateHousehold, request: Request):
    households, error = _store_or_503()
    if error is not None:
        return error
    kind = body.kind if body.kind in ("book", "collage") else ""
    if not kind:
        return JSONResponse(
            status_code=400,
            content={"message": "A family share is a book or a collage."},
        )
    try:
        layout = _layout(body.layout) if kind == "collage" else None
    except (ValueError, ValidationError):
        return JSONResponse(
            status_code=400,
            content={"message": "That collage layout could not be read."},
        )
    book = households.create(
        sub=request.state.sub,
        name=_name(request),
        title=body.title.strip(),
        kind=kind,
        layout=layout,
    )
    return _view(book, request.state.sub)


@router.post("/v1/households/join")
def join_household(body: JoinHousehold, request: Request):
    households, error = _store_or_503()
    if error is not None:
        return error
    try:
        book = households.join(
            sub=request.state.sub,
            name=_name(request),
            code=body.code,
        )
    except ValueError as exc:
        return JSONResponse(status_code=400, content={"message": str(exc)})
    if book is None:
        return JSONResponse(
            status_code=404,
            content={"message": "That code is not a family book."},
        )
    return _view(book, request.state.sub)


@router.get("/v1/households/{code}")
def read_household(code: str, request: Request):
    households, error = _store_or_503()
    if error is not None:
        return error
    book = households.get(code, request.state.sub)
    if book is None:
        return JSONResponse(
            status_code=404,
            content={"message": "That code is not a family book you belong to."},
        )
    return _view(book, request.state.sub)


@router.post("/v1/households/{code}/layout")
def update_layout(code: str, body: CollageLayout, request: Request):
    households, error = _store_or_503()
    if error is not None:
        return error
    try:
        book = households.set_layout(code, request.state.sub, _layout(body))
    except ValueError as exc:
        return JSONResponse(status_code=400, content={"message": str(exc)})
    if book is None:
        return JSONResponse(
            status_code=404,
            content={"message": "That code is not a family book you belong to."},
        )
    return _view(book, request.state.sub)


@router.post("/v1/households/{code}/photos")
def reserve_photos(code: str, body: ReservePhotos, request: Request):
    households, error = _store_or_503()
    if error is not None:
        return error
    try:
        keys = households.reserve(code, request.state.sub, body.count)
    except ValueError as exc:
        return JSONResponse(status_code=400, content={"message": str(exc)})
    if not keys:
        return JSONResponse(
            status_code=404,
            content={"message": "That code is not a family book you belong to."},
        )
    return {
        "uploads": [
            {"key": key, "url": _sign_put(key), "contentType": "image/jpeg"}
            for key in keys
        ]
    }


@router.post("/v1/households/{code}/photos/commit")
def commit_photos(code: str, body: CommitPhotos, request: Request):
    households, error = _store_or_503()
    if error is not None:
        return error
    if body.slots is not None and len(body.slots) != len(body.keys):
        return JSONResponse(
            status_code=400,
            content={"message": "Each photo needs the frame it belongs in."},
        )
    try:
        book = households.commit(
            code,
            request.state.sub,
            _name(request),
            body.keys,
            body.slots,
        )
    except ValueError as exc:
        return JSONResponse(status_code=400, content={"message": str(exc)})
    if book is None:
        return JSONResponse(
            status_code=404,
            content={"message": "That code is not a family book you belong to."},
        )
    return _view(book, request.state.sub)
