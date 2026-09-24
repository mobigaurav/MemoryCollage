from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from mb_api.config import get_settings
from mb_api.middleware import AuthMiddleware
from mb_api.routers import ai, billing, health, me


def create_app() -> FastAPI:
    settings = get_settings()
    origins = [item.strip() for item in settings.cors_origins.split(",") if item.strip()]
    app = FastAPI(title="Memory Book API", version="0.1.0")
    app.add_middleware(AuthMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins or ["*"],
        allow_methods=["*"],
        allow_headers=["*"],
        allow_credentials=False,
    )
    app.include_router(health.router)
    app.include_router(me.router)
    app.include_router(ai.router)
    app.include_router(billing.router)
    return app


app = create_app()
