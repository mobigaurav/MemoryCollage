from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, model_validator

from mb_api.analytics_service import Events, track
from mb_api.config import get_settings
from mb_api.fal_video import FalVideo
from mb_api.runway_video import RunwayVideo
from mb_api.store import store

router = APIRouter()


class VideoRequest(BaseModel):
    imageBase64: str | None = None
    prompt: str | None = None
    style: str = "cinematic"
    durationSec: int = Field(default=5, ge=2, le=10)

    @model_validator(mode="after")
    def _needs_a_source(self) -> "VideoRequest":
        image = (self.imageBase64 or "").strip()
        prompt = (self.prompt or "").strip()
        if len(image) < 8 and not prompt:
            raise ValueError("Add a photo, a prompt, or both.")
        if image and len(image) < 8:
            raise ValueError("That photo could not be read.")
        return self


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


def _prompt_for(body: VideoRequest, *, has_image: bool) -> str:
    written = (body.prompt or "").strip()
    if has_image:
        motion = written or "a gentle living movement, a blink, a breath, or a small shift"
        return (
            "Animate this exact photograph. Keep the same people, faces, clothes, "
            "place, colors, and framing. Do not create a new picture. "
            f"Only add this motion: {motion}"
        )[:1000]
    return (written or "Gentle cinematic motion.")[:1000]


def _refund(job) -> None:
    if job.refunded:
        return
    store.grant(job.sub, 1, "refund_video")
    job.refunded = True


@router.post("/v1/ai/video")
def create_video(body: VideoRequest, request: Request) -> dict:
    sub = request.state.sub
    balance = store.ensure_user(sub, request.state.email)
    settings = get_settings()
    has_image = bool((body.imageBase64 or "").strip())
    if not settings.vendor_ready:
        if has_image:
            return _payload(
                "fallback",
                message="Cloud video is not connected yet. Filming this photo on this phone.",
                balance=balance,
            )
        return _payload(
            "unavailable",
            message="Cloud video is not connected yet.",
            balance=balance,
        )

    if settings.video_vendor not in ("fal", "runway"):
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

    if not store.spend(sub, 1, "ai_video"):
        return JSONResponse(
            status_code=402,
            content={"message": "Not enough credits.", "balance": balance},
        )

    vendor = _vendor(settings)
    try:
        submitted = vendor.submit(
            prompt=_prompt_for(body, has_image=has_image),
            image_base64=body.imageBase64 if has_image else None,
            duration_sec=body.durationSec,
        )
    except Exception as exc:
        store.grant(sub, 1, "refund_video")
        return _payload(
            "failed",
            message=str(exc),
            balance=store.balance(sub),
        )
    finally:
        vendor.close()

    job = store.create_job(sub, body.style, "queued")
    track(Events.ai_clip_started, distinct_id=sub, properties={"style": body.style})
    job.prompt = _prompt_for(body, has_image=has_image)
    job.status_url = submitted.status_url
    job.response_url = submitted.response_url
    return _payload(
        "queued",
        jobId=job.id,
        message="Making the clip.",
        balance=store.balance(sub),
        fallbackToOnDevice=False,
    )


@router.get("/v1/ai/jobs/{job_id}")
def get_job(job_id: str, request: Request) -> dict:
    job = store.jobs.get(job_id)
    if job is None or job.sub != request.state.sub:
        return JSONResponse(status_code=404, content={"message": "Job not found"})
    settings = get_settings()
    if (
        job.status == "queued"
        and job.status_url
        and settings.video_vendor in ("fal", "runway")
        and settings.vendor_ready
    ):
        vendor = _vendor(settings)
        try:
            polled = vendor.poll(job.status_url, job.response_url)
        except Exception as exc:
            polled_error = str(exc)
            polled = None
        else:
            polled_error = None
        finally:
            vendor.close()
        if polled_error:
            job.status = "failed"
            job.error = polled_error
            _refund(job)
        elif polled is not None and polled.status == "completed" and polled.video_url:
            job.status = "completed"
            job.video_url = polled.video_url
            job.error = None
        elif polled is not None and polled.status == "failed":
            job.status = "failed"
            job.error = polled.error or "The clip failed."
            _refund(job)
    return {
        "jobId": job.id,
        "status": job.status,
        "videoUrl": job.video_url,
        "message": job.error or ("Clip ready." if job.video_url else "Making the clip."),
        "balance": store.balance(job.sub),
        "fallbackToOnDevice": False,
    }


def _vendor(settings):
    if settings.video_vendor == "runway":
        return RunwayVideo(settings)
    return FalVideo(settings)
