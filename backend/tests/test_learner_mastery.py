import os
import sys
import time
from uuid import uuid4, UUID
from datetime import datetime, timedelta, timezone
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.main import app
from app.database.base import Base
from app.database.session import get_db
from app.database.seed import seed_database
from app.models import Student, Concept, LearnerProfile
from app.services.learner.mastery_model import LearnerMasteryModel
from app.services.learner.preprocessor import TelemetryPreprocessor

# In-memory SQLite for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"
test_engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


@pytest.fixture(autouse=True)
def setup_database():
    Base.metadata.create_all(bind=test_engine)
    app.dependency_overrides[get_db] = override_get_db
    db = TestingSessionLocal()
    seed_database(db)
    db.close()
    yield
    Base.metadata.drop_all(bind=test_engine)
    app.dependency_overrides.pop(get_db, None)


def test_telemetry_preprocessor_latency_and_outliers():
    """Verifies latency clipping and z-score computation."""
    # Fast outlier
    clipped, z, is_outlier = TelemetryPreprocessor.clean_and_normalize_latency(500)
    assert clipped == TelemetryPreprocessor.MIN_VALID_LATENCY_MS
    assert is_outlier is True

    # Slow outlier
    clipped_slow, z_slow, is_slow_outlier = TelemetryPreprocessor.clean_and_normalize_latency(450000)
    assert clipped_slow == TelemetryPreprocessor.MAX_VALID_LATENCY_MS
    assert is_slow_outlier is True

    # Normal observation
    clipped_norm, z_norm, is_norm_outlier = TelemetryPreprocessor.clean_and_normalize_latency(32000)
    assert clipped_norm == 32000.0
    assert abs(z_norm) < 0.1
    assert is_norm_outlier is False


def test_multimodal_evidence_slip_and_guess():
    """Verifies that behavioral cues isolate slips and guesses."""
    # Slip: Fast incorrect with no hints
    slip_ev = TelemetryPreprocessor.compute_behavioral_evidence(
        is_correct=False,
        response_time_ms=8000,
        attempt_number=1,
        hints_used=0
    )
    assert slip_ev["is_potential_slip"] is True
    assert slip_ev["is_potential_guess"] is False

    # Guess: Extremely fast correct with 1 attempt
    guess_ev = TelemetryPreprocessor.compute_behavioral_evidence(
        is_correct=True,
        response_time_ms=5000,
        attempt_number=1,
        hints_used=0
    )
    assert guess_ev["is_potential_guess"] is True
    assert guess_ev["is_potential_slip"] is False


def test_ebbinghaus_temporal_decay():
    """Tests exponential decay over multi-day non-practice intervals."""
    initial_mastery = 0.85
    stability = 1.5
    t0 = datetime.now(timezone.utc)

    # 0 days elapsed -> full retention
    decay_0d = LearnerMasteryModel.calculate_temporal_decay(initial_mastery, t0, stability, t0)
    assert decay_0d == initial_mastery

    # 3 days elapsed -> partial decay
    t_3d = t0 + timedelta(days=3)
    decay_3d = LearnerMasteryModel.calculate_temporal_decay(initial_mastery, t0, stability, t_3d)
    assert 0.60 <= decay_3d < initial_mastery

    # 14 days elapsed -> significant decay
    t_14d = t0 + timedelta(days=14)
    decay_14d = LearnerMasteryModel.calculate_temporal_decay(initial_mastery, t0, stability, t_14d)
    assert decay_14d < decay_3d
    assert decay_14d >= 0.05


def test_knowledge_tracing_consecutive_success():
    """Verifies that consecutive correct answers with good speed increase mastery."""
    prior = 0.20
    stability = 1.0

    step1 = LearnerMasteryModel.update_mastery_state(
        prior_mastery=prior,
        is_correct=True,
        response_time_ms=18000,
        prior_stability=stability
    )
    assert step1["new_mastery"] > prior
    assert step1["trend"] in ["improving", "mastered"]

    step2 = LearnerMasteryModel.update_mastery_state(
        prior_mastery=step1["new_mastery"],
        is_correct=True,
        response_time_ms=15000,
        prior_stability=step1["new_stability"]
    )
    assert step2["new_mastery"] > step1["new_mastery"]
    assert step2["new_stability"] > stability


def test_diagnostic_calibration(db_session=None):
    """Verifies that diagnostic assessment responses calibrate baseline profile."""
    db = TestingSessionLocal()
    try:
        student = db.query(Student).first()
        concept = db.query(Concept).first()

        diag_responses = [
            {"question_id": uuid4(), "concept_id": concept.id, "is_correct": True, "response_time_ms": 14000},
            {"question_id": uuid4(), "concept_id": concept.id, "is_correct": True, "response_time_ms": 16000}
        ]

        result = LearnerMasteryModel.calibrate_diagnostic_profile(
            db=db,
            student_id=student.id,
            responses=diag_responses
        )

        assert result["student_id"] == student.id
        assert len(result["initial_mastery_vector"]) >= 1
        item = result["initial_mastery_vector"][0]
        assert item["mastery_probability"] >= 0.80
        assert item["is_weak_concept"] is False
    finally:
        db.close()


def test_weak_concept_and_prerequisite_detection():
    """Verifies prerequisite blocker identification for weak concepts."""
    db = TestingSessionLocal()
    try:
        student = db.query(Student).first()
        # Find concept with prerequisites (e.g. Indices 2 or Log 1)
        dependent_concept = db.query(Concept).filter(Concept.prerequisite_concept_ids != []).first()
        if not dependent_concept:
            pytest.skip("No dependent concept found in seeds.")

        prereq_id = UUID(dependent_concept.prerequisite_concept_ids[0])

        # Create deficient prerequisite profile
        p_prereq = LearnerMasteryModel.get_or_create_profile(db, student.id, prereq_id)
        p_prereq.mastery_probability = 0.25
        p_prereq.is_weak_concept = True

        # Create deficient dependent concept profile
        p_dep = LearnerMasteryModel.get_or_create_profile(db, student.id, dependent_concept.id)
        p_dep.mastery_probability = 0.30
        p_dep.is_weak_concept = True
        db.commit()

        weak_report = LearnerMasteryModel.detect_weak_concepts(db, student.id)
        assert len(weak_report) >= 1

        # Check if prerequisite blocker was identified
        dep_entry = next((w for w in weak_report if w["concept_id"] == dependent_concept.id), None)
        assert dep_entry is not None
        assert len(dep_entry["prerequisite_blockers"]) > 0
    finally:
        db.close()


def test_learner_api_endpoints():
    """Verifies all FastAPI routes for Component 02."""
    db = TestingSessionLocal()
    student = db.query(Student).first()
    concept = db.query(Concept).first()
    db.close()

    # 1. GET /api/v1/learner/profile/{student_id}
    resp1 = client.get(f"/api/v1/learner/profile/{student.id}")
    assert resp1.status_code == 200
    data1 = resp1.json()
    assert data1["student_id"] == str(student.id)
    assert "mastery_vector" in data1

    # 2. POST /api/v1/learner/telemetry/submit
    telemetry_payload = {
        "student_id": str(student.id),
        "question_id": str(uuid4()),
        "concept_id": str(concept.id),
        "is_correct": True,
        "response_time_ms": 16000,
        "attempt_number": 1,
        "hints_used": 0,
        "option_switches": 0
    }
    resp2 = client.post("/api/v1/learner/telemetry/submit", json=telemetry_payload)
    assert resp2.status_code == 200
    data2 = resp2.json()
    assert data2["mastery_probability"] > 0.0
    assert "trend" in data2

    # 3. POST /api/v1/learner/diagnostic/calibrate
    diag_payload = {
        "student_id": str(student.id),
        "topic_category": "Indices and Logarithms",
        "responses": [
            {
                "question_id": str(uuid4()),
                "concept_id": str(concept.id),
                "is_correct": False,
                "response_time_ms": 45000,
                "attempt_number": 2
            }
        ]
    }
    resp3 = client.post("/api/v1/learner/diagnostic/calibrate", json=diag_payload)
    assert resp3.status_code == 200
    data3 = resp3.json()
    assert len(data3["weak_concepts"]) >= 1

    # 4. GET /api/v1/learner/profile/{student_id}/weak-concepts
    resp4 = client.get(f"/api/v1/learner/profile/{student.id}/weak-concepts")
    assert resp4.status_code == 200
    data4 = resp4.json()
    assert "weak_concepts" in data4

    # 5. GET /api/v1/learner/profile/{student_id}/retention-forecast
    resp5 = client.get(f"/api/v1/learner/profile/{student.id}/retention-forecast")
    assert resp5.status_code == 200
    data5 = resp5.json()
    assert "forecast" in data5
    if data5["forecast"]:
        first_f = data5["forecast"][0]
        assert first_f["projected_mastery_1d"] >= first_f["projected_mastery_7d"]
        assert first_f["projected_mastery_7d"] >= first_f["projected_mastery_30d"]


def test_api_latency_under_150ms():
    """Non-Functional Requirement NFR-01: Verify inference & API latency < 150ms."""
    db = TestingSessionLocal()
    student = db.query(Student).first()
    concept = db.query(Concept).first()
    db.close()

    payload = {
        "student_id": str(student.id),
        "question_id": str(uuid4()),
        "concept_id": str(concept.id),
        "is_correct": True,
        "response_time_ms": 14000,
        "attempt_number": 1,
        "hints_used": 0,
        "option_switches": 0
    }

    latencies = []
    for _ in range(25):
        t0 = time.perf_counter()
        resp = client.post("/api/v1/learner/telemetry/submit", json=payload)
        t_elapsed_ms = (time.perf_counter() - t0) * 1000.0
        assert resp.status_code == 200
        latencies.append(t_elapsed_ms)

    avg_latency = sum(latencies) / len(latencies)
    assert avg_latency < 150.0, f"Average latency {avg_latency:.2f}ms exceeded 150ms threshold."
