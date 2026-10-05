import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, Integer, Text, DateTime, ForeignKey, Uuid
from app.database.base import Base


class Attempt(Base):
    __tablename__ = "attempts"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    question_id = Column(Uuid(as_uuid=True), ForeignKey("questions.id"), nullable=False, index=True)
    is_correct = Column(Boolean, nullable=False)
    student_solution = Column(Text, nullable=False)
    response_time_ms = Column(Integer, nullable=False)
    attempt_number = Column(Integer, nullable=False, default=1)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
