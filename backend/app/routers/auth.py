import secrets
import uuid
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import create_access_token, hash_password
from app.crud.user import authenticate_user, create_user, get_user_by_email, get_user_by_reset_token
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.user import (
    ForgotPasswordRequest,
    MessageResponse,
    ResetPasswordRequest,
    Token,
    UserCreate,
    UserResponse,
)

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


@router.post("/signup", response_model=Token, status_code=status.HTTP_201_CREATED)
def signup(user_in: UserCreate, db: Session = Depends(get_db)) -> Token:
    """Register a new user and return a JWT access token."""
    existing_user = get_user_by_email(db, email=user_in.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists",
        )

    user = create_user(db, user_in)
    access_token = create_access_token(
        data={"user_id": user.id, "email": user.email}
    )
    return Token(access_token=access_token, token_type="bearer")


@router.post("/login", response_model=Token)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
) -> Token:
    """Authenticate a user with email (as username) and password, return JWT."""
    user = authenticate_user(db, email=form_data.username, password=form_data.password)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(
        data={"user_id": user.id, "email": user.email}
    )
    return Token(access_token=access_token, token_type="bearer")


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)) -> User:
    """Return the profile of the currently authenticated user."""
    return current_user


@router.post("/guest", response_model=Token, status_code=status.HTTP_201_CREATED)
def create_guest(db: Session = Depends(get_db)) -> Token:
    """Create a guest user with auto-generated credentials and return a JWT."""
    guest_id = uuid.uuid4().hex[:12]
    guest_email = f"guest_{guest_id}@driveprep.local"
    guest_username = f"guest_{guest_id}"
    guest_password = uuid.uuid4().hex

    guest_user = User(
        email=guest_email,
        username=guest_username,
        hashed_password=hash_password(guest_password),
        is_guest=True,
    )
    db.add(guest_user)
    db.commit()
    db.refresh(guest_user)

    access_token = create_access_token(
        data={"user_id": guest_user.id, "email": guest_user.email}
    )
    return Token(access_token=access_token, token_type="bearer")


@router.post("/forgot-password", response_model=MessageResponse)
def forgot_password(payload: ForgotPasswordRequest, db: Session = Depends(get_db)) -> MessageResponse:
    """Generate a password reset token for the given email."""
    user = get_user_by_email(db, email=payload.email)
    if user is None or user.is_guest:
        return MessageResponse(
            message="If that email is registered, a reset code has been sent.",
        )

    token = secrets.token_urlsafe(32)
    user.reset_token = token
    user.reset_token_expires = datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(hours=1)
    db.commit()

    return MessageResponse(
        message="Reset code generated. Use it within 1 hour to set a new password.",
        reset_token=token,
    )


@router.post("/reset-password", response_model=MessageResponse)
def reset_password(payload: ResetPasswordRequest, db: Session = Depends(get_db)) -> MessageResponse:
    """Reset password using a valid reset token."""
    user = get_user_by_reset_token(db, token=payload.token)
    if user is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired reset token")

    if user.reset_token_expires and user.reset_token_expires < datetime.now(timezone.utc).replace(tzinfo=None):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Reset token has expired")

    if len(payload.new_password) < 6:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Password must be at least 6 characters")

    user.hashed_password = hash_password(payload.new_password)
    user.reset_token = None
    user.reset_token_expires = None
    db.commit()

    return MessageResponse(message="Password updated successfully.")
