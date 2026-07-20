from fastapi import APIRouter, Query

from app.services.content_loader import (
    get_highway_code,
    get_questions,
    get_road_signs,
)

router = APIRouter(prefix="/api/v1/content", tags=["content"])


@router.get("/questions")
def list_questions(category: str | None = Query(default=None)) -> list[dict]:
    """Return theory test questions. Optional filter by category."""
    items = get_questions()
    if category:
        items = [q for q in items if q.get("category") == category]
    return items


@router.get("/road-signs")
def list_road_signs(category: str | None = Query(default=None)) -> list[dict]:
    """Return road sign study content."""
    items = get_road_signs()
    if category:
        items = [s for s in items if s.get("category") == category]
    return items


@router.get("/highway-code")
def list_highway_code() -> list[dict]:
    """Return Highway Code reference sections."""
    return get_highway_code()
