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


def test_auth_register_and_relogin():
    # 1. Register new student
    reg_resp = client.post(
        "/api/v1/auth/register",
        json={
            "full_name": "Test Student LK",
            "email": "test.student@school.lk",
            "password": "mySecurePassword123",
            "grade_level": 10,
            "school": "Jaffna Central College",
            "district": "Northern Province",
            "preferred_goal": "COMPREHENSIVE",
            "avatar_id": "owl_scholar"
        }
    )
    assert reg_resp.status_code == 200
    reg_data = reg_resp.json()
    assert reg_data["full_name"] == "Test Student LK"
    assert reg_data["email"] == "test.student@school.lk"
    assert reg_data["grade_level"] == 10
    assert reg_data["avatar_id"] == "owl_scholar"

    # 2. Login back with the exact registered credentials — verify persistence!
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "test.student@school.lk", "password": "mySecurePassword123"}
    )
    assert login_resp.status_code == 200
    login_data = login_resp.json()
    assert login_data["full_name"] == "Test Student LK"
    assert login_data["email"] == "test.student@school.lk"
    assert login_data["grade_level"] == 10
    assert login_data["school"] == "Jaffna Central College"
    assert login_data["avatar_id"] == "owl_scholar"


def test_auth_google():
    resp = client.post(
        "/api/v1/auth/google",
        json={
            "google_id": "google_uid_123456789",
            "email": "google.student@gmail.com",
            "full_name": "Google Scholar Student",
            "grade_level": 11,
            "preferred_goal": "TERM_TEST"
        }
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["auth_provider"] == "google"
    assert data["email"] == "google.student@gmail.com"
    assert data["full_name"] == "Google Scholar Student"
    assert "access_token" in data


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
