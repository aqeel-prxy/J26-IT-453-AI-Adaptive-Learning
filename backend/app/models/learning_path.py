import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Float, Text, Date, DateTime, ForeignKey, Uuid, JSON
from app.database.base import Base


class LearningPathPlan(Base):
    """
    Stores active and historical goal-aware learning pathways for each student.
    Component 1 (Aqeel M.I.M - IT23244016)
    """
    __tablename__ = "learning_path_plans"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    topic_category = Column(String(100), nullable=False, default="Indices and Logarithms")
    goal_type = Column(String(50), nullable=False, default="COMPREHENSIVE")  # TERM_TEST, COMPREHENSIVE
    target_date = Column(Date, nullable=True)
    available_daily_minutes = Column(Integer, nullable=False, default=30)
    current_concept_id = Column(Uuid(as_uuid=True), ForeignKey("concepts.id"), nullable=True)
    status = Column(String(50), nullable=False, default="ACTIVE")  # ACTIVE, COMPLETED, ARCHIVED
    pathway_state = Column(JSON, nullable=False, default=dict)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)


class LearningPathDecision(Base):
    """
    Logs every planning decision, prerequisite check, ML readiness prediction,
    and dynamic revision rationale for research evaluation telemetry.
    Component 1 (Aqeel M.I.M - IT23244016)
    """
    __tablename__ = "learning_path_decisions"

    id = Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    plan_id = Column(Uuid(as_uuid=True), ForeignKey("learning_path_plans.id"), nullable=False, index=True)
    student_id = Column(Uuid(as_uuid=True), ForeignKey("students.id"), nullable=False, index=True)
    target_concept_id = Column(Uuid(as_uuid=True), ForeignKey("concepts.id"), nullable=True)
    decision_type = Column(String(50), nullable=False)  # PROCEED_DIRECT, REVISE_PREREQUISITE, WORKED_EXAMPLE, PRACTICE
    predicted_readiness = Column(Float, nullable=True)
    model_version = Column(String(50), nullable=False, default="RandomForest-v1")
    rationale = Column(Text, nullable=False)
    prerequisite_evidence = Column(JSON, nullable=False, default=dict)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
