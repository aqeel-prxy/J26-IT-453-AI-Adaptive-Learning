import sys
import os
from uuid import uuid4
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.main import app

client = TestClient(app)


def test_auth_login():
    response = client.post(
        "/api/v1/auth/login",
        json={"email": "student@example.lk", "password": "password123"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_mathematics_topics():
    response = client.get("/api/v1/mathematics/topics")
    assert response.status_code == 200
    topics = response.json()
    assert isinstance(topics, list)
    assert len(topics) >= 1
    assert topics[0]["topic_category"] == "Quadratic Equations"


def test_attempt_submission_end_to_end_stubs():
    student_id = str(uuid4())
    question_id = str(uuid4())
    
    payload = {
        "student_id": student_id,
        "question_id": question_id,
        "student_solution": "x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3",
        "response_time_ms": 12000
    }
    
    response = client.post("/api/v1/mathematics/attempts/submit", json=payload)
    assert response.status_code == 200
    data = response.json()
    
    # Verify response schema integration across stubs
    assert "attempt_id" in data
    assert data["is_correct"] is False
    assert data["error_diagnosis"]["error_category"] == "Sign Error"
    assert data["learner_profile"]["mastery_probability"] is not None
    assert data["recommended_representation"]["format_type"] == "STEP_BY_STEP"
    assert data["engagement"]["current_streak_days"] == 4
