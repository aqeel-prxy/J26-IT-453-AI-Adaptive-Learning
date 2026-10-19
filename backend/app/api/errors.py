from fastapi import APIRouter, Query
from typing import Optional
from app.schemas.error import (
    ErrorDiagnoseRequest,
    ErrorDiagnoseResponse,
    OCRRequest,
    OCRResponse,
    SolveAndDiagnoseRequest,
    SolveAndDiagnoseResponse,
    SolveQuestionRequest,
    SolveQuestionResponse,
    CheckWorkingRequest,
    CheckWorkingResponse,
    SimilarQuestionResponse,
    SolutionStep,
)
from app.services.error_diagnosis.math_solver import MathSolver
from app.services.error_diagnosis.ocr_service import MathOCRService
from app.services.error_diagnosis.question_generator import SimilarQuestionService

router = APIRouter(prefix="/error", tags=["Error Diagnosis (Component 4)"])


@router.post("/ocr", response_model=OCRResponse)
def extract_math_question_ocr(request: OCRRequest):
    """
    Extracts mathematical question text from an uploaded photo or camera capture.
    Performs image validation and returns extracted question or clear error message.
    """
    result = MathOCRService.extract_question_from_base64(request.image_base64)
    return OCRResponse(
        success=result.get("success", False),
        extracted_question=result.get("extracted_question"),
        detected_topic=result.get("detected_topic"),
        confidence=result.get("confidence", 0.94),
        error_message=result.get("error_message")
    )


@router.post("/solve", response_model=SolveQuestionResponse)
def solve_mathematical_question(request: SolveQuestionRequest):
    """
    Validates and solves a mathematical question step-by-step.
    Returns structured steps with expression and explanation, or an error state if unsupported.
    """
    res = MathSolver.solve_question(request.question)
    raw_steps = res.get("steps", [])
    structured_steps = [
        SolutionStep(
            step_number=s["step_number"],
            expression=s["expression"],
            explanation=s["explanation"]
        ) for s in raw_steps
    ]

    return SolveQuestionResponse(
        success=res.get("success", False),
        question=request.question,
        topic=res.get("topic"),
        final_answer=res.get("final_answer"),
        steps=structured_steps,
        supported=res.get("supported", True),
        error_message=res.get("error_message")
    )


@router.post("/check-working", response_model=CheckWorkingResponse)
def check_student_working(request: CheckWorkingRequest):
    """
    Evaluates the student's own intermediate solution steps against the verified benchmark.
    Identifies the first incorrect line, error category, evidence, and corrected step.
    Does not penalize valid alternative methods.
    """
    res = MathSolver.check_student_working(request.question, request.solution_steps)
    raw_steps = res.get("correct_steps", [])
    structured_steps = [
        SolutionStep(
            step_number=s["step_number"],
            expression=s["expression"],
            explanation=s["explanation"]
        ) for s in raw_steps
    ]

    return CheckWorkingResponse(
        is_correct=res.get("is_correct", False),
        question=request.question,
        final_answer=res.get("final_answer"),
        failed_step_index=res.get("failed_step_index"),
        error_category=res.get("error_category"),
        explanation_text=res.get("explanation_text", ""),
        corrected_step=res.get("corrected_step"),
        evidence=res.get("evidence"),
        is_ambiguous=res.get("is_ambiguous", False),
        uncertainty_notice=res.get("uncertainty_notice"),
        correct_steps=structured_steps
    )


@router.get("/similar-question", response_model=SimilarQuestionResponse)
def get_similar_practice_question(current_question: str = Query("2x² + 5x - 3 = 0")):
    """
    Provides a mathematically verified similar practice question testing the same concept.
    """
    q_data = SimilarQuestionService.get_similar_question(current_question)
    return SimilarQuestionResponse(
        concept_id=q_data["concept_id"],
        topic=q_data["topic"],
        question=q_data["question"],
        difficulty=q_data["difficulty"],
        expected_answer=q_data["expected_answer"]
    )


# -------------------------------------------------------------
# Backwards compatibility endpoints
# -------------------------------------------------------------
@router.post("/solve-and-diagnose", response_model=SolveAndDiagnoseResponse)
def solve_and_diagnose(request: SolveAndDiagnoseRequest):
    """Backwards compatible endpoint combining solving and working evaluation."""
    checked = MathSolver.check_student_working(request.question, request.solution_text)
    raw_steps = checked.get("correct_steps", [])
    flat_steps = [f"Step {s['step_number']}: {s['expression']} ({s['explanation']})" for s in raw_steps]

    return SolveAndDiagnoseResponse(
        is_correct=checked["is_correct"],
        question=request.question,
        final_answer=checked.get("final_answer", ""),
        correct_steps=flat_steps,
        failed_step_index=checked.get("failed_step_index"),
        error_category=checked.get("error_category"),
        explanation_text=checked.get("explanation_text", ""),
        pedagogical_guidance=checked.get("evidence")
    )


@router.post("/diagnose", response_model=ErrorDiagnoseResponse)
def diagnose_error(request: ErrorDiagnoseRequest):
    """Backwards compatible diagnostic endpoint."""
    q_text = request.question_text or "x^2 + 5x + 6 = 0"
    checked = MathSolver.check_student_working(q_text, request.solution_text)
    raw_steps = checked.get("correct_steps", [])
    flat_steps = [f"Step {s['step_number']}: {s['expression']}" for s in raw_steps]

    return ErrorDiagnoseResponse(
        is_correct=checked["is_correct"],
        failed_step_index=checked.get("failed_step_index"),
        error_category=checked.get("error_category"),
        explanation_text=checked.get("explanation_text", ""),
        corrected_solution_step=checked.get("corrected_step"),
        correct_steps=flat_steps,
        final_answer=checked.get("final_answer")
    )
