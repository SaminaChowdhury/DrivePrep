from datetime import datetime

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.crud.progress import (
    add_test_session,
    get_progress,
    list_test_sessions,
    sync_progress,
)
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.progress import (
    ProgressResponse,
    ProgressSyncRequest,
    TestSessionCreate,
    TestSessionResponse,
)

router = APIRouter(prefix="/api/v1/progress", tags=["progress"])


@router.get("", response_model=ProgressResponse)
def read_progress(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ProgressResponse:
    """Fetch the authenticated user's saved study progress."""
    progress = get_progress(db, current_user.id)
    return ProgressResponse(
        answered_questions=progress.answered_questions or {},
        sign_quiz_history=progress.sign_quiz_history or {},
        test_session_logs=progress.test_session_logs or [],
        updated_at=progress.updated_at,
    )


@router.post("/sync", response_model=ProgressResponse)
def save_progress_sync(
    payload: ProgressSyncRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> ProgressResponse:
    """Merge bulk progress data from the mobile app."""
    progress = sync_progress(db, current_user.id, payload)
    return ProgressResponse(
        answered_questions=progress.answered_questions or {},
        sign_quiz_history=progress.sign_quiz_history or {},
        test_session_logs=progress.test_session_logs or [],
        updated_at=progress.updated_at,
    )


@router.post(
    "/sessions",
    response_model=TestSessionResponse,
    status_code=status.HTTP_201_CREATED,
)
def save_test_session(
    payload: TestSessionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> TestSessionResponse:
    """Log a completed test session."""
    session = add_test_session(db, current_user.id, payload)
    return session


@router.get("/sessions", response_model=list[TestSessionResponse])
def read_test_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[TestSessionResponse]:
    """List recent completed test sessions for the current user."""
    return list_test_sessions(db, current_user.id)
