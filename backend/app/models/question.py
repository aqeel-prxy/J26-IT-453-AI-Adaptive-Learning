import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Float, Text, JSON, DateTime, ForeignKey, Uuid
from app.database.base import Base


class Question(Base):
    __tablename__ = "questions"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    concept_id = Column(Uuid(as_uuid=True), ForeignKey("concepts.id"), nullable=False, index=True)
    difficulty_level = Column(Float, nullable=False, default=0.5)
    question_text = Column(Text, nullable=False)
    reference_solution = Column(JSON, nullable=False)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
