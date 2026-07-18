from datetime import datetime

from pydantic import BaseModel, ConfigDict, computed_field


class UserCreate(BaseModel):
    """Schema for user registration."""

    email: str
    username: str
    password: str
    full_name: str | None = None


class UserLogin(BaseModel):
    """Schema for user login."""

    email: str
    password: str


class UserResponse(BaseModel):
    """Schema for returning user data in API responses."""

    id: int
    email: str
    username: str
    full_name: str | None = None
    is_active: bool
    is_guest: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    """Schema for JWT token response."""

    access_token: str
    token_type: str = "bearer"

    @computed_field  # type: ignore[prop-decorator]
    @property
    def token(self) -> str:
        """Alias used by the Flutter client."""
        return self.access_token


class TokenData(BaseModel):
    """Schema for decoded JWT token payload."""

    user_id: int | None = None
    email: str | None = None


class ForgotPasswordRequest(BaseModel):
    email: str


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str


class MessageResponse(BaseModel):
    message: str
    reset_token: str | None = None
