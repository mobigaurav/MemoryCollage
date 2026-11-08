"""The signed-in shelf: books and reels that survive a reinstall."""

from __future__ import annotations

import os

from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from mb_api.library_store import get_library

router = APIRouter()


class UploadFile(BaseModel):
    contentType: str = "image/jpeg"


class UploadBody(BaseModel):
    files: list[UploadFile] = Field(default_factory=list)


class ShelfBody(BaseModel):
    books: list[dict] = Field(default_factory=list)
    reels: list[dict] = Field(default_factory=list)


def _store_or_503():
    library = get_library()
    if library is None:
        return None, JSONResponse(
            status_code=503,
            content={"message": "The shelf is not on this server yet."},
        )
    return library, None


def _with_urls(library, sub: str, shelf) -> dict:
    def sign(key: str) -> str:
        if hasattr(library, "sign_get"):
            return library.sign_get(key)
        return f"https://memory.invalid/{key}"

    books = []
    for book in shelf.books:
        pages = []
        for page in book.get("pages") or []:
            slots = []
            for slot in page.get("slots") or []:
                key = slot.get("photoKey") or ""
                slots.append({**slot, "photoUrl": sign(key) if key else ""})
            pages.append({**page, "slots": slots})
        cover = book.get("coverKey") or ""
        books.append({**book, "pages": pages, "coverUrl": sign(cover) if cover else ""})
    reels = []
    for reel in shelf.reels:
        key = reel.get("videoKey") or ""
        reels.append({**reel, "videoUrl": sign(key) if key else ""})
    return {"books": books, "reels": reels}


@router.get("/v1/library")
def read_library(request: Request):
    library, error = _store_or_503()
    if error is not None:
        return error
    return _with_urls(library, request.state.sub, library.read(request.state.sub))


@router.post("/v1/library/uploads")
def reserve_uploads(body: UploadBody, request: Request):
    library, error = _store_or_503()
    if error is not None:
        return error
    if not body.files or len(body.files) > 40:
        return JSONResponse(status_code=400, content={"message": "Choose between 1 and 40 files."})
    uploads = []
    for item in body.files:
        content_type = item.contentType if item.contentType in {
            "image/jpeg",
            "image/png",
            "image/heic",
            "video/mp4",
        } else "image/jpeg"
        uploads.extend(library.reserve(request.state.sub, 1, content_type))
    return {"uploads": uploads}


@router.put("/v1/library")
def write_library(body: ShelfBody, request: Request):
    library, error = _store_or_503()
    if error is not None:
        return error
    if len(body.books) > 40 or len(body.reels) > 80:
        return JSONResponse(status_code=400, content={"message": "This shelf is too large."})
    try:
        library.write(request.state.sub, body.books, body.reels)
    except ValueError as exc:
        return JSONResponse(status_code=400, content={"message": str(exc)})
    return _with_urls(library, request.state.sub, library.read(request.state.sub))


def delete_account_data(sub: str) -> None:
    library = get_library()
    if library is not None:
        library.wipe(sub)
    from mb_api.household_store import get_households

    households = get_households()
    if households is None:
        return
    keys = households.delete_owned(sub)
    bucket = os.environ.get("MEDIA_BUCKET", "").strip()
    if not bucket or os.environ.get("HOUSEHOLD_MEMORY") == "1":
        return
    import boto3

    client = boto3.client("s3")
    for key in keys:
        if key.startswith("households/") and ".." not in key:
            client.delete_object(Bucket=bucket, Key=key)
