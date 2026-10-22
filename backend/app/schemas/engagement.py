from typing import List, Optional, Dict, Any
from uuid import UUID
from pydantic import BaseModel


class VirtualPetStatus(BaseModel):
    level: int = 1
    health: int = 100
    pet_name: str = "MathPaws"


class EngagementDashboardResponse(BaseModel):
    student_id: UUID
    current_streak_days: int
    total_points: int
    virtual_pet: VirtualPetStatus


class TelemetryIndicatorsSchema(BaseModel):
    time_per_problem_sec: float
    hesitation_score: float
    blind_guessing_probability: float
    consecutive_errors: int
    idle_latency_sec: float
    active_topic: str


class ScaffoldingActionSchema(BaseModel):
    id: str
    title: str
    description: str
    action_type: str
    badge_text: str
    is_completed: bool = False


class ProfileEngagementFeedbackResponse(BaseModel):
    student_id: UUID
    affective_state: str  # FOCUSED, FRUSTRATED, BORED, AT_RISK
    state_label: str
    confidence_score: float
    motivational_archetype: str
    situation_explanation: str
    primary_recommendation: str
    telemetry: TelemetryIndicatorsSchema
    scaffolding_actions: List[ScaffoldingActionSchema]
    streak_days: int
    streak_freeze_shields: int
    total_gamification_points: int
    virtual_pet: Dict[str, Any]
    model_name: Optional[str] = "Random Forest (Trained)"
    probabilities: Optional[Dict[str, float]] = None


class TelemetryEvaluateRequest(BaseModel):
    student_id: UUID
    # Backward-compatible fields
    time_per_problem_sec: float = 45.0
    hesitation_pauses_sec: float = 10.0
    attempt_burst_count: int = 1
    consecutive_errors: int = 0
    idle_latency_sec: float = 5.0
    active_topic: Optional[str] = "Quadratic Equations"

    # Direct ML Model Training Features (from synthetic engagement telemetry)
    time_taken_sec: Optional[float] = None
    option_switches: Optional[int] = None
    is_rapid_guess: Optional[int] = None
    is_correct: Optional[int] = None
    idle_seconds: Optional[float] = None


class EngagementModelMetricsResponse(BaseModel):
    selected_model: str
    feature_columns: List[str]
    target_classes: List[str]
    feature_importances: Dict[str, float]
    comparative_metrics: Dict[str, Any]
    cross_validation_5fold_ci95: Dict[str, Any]
    total_samples: int
    train_samples: int
    test_samples: int

