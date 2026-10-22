from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Query
from app.schemas.engagement import (
    EngagementDashboardResponse,
    VirtualPetStatus,
    ProfileEngagementFeedbackResponse,
    TelemetryEvaluateRequest,
    EngagementModelMetricsResponse,
)
from app.services.engagement.engagement_service import EngagementService

router = APIRouter(prefix="/engagement", tags=["Engagement (Component 3)"])


@router.get("/dashboard/{student_id}", response_model=EngagementDashboardResponse)
def get_engagement_dashboard(student_id: UUID):
    """Get engagement, streak, and virtual pet status from Component 3 ML engine"""
    data = EngagementService.get_dashboard_data(student_id)
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
    confidence score, probability distributions, and adaptive scaffolding suggestions.
    """
    feedback = EngagementService.get_profile_feedback(student_id, forced_state=state)
    return ProfileEngagementFeedbackResponse(**feedback)


@router.post("/telemetry/evaluate", response_model=ProfileEngagementFeedbackResponse)
def evaluate_telemetry(payload: TelemetryEvaluateRequest):
    """
    Component 3 Closed-Loop ML Engine: Evaluates continuous clickstream telemetry
    using the trained Random Forest classifier to dynamically determine the student's
    affective state, confidence, and personalized scaffolding actions.
    """
    feedback = EngagementService.evaluate_telemetry(
        student_id=payload.student_id,
        time_taken_sec=payload.time_taken_sec,
        option_switches=payload.option_switches,
        is_rapid_guess=payload.is_rapid_guess,
        is_correct=payload.is_correct,
        idle_seconds=payload.idle_seconds,
        time_per_problem_sec=payload.time_per_problem_sec,
        hesitation_pauses_sec=payload.hesitation_pauses_sec,
        attempt_burst_count=payload.attempt_burst_count,
        consecutive_errors=payload.consecutive_errors,
        idle_latency_sec=payload.idle_latency_sec,
        active_topic=payload.active_topic,
    )
    return ProfileEngagementFeedbackResponse(**feedback)


@router.get("/ml-metrics", response_model=EngagementModelMetricsResponse)
def get_ml_metrics():
    """
    Component 3 Research Transparency: Returns the trained model metrics,
    5-fold cross-validation 95% CI, confusion matrix, and feature importances.
    """
    metrics = EngagementService.get_model_metrics()
    return EngagementModelMetricsResponse(**metrics)
