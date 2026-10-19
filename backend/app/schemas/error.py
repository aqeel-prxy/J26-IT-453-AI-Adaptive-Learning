from typing import Optional
from uuid import UUID
from pydantic import BaseModel


class ErrorDiagnoseRequest(BaseModel):
    question_id: UUID
    solution_text: str


class ErrorDiagnoseResponse(BaseModel):
    is_correct: bool
    failed_step_index: Optional[int] = None
    error_category: Optional[str] = None
    explanation_text: str
    corrected_solution_step: Optional[str] = None
