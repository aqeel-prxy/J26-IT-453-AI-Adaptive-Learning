from typing import Optional, List
from uuid import UUID
from pydantic import BaseModel


class ErrorDiagnoseRequest(BaseModel):
    question_id: Optional[UUID] = None
    question_text: Optional[str] = None
    solution_text: str


class ErrorDiagnoseResponse(BaseModel):
    is_correct: bool
    failed_step_index: Optional[int] = None
    error_category: Optional[str] = None
    explanation_text: str
    corrected_solution_step: Optional[str] = None
    correct_steps: Optional[List[str]] = None
    final_answer: Optional[str] = None


class OCRRequest(BaseModel):
    image_base64: str


class OCRResponse(BaseModel):
    success: bool
    extracted_question: str
    detected_topic: Optional[str] = None
    confidence: float = 0.95


class SolveAndDiagnoseRequest(BaseModel):
    question: str
    solution_text: str


class SolveAndDiagnoseResponse(BaseModel):
    is_correct: bool
    question: str
    final_answer: str
    correct_steps: List[str]
    failed_step_index: Optional[int] = None
    error_category: Optional[str] = None
    explanation_text: str
    pedagogical_guidance: Optional[str] = None
