"""
============================================================
BACKWARD COMPATIBILITY STUB & FACADE — Component 2
Owner: Jayasinghe J.A.N.V (IT23319356)
Component 2: AI-Based Multi-Modal Learner Profiling & Knowledge Tracing
============================================================
Provides backward compatibility for existing platform integration tests
while routing live calls to the production LearnerMasteryModel.
"""
from typing import Dict, Any, Optional
from uuid import UUID
from sqlalchemy.orm import Session
from app.services.learner.mastery_model import LearnerMasteryModel


class LearnerProfilingStub:
    """Compatibility facade delegating to LearnerMasteryModel with deterministic fallback."""

    @staticmethod
    def get_learner_state(student_id: UUID, db: Optional[Session] = None) -> Dict[str, Any]:
        if db is not None:
            vector = LearnerMasteryModel.get_decayed_mastery_vector(db, student_id)
            if vector:
                return {
                    "student_id": str(student_id),
                    "mastery_vector": vector,
                    "model_version": "bkt_ebbinghaus_v1"
                }

        # Deterministic fallback for offline testing
        return {
            "student_id": str(student_id),
            "mastery_vector": [
                {
                    "concept_id": "c1111111-1111-1111-1111-111111111111",
                    "concept_code": "MATH-G10-QUAD-01",
                    "mastery_probability": 0.42,
                    "forgetting_factor": 0.95,
                    "stability_factor": 1.0,
                    "total_attempts": 1,
                    "correct_attempts": 0,
                    "average_response_time_ms": 14200.0,
                    "is_weak_concept": True,
                    "last_practiced_at": "2026-10-03T14:00:00Z"
                }
            ],
            "stub_notice": "DEVELOPMENT STUB — NOT FINAL RESEARCH MODEL"
        }

    @staticmethod
    def update_learner_state(
        student_id: UUID,
        question_id: UUID,
        is_correct: bool,
        response_time_ms: int,
        concept_id: Optional[UUID] = None,
        db: Optional[Session] = None
    ) -> Dict[str, Any]:
        if db is not None and concept_id is not None:
            res = LearnerMasteryModel.record_telemetry_and_update(
                db=db,
                student_id=student_id,
                concept_id=concept_id,
                is_correct=is_correct,
                response_time_ms=response_time_ms
            )
            return {
                "student_id": str(student_id),
                "concept_id": str(concept_id),
                "mastery_probability": res["mastery_probability"],
                "trend": res["trend"],
                "is_slip": res["is_slip"],
                "is_guess": res["is_guess"]
            }

        # Dynamic Bayesian calculation even in offline mode
        calc = LearnerMasteryModel.update_mastery_state(
            prior_mastery=0.42,
            is_correct=is_correct,
            response_time_ms=response_time_ms
        )
        return {
            "student_id": str(student_id),
            "concept_id": str(concept_id or "c1111111-1111-1111-1111-111111111111"),
            "mastery_probability": calc["new_mastery"],
            "trend": calc["trend"],
            "is_slip": calc["is_slip"],
            "is_guess": calc["is_guess"],
            "stub_notice": "DEVELOPMENT STUB — NOT FINAL RESEARCH MODEL"
        }
