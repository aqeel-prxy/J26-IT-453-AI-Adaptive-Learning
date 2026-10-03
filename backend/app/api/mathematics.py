from typing import List
from uuid import UUID, uuid4
from fastapi import APIRouter
from app.schemas.mathematics import (
    ConceptResponse, TopicCategoryResponse, AttemptSubmitRequest, AdaptiveAttemptResponse
)
from app.services.error_diagnosis.error_stub import ErrorDiagnosisStub
from app.services.learner.learner_stub import LearnerProfilingStub
from app.services.representation.representation_stub import RepresentationStub
from app.services.engagement.engagement_stub import EngagementStub

router = APIRouter(prefix="/mathematics", tags=["Mathematics"])


@router.get("/topics", response_model=List[TopicCategoryResponse])
def list_topics():
    """Get Grade 10-11 Math Topic Categories"""
    return [
        TopicCategoryResponse(
            topic_category="Quadratic Equations",
            grade_level=10,
            concept_count=4
        ),
        TopicCategoryResponse(
            topic_category="Perimeter and Area of Plane Figures",
            grade_level=10,
            concept_count=3
        ),
        TopicCategoryResponse(
            topic_category="Indices and Logarithms",
            grade_level=11,
            concept_count=5
        )
    ]


@router.get("/concepts/{concept_id}", response_model=ConceptResponse)
def get_concept(concept_id: UUID):
    """Get Concept details by ID"""
    return ConceptResponse(
        concept_id=concept_id,
        topic_category="Quadratic Equations",
        code="MATH-G10-QUAD-01",
        title="Solving Quadratic Equations by Factorization",
        prerequisites=[]
    )


@router.post("/attempts/submit", response_model=AdaptiveAttemptResponse)
def submit_attempt(request: AttemptSubmitRequest):
    """
    Submits a student answer attempt.
    Coordinates between component development stubs:
    - Component 4 Error Diagnosis
    - Component 2 Learner Profiling
    - Component 1 Representation Selection
    - Component 3 Engagement & Feedback
    """
    attempt_id = uuid4()
    
    # 1. Error Diagnosis Stub (Component 4)
    diag = ErrorDiagnosisStub.analyze_solution(request.question_id, request.student_solution)
    is_correct = diag["is_correct"]
    
    # 2. Learner Profiling Stub (Component 2)
    profile = LearnerProfilingStub.update_learner_state(
        request.student_id, request.question_id, is_correct, request.response_time_ms
    )
    
    # 3. Representation Selection Stub (Component 1)
    rep = RepresentationStub.select_representation(request.student_id, UUID("c1111111-1111-1111-1111-111111111111"))
    
    # 4. Engagement & Feedback Stub (Component 3)
    eng = EngagementStub.process_activity_outcome(request.student_id, is_correct)
    
    return AdaptiveAttemptResponse(
        attempt_id=attempt_id,
        is_correct=is_correct,
        error_diagnosis=diag,
        learner_profile=profile,
        recommended_representation=rep,
        engagement=eng
    )
