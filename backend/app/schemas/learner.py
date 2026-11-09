from typing import List, Optional, Dict, Any
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field


class ConceptMasteryItem(BaseModel):
    """Represents the real-time knowledge tracing state of a single concept."""
    concept_id: UUID
    concept_code: str
    mastery_probability: float = Field(..., ge=0.0, le=1.0)
    forgetting_factor: float = Field(..., ge=0.0, le=1.0)
    stability_factor: float = Field(default=1.0, ge=0.1)
    total_attempts: int = Field(default=0, ge=0)
    correct_attempts: int = Field(default=0, ge=0)
    average_response_time_ms: float = Field(default=0.0, ge=0.0)
    is_weak_concept: bool = False
    last_practiced_at: Optional[datetime] = None


class LearnerProfileResponse(BaseModel):
    """Complete concept mastery vector and profiling summary for a student."""
    student_id: UUID
    mastery_vector: List[ConceptMasteryItem]
    weak_concept_count: int = 0
    updated_at: Optional[datetime] = None


class TelemetryEventSubmitRequest(BaseModel):
    """Incoming multi-modal telemetry payload for problem-solving interaction."""
    student_id: UUID
    question_id: UUID
    concept_id: UUID
    is_correct: bool
    response_time_ms: int = Field(..., ge=0, description="Response time in milliseconds")
    attempt_number: int = Field(default=1, ge=1)
    hints_used: int = Field(default=0, ge=0)
    option_switches: int = Field(default=0, ge=0)


class TelemetryEventResponse(BaseModel):
    """Real-time knowledge tracing update returned to client and platform."""
    student_id: UUID
    concept_id: UUID
    mastery_probability: float
    decayed_mastery_probability: float
    forgetting_factor: float
    trend: str = Field(description="'improving', 'mastered', 'needs_practice', or 'decaying'")
    is_slip: bool = False
    is_guess: bool = False
    is_weak_concept: bool = False


class DiagnosticQuestionSubmission(BaseModel):
    """Individual question answer in a baseline diagnostic test."""
    question_id: UUID
    concept_id: UUID
    is_correct: bool
    response_time_ms: int = Field(..., ge=0)
    attempt_number: int = Field(default=1, ge=1)


class DiagnosticCalibrateRequest(BaseModel):
    """Submission payload for student initial diagnostic assessment."""
    student_id: UUID
    topic_category: Optional[str] = None
    responses: List[DiagnosticQuestionSubmission]


class DiagnosticCalibrateResponse(BaseModel):
    """Outcome of baseline diagnostic profiling across assessed concepts."""
    student_id: UUID
    initial_mastery_vector: List[ConceptMasteryItem]
    weak_concepts: List[str]
    diagnostic_summary: Dict[str, Any]


class WeakConceptItem(BaseModel):
    """Details on a concept identified with deficient mastery or decay."""
    concept_id: UUID
    concept_code: str
    concept_title: str
    topic_category: str
    mastery_probability: float
    decayed_mastery_probability: float
    prerequisite_blockers: List[str] = Field(default_factory=list)
    recommendation: str


class WeakConceptsResponse(BaseModel):
    """Aggregated weak concepts and prerequisite gaps for downstream planning."""
    student_id: UUID
    weak_concepts: List[WeakConceptItem]
    count: int


class RetentionForecastItem(BaseModel):
    """Projected retention decay over non-practice intervals."""
    concept_id: UUID
    concept_code: str
    current_mastery: float
    projected_mastery_1d: float
    projected_mastery_7d: float
    projected_mastery_30d: float


class RetentionForecastResponse(BaseModel):
    """Multi-day memory decay projection for proactive revision scheduling."""
    student_id: UUID
    forecast: List[RetentionForecastItem]
