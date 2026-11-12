import os

from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse

from mb_api.routers.library import delete_account_data
from mb_api.store import store

router = APIRouter()


@router.get("/v1/me")
def me(request: Request) -> dict:
    sub = request.state.sub
    email = request.state.email
    balance = store.ensure_user(sub, email)
    return {"sub": sub, "email": email, "credits": balance}


@router.delete("/v1/me")
def delete_me(request: Request):
    """Removes the shelf, family books this person owns, and the Cognito user."""
    sub = request.state.sub
    delete_account_data(sub)
    username = getattr(request.state, "username", "") or ""
    pool = os.environ.get("COGNITO_USER_POOL_ID", "").strip()
    if username and pool and os.environ.get("HOUSEHOLD_MEMORY") != "1":
        import boto3

        try:
            boto3.client("cognito-idp").admin_delete_user(
                UserPoolId=pool,
                Username=username,
            )
        except Exception:
            return JSONResponse(
                status_code=502,
                content={"message": "The shelf was cleared, but the account is still there."},
            )
    store.forget(sub)
    return {"deleted": True}
