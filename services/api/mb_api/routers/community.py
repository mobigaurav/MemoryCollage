import os

from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from mb_api.analytics_service import Events, track
from mb_api.community_store import author_label, get_community

router = APIRouter()


class CreatePost(BaseModel):
    title: str = Field(min_length=1, max_length=80)
    kind: str
    count: int = Field(ge=1, le=12)


class PublishPost(BaseModel):
    keys: list[str] = Field(min_length=1, max_length=12)


def _store_or_503():
    community = get_community()
    if community is None:
        return None, JSONResponse(
            status_code=503,
            content={"message": "The world is not connected on this server yet."},
        )
    return community, None


def _sign_put(key: str, content_type: str) -> str:
    if os.environ.get("COMMUNITY_MEMORY") == "1":
        return f"https://memory.invalid/{key}"
    from mb_api.config import get_settings
    import boto3

    bucket = get_settings().media_bucket
    return boto3.client("s3").generate_presigned_url(
        "put_object",
        Params={"Bucket": bucket, "Key": key, "ContentType": content_type},
        ExpiresIn=900,
    )


def _sign_get(key: str) -> str:
    if os.environ.get("COMMUNITY_MEMORY") == "1":
        return f"https://memory.invalid/{key}"
    from mb_api.config import get_settings
    import boto3

    bucket = get_settings().media_bucket
    return boto3.client("s3").generate_presigned_url(
        "get_object",
        Params={"Bucket": bucket, "Key": key},
        ExpiresIn=3600,
    )


def _view(post, viewer: str) -> dict:
    body = post.public(viewer)
    keys = body.pop("keys")
    body["media"] = [_sign_get(key) for key in keys]
    return body


@router.get("/v1/community")
def feed(request: Request) -> dict:
    community, error = _store_or_503()
    if error is not None:
        return error
    viewer = request.state.sub or ""
    return {"posts": [_view(post, viewer) for post in community.list_posts(viewer)]}


@router.post("/v1/community")
def create_post(body: CreatePost, request: Request):
    if body.kind not in ("album", "reel"):
        return JSONResponse(status_code=400, content={"message": "Post a book or a reel."})
    if body.kind == "reel" and body.count != 1:
        return JSONResponse(status_code=400, content={"message": "A reel is one video."})
    community, error = _store_or_503()
    if error is not None:
        return error
    title = body.title.strip()
    post = community.create(
        sub=request.state.sub,
        author=author_label(getattr(request.state, "name", ""), request.state.email),
        title=title,
        kind=body.kind,
        count=body.count,
    )
    content_type = "video/mp4" if body.kind == "reel" else "image/jpeg"
    return {
        "id": post.id,
        "uploads": [
            {"key": key, "url": _sign_put(key, content_type), "contentType": content_type}
            for key in post.keys
        ],
    }


@router.post("/v1/community/{post_id}/publish")
def publish_post(post_id: str, body: PublishPost, request: Request):
    community, error = _store_or_503()
    if error is not None:
        return error
    try:
        post = community.publish(post_id, request.state.sub, body.keys)
    except ValueError as exc:
        return JSONResponse(status_code=400, content={"message": str(exc)})
    if post is None:
        return JSONResponse(status_code=404, content={"message": "That post is not yours."})
    track(
        Events.world_posted,
        distinct_id=request.state.sub,
        properties={"kind": post.kind},
    )
    return _view(post, request.state.sub)


@router.post("/v1/community/{post_id}/love")
def love_post(post_id: str, request: Request):
    community, error = _store_or_503()
    if error is not None:
        return error
    post = community.love(post_id, request.state.sub)
    if post is None:
        return JSONResponse(status_code=404, content={"message": "That post is gone."})
    return {"loved": request.state.sub in post.loved_by, "loves": len(post.loved_by)}


@router.post("/v1/community/{post_id}/ignore")
def ignore_post(post_id: str, request: Request):
    community, error = _store_or_503()
    if error is not None:
        return error
    if not community.ignore(post_id, request.state.sub):
        return JSONResponse(status_code=404, content={"message": "That post is gone."})
    return {"ok": True}


@router.delete("/v1/community/{post_id}")
def delete_post(post_id: str, request: Request):
    community, error = _store_or_503()
    if error is not None:
        return error
    post = community.delete(post_id, request.state.sub)
    if post is None:
        return JSONResponse(
            status_code=404,
            content={"message": "That post is already gone, or it is not yours."},
        )
    return {"ok": True}
