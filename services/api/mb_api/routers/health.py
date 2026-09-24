from fastapi import APIRouter

router = APIRouter()


@router.get("/")
@router.get("/health")
@router.get("/healthz")
def health() -> dict:
    return {"ok": True, "service": "memory-book"}
