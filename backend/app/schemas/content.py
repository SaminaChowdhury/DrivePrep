from pydantic import BaseModel, ConfigDict


class ContentListResponse(BaseModel):
    """Wrapper for list payloads (also accepted as bare arrays by the app)."""

    data: list[dict]

    model_config = ConfigDict(from_attributes=True)
