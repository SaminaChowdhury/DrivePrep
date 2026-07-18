from pydantic import BaseModel, ConfigDict, Field


class ContentListResponse(BaseModel):
    """Wrapper for list payloads (also accepted as bare arrays by the app)."""

    data: list[dict]


class HazardVideoResponse(BaseModel):
    id: str
    title: str
    description: str
    videoUrl: str
    thumbnailUrl: str | None = None
    durationSeconds: int
    category: str
    hazardTimestampSeconds: int
    order: int

    model_config = ConfigDict(from_attributes=True)
