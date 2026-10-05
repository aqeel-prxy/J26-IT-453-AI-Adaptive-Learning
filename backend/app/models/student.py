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
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
