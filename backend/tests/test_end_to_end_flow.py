import sys
import os
import pytest
from uuid import uuid4
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.main import app
from app.database.base import Base
from app.database.session import get_db
from app.database.seed import seed_database
from app.models import Attempt, ErrorDiagnosis, RepresentationOutcome

from sqlalchemy.pool import StaticPool

SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_test_database():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    seed_database(db)
    db.close()
    app.dependency_overrides[get_db] = override_get_db
    yield
    app.dependency_overrides.pop(get_db, None)
    Base.metadata.drop_all(bind=engine)



def test_complete_end_to_end_adaptive_learning_flow():
    """
    Tests the complete Phase 5 End-to-End Vertical Slice:
    Student Login -> Dashboard -> Topic -> Concept -> Submit Attempt -> 
    Backend Attempt Storage -> Component Stubs Orchestration -> Composite Response -> Outcome Telemetry
    """
    # 1. Student Login
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "student@example.lk", "password": "password123"}
    )
    assert login_resp.status_code == 200
    login_data = login_resp.json()
    student_id = login_data["student_id"]
    assert "access_token" in login_data

    # 2. Student Dashboard
    dash_resp = client.get(f"/api/v1/engagement/dashboard/{student_id}")
    assert dash_resp.status_code == 200
    dash_data = dash_resp.json()
    assert dash_data["current_streak_days"] == 4
    assert dash_data["virtual_pet"]["pet_name"] == "MathPaws"

    # 3. Topic Category List
    topics_resp = client.get("/api/v1/mathematics/topics")
    assert topics_resp.status_code == 200
    topics_data = topics_resp.json()
    assert len(topics_data) >= 3
    assert topics_data[0]["topic_category"] == "Quadratic Equations"

    # 4. Concept Details
    concept_id = "c1111111-1111-1111-1111-111111111111"
    concept_resp = client.get(f"/api/v1/mathematics/concepts/{concept_id}")
    assert concept_resp.status_code == 200
    concept_data = concept_resp.json()
    assert concept_data["code"] == "MATH-G10-QUAD-01"

    # 5. Submit Attempt Solution (Triggers Component 1, 2, 3, 4 Stubs & DB Persistence)
    question_id = "22222222-2222-2222-2222-222222222222"
    submit_payload = {
        "student_id": student_id,
        "question_id": question_id,
        "student_solution": "x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3",
        "response_time_ms": 14500
    }
    submit_resp = client.post("/api/v1/mathematics/attempts/submit", json=submit_payload)
    assert submit_resp.status_code == 200
    submit_data = submit_resp.json()

    # Verify Component 4 Error Diagnosis Stub
    assert submit_data["is_correct"] is False
    assert submit_data["error_diagnosis"]["failed_step_index"] == 3
    assert submit_data["error_diagnosis"]["error_category"] == "Sign Error"

    # Verify Component 2 Learner Profile Stub
    assert submit_data["learner_profile"]["mastery_probability"] is not None

    # Verify Component 1 Representation Selection Stub
    rep_id = submit_data["recommended_representation"]["representation_id"]
    assert submit_data["recommended_representation"]["format_type"] == "STEP_BY_STEP"

    # Verify Component 3 Engagement Stub
    assert submit_data["engagement"]["current_streak_days"] == 4

    # 6. Record Representation Outcome Telemetry
    outcome_payload = {
        "student_id": student_id,
        "representation_id": rep_id,
        "duration_seconds": 25,
        "is_successful": True
    }
    outcome_resp = client.post("/api/v1/representation/outcome", json=outcome_payload)
    assert outcome_resp.status_code == 200
    assert outcome_resp.json()["status"] == "recorded"

    # 7. Verify Database Persistence in DB Session
    from uuid import UUID as _UUID
    db = TestingSessionLocal()
    student_uuid = _UUID(student_id)
    attempt_uuid = _UUID(submit_data["attempt_id"])

    attempts_in_db = db.query(Attempt).filter_by(student_id=student_uuid).all()
    assert len(attempts_in_db) == 1
    assert attempts_in_db[0].is_correct is False

    diag_in_db = db.query(ErrorDiagnosis).filter_by(attempt_id=attempt_uuid).first()
    assert diag_in_db is not None
    assert diag_in_db.error_category == "Sign Error"

    outcomes_in_db = db.query(RepresentationOutcome).filter_by(student_id=student_uuid).all()
    assert len(outcomes_in_db) == 1
    assert outcomes_in_db[0].duration_seconds == 25
    db.close()
