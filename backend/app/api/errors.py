from fastapi import APIRouter
from app.schemas.error import ErrorDiagnoseRequest, ErrorDiagnoseResponse
from app.services.error_diagnosis.error_stub import ErrorDiagnosisStub

router = APIRouter(prefix="/error", tags=["Error Diagnosis (Component 4)"])


@router.post("/diagnose", response_model=ErrorDiagnoseResponse)
def diagnose_error(request: ErrorDiagnoseRequest):
    """Diagnose mathematical solution step errors using Component 4 development stub"""
    diag = ErrorDiagnosisStub.analyze_solution(request.question_id, request.solution_text)
    return ErrorDiagnoseResponse(
        is_correct=diag["is_correct"],
        failed_step_index=diag.get("failed_step_index"),
        error_category=diag.get("error_category"),
        explanation_text=diag["explanation_text"],
        corrected_solution_step=diag.get("corrected_solution_step")
    )
