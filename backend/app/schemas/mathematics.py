from typing import List, Optional, Any, Dict
from uuid import UUID
from pydantic import BaseModel, ConfigDict


class ConceptResponse(BaseModel):
    concept_id: UUID
    topic_category: str
    code: str
    title: str
    prerequisites: List[UUID] = []

    model_config = ConfigDict(from_attributes=True)


class TopicCategoryResponse(BaseModel):
    topic_category: str
    grade_level: int
    concept_count: int


class AttemptSubmitRequest(BaseModel):
    student_id: UUID
    question_id: UUID
    student_solution: str
    response_time_ms: int


class AdaptiveAttemptResponse(BaseModel):
    attempt_id: UUID
    is_correct: bool
    error_diagnosis: Optional[Dict[str, Any]] = None
    learner_profile: Optional[Dict[str, Any]] = None
    recommended_representation: Optional[Dict[str, Any]] = None
    engagement: Optional[Dict[str, Any]] = None
