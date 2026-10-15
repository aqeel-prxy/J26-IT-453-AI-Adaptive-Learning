"""
Readiness Inference Service — Component 1 (Aqeel M.I.M)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Exposes online readiness inference for concept nodes:
- Uses trained supervised ML model when artifact is available on disk.
- Falls back gracefully to transparent deterministic rule-based baseline if model is unavailable.
- Clearly flags model version and confidence in prediction output.
"""
import os
import joblib
import pandas as pd
from typing import Dict, Any, Optional
from app.services.learning_path.data_pipeline import FEATURE_COLUMNS

ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "artifacts")
MODEL_PATH = os.path.join(ARTIFACTS_DIR, "readiness_model.pkl")
METRICS_PATH = os.path.join(ARTIFACTS_DIR, "model_metrics.json")


class ReadinessPredictor:
    """Predicts learner readiness for mathematical concepts using pre-attempt evidence."""

    def __init__(self, model_path: str = MODEL_PATH):
        self.model_path = model_path
        self.model = None
        self.model_name = "RuleBased_Fallback"
        self._load_model()

    def _load_model(self) -> None:
        """Attempts to load the serialized ML model pipeline from disk."""
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

    def predict_readiness(
        self,
        student_id: str,
        concept_id: str,
        concept_order_index: int,
        prerequisite_avg_accuracy: float,
        past_overall_accuracy: float,
        recent_attempt_count: int = 1,
        avg_response_time_ms: float = 18000.0
    ) -> Dict[str, Any]:
        """
        Estimates the probability that the student is ready to master the target concept.
        Returns:
            Dict containing readiness probability, binary classification, confidence,
            model version, and snapshot of features used.
        """
        features_dict = {
            "concept_order_index": concept_order_index,
            "prerequisite_avg_accuracy": float(prerequisite_avg_accuracy),
            "past_overall_accuracy": float(past_overall_accuracy),
            "recent_attempt_count": int(recent_attempt_count),
            "avg_response_time_ms": float(avg_response_time_ms)
        }

        # 1. ML-based prediction if model is loaded
        if self.model is not None:
            df = pd.DataFrame([features_dict])[FEATURE_COLUMNS]
            proba = float(self.model.predict_proba(df)[0, 1])
            model_version = f"ML-{self.model.named_steps['classifier'].__class__.__name__}"
        else:
            # 2. Transparent rule-based fallback baseline
            order_factor = max(0.0, (concept_order_index - 1) * 0.05)
            score = (
                (0.55 * prerequisite_avg_accuracy)
                + (0.35 * past_overall_accuracy)
                - order_factor
            )
            proba = max(0.05, min(0.95, score))
            model_version = "Baseline-RuleBased-Fallback"

        # Threshold: 0.60 probability required for direct progression
        is_ready = bool(proba >= 0.60)
        # Confidence metric: distance from uncertain decision boundary (0.50) scaled to [0, 1]
        confidence = round(float(abs(proba - 0.50) * 2.0), 4)

        return {
            "student_id": student_id,
            "concept_id": concept_id,
            "readiness_probability": round(proba, 4),
            "is_ready": is_ready,
            "confidence": confidence,
            "model_version": model_version,
            "features_used": features_dict
        }
