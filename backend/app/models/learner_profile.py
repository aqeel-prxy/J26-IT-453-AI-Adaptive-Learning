import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, Float, Integer, Boolean, DateTime, ForeignKey, Uuid, UniqueConstraint
from app.database.base import Base


class LearnerProfile(Base):
    """
    Component 2: AI-Based Multi-Modal & Time-Aware Learner Profiling
    Owner: Jayasinghe J.A.N.V. (IT23319356)
    
    Persists concept-level mastery probabilities, Ebbinghaus memory decay parameters,
    and multi-modal telemetry aggregates per student-concept pair.
    """
    __tablename__ = "learner_profiles"
    __table_args__ = (
        UniqueConstraint("student_id", "concept_id", name="uq_student_concept_mastery"),
    )

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    concept_id = Column(Uuid(as_uuid=True), ForeignKey("concepts.id"), nullable=False, index=True)
    
    # Cognitive State & Knowledge Tracing Metrics
    mastery_probability = Column(Float, nullable=False, default=0.1)
    forgetting_factor = Column(Float, nullable=False, default=1.0)
    stability_factor = Column(Float, nullable=False, default=1.0)  # S in Ebbinghaus R = e^(-t/S)
    guess_probability = Column(Float, nullable=False, default=0.2)
    slip_probability = Column(Float, nullable=False, default=0.1)
    is_weak_concept = Column(Boolean, nullable=False, default=False)
    
    # Multi-Modal Telemetry Aggregates
    total_attempts = Column(Integer, nullable=False, default=0)
    correct_attempts = Column(Integer, nullable=False, default=0)
    average_response_time_ms = Column(Float, nullable=False, default=0.0)
    
    # Temporal Timestamps
    last_practiced_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False
    )
