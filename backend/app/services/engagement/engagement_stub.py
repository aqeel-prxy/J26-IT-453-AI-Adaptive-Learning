"""
============================================================
Component 3: AI-Assisted Engagement, Gamification & Feedback Adaptation
Owner: Dharmasena K.C.D (IT23320628)
============================================================
This service implements:
1. Temporal Disengagement & Cognitive State Inference (Engaged, Bored, Frustrated, At-Risk)
2. Behavior-Driven Motivation Clustering (Hexad User Types: Achiever, Player, Free Spirit)
3. Closed-Loop Scaffolding Engine (Streak Protection, Step-by-Step Hints, Quick Reset Challenges)
"""
from typing import Dict, Any, Optional
from uuid import UUID


class EngagementStub:
    """Component 3 Service Engine for Affective Inference & Scaffolding Interventions"""

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
            "stub_notice": "Component 3 Engagement Model Active"
        }

    @staticmethod
    def process_activity_outcome(student_id: UUID, is_correct: bool) -> Dict[str, Any]:
        earned = 10 if is_correct else 2
        return {
            "current_streak_days": 4,
            "virtual_pet_health": 95,
            "earned_points": earned,
            "feedback_message": "Great work! Keep practicing to increase your streak!" if is_correct else "Good effort! Practice makes perfect.",
            "stub_notice": "Component 3 Engagement Model Active"
        }

    @staticmethod
    def evaluate_telemetry_state(
        time_per_problem: float,
        hesitation_pauses: float,
        attempt_bursts: int,
        consecutive_errors: int,
        idle_latency: float,
    ) -> str:
        """
        Rule/ML classifier mapping continuous clickstream interaction telemetry
        to discrete cognitive and affective states:
        - FOCUSED: Balanced time per problem, minimal idle latency, low error rate
        - FRUSTRATED: High latency, attempt bursts (multiple fast retries), repeated mistakes
        - BORED: Low latency (< 15s), high idle gaps, mechanical guessing
        - AT_RISK: Extreme hesitation, multiple consecutive errors, prolonged inactivity
        """
        if consecutive_errors >= 4 or idle_latency > 120.0 or (time_per_problem > 200.0 and hesitation_pauses > 40.0):
            return "AT_RISK"
        elif consecutive_errors >= 2 and (attempt_bursts >= 2 or hesitation_pauses > 30.0):
            return "FRUSTRATED"
        elif time_per_problem < 18.0 and idle_latency > 50.0:
            return "BORED"
        else:
            return "FOCUSED"

    @classmethod
    def get_profile_feedback(
        cls,
        student_id: UUID,
        forced_state: Optional[str] = None
    ) -> Dict[str, Any]:
        state = (forced_state or "FRUSTRATED").upper()

        if state == "FOCUSED":
            return {
                "student_id": str(student_id),
                "affective_state": "FOCUSED",
                "state_label": "Focused & In Deep Flow",
                "confidence_score": 0.94,
                "motivational_archetype": "Achiever",
                "situation_explanation": "Continuous focus detected: steady problem-solving pace (42s average) with active deliberation and zero blind guessing.",
                "primary_recommendation": "You are in an optimal learning zone! Maintain this pace to consolidate algebraic concepts.",
                "telemetry": {
                    "time_per_problem_sec": 42.0,
                    "hesitation_score": 0.14,
                    "blind_guessing_probability": 0.05,
                    "consecutive_errors": 0,
                    "idle_latency_sec": 4.5,
                    "active_topic": "Indices & Logarithms (Power Rules)"
                },
                "scaffolding_actions": [
                    {
                        "id": "scaff-f1",
                        "title": "Flow Multiplier Active",
                        "description": "Earning 1.5x Mastery Points for consistent conceptual responses.",
                        "action_type": "STREAK_SHIELD",
                        "badge_text": "1.5x XP Active",
                        "is_completed": False
                    },
                    {
                        "id": "scaff-f2",
                        "title": "Peer Speed Challenge Ready",
                        "description": "Test your reflexes against an asynchronous peer problem set.",
                        "action_type": "RESET_CHALLENGE",
                        "badge_text": "Challenge Ready",
                        "is_completed": False
                    }
                ],
                "streak_days": 4,
                "streak_freeze_shields": 2,
                "total_gamification_points": 310,
                "virtual_pet": {"name": "MathPaws", "level": 2, "health": 98}
            }

        elif state == "BORED":
            return {
                "student_id": str(student_id),
                "affective_state": "BORED",
                "state_label": "Boredom / Inattention Detected",
                "confidence_score": 0.86,
                "motivational_archetype": "Player",
                "situation_explanation": "Rapid question clicks (<15s) combined with prolonged idle pauses (78s) indicate loss of cognitive stimulation. The current material may feel too repetitive.",
                "primary_recommendation": "Re-energize your brain with a 60-second Quick Reset Challenge before tackling higher difficulty equations.",
                "telemetry": {
                    "time_per_problem_sec": 14.0,
                    "hesitation_score": 0.08,
                    "blind_guessing_probability": 0.76,
                    "consecutive_errors": 1,
                    "idle_latency_sec": 78.0,
                    "active_topic": "Simple Factorization of Linear Terms"
                },
                "scaffolding_actions": [
                    {
                        "id": "scaff-b1",
                        "title": "60s Quick Reset Mini-Puzzle",
                        "description": "Solve 3 rapid mental calculation puzzles to wake up analytical focus.",
                        "action_type": "RESET_CHALLENGE",
                        "badge_text": "Brain Reset",
                        "is_completed": False
                    },
                    {
                        "id": "scaff-b2",
                        "title": "Jump to Advanced Quadratic Challenge",
                        "description": "Skip repetitive intro drills and attempt quadratic formula derivations directly.",
                        "action_type": "CURRICULUM_ADAPT",
                        "badge_text": "Fast Forward",
                        "is_completed": False
                    }
                ],
                "streak_days": 4,
                "streak_freeze_shields": 2,
                "total_gamification_points": 240,
                "virtual_pet": {"name": "MathPaws", "level": 2, "health": 88}
            }

        elif state == "AT_RISK":
            return {
                "student_id": str(student_id),
                "affective_state": "AT_RISK",
                "state_label": "At-Risk of Task Abandonment",
                "confidence_score": 0.92,
                "motivational_archetype": "Free Spirit",
                "situation_explanation": "Telemetry indicates cognitive overload: interaction latency exceeded 215s, 4 consecutive incorrect attempts, and long inactivity periods indicate imminent session exit.",
                "primary_recommendation": "Emergency Streak Shield activated! Your 4-day streak is guaranteed safe. Take a short 2-minute break or switch to a visual representation.",
                "telemetry": {
                    "time_per_problem_sec": 215.0,
                    "hesitation_score": 0.95,
                    "blind_guessing_probability": 0.88,
                    "consecutive_errors": 4,
                    "idle_latency_sec": 125.0,
                    "active_topic": "Completing the Square - Quadratic Roots"
                },
                "scaffolding_actions": [
                    {
                        "id": "scaff-r1",
                        "title": "Emergency Streak Shield Engaged",
                        "description": "Your 4-day streak is protected against abandonment penalty.",
                        "action_type": "STREAK_SHIELD",
                        "badge_text": "Shield Active 🛡️",
                        "is_completed": False
                    },
                    {
                        "id": "scaff-r2",
                        "title": "Visual Representation Pivot",
                        "description": "Switch from symbolic quadratic algebra to geometric area models.",
                        "action_type": "CURRICULUM_ADAPT",
                        "badge_text": "Visual Mode",
                        "is_completed": False
                    },
                    {
                        "id": "scaff-r3",
                        "title": "Signal Member 4 (Curriculum Engine)",
                        "description": "Direct Member 4 to sequence an easier prerequisite before this problem.",
                        "action_type": "STEP_HINT",
                        "badge_text": "Path Adapted",
                        "is_completed": False
                    }
                ],
                "streak_days": 4,
                "streak_freeze_shields": 1,
                "total_gamification_points": 240,
                "virtual_pet": {"name": "MathPaws", "level": 2, "health": 75}
            }

        else:  # FRUSTRATED (Default)
            return {
                "student_id": str(student_id),
                "affective_state": "FRUSTRATED",
                "state_label": "Cognitive Strain & Frustration Detected",
                "confidence_score": 0.89,
                "motivational_archetype": "Achiever",
                "situation_explanation": "Our behavioral AI model detected rapid consecutive attempts and extended hesitation (52s) on Quadratic Equations. Pattern reflects genuine cognitive struggle rather than inattention.",
                "primary_recommendation": "Streak Shield is active. Rather than blind guessing, follow Step-by-Step Guided Hints to unblock this problem.",
                "telemetry": {
                    "time_per_problem_sec": 148.0,
                    "hesitation_score": 0.81,
                    "blind_guessing_probability": 0.68,
                    "consecutive_errors": 3,
                    "idle_latency_sec": 44.0,
                    "active_topic": "Quadratic Equations (Factorization)"
                },
                "scaffolding_actions": [
                    {
                        "id": "scaff-fr1",
                        "title": "Streak Protection Active 🛡️",
                        "description": "System identified genuine struggle on difficult math. Your 4-day streak will not break.",
                        "action_type": "STREAK_SHIELD",
                        "badge_text": "Streak Safe",
                        "is_completed": False
                    },
                    {
                        "id": "scaff-fr2",
                        "title": "Step-by-Step Guided Hint",
                        "description": "Deconstruct quadratic trinomial into 3 manageable steps (calculate a×c, find factors, split middle term).",
                        "action_type": "STEP_HINT",
                        "badge_text": "3 Sub-Steps",
                        "is_completed": False
                    },
                    {
                        "id": "scaff-fr3",
                        "title": "Signal Member 4 Difficulty Adjuster",
                        "description": "Member 4 receives real-time frustration flag to serve foundational prerequisite next.",
                        "action_type": "CURRICULUM_ADAPT",
                        "badge_text": "Calibrated",
                        "is_completed": False
                    }
                ],
                "streak_days": 4,
                "streak_freeze_shields": 2,
                "total_gamification_points": 240,
                "virtual_pet": {"name": "MathPaws", "level": 2, "health": 92}
            }
