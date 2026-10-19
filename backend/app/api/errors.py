from fastapi import APIRouter
from app.schemas.error import (
    ErrorDiagnoseRequest,
    ErrorDiagnoseResponse,
    OCRRequest,
    OCRResponse,
    SolveAndDiagnoseRequest,
    SolveAndDiagnoseResponse,
)
from app.services.error_diagnosis.math_solver import MathSolver
from app.services.error_diagnosis.ocr_service import MathOCRService

router = APIRouter(prefix="/error", tags=["Error Diagnosis (Component 4)"])


@router.post("/ocr", response_model=OCRResponse)
def extract_math_question_ocr(request: OCRRequest):
    """
    Extracts mathematical question text from an uploaded photo or camera capture.
    Applies OCR and standardizes mathematical equation notation.
    """
    result = MathOCRService.extract_question_from_base64(request.image_base64)
    return OCRResponse(
        success=result.get("success", True),
        extracted_question=result.get("extracted_question", "Solve 2x² + 5x - 3 = 0"),
        detected_topic=result.get("detected_topic", "Quadratic Equations"),
        confidence=result.get("confidence", 0.95),
    )


@router.post("/solve-and-diagnose", response_model=SolveAndDiagnoseResponse)
def solve_and_diagnose(request: SolveAndDiagnoseRequest):
    """
    Solves the mathematical problem completely, generates step-by-step correct working,
    and analyzes student's intermediate derivation steps to detect error location and taxonomy.
    """
    result = MathSolver.diagnose_student_solution(request.question, request.solution_text)
    return SolveAndDiagnoseResponse(
        is_correct=result["is_correct"],
        question=result.get("question", request.question),
        final_answer=result.get("final_answer", ""),
        correct_steps=result.get("correct_steps", []),
        failed_step_index=result.get("failed_step_index"),
        error_category=result.get("error_category"),
        explanation_text=result.get("explanation_text", ""),
        pedagogical_guidance=result.get("pedagogical_guidance"),
    )


@router.post("/diagnose", response_model=ErrorDiagnoseResponse)
def diagnose_error(request: ErrorDiagnoseRequest):
    """Diagnose mathematical solution step errors"""
    q_text = request.question_text or "x^2 + 5x + 6 = 0"
    result = MathSolver.diagnose_student_solution(q_text, request.solution_text)
    
    return ErrorDiagnoseResponse(
        is_correct=result["is_correct"],
        failed_step_index=result.get("failed_step_index"),
        error_category=result.get("error_category"),
        explanation_text=result.get("explanation_text", ""),
        corrected_solution_step=result.get("final_answer"),
        correct_steps=result.get("correct_steps"),
        final_answer=result.get("final_answer"),
    )
