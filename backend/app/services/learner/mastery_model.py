import math
from datetime import datetime, timezone, timedelta
from typing import Dict, Any, List, Optional
from uuid import UUID

from sqlalchemy.orm import Session
from app.models.learner_profile import LearnerProfile
from app.models.concept import Concept
from app.services.learner.preprocessor import TelemetryPreprocessor


class LearnerMasteryModel:
    """
    Component 02: AI-Based Multi-Modal and Time-Aware Learner Profiling & Knowledge Tracing
    Owner: Jayasinghe J.A.N.V. (IT23319356)

    Production service implementing:
    1. Multi-modal Bayesian Knowledge Tracing with Slip and Guess separation.
    2. Ebbinghaus exponential memory decay across non-learning intervals.
    3. Prerequisite gap detection across Grade 10-11 Mathematics concepts.
    4. Diagnostic assessment baseline calibration.
    """

    # Baseline Knowledge Tracing Hyperparameters
    DEFAULT_P_TRANSIT = 0.15   # Probability of transitioning from unlearned to learned
    DEFAULT_P_GUESS = 0.20     # Base probability of a lucky guess
    DEFAULT_P_SLIP = 0.10      # Base probability of a careless slip
    DEFAULT_DECAY_SCALE = 7.0  # Lambda parameter for Ebbinghaus half-life (in days)
    WEAK_CONCEPT_THRESHOLD = 0.50

    @classmethod
    def calculate_temporal_decay(
        cls,
        mastery: float,
        last_practiced_at: datetime,
        stability_factor: float = 1.0,
        current_time: Optional[datetime] = None
    ) -> float:
        """
        Calculates Ebbinghaus retention decay: R = exp(- delta_t / (S * lambda))
        delta_t is measured in days.
        """
        if current_time is None:
            current_time = datetime.now(timezone.utc)

        if last_practiced_at.tzinfo is None:
            last_practiced_at = last_practiced_at.replace(tzinfo=timezone.utc)

        elapsed_seconds = max(0.0, (current_time - last_practiced_at).total_seconds())
        delta_days = elapsed_seconds / 86400.0

        # Effective retention factor
        effective_stability = max(0.2, stability_factor) * cls.DEFAULT_DECAY_SCALE
        retention = math.exp(-delta_days / effective_stability)

        # Decayed mastery cannot drop below floor 0.05
        decayed_mastery = max(0.05, mastery * retention)
        return round(decayed_mastery, 4)

    @classmethod
    def update_mastery_state(
        cls,
        prior_mastery: float,
        is_correct: bool,
        response_time_ms: int,
        attempt_number: int = 1,
        hints_used: int = 0,
        option_switches: int = 0,
        prior_stability: float = 1.0
    ) -> Dict[str, Any]:
        """
        Fuses multi-modal telemetry into Bayesian Knowledge Tracing update
        with dynamic slip and guess parameterization.
        """
        # 1. Multi-modal signal analysis
        evidence = TelemetryPreprocessor.compute_behavioral_evidence(
            is_correct=is_correct,
            response_time_ms=response_time_ms,
            attempt_number=attempt_number,
            hints_used=hints_used,
            option_switches=option_switches
        )

        p_slip = cls.DEFAULT_P_SLIP
        p_guess = cls.DEFAULT_P_GUESS

        # Adjust guess probability if very fast without foundational mastery
        if evidence["is_potential_guess"] and prior_mastery < 0.40:
            p_guess = 0.35

        # Adjust slip probability if fast but familiar
        if evidence["is_potential_slip"] and prior_mastery > 0.60:
            p_slip = 0.25

        p_l_prev = max(0.01, min(0.99, prior_mastery))

        # 2. Bayesian observation likelihood
        if is_correct:
            p_obs_given_l = 1.0 - p_slip
            p_obs_given_not_l = p_guess
            # Dampen evidence if heavily assisted by hints or multiple attempts
            p_obs_given_l *= evidence["evidence_score"]
        else:
            p_obs_given_l = p_slip
            p_obs_given_not_l = 1.0 - p_guess

        # Posterior probability: P(L_t | Obs)
        p_obs = (p_l_prev * p_obs_given_l) + ((1.0 - p_l_prev) * p_obs_given_not_l)
        p_l_posterior = (p_l_prev * p_obs_given_l) / max(0.0001, p_obs)

        # Knowledge transition: P(L_t) = P(L_t | Obs) + (1 - P(L_t | Obs)) * P(T)
        new_mastery = p_l_posterior + ((1.0 - p_l_posterior) * cls.DEFAULT_P_TRANSIT)
        new_mastery = round(max(0.05, min(0.98, new_mastery)), 4)

        # 3. Update memory stability factor (S)
        if is_correct:
            new_stability = prior_stability * (1.0 + (0.25 * new_mastery))
        else:
            new_stability = max(0.5, prior_stability * 0.85)

        # Trend label
        if new_mastery >= 0.80:
            trend = "mastered"
        elif new_mastery > prior_mastery:
            trend = "improving"
        elif new_mastery < prior_mastery:
            trend = "needs_practice"
        else:
            trend = "stable"

        return {
            "new_mastery": new_mastery,
            "new_stability": round(new_stability, 3),
            "p_slip": p_slip,
            "p_guess": p_guess,
            "trend": trend,
            "is_slip": evidence["is_potential_slip"],
            "is_guess": evidence["is_potential_guess"],
            "evidence": evidence
        }

    @classmethod
    def get_or_create_profile(
        cls,
        db: Session,
        student_id: UUID,
        concept_id: UUID
    ) -> LearnerProfile:
        """Fetches existing learner profile or creates an initialized default profile."""
        profile = db.query(LearnerProfile).filter_by(
            student_id=student_id,
            concept_id=concept_id
        ).first()

        if profile is None:
            profile = LearnerProfile(
                student_id=student_id,
                concept_id=concept_id,
                mastery_probability=0.15,
                forgetting_factor=1.0,
                stability_factor=1.0,
                guess_probability=cls.DEFAULT_P_GUESS,
                slip_probability=cls.DEFAULT_P_SLIP,
                total_attempts=0,
                correct_attempts=0,
                average_response_time_ms=0.0,
                is_weak_concept=True,
                last_practiced_at=datetime.now(timezone.utc)
            )
            db.add(profile)
            db.commit()
            db.refresh(profile)

        return profile

    @classmethod
    def record_telemetry_and_update(
        cls,
        db: Session,
        student_id: UUID,
        concept_id: UUID,
        is_correct: bool,
        response_time_ms: int,
        attempt_number: int = 1,
        hints_used: int = 0,
        option_switches: int = 0
    ) -> Dict[str, Any]:
        """
        Production ingestion method: updates knowledge state, re-calculates memory
        stability, and persists updated profile to database.
        """
        profile = cls.get_or_create_profile(db, student_id, concept_id)

        # 1. Apply existing decay before updating with new observation
        now = datetime.now(timezone.utc)
        current_decayed = cls.calculate_temporal_decay(
            mastery=profile.mastery_probability,
            last_practiced_at=profile.last_practiced_at,
            stability_factor=profile.stability_factor,
            current_time=now
        )

        # 2. Knowledge tracing update from current decayed base
        update_result = cls.update_mastery_state(
            prior_mastery=current_decayed,
            is_correct=is_correct,
            response_time_ms=response_time_ms,
            attempt_number=attempt_number,
            hints_used=hints_used,
            option_switches=option_switches,
            prior_stability=profile.stability_factor
        )

        # 3. Update profile entity fields
        profile.mastery_probability = update_result["new_mastery"]
        profile.stability_factor = update_result["new_stability"]
        profile.slip_probability = update_result["p_slip"]
        profile.guess_probability = update_result["p_guess"]
        profile.total_attempts += 1
        if is_correct:
            profile.correct_attempts += 1

        # Moving average response latency
        n = profile.total_attempts
        profile.average_response_time_ms = (
            ((profile.average_response_time_ms * (n - 1)) + response_time_ms) / n
        )

        profile.is_weak_concept = profile.mastery_probability < cls.WEAK_CONCEPT_THRESHOLD
        profile.last_practiced_at = now
        profile.updated_at = now

        db.commit()
        db.refresh(profile)

        return {
            "student_id": student_id,
            "concept_id": concept_id,
            "mastery_probability": profile.mastery_probability,
            "decayed_mastery_probability": profile.mastery_probability,
            "forgetting_factor": 1.0,
            "trend": update_result["trend"],
            "is_slip": update_result["is_slip"],
            "is_guess": update_result["is_guess"],
            "is_weak_concept": profile.is_weak_concept
        }

    @classmethod
    def get_decayed_mastery_vector(
        cls,
        db: Session,
        student_id: UUID
    ) -> List[Dict[str, Any]]:
        """Returns the complete concept mastery vector with real-time temporal decay."""
        profiles = db.query(LearnerProfile).filter_by(student_id=student_id).all()
        now = datetime.now(timezone.utc)
        vector = []

        for p in profiles:
            concept = db.query(Concept).filter_by(id=p.concept_id).first()
            concept_code = concept.code if concept else "MATH-UNKNOWN"

            decayed = cls.calculate_temporal_decay(
                mastery=p.mastery_probability,
                last_practiced_at=p.last_practiced_at,
                stability_factor=p.stability_factor,
                current_time=now
            )
            forgetting_ratio = round(decayed / max(0.01, p.mastery_probability), 3)

            vector.append({
                "concept_id": p.concept_id,
                "concept_code": concept_code,
                "mastery_probability": decayed,
                "forgetting_factor": min(1.0, forgetting_ratio),
                "stability_factor": p.stability_factor,
                "total_attempts": p.total_attempts,
                "correct_attempts": p.correct_attempts,
                "average_response_time_ms": round(p.average_response_time_ms, 1),
                "is_weak_concept": decayed < cls.WEAK_CONCEPT_THRESHOLD,
                "last_practiced_at": p.last_practiced_at
            })

        return vector

    @classmethod
    def detect_weak_concepts(
        cls,
        db: Session,
        student_id: UUID
    ) -> List[Dict[str, Any]]:
        """
        Identifies concepts with sub-threshold mastery and determines whether
        unmastered prerequisites are blocking learning progression.
        """
        vector = cls.get_decayed_mastery_vector(db, student_id)
        mastery_map = {str(item["concept_id"]): item["mastery_probability"] for item in vector}
        weak_list = []

        for item in vector:
            if item["mastery_probability"] < cls.WEAK_CONCEPT_THRESHOLD:
                concept = db.query(Concept).filter_by(id=item["concept_id"]).first()
                if not concept:
                    continue

                prereq_blockers = []
                # Check prerequisite concept statuses
                prereq_ids = concept.prerequisite_concept_ids or []
                for pid in prereq_ids:
                    p_score = mastery_map.get(str(pid), 0.0)
                    if p_score < 0.60:
                        prereq_concept = db.query(Concept).filter_by(id=UUID(pid)).first() if isinstance(pid, str) else None
                        p_code = prereq_concept.code if prereq_concept else str(pid)
                        prereq_blockers.append(p_code)

                if prereq_blockers:
                    recommendation = f"Prerequisite gap detected: Must reinforce {', '.join(prereq_blockers)} first."
                else:
                    recommendation = f"Needs direct revision: Practice fundamental exercises in {concept.title}."

                weak_list.append({
                    "concept_id": item["concept_id"],
                    "concept_code": item["concept_code"],
                    "concept_title": concept.title,
                    "topic_category": concept.topic_category,
                    "mastery_probability": item["mastery_probability"],
                    "decayed_mastery_probability": item["mastery_probability"],
                    "prerequisite_blockers": prereq_blockers,
                    "recommendation": recommendation
                })

        return weak_list

    @classmethod
    def calibrate_diagnostic_profile(
        cls,
        db: Session,
        student_id: UUID,
        responses: List[Any],
        topic_category: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Calibrates initial cold-start mastery vector from diagnostic assessment responses.
        """
        # Group responses by concept_id
        grouped: Dict[str, List[Dict[str, Any]]] = {}
        for r in responses:
            cid = str(r.concept_id) if hasattr(r, "concept_id") else str(r["concept_id"])
            if cid not in grouped:
                grouped[cid] = []
            grouped[cid].append({
                "is_correct": r.is_correct if hasattr(r, "is_correct") else r["is_correct"],
                "response_time_ms": r.response_time_ms if hasattr(r, "response_time_ms") else r["response_time_ms"],
            })

        now = datetime.now(timezone.utc)
        calibrated_items = []
        weak_concept_codes = []

        for cid_str, items in grouped.items():
            cid = UUID(cid_str)
            correct_count = sum(1 for x in items if x["is_correct"])
            total = len(items)
            avg_time = sum(x["response_time_ms"] for x in items) / total

            accuracy = correct_count / total

            # Baseline ability calibration
            if accuracy >= 0.80 and avg_time < 25000:
                p_0 = 0.85
                stability = 2.0
            elif accuracy >= 0.50:
                p_0 = 0.55
                stability = 1.2
            else:
                p_0 = 0.20
                stability = 0.8

            profile = cls.get_or_create_profile(db, student_id, cid)
            profile.mastery_probability = p_0
            profile.stability_factor = stability
            profile.total_attempts = total
            profile.correct_attempts = correct_count
            profile.average_response_time_ms = avg_time
            profile.is_weak_concept = p_0 < cls.WEAK_CONCEPT_THRESHOLD
            profile.last_practiced_at = now
            profile.updated_at = now
            db.commit()

            concept = db.query(Concept).filter_by(id=cid).first()
            c_code = concept.code if concept else "MATH-CONCEPT"
            if profile.is_weak_concept:
                weak_concept_codes.append(c_code)

            calibrated_items.append({
                "concept_id": cid,
                "concept_code": c_code,
                "mastery_probability": p_0,
                "forgetting_factor": 1.0,
                "stability_factor": stability,
                "total_attempts": total,
                "correct_attempts": correct_count,
                "average_response_time_ms": avg_time,
                "is_weak_concept": profile.is_weak_concept,
                "last_practiced_at": now
            })

        return {
            "student_id": student_id,
            "initial_mastery_vector": calibrated_items,
            "weak_concepts": weak_concept_codes,
            "diagnostic_summary": {
                "total_assessed_concepts": len(calibrated_items),
                "weak_concepts_count": len(weak_concept_codes),
                "calibration_timestamp": now.isoformat()
            }
        }

    @classmethod
    def get_retention_forecast(
        cls,
        db: Session,
        student_id: UUID
    ) -> List[Dict[str, Any]]:
        """Forecasts concept retention after 1, 7, and 30 days of inactivity."""
        profiles = db.query(LearnerProfile).filter_by(student_id=student_id).all()
        now = datetime.now(timezone.utc)
        forecast_list = []

        for p in profiles:
            concept = db.query(Concept).filter_by(id=p.concept_id).first()
            c_code = concept.code if concept else "MATH-CONCEPT"

            m1 = cls.calculate_temporal_decay(p.mastery_probability, now, p.stability_factor, now + timedelta(days=1))
            m7 = cls.calculate_temporal_decay(p.mastery_probability, now, p.stability_factor, now + timedelta(days=7))
            m30 = cls.calculate_temporal_decay(p.mastery_probability, now, p.stability_factor, now + timedelta(days=30))

            forecast_list.append({
                "concept_id": p.concept_id,
                "concept_code": c_code,
                "current_mastery": p.mastery_probability,
                "projected_mastery_1d": m1,
                "projected_mastery_7d": m7,
                "projected_mastery_30d": m30
            })

        return forecast_list
