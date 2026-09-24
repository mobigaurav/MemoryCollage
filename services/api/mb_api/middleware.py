from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from mb_api.auth import AuthError, verify_cognito_token
from mb_api.config import get_settings

PUBLIC_PATHS = {"/", "/health", "/healthz", "/v1/billing/revenuecat"}


class AuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        if request.method == "OPTIONS" or request.url.path in PUBLIC_PATHS:
            return await call_next(request)

        header = request.headers.get("authorization", "")
        if not header.lower().startswith("bearer "):
            return JSONResponse({"error": "Sign in required"}, status_code=401)
        token = header.split(" ", 1)[1].strip()
        settings = get_settings()

        if settings.allow_dev_token and token == "dev":
            request.state.sub = "dev-local-user"
            request.state.email = "dev@memorybook.local"
            return await call_next(request)

        try:
            claims = verify_cognito_token(token)
        except AuthError as exc:
            return JSONResponse({"error": str(exc)}, status_code=401)

        request.state.sub = str(claims.get("sub") or "")
        request.state.email = claims.get("email")
        if not request.state.sub:
            return JSONResponse({"error": "Token has no subject"}, status_code=401)
        return await call_next(request)
