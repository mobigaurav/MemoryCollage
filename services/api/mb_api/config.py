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
    fal_text_model: str
    fal_image_model: str
    cors_origins: str
    posthog_api_key: str
    posthog_host: str

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
        fal_text_model=os.environ.get(
            "FAL_TEXT_MODEL", "fal-ai/pixverse/v6/text-to-video"
        ),
        fal_image_model=os.environ.get(
            "FAL_IMAGE_MODEL", "fal-ai/pixverse/v6/image-to-video"
        ),
        cors_origins=os.environ.get("CORS_ORIGINS", "*"),
        posthog_api_key=os.environ.get("POSTHOG_API_KEY", "phc_rdCbaskeHzwjYRxAqDApHwKXtqV4wPuSeny9sGb9YrtN"),
        posthog_host=os.environ.get("POSTHOG_HOST", "https://us.i.posthog.com"),
    )
