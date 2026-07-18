from sqlalchemy.orm import Session

from app.core.security import hash_password, verify_password
from app.models.user import User
from app.schemas.user import UserCreate


def get_user_by_email(db: Session, email: str) -> User | None:
    """Fetch a user by their email address."""
    return db.query(User).filter(User.email == email).first()


def get_user_by_id(db: Session, user_id: int) -> User | None:
    """Fetch a user by their primary key ID."""
    return db.query(User).filter(User.id == user_id).first()


def get_user_by_reset_token(db: Session, token: str) -> User | None:
    """Fetch a user by their active password reset token."""
    return db.query(User).filter(User.reset_token == token).first()


def create_user(db: Session, user: UserCreate) -> User:
    """Create a new user with a hashed password and persist to the database."""
    db_user = User(
        email=user.email,
        username=user.username,
        hashed_password=hash_password(user.password),
        full_name=user.full_name,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def authenticate_user(db: Session, email: str, password: str) -> User | None:
    """Verify credentials and return the user if valid, or None otherwise."""
    user = get_user_by_email(db, email)
    if user is None:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user
