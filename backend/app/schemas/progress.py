from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class TestSessionCreate(BaseModel):
    """Payload for logging a completed test session."""

    module: str
    mode: str
    topic: str | None = None
    correct: int
    total: int
    completed_at: datetime | None = Field(default=None, alias="completedAt")

    model_config = ConfigDict(populate_by_name=True)


class TestSessionResponse(BaseModel):
    id: int
    module: str
    mode: str
    topic: str | None
    correct: int
    total: int
    completed_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ProgressSyncRequest(BaseModel):
    """Bulk progress sync from the mobile client."""

    answered_questions: dict[str, bool] | None = Field(
        default=None, alias="answeredQuestions"
    )
    sign_quiz_history: dict[str, bool] | None = Field(
        default=None, alias="signQuizHistory"
    )
    test_sessions: list[TestSessionCreate] | None = Field(
        default=None, alias="testSessions"
    )

    model_config = ConfigDict(populate_by_name=True)


class ProgressResponse(BaseModel):
    answered_questions: dict[str, bool] = Field(alias="answeredQuestions")
    sign_quiz_history: dict[str, bool] = Field(alias="signQuizHistory")
    test_session_logs: list[dict] = Field(alias="testSessionLogs")
    updated_at: datetime | None = Field(default=None, alias="updatedAt")

    model_config = ConfigDict(populate_by_name=True, ser_json_by_alias=True)
