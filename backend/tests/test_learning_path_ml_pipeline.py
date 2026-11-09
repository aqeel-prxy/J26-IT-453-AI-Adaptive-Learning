"""
Unit Tests for Component 1 Machine Learning Pipeline & Inference
AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning for Grade 11 Students
"""
import sys
import os
import pytest
import json
import joblib
import pandas as pd

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.services.learning_path.data_pipeline import (
    generate_development_dataset, load_dataset, student_train_test_split,
    FEATURE_COLUMNS, TARGET_COLUMN
)
from app.services.learning_path.readiness_model import (
    ReadinessModelTrainer, MODEL_PATH, METRICS_PATH
)
from app.services.learning_path.readiness_predictor import ReadinessPredictor


def test_dev_dataset_generation_and_safeguards():
    """Verify that development dataset is generated with required research safeguards and schema."""
    test_path = "data/development/test_dataset.csv"
    df = generate_development_dataset(output_path=test_path, num_students=20, random_seed=42)

    assert os.path.exists(test_path)
    # Check that safeguard header is present in the raw file
    with open(test_path, "r", encoding="utf-8") as f:
        first_line = f.readline()
        assert "DEVELOPMENT-ONLY DATASET" in first_line or first_line.startswith("#")

    # Verify loaded dataframe schema
    loaded_df = load_dataset(test_path)
    for col in FEATURE_COLUMNS + [TARGET_COLUMN, "student_id", "concept_id"]:
        assert col in loaded_df.columns

    # Clean up test artifact
    if os.path.exists(test_path):
        os.remove(test_path)


def test_student_train_test_split_zero_leakage():
    """Verify that train and test splits have 0 student overlap (strictly zero learner data leakage)."""
    df = generate_development_dataset(num_students=40, random_seed=123)
    train_df, test_df = student_train_test_split(df, test_size=0.25, random_seed=123)

    train_students = set(train_df["student_id"].unique())
    test_students = set(test_df["student_id"].unique())

    assert len(train_students.intersection(test_students)) == 0
    assert len(train_students) + len(test_students) == 40


def test_model_training_and_comparative_evaluation():
    """Verify that candidate models (Logistic Regression, Random Forest, GBDT) are evaluated and artifact persisted."""
    df = generate_development_dataset(num_students=50, random_seed=99)
    train_df, test_df = student_train_test_split(df, test_size=0.25, random_seed=99)

    trainer = ReadinessModelTrainer(random_seed=99)
    report = trainer.train_and_evaluate(train_df, test_df)

    assert os.path.exists(MODEL_PATH)
    assert os.path.exists(METRICS_PATH)
    assert report["selected_model"] in report["comparative_metrics"]

    # Verify all 3 models evaluated
    expected_models = {"LogisticRegression_Baseline", "RandomForest", "GradientBoosting"}
    assert set(report["comparative_metrics"].keys()) == expected_models

    for model_name, metrics in report["comparative_metrics"].items():
        assert 0.0 <= metrics["accuracy"] <= 1.0
        assert 0.0 <= metrics["f1_score"] <= 1.0
        assert 0.0 <= metrics["brier_score"] <= 1.0


def test_readiness_predictor_online_inference():
    """Verify that ReadinessPredictor executes inference correctly with probability and confidence."""
    predictor = ReadinessPredictor(model_path=MODEL_PATH)

    result = predictor.predict_readiness(
        student_id="test-student-001",
        concept_id="10000000-0000-0000-0000-000000000004",
        concept_order_index=4,
        prerequisite_avg_accuracy=0.85,
        past_overall_accuracy=0.80,
        recent_attempt_count=2,
        avg_response_time_ms=15000.0
    )

    assert result["student_id"] == "test-student-001"
    assert 0.0 <= result["readiness_probability"] <= 1.0
    assert isinstance(result["is_ready"], bool)
    assert 0.0 <= result["confidence"] <= 1.0
    assert "features_used" in result


def test_readiness_predictor_pedagogical_monotonicity():
    """
    Verify pedagogical consistency:
    A student with strong prerequisite performance (90%) must receive a higher readiness
    probability than a student with poor prerequisite performance (20%) on the same concept.
    """
    predictor = ReadinessPredictor(model_path=MODEL_PATH)

    high_prereq_result = predictor.predict_readiness(
        student_id="student-high",
        concept_id="10000000-0000-0000-0000-000000000005",
        concept_order_index=5,
        prerequisite_avg_accuracy=0.90,
        past_overall_accuracy=0.85
    )

    low_prereq_result = predictor.predict_readiness(
        student_id="student-low",
        concept_id="10000000-0000-0000-0000-000000000005",
        concept_order_index=5,
        prerequisite_avg_accuracy=0.20,
        past_overall_accuracy=0.30
    )

    assert high_prereq_result["readiness_probability"] > low_prereq_result["readiness_probability"], (
        f"High prereq readiness ({high_prereq_result['readiness_probability']}) must exceed "
        f"low prereq readiness ({low_prereq_result['readiness_probability']})"
    )


def test_predictor_fallback_when_model_file_missing():
    """Verify that predictor falls back to transparent rule-based baseline when no model file exists."""
    fallback_predictor = ReadinessPredictor(model_path="nonexistent_model_path_123.pkl")
    assert fallback_predictor.model is None

    result = fallback_predictor.predict_readiness(
        student_id="student-fallback",
        concept_id="10000000-0000-0000-0000-000000000002",
        concept_order_index=2,
        prerequisite_avg_accuracy=0.75,
        past_overall_accuracy=0.70
    )

    assert 0.0 <= result["readiness_probability"] <= 1.0
    assert "Fallback" in result["model_version"]
