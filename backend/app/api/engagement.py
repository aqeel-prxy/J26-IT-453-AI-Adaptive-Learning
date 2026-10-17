from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Query
from app.schemas.engagement import (
    EngagementDashboardResponse,
    VirtualPetStatus,
    ProfileEngagementFeedbackResponse,
    TelemetryEvaluateRequest,
)
from app.services.engagement.engagement_stub import EngagementStub

router = APIRouter(prefix="/engagement", tags=["Engagement (Component 3)"])


@router.get("/dashboard/{student_id}", response_model=EngagementDashboardResponse)
def get_engagement_dashboard(student_id: UUID):
    """Get engagement, streak, and virtual pet status from Component 3 development stub"""
    data = EngagementStub.get_dashboard_data(student_id)
    return EngagementDashboardResponse(
        student_id=student_id,
        current_streak_days=data["current_streak_days"],
        total_points=data["total_points"],
        virtual_pet=VirtualPetStatus(
            level=data["virtual_pet"]["level"],
            health=data["virtual_pet"]["health"],
            pet_name=data["virtual_pet"]["pet_name"]
        )
    )


@router.get("/profile-feedback/{student_id}", response_model=ProfileEngagementFeedbackResponse)
def get_profile_feedback(
    student_id: UUID,
    state: Optional[str] = Query(None, description="Optional override state: FOCUSED, FRUSTRATED, BORED, AT_RISK")
):
    """
    Component 3 ML Model: Returns real-time affective diagnosis, telemetry indicators,
    and adaptive scaffolding suggestions (streak shield, hints, reset challenge).
    """
    feedback = EngagementStub.get_profile_feedback(student_id, forced_state=state)
    return ProfileEngagementFeedbackResponse(**feedback)


@router.post("/telemetry/evaluate", response_model=ProfileEngagementFeedbackResponse)
def evaluate_telemetry(payload: TelemetryEvaluateRequest):
    """
    Component 3 Closed-Loop Engine: Ingests real-time clickstream telemetry
    and dynamically determines the student's affective state and intervention actions.
    """
    inferred_state = EngagementStub.evaluate_telemetry_state(
        time_per_problem=payload.time_per_problem_sec,
        hesitation_pauses=payload.hesitation_pauses_sec,
        attempt_bursts=payload.attempt_burst_count,
        consecutive_errors=payload.consecutive_errors,
        idle_latency=payload.idle_latency_sec,
    )
    feedback = EngagementStub.get_profile_feedback(payload.student_id, forced_state=inferred_state)
    return ProfileEngagementFeedbackResponse(**feedback)
