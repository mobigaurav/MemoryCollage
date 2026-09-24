from fastapi import APIRouter, Request

router = APIRouter()


@router.post("/v1/billing/revenuecat")
async def revenuecat_webhook(request: Request) -> dict:
    # Signature check lands with the RevenueCat secret. The route is public
    # so the store can reach it, and it does not grant credits yet.
    await request.body()
    return {"ok": True, "applied": False}
