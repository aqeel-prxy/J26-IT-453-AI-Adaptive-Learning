import uuid
from datetime import datetime, timezone, date
from sqlalchemy import Column, String, Float, Integer, Date, DateTime, ForeignKey, Uuid
from app.database.base import Base


class StudentEngagement(Base):
    __tablename__ = "student_engagement"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), unique=True, nullable=False, index=True)
    current_streak_days = Column(Integer, nullable=False, default=0)
    total_points = Column(Integer, nullable=False, default=0)
    virtual_pet_health = Column(Integer, nullable=False, default=100)
    virtual_pet_level = Column(Integer, nullable=False, default=1)
    last_activity_date = Column(Date, default=date.today)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))


class GameSession(Base):
    __tablename__ = "game_sessions"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    game_type = Column(String(50), nullable=False)  # SPEED_CALC, PEER_CHALLENGE
    score = Column(Integer, nullable=False)
    accuracy = Column(Float, nullable=False)
    duration_seconds = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
