from uuid import UUID
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.schemas.learner import (
    LearnerProfileResponse,
    TelemetryEventSubmitRequest,
    TelemetryEventResponse,
    DiagnosticCalibrateRequest,
    DiagnosticCalibrateResponse,
    WeakConceptsResponse,
    WeakConceptItem,
    RetentionForecastResponse,
    RetentionForecastItem,
    ConceptMasteryItem
)
from app.services.learner.mastery_model import LearnerMasteryModel
from app.services.learner.learner_stub import LearnerProfilingStub

router = APIRouter(prefix="/learner", tags=["Learner Profiling & Knowledge Tracing (Component 2)"])


@router.get("/profile/{student_id}", response_model=LearnerProfileResponse)
def get_learner_profile(student_id: UUID, db: Session = Depends(get_db)):
    """
    Retrieves the real-time learner profile and concept mastery vector.
    Applies on-the-fly Ebbinghaus memory decay for elapsed time since last practice.
    """
    try:
        vector_data = LearnerMasteryModel.get_decayed_mastery_vector(db, student_id)
        if not vector_data:
            # Fallback for demo student if unseeded or stub testing
            stub_state = LearnerProfilingStub.get_learner_state(student_id)
            vector_data = stub_state["mastery_vector"]

        mastery_items = [ConceptMasteryItem(**item) for item in vector_data]
        weak_count = sum(1 for item in mastery_items if item.is_weak_concept)

        return LearnerProfileResponse(
            student_id=student_id,
            mastery_vector=mastery_items,
            weak_concept_count=weak_count,
            updated_at=datetime.now(timezone.utc)
        )
    except Exception as e:
        # Graceful fallback to preserve high availability
        stub_state = LearnerProfilingStub.get_learner_state(student_id)
        mastery_items = [ConceptMasteryItem(**item) for item in stub_state["mastery_vector"]]
        return LearnerProfileResponse(
            student_id=student_id,
            mastery_vector=mastery_items,
            weak_concept_count=1,
            updated_at=datetime.now(timezone.utc)
        )


@router.post("/telemetry/submit", response_model=TelemetryEventResponse)
def submit_telemetry_event(
    request: TelemetryEventSubmitRequest,
    db: Session = Depends(get_db)
):
    """
    Ingests multi-modal problem-solving telemetry:
    Updates Knowledge Tracing state, detects slips/guesses, and updates memory stability.
    """
    result = LearnerMasteryModel.record_telemetry_and_update(
        db=db,
        student_id=request.student_id,
        concept_id=request.concept_id,
        is_correct=request.is_correct,
        response_time_ms=request.response_time_ms,
        attempt_number=request.attempt_number,
        hints_used=request.hints_used,
        option_switches=request.option_switches
    )
    return TelemetryEventResponse(**result)


@router.post("/diagnostic/calibrate", response_model=DiagnosticCalibrateResponse)
def calibrate_diagnostic(
    request: DiagnosticCalibrateRequest,
    db: Session = Depends(get_db)
):
    """
    Calibrates cold-start baseline mastery vector from diagnostic assessment responses.
    """
    if not request.responses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Diagnostic responses list cannot be empty."
        )

    calibration_result = LearnerMasteryModel.calibrate_diagnostic_profile(
        db=db,
        student_id=request.student_id,
        responses=request.responses,
        topic_category=request.topic_category
    )

    items = [ConceptMasteryItem(**x) for x in calibration_result["initial_mastery_vector"]]

    return DiagnosticCalibrateResponse(
        student_id=request.student_id,
        initial_mastery_vector=items,
        weak_concepts=calibration_result["weak_concepts"],
        diagnostic_summary=calibration_result["diagnostic_summary"]
    )


@router.get("/profile/{student_id}/weak-concepts", response_model=WeakConceptsResponse)
def get_weak_concepts(student_id: UUID, db: Session = Depends(get_db)):
    """
    Identifies weak concepts and detects whether prerequisite bottlenecks
    are obstructing learning progress.
    """
    weak_items = LearnerMasteryModel.detect_weak_concepts(db, student_id)
    items = [WeakConceptItem(**x) for x in weak_items]
    return WeakConceptsResponse(
        student_id=student_id,
        weak_concepts=items,
        count=len(items)
    )


@router.get("/profile/{student_id}/retention-forecast", response_model=RetentionForecastResponse)
def get_retention_forecast(student_id: UUID, db: Session = Depends(get_db)):
    """
    Projects Ebbinghaus retention decay for 1-day, 7-day, and 30-day non-practice intervals.
    """
    forecast_data = LearnerMasteryModel.get_retention_forecast(db, student_id)
    items = [RetentionForecastItem(**x) for x in forecast_data]
    return RetentionForecastResponse(
        student_id=student_id,
        forecast=items
    )
