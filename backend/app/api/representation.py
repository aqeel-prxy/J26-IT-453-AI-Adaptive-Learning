from uuid import UUID
from fastapi import APIRouter
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
def record_outcome(request: RepresentationOutcomeRequest):
    """Log representation outcome for Component 1 research evaluation"""
    return RepresentationStub.record_outcome(
        request.student_id, request.representation_id, request.duration_seconds, request.is_successful
    )
