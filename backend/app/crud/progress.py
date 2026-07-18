from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.models.progress import TestSession, UserProgress
from app.schemas.progress import ProgressSyncRequest, TestSessionCreate


def get_or_create_progress(db: Session, user_id: int) -> UserProgress:
    progress = db.query(UserProgress).filter(UserProgress.user_id == user_id).first()
    if progress is None:
        progress = UserProgress(
            user_id=user_id,
            answered_questions={},
            sign_quiz_history={},
            test_session_logs=[],
        )
        db.add(progress)
        db.commit()
        db.refresh(progress)
    return progress


def get_progress(db: Session, user_id: int) -> UserProgress:
    return get_or_create_progress(db, user_id)


def _session_to_log_dict(session: TestSession) -> dict:
    return {
        "id": str(session.id),
        "module": session.module,
        "mode": session.mode,
        "topic": session.topic,
        "correct": session.correct,
        "total": session.total,
        "completedAt": session.completed_at.isoformat(),
    }


def add_test_session(
    db: Session, user_id: int, payload: TestSessionCreate
) -> TestSession:
    completed_at = payload.completed_at or datetime.now(timezone.utc)
    session = TestSession(
        user_id=user_id,
        module=payload.module,
        mode=payload.mode,
        topic=payload.topic,
        correct=payload.correct,
        total=payload.total,
        completed_at=completed_at.replace(tzinfo=None)
        if completed_at.tzinfo
        else completed_at,
    )
    db.add(session)
    db.commit()
    db.refresh(session)

    progress = get_or_create_progress(db, user_id)
    logs = list(progress.test_session_logs or [])
    logs.insert(0, _session_to_log_dict(session))
    progress.test_session_logs = logs[:50]
    db.commit()
    return session


def sync_progress(
    db: Session, user_id: int, payload: ProgressSyncRequest
) -> UserProgress:
    progress = get_or_create_progress(db, user_id)

    if payload.answered_questions:
        merged = dict(progress.answered_questions or {})
        merged.update(payload.answered_questions)
        progress.answered_questions = merged

    if payload.sign_quiz_history:
        merged = dict(progress.sign_quiz_history or {})
        merged.update(payload.sign_quiz_history)
        progress.sign_quiz_history = merged

    if payload.test_sessions:
        for session_payload in payload.test_sessions:
            add_test_session(db, user_id, session_payload)

    db.commit()
    db.refresh(progress)
    return progress


def list_test_sessions(db: Session, user_id: int, limit: int = 50) -> list[TestSession]:
    return (
        db.query(TestSession)
        .filter(TestSession.user_id == user_id)
        .order_by(TestSession.completed_at.desc())
        .limit(limit)
        .all()
    )
