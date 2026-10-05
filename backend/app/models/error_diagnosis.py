import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey, Uuid
from app.database.base import Base


class ErrorDiagnosis(Base):
    __tablename__ = "error_diagnosis"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    attempt_id = Column(Uuid(as_uuid=True), ForeignKey("attempts.id"), nullable=False, index=True)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    question_id = Column(Uuid(as_uuid=True), ForeignKey("questions.id"), nullable=False, index=True)
    failed_step_index = Column(Integer, nullable=True)
    error_category = Column(String(50), nullable=False)
    explanation_text = Column(Text, nullable=False)
    corrected_step = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
