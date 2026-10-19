from typing import Generator
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

db_uri = settings.SQLALCHEMY_DATABASE_URI
connect_args = {}
if db_uri.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

# Create SQLAlchemy engine
engine = create_engine(
    db_uri,
    connect_args=connect_args,
    pool_pre_ping=True,
    echo=False
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db() -> Generator:
    """Dependency generator providing a database session per request."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
