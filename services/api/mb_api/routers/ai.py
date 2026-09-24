from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from mb_api.config import get_settings
from mb_api.store import store

router = APIRouter()


class VideoRequest(BaseModel):
    imageBase64: str = Field(min_length=8)
    style: str = "cinematic"
    durationSec: int = Field(default=5, ge=2, le=10)


def _payload(job_status: str, **extra: object) -> dict:
    body = {
        "status": job_status,
        "fallbackToOnDevice": job_status == "fallback",
        "videoUrl": None,
        "jobId": None,
        "message": extra.pop("message", None),
    }
    body.update(extra)
    return body


@router.post("/v1/ai/video")
def create_video(body: VideoRequest, request: Request) -> dict:
    sub = request.state.sub
    balance = store.ensure_user(sub, request.state.email)
    settings = get_settings()
    if not settings.vendor_ready:
        return _payload(
            "fallback",
            message="Cloud video is not connected yet. Filming this photo on this phone.",
            balance=balance,
        )

    if not store.spend(sub, 1, "ai_video"):
        return JSONResponse(
            status_code=402,
            content={"message": "Not enough credits.", "balance": balance},
        )

    job = store.create_job(sub, body.style, "queued")
    return _payload(
        "queued",
        jobId=job.id,
        message="Queued",
        balance=store.balance(sub),
        fallbackToOnDevice=False,
    )


@router.get("/v1/ai/jobs/{job_id}")
def get_job(job_id: str, request: Request) -> dict:
    job = store.jobs.get(job_id)
    if job is None or job.sub != request.state.sub:
        return JSONResponse(status_code=404, content={"message": "Job not found"})
    return {
        "jobId": job.id,
        "status": job.status,
        "videoUrl": job.video_url,
        "message": job.error,
    }
