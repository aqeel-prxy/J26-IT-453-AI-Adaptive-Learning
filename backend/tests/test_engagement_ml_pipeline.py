import sys
import os
from uuid import uuid4
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.main import app
from app.services.engagement.data_pipeline import load_dataset, split_dataset
from app.services.engagement.engagement_model import EngagementPredictor

client = TestClient(app)


def test_data_pipeline_loading():
    """Verify that dataset loads cleanly with expected shape, columns, and class balance."""
    df = load_dataset()
    assert len(df) == 600
    assert "state" in df.columns
    assert set(df["state"].unique()) == {"Engaged", "Bored", "Frustrated"}
    assert df["state"].value_counts()["Engaged"] == 200
    assert df["state"].value_counts()["Bored"] == 200
    assert df["state"].value_counts()["Frustrated"] == 200

    train_df, test_df = split_dataset(df, test_size=0.25, random_seed=42)
    assert len(train_df) == 450
    assert len(test_df) == 150


def test_engagement_predictor_states():
    """Test predictor with sample telemetry across all cognitive and affective profiles."""
    predictor = EngagementPredictor.get_instance()

    # 1. Boredom profile (rapid unreflective guess)
    bored_res = predictor.predict(
        time_taken_sec=1.5,
        option_switches=0,
        is_rapid_guess=1,
        is_correct=0,
        idle_seconds=0.0
    )
    assert bored_res["predicted_state"] == "BORED"
    assert bored_res["confidence_score"] > 0.80
    assert "Bored" in bored_res["probabilities"]

    # 2. Engaged profile (optimal deliberation, correct)
    engaged_res = predictor.predict(
        time_taken_sec=16.0,
        option_switches=0,
        is_rapid_guess=0,
        is_correct=1,
        idle_seconds=2.0
    )
    assert engaged_res["predicted_state"] == "FOCUSED"
    assert engaged_res["confidence_score"] > 0.80

    # 3. Frustrated profile (high time, multiple switches, high hesitation)
    frustrated_res = predictor.predict(
        time_taken_sec=38.0,
        option_switches=3,
        is_rapid_guess=0,
        is_correct=0,
        idle_seconds=14.0
    )
    assert frustrated_res["predicted_state"] == "FRUSTRATED"

    # 4. At-risk profile (severe frustration + repeated errors)
    at_risk_res = predictor.predict(
        time_taken_sec=45.0,
        option_switches=3,
        is_rapid_guess=0,
        is_correct=0,
        idle_seconds=18.0,
        consecutive_errors=4
    )
    assert at_risk_res["predicted_state"] == "AT_RISK"
    assert at_risk_res["is_escalated_at_risk"] is True


def test_api_telemetry_evaluate_with_csv_features():
    """Verify POST /engagement/telemetry/evaluate endpoint works with direct CSV feature inputs."""
    student_id = str(uuid4())

    # Send Bored profile
    res_bored = client.post(
        "/api/v1/engagement/telemetry/evaluate",
        json={
            "student_id": student_id,
            "time_taken_sec": 1.2,
            "option_switches": 0,
            "is_rapid_guess": 1,
            "is_correct": 0,
            "idle_seconds": 0.0
        }
    )
    assert res_bored.status_code == 200
    data_bored = res_bored.json()
    assert data_bored["affective_state"] == "BORED"
    assert data_bored["confidence_score"] > 0.80
    assert any(a["action_type"] == "RESET_CHALLENGE" for a in data_bored["scaffolding_actions"])

    # Send Frustrated profile
    res_frustrated = client.post(
        "/api/v1/engagement/telemetry/evaluate",
        json={
            "student_id": student_id,
            "time_taken_sec": 42.0,
            "option_switches": 3,
            "is_rapid_guess": 0,
            "is_correct": 0,
            "idle_seconds": 15.0
        }
    )
    assert res_frustrated.status_code == 200
    data_frustrated = res_frustrated.json()
    assert data_frustrated["affective_state"] == "FRUSTRATED"
    assert any(a["action_type"] == "STREAK_SHIELD" for a in data_frustrated["scaffolding_actions"])


def test_api_ml_metrics_endpoint():
    """Verify GET /engagement/ml-metrics endpoint returns research transparency report."""
    response = client.get("/api/v1/engagement/ml-metrics")
    assert response.status_code == 200
    data = response.json()
    assert data["selected_model"] == "Random Forest"
    assert data["total_samples"] == 600
    assert "idle_seconds" in data["feature_importances"]
    assert "Random Forest" in data["comparative_metrics"]
    assert "Gradient Boosting" in data["comparative_metrics"]
