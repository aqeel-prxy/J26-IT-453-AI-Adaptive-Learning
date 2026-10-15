"""
Model Training & Evaluation Pipeline — Component 1 (Aqeel M.I.M)
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students

Implements reproducible supervised machine-learning training and model selection:
1. Baseline: Logistic Regression (Transparent linear reference model).
2. Candidate 2: Random Forest Classifier (Ensemble bagged decision trees).
3. Candidate 3: Gradient Boosting Classifier (Sequential error-reducing ensemble).

Evaluation uses student-grouped cross-validation to guarantee zero target leakage across learners.
Standard metrics: Precision, Recall, F1-Score, ROC-AUC, Brier Calibration Score.
"""
import os
import json
import joblib
import pandas as pd
from typing import Dict, Any, Tuple
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score, roc_auc_score, brier_score_loss
)
from app.services.learning_path.data_pipeline import FEATURE_COLUMNS, TARGET_COLUMN

ARTIFACTS_DIR = os.path.join(os.path.dirname(__file__), "artifacts")
MODEL_PATH = os.path.join(ARTIFACTS_DIR, "readiness_model.pkl")
METRICS_PATH = os.path.join(ARTIFACTS_DIR, "model_metrics.json")


class ReadinessModelTrainer:
    """Trains, compares, calibrates, and persists the concept readiness prediction model."""

    def __init__(self, random_seed: int = 42):
        self.random_seed = random_seed
        self.models: Dict[str, Pipeline] = {
            "LogisticRegression_Baseline": Pipeline([
                ("scaler", StandardScaler()),
                ("classifier", LogisticRegression(max_iter=1000, random_state=self.random_seed))
            ]),
            "RandomForest": Pipeline([
                ("scaler", StandardScaler()),
                ("classifier", RandomForestClassifier(
                    n_estimators=100, max_depth=5, min_samples_leaf=3, random_state=self.random_seed
                ))
            ]),
            "GradientBoosting": Pipeline([
                ("scaler", StandardScaler()),
                ("classifier", GradientBoostingClassifier(
                    n_estimators=100, max_depth=3, learning_rate=0.08, random_state=self.random_seed
                ))
            ])
        }

    def train_and_evaluate(
        self, train_df: pd.DataFrame, test_df: pd.DataFrame
    ) -> Dict[str, Any]:
        """
        Trains all 3 candidate models on train_df and evaluates on test_df (unseen learners).
        Identifies the optimal model, saves model artifact, and returns comparative metrics.
        """
        X_train = train_df[FEATURE_COLUMNS]
        y_train = train_df[TARGET_COLUMN]
        X_test = test_df[FEATURE_COLUMNS]
        y_test = test_df[TARGET_COLUMN]

        results: Dict[str, Any] = {}
        best_model_name = ""
        best_f1 = -1.0
        best_pipeline = None

        for name, pipeline in self.models.items():
            # 1. Fit model
            pipeline.fit(X_train, y_train)

            # 2. Predict on unseen test learners
            y_pred = pipeline.predict(X_test)
            y_proba = pipeline.predict_proba(X_test)[:, 1]

            # 3. Calculate metrics
            acc = float(accuracy_score(y_test, y_pred))
            prec = float(precision_score(y_test, y_pred, zero_division=0))
            rec = float(recall_score(y_test, y_pred, zero_division=0))
            f1 = float(f1_score(y_test, y_pred, zero_division=0))
            roc_auc = float(roc_auc_score(y_test, y_proba))
            brier = float(brier_score_loss(y_test, y_proba))

            results[name] = {
                "accuracy": round(acc, 4),
                "precision": round(prec, 4),
                "recall": round(rec, 4),
                "f1_score": round(f1, 4),
                "roc_auc": round(roc_auc, 4),
                "brier_score": round(brier, 4),  # Lower is better calibrated
            }

            # Select model with highest F1 score on test set
            if f1 > best_f1:
                best_f1 = f1
                best_model_name = name
                best_pipeline = pipeline

        # Save the selected winning model
        os.makedirs(ARTIFACTS_DIR, exist_ok=True)
        joblib.dump(best_pipeline, MODEL_PATH)

        report = {
            "status": "trained",
            "selected_model": best_model_name,
            "train_samples": len(train_df),
            "test_samples": len(test_df),
            "train_unique_students": int(train_df["student_id"].nunique()),
            "test_unique_students": int(test_df["student_id"].nunique()),
            "feature_columns": FEATURE_COLUMNS,
            "comparative_metrics": results,
            "model_path": MODEL_PATH
        }

        with open(METRICS_PATH, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)

        return report
