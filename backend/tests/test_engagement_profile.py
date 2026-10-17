import sys
import os
from uuid import uuid4
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.main import app

client = TestClient(app)


def test_get_student_profile():
    response = client.get("/api/v1/students/profile")
    assert response.status_code == 200
    data = response.json()
    assert "student_id" in data
    assert data["full_name"] == "Kavindu Dharmasena"
    assert data["avatar_id"] == "fox_math"
    assert data["motivational_archetype"] == "Achiever"


def test_update_student_profile():
    update_payload = {
        "full_name": "Kavindu D.",
        "avatar_id": "owl_scholar",
        "motivational_archetype": "Player",
        "grade_level": 11
    }
    response = client.post("/api/v1/students/profile", json=update_payload)
    assert response.status_code == 200
    data = response.json()
    assert data["full_name"] == "Kavindu D."
    assert data["avatar_id"] == "owl_scholar"
    assert data["motivational_archetype"] == "Player"
    assert data["grade_level"] == 11


def test_engagement_profile_feedback():
    student_id = str(uuid4())
    # Test Frustrated State
    response = client.get(f"/api/v1/engagement/profile-feedback/{student_id}?state=FRUSTRATED")
    assert response.status_code == 200
    data = response.json()
    assert data["affective_state"] == "FRUSTRATED"
    assert "Cognitive Strain" in data["state_label"]
    assert "telemetry" in data
    assert len(data["scaffolding_actions"]) >= 2
    assert any(action["action_type"] == "STREAK_SHIELD" for action in data["scaffolding_actions"])

    # Test Focused State
    response_focused = client.get(f"/api/v1/engagement/profile-feedback/{student_id}?state=FOCUSED")
    assert response_focused.status_code == 200
    data_focused = response_focused.json()
    assert data_focused["affective_state"] == "FOCUSED"

    # Test Bored State
    response_bored = client.get(f"/api/v1/engagement/profile-feedback/{student_id}?state=BORED")
    assert response_bored.status_code == 200
    data_bored = response_bored.json()
    assert data_bored["affective_state"] == "BORED"
    assert any(action["action_type"] == "RESET_CHALLENGE" for action in data_bored["scaffolding_actions"])


def test_engagement_telemetry_evaluate():
    student_id = str(uuid4())
    payload = {
        "student_id": student_id,
        "time_per_problem_sec": 180.0,
        "hesitation_pauses_sec": 45.0,
        "attempt_burst_count": 3,
        "consecutive_errors": 3,
        "idle_latency_sec": 40.0
    }
    response = client.post("/api/v1/engagement/telemetry/evaluate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["affective_state"] == "FRUSTRATED"
    assert data["telemetry"]["consecutive_errors"] == 3
