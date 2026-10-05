import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Float, Boolean, Integer, JSON, DateTime, ForeignKey, Uuid
from app.database.base import Base


class Representation(Base):
    __tablename__ = "representations"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    concept_id = Column(Uuid(as_uuid=True), ForeignKey("concepts.id"), nullable=False, index=True)
    format_type = Column(String(50), nullable=False)  # TEXT, DIAGRAM, GRAPH, STEP_BY_STEP
    content_payload = Column(JSON, nullable=False)
    complexity_level = Column(Float, nullable=False, default=0.5)


class RepresentationOutcome(Base):
    __tablename__ = "representation_outcomes"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    representation_id = Column(Uuid(as_uuid=True), ForeignKey("representations.id"), nullable=False, index=True)
    duration_seconds = Column(Integer, nullable=False)
    is_successful = Column(Boolean, nullable=False)
    switched_from_id = Column(Uuid(as_uuid=True), ForeignKey("representations.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
