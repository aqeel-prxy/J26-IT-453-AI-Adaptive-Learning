from typing import Optional, List
from uuid import UUID
from pydantic import BaseModel


class SolutionStep(BaseModel):
    step_number: int
    expression: str
    explanation: str


class SolveQuestionRequest(BaseModel):
    question: str


class SolveQuestionResponse(BaseModel):
    success: bool
    question: str
    topic: Optional[str] = None
    final_answer: Optional[str] = None
    steps: List[SolutionStep] = []
    supported: bool = True
    error_message: Optional[str] = None


class CheckWorkingRequest(BaseModel):
    question: str
    solution_steps: str


class CheckWorkingResponse(BaseModel):
    is_correct: bool
    question: str
    final_answer: Optional[str] = None
    failed_step_index: Optional[int] = None
    error_category: Optional[str] = None
    explanation_text: str
    corrected_step: Optional[str] = None
    evidence: Optional[str] = None
    is_ambiguous: bool = False
    uncertainty_notice: Optional[str] = None
    correct_steps: List[SolutionStep] = []


class SimilarQuestionResponse(BaseModel):
    concept_id: str
    topic: str
    question: str
    difficulty: str
    expected_answer: str


class OCRRequest(BaseModel):
    image_base64: str


class OCRResponse(BaseModel):
    success: bool
    extracted_question: Optional[str] = None
    detected_topic: Optional[str] = None
    confidence: float = 0.95
    error_message: Optional[str] = None


# Backwards compatibility schemas
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
