"""
============================================================
DEVELOPMENT STUB — NOT FINAL RESEARCH MODEL
Owner: Dharmasena K.C.D (IT23320628)
Component 3: Engagement, Gamification & Feedback Adaptation
============================================================
This stub provides sample engagement metrics, streak counters, and pet health data for integration testing.
The actual adaptive gamification model will be implemented in Phase 7 on feature/dharmasena-engagement.
"""
from typing import Dict, Any
from uuid import UUID


class EngagementStub:
    """DEVELOPMENT STUB — NOT FINAL RESEARCH MODEL"""

    @staticmethod
    def get_dashboard_data(student_id: UUID) -> Dict[str, Any]:
        return {
            "student_id": str(student_id),
            "current_streak_days": 4,
            "total_points": 240,
            "virtual_pet": {
                "level": 2,
                "health": 95,
                "pet_name": "MathPaws"
            },
            "stub_notice": "DEVELOPMENT STUB — NOT FINAL RESEARCH MODEL"
        }

    @staticmethod
    def process_activity_outcome(student_id: UUID, is_correct: bool) -> Dict[str, Any]:
        earned = 10 if is_correct else 2
        return {
            "current_streak_days": 4,
            "virtual_pet_health": 95,
            "earned_points": earned,
            "feedback_message": "Great work! Keep practicing to increase your streak!" if is_correct else "Good effort! Practice makes perfect.",
            "stub_notice": "DEVELOPMENT STUB — NOT FINAL RESEARCH MODEL"
        }
