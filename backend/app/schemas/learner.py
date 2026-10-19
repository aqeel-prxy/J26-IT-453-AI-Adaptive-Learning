from typing import List, Optional
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel


class ConceptMasteryItem(BaseModel):
    concept_id: UUID
    concept_code: str
    mastery_probability: float
    forgetting_factor: float
    last_practiced_at: Optional[datetime] = None


class LearnerProfileResponse(BaseModel):
    student_id: UUID
    mastery_vector: List[ConceptMasteryItem]
