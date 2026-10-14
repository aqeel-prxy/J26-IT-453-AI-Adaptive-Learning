from uuid import UUID
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models import RepresentationOutcome
from app.schemas.representation import (
    RepresentationSelectRequest, RepresentationResponse, RepresentationOutcomeRequest
)
from app.services.representation.representation_stub import RepresentationStub

router = APIRouter(prefix="/representation", tags=["Representation (Component 1)"])


@router.post("/select", response_model=RepresentationResponse)
def select_representation(request: RepresentationSelectRequest):
    """Select representation for concept from Component 1 development stub"""
    data = RepresentationStub.select_representation(request.student_id, request.concept_id)
    return RepresentationResponse(
        representation_id=UUID(data["representation_id"]),
        concept_id=request.concept_id,
        format_type=data["format_type"],
        content_payload=data["content_payload"],
        complexity_level=data["complexity_level"]
    )


@router.post("/outcome")
def record_outcome(request: RepresentationOutcomeRequest, db: Session = Depends(get_db)):
    """Log representation outcome for Component 1 research evaluation"""
    result = RepresentationStub.record_outcome(
        request.student_id, request.representation_id, request.duration_seconds, request.is_successful
    )
    
    try:
        outcome = RepresentationOutcome(
            student_id=request.student_id,
            representation_id=request.representation_id,
            duration_seconds=request.duration_seconds,
            is_successful=request.is_successful,
            switched_from_id=request.switched_from_id
        )
        db.add(outcome)
        db.commit()
    except Exception:
        db.rollback()
        
    return result
