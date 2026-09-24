from fastapi import APIRouter, Request

from mb_api.store import store

router = APIRouter()


@router.get("/v1/me")
def me(request: Request) -> dict:
    sub = request.state.sub
    email = request.state.email
    balance = store.ensure_user(sub, email)
    return {"sub": sub, "email": email, "credits": balance}
