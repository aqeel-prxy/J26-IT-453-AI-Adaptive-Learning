from typing import Dict, Any, Optional
from uuid import UUID
from pydantic import BaseModel


class RepresentationSelectRequest(BaseModel):
    student_id: UUID
    concept_id: UUID


class RepresentationResponse(BaseModel):
    representation_id: UUID
    concept_id: UUID
    format_type: str  # TEXT, DIAGRAM, GRAPH, STEP_BY_STEP
    content_payload: Dict[str, Any]
    complexity_level: float = 0.5


class RepresentationOutcomeRequest(BaseModel):
    student_id: UUID
    representation_id: UUID
    duration_seconds: int
    is_successful: bool
    switched_from_id: Optional[UUID] = None
