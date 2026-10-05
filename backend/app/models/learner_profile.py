import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, Float, DateTime, ForeignKey, Uuid
from app.database.base import Base


class LearnerProfile(Base):
    __tablename__ = "learner_profiles"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    concept_id = Column(Uuid(as_uuid=True), ForeignKey("concepts.id"), nullable=False, index=True)
    mastery_probability = Column(Float, nullable=False, default=0.1)
    forgetting_factor = Column(Float, nullable=False, default=1.0)
    last_practiced_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
