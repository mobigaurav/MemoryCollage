"""Cognito id-token checks. Dev builds also accept Bearer dev."""

from __future__ import annotations

import time
from functools import lru_cache

import httpx
from jose import jwt
from jose.exceptions import JWTError

from mb_api.config import get_settings


class AuthError(Exception):
    pass


@lru_cache(maxsize=1)
def _jwks() -> dict:
    settings = get_settings()
    if not settings.cognito_user_pool_id:
        raise AuthError("Cognito user pool is not configured")
    url = (
        f"https://cognito-idp.{settings.aws_region}.amazonaws.com/"
        f"{settings.cognito_user_pool_id}/.well-known/jwks.json"
    )
    response = httpx.get(url, timeout=5.0)
    response.raise_for_status()
    return response.json()


def verify_cognito_token(token: str) -> dict:
    if not token:
        raise AuthError("missing token")
    try:
        header = jwt.get_unverified_header(token)
        kid = header["kid"]
    except (JWTError, KeyError) as exc:
        raise AuthError("malformed token") from exc

    key = next((item for item in _jwks()["keys"] if item["kid"] == kid), None)
    if key is None:
        raise AuthError("unknown signing key")

    settings = get_settings()
    issuer = (
        f"https://cognito-idp.{settings.aws_region}.amazonaws.com/"
        f"{settings.cognito_user_pool_id}"
    )
    try:
        claims = jwt.decode(
            token,
            key,
            algorithms=["RS256"],
            issuer=issuer,
            options={"verify_aud": False, "verify_at_hash": False},
        )
    except JWTError as exc:
        raise AuthError("invalid token") from exc

    expected = settings.cognito_app_client_id
    if expected and claims.get("aud") != expected and claims.get("client_id") != expected:
        raise AuthError("invalid audience")
    if claims.get("token_use") not in (None, "id", "access"):
        raise AuthError("unexpected token")
    if int(claims.get("exp", 0)) < int(time.time()):
        raise AuthError("expired token")
    return claims
