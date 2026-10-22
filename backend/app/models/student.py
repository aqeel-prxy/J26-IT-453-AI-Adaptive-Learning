import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, DateTime, Uuid
from app.database.base import Base


class Student(Base):
    __tablename__ = "students"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    anonymized_student_code = Column(String(64), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    grade_level = Column(Integer, nullable=False, default=10)
    full_name = Column(String(255), nullable=True, default="Student")
    school = Column(String(255), nullable=True, default="Central College, Kandy")
    district = Column(String(255), nullable=True, default="Central Province")
    avatar_id = Column(String(64), nullable=True, default="fox_math")
    preferred_goal = Column(String(64), nullable=True, default="TERM_TEST")
    auth_provider = Column(String(32), nullable=True, default="email")
    google_id = Column(String(255), nullable=True, index=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
