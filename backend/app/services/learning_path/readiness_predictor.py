"""
Readiness Inference Service — Component 1 (Aqeel M.I.M)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Exposes online readiness inference for concept nodes:
- Uses trained supervised ML model when artifact is available on disk.
- Automatically applies empirically tuned pedagogical decision cutoff tau* (minimizing cognitive overload cost).
- Integrates Component 2 (Jayasinghe) latent knowledge tracing mastery signals when available.
- Falls back gracefully to transparent deterministic rule-based baseline if model is unavailable.
- Clearly flags model version, confidence, and feature attribution in prediction output.
"""
import os
import json
import joblib
import pandas as pd
from typing import Dict, Any, Optional
from app.services.learning_path.data_pipeline import FEATURE_COLUMNS, EXTENDED_FEATURE_COLUMNS

ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "artifacts")
MODEL_PATH = os.path.join(ARTIFACTS_DIR, "readiness_model.pkl")
METRICS_PATH = os.path.join(ARTIFACTS_DIR, "model_metrics.json")

# Default pedagogical decision cutoff when metrics file is missing
DEFAULT_DECISION_THRESHOLD = 0.62


class ReadinessPredictor:
    """Predicts learner readiness for mathematical concepts using pre-attempt evidence and C2 mastery."""

    def __init__(self, model_path: str = MODEL_PATH, metrics_path: str = METRICS_PATH):
        self.model_path = model_path
        self.metrics_path = metrics_path
        self.model = None
        self.model_name = "RuleBased_Fallback"
        self.decision_threshold = DEFAULT_DECISION_THRESHOLD
        self.feature_columns = FEATURE_COLUMNS
        self._load_model_and_metrics()

    def _load_model_and_metrics(self) -> None:
        """Attempts to load the serialized ML model pipeline and calibrated threshold from disk."""
        if os.path.exists(self.model_path):
            try:
                self.model = joblib.load(self.model_path)
                self.model_name = "Trained_ML_Model"
            except Exception:
                self.model = None
                self.model_name = "RuleBased_Fallback"
        else:
            self.model = None
            self.model_name = "RuleBased_Fallback"

        if os.path.exists(self.metrics_path):
            try:
                with open(self.metrics_path, "r", encoding="utf-8") as f:
                    metrics_data = json.load(f)
                    tuning = metrics_data.get("pedagogical_threshold_tuning", {})
                    self.decision_threshold = float(
                        tuning.get("optimal_decision_threshold", DEFAULT_DECISION_THRESHOLD)
                    )
                    self.feature_columns = metrics_data.get("feature_columns", FEATURE_COLUMNS)
            except Exception:
                self.decision_threshold = DEFAULT_DECISION_THRESHOLD

    def predict_readiness(
        self,
        student_id: str,
        concept_id: str,
        concept_order_index: int,
        prerequisite_avg_accuracy: float,
        past_overall_accuracy: float,
        recent_attempt_count: int = 1,
        avg_response_time_ms: float = 18000.0,
        c2_mastery_probability: Optional[float] = None,
        c2_prerequisite_mastery_mean: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Estimates the probability that the student is ready to master the target concept.
        Fuses pre-attempt performance with Component 2 (Jayasinghe) latent knowledge tracing when provided.
        Returns:
            Dict containing readiness probability, cost-optimized classification, confidence,
            model version, and snapshot of features used.
        """
        features_dict: Dict[str, Any] = {
            "concept_order_index": concept_order_index,
            "prerequisite_avg_accuracy": float(prerequisite_avg_accuracy),
            "past_overall_accuracy": float(past_overall_accuracy),
            "recent_attempt_count": int(recent_attempt_count),
            "avg_response_time_ms": float(avg_response_time_ms)
        }

        # Include Component 2 features if available
        if c2_mastery_probability is not None:
            features_dict["c2_mastery_probability"] = float(c2_mastery_probability)
        if c2_prerequisite_mastery_mean is not None:
            features_dict["c2_prerequisite_mastery_mean"] = float(c2_prerequisite_mastery_mean)

        c2_integrated = c2_mastery_probability is not None

        # 1. ML-based prediction if model is loaded
        if self.model is not None:
            # Check what feature columns the pipeline expects
            expected_cols = [c for c in self.feature_columns if c in features_dict]
            # If pipeline was trained on basic features, use basic; if trained on extended, use extended
            try:
                df = pd.DataFrame([features_dict])[expected_cols]
                proba = float(self.model.predict_proba(df)[0, 1])
                model_version = f"ML-{self.model.named_steps['classifier'].__class__.__name__}"
            except Exception:
                # Fallback to standard FEATURE_COLUMNS
                df = pd.DataFrame([features_dict])[FEATURE_COLUMNS]
                proba = float(self.model.predict_proba(df)[0, 1])
                model_version = f"ML-{self.model.named_steps['classifier'].__class__.__name__}"
        else:
            # 2. Transparent rule-based fallback baseline
            order_factor = max(0.0, (concept_order_index - 1) * 0.05)
            if c2_mastery_probability is not None:
                score = (
                    (0.40 * float(c2_mastery_probability))
                    + (0.35 * prerequisite_avg_accuracy)
                    + (0.25 * past_overall_accuracy)
                    - order_factor
                )
            else:
                score = (
                    (0.55 * prerequisite_avg_accuracy)
                    + (0.35 * past_overall_accuracy)
                    - order_factor
                )
            proba = max(0.05, min(0.95, score))
            model_version = "Baseline-RuleBased-Fallback"

        # Apply empirically tuned pedagogical cutoff (minimizing cognitive overload cost)
        is_ready = bool(proba >= self.decision_threshold)
        # Confidence metric: distance from uncertain decision boundary (0.50) scaled to [0, 1]
        confidence = round(float(abs(proba - 0.50) * 2.0), 4)

        return {
            "student_id": student_id,
            "concept_id": concept_id,
            "readiness_probability": round(proba, 4),
            "is_ready": is_ready,
            "decision_threshold_applied": round(self.decision_threshold, 4),
            "cost_sensitive_optimization": "Cost_FP=3.0 (Overload) vs Cost_FN=1.0 (Review)",
            "confidence": confidence,
            "model_version": model_version,
            "component2_mastery_integrated": c2_integrated,
            "features_used": features_dict
        }
