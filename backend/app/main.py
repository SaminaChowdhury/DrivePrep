from contextlib import asynccontextmanager
from collections.abc import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text

from app.core.config import settings
from app.core.database import Base, engine
from app.models import progress  # noqa: F401 — register models
from app.models import user  # noqa: F401
from app.routers.auth import router as auth_router
from app.routers.content import router as content_router
from app.routers.progress import router as progress_router


def _migrate_sqlite_schema() -> None:
    """Add columns that create_all will not alter on existing SQLite tables."""
    if not settings.DATABASE_URL.startswith("sqlite"):
        return
    with engine.connect() as conn:
        cols = {
            row[1]
            for row in conn.execute(text("PRAGMA table_info(users)")).fetchall()
        }
        if "reset_token" not in cols:
            conn.execute(text("ALTER TABLE users ADD COLUMN reset_token VARCHAR(255)"))
        if "reset_token_expires" not in cols:
            conn.execute(
                text("ALTER TABLE users ADD COLUMN reset_token_expires DATETIME")
            )
        conn.commit()


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Create database tables on startup."""
    Base.metadata.create_all(bind=engine)
    _migrate_sqlite_schema()
    yield


app = FastAPI(
    title="DrivePrep API",
    description="Backend for DrivePrep UK Theory — auth, content, and progress sync.",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(content_router)
app.include_router(progress_router)


@app.get("/")
def root() -> dict[str, str]:
    """Health-check / root endpoint."""
    return {"message": "DrivePrep API v1.0", "docs": "/docs"}
