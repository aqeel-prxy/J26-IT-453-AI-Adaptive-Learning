from uuid import UUID
from fastapi import APIRouter
from app.schemas.learner import LearnerProfileResponse
from app.services.learner.learner_stub import LearnerProfilingStub

router = APIRouter(prefix="/learner", tags=["Learner Profiling (Component 2)"])


@router.get("/profile/{student_id}", response_model=LearnerProfileResponse)
def get_learner_profile(student_id: UUID):
    """Get Learner Profile and concept mastery vector from Component 2 development stub"""
    state = LearnerProfilingStub.get_learner_state(student_id)
    return LearnerProfileResponse(
        student_id=student_id,
        mastery_vector=state["mastery_vector"]
    )
