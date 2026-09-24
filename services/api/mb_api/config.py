import os
from dataclasses import dataclass
from functools import lru_cache


@dataclass(frozen=True)
class Settings:
    env: str
    aws_region: str
    cognito_user_pool_id: str
    cognito_app_client_id: str
    media_bucket: str
    video_vendor: str
    video_vendor_api_key: str
    cors_origins: str

    @property
    def vendor_ready(self) -> bool:
        return self.video_vendor not in ("", "none") and bool(self.video_vendor_api_key)

    @property
    def allow_dev_token(self) -> bool:
        return self.env == "dev"


@lru_cache
def get_settings() -> Settings:
    return Settings(
        env=os.environ.get("ENV", "dev"),
        aws_region=os.environ.get("AWS_REGION", "us-east-1"),
        cognito_user_pool_id=os.environ.get("COGNITO_USER_POOL_ID", ""),
        cognito_app_client_id=os.environ.get("COGNITO_APP_CLIENT_ID", ""),
        media_bucket=os.environ.get("MEDIA_BUCKET", ""),
        video_vendor=os.environ.get("VIDEO_VENDOR", "none"),
        video_vendor_api_key=os.environ.get("VIDEO_VENDOR_API_KEY", ""),
        cors_origins=os.environ.get("CORS_ORIGINS", "*"),
    )
