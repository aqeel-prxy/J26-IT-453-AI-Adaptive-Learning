import sys
import os
import uuid
from datetime import date, timedelta
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.main import app

from app.database.base import Base
from app.database.session import get_db
from app.services.learning_path.planner_service import LearningPathService
from app.services.learning_path.curriculum_graph import INDICES_LOGARITHMS_DAG
from app.services.learning_path.lesson_bank import LESSON_BANK, get_lesson_for_concept
from app.models.student import Student
from app.models.learning_path import LearningPathPlan, LearningPathDecision

# In-memory SQLite for testing
from sqlalchemy.pool import StaticPool
from app.database.seed import seed_database
from app.models import *

TEST_DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(
    TEST_DATABASE_URL,
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


app.dependency_overrides[get_db] = override_get_db
client_instance = TestClient(app)


@pytest.fixture(autouse=True)
def setup_test_db():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    seed_database(db)
    app.dependency_overrides[get_db] = override_get_db
    yield
    app.dependency_overrides.pop(get_db, None)
    db.close()
    Base.metadata.drop_all(bind=engine)



@pytest.fixture
def client():
    return client_instance



# ==============================================================================
# 1. CORE PLANNER SERVICE TESTS
# ==============================================================================

def test_planner_generates_valid_pathway_comprehensive():
    planner = LearningPathService()
    student_id = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
    
    plan = planner.generate_path(
        student_id=student_id,
        topic_category="Indices and Logarithms",
        goal_type="COMPREHENSIVE",
        available_daily_minutes=30
    )

    assert plan["goal_type"] == "COMPREHENSIVE"
    assert len(plan["pathway_nodes"]) == 7
    # Verify topological order is preserved
    codes = [n["code"] for n in plan["pathway_nodes"]]
    assert codes[0] == "MATH-G11-IND-01"
    assert "MATH-G11-LOG-04" in codes

    # Prerequisite constraint check: Node 1 has no prerequisites and should be unlocked
    node1 = plan["pathway_nodes"][0]
    assert node1["status"] in ["RECOMMENDED_NEXT", "AVAILABLE", "MASTERED"]


def test_planner_goal_aware_term_test_mode():
    planner = LearningPathService()
    student_id = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
    target_exam = date.today() + timedelta(days=14)

    plan = planner.generate_path(
        student_id=student_id,
        topic_category="Indices and Logarithms",
        goal_type="TERM_TEST",
        target_date=target_exam,
        available_daily_minutes=20,
        known_mastery={"10000000-0000-0000-0000-000000000001": 0.90}
    )

    assert plan["goal_type"] == "TERM_TEST"
    assert plan["available_daily_minutes"] == 20
    assert plan["recommended_activity"]["activity_type"] in ["PRACTICE", "WORKED_EXAMPLE", "PROCEED_DIRECT"]
    assert "Term-Test" in plan["recommended_activity"]["rationale"]


def test_planner_prerequisite_integrity_enforced():
    """NFR-C1-02: Ensure dependent concepts cannot be recommended before prerequisites."""
    planner = LearningPathService()
    student_id = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"

    # With zero mastery, terminal logarithm concepts MUST be locked
    plan = planner.generate_path(
        student_id=student_id,
        known_mastery={}
    )

    nodes_by_code = {n["code"]: n for n in plan["pathway_nodes"]}
    log_terminal = nodes_by_code["MATH-G11-LOG-03"]
    assert log_terminal["status"] in ["LOCKED", "REVISION_REQUIRED"]


def test_dynamic_pathway_revision_on_quiz_success():
    planner = LearningPathService()
    student_id = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
    concept_id = "10000000-0000-0000-0000-000000000001"

    revision = planner.revise_path(
        student_id=student_id,
        concept_id=concept_id,
        activity_type="QUIZ",
        is_successful=True,
        score=0.95,
        duration_seconds=120
    )

    assert revision["status"] == "revised"
    assert revision["previous_concept_id"] == concept_id
    # Verified that completed node became MASTERED
    completed_node = next(n for n in revision["pathway_nodes"] if n["concept_id"] == concept_id)
    assert completed_node["status"] == "MASTERED"
    assert "dynamically advanced" in revision["next_recommended_activity"]["rationale"].lower()


def test_diagnostic_evaluation_computes_readiness():
    planner = LearningPathService()
    student_id = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"

    responses = [
        {
            "question_id": "q1000000-0000-0000-0000-000000000001",
            "concept_id": "10000000-0000-0000-0000-000000000001",
            "is_correct": True,
            "response_time_ms": 10000
        },
        {
            "question_id": "q1000000-0000-0000-0000-000000000002",
            "concept_id": "10000000-0000-0000-0000-000000000001",
            "is_correct": True,
            "response_time_ms": 11000
        }
    ]

    diag_result = planner.evaluate_diagnostic(
        student_id=student_id,
        topic_category="Indices and Logarithms",
        goal_type="COMPREHENSIVE",
        responses=responses
    )

    assert "initial_readiness_vector" in diag_result
    c1_readiness = diag_result["initial_readiness_vector"]["10000000-0000-0000-0000-000000000001"]
    assert c1_readiness > 0.50


def test_baseline_comparison():
    planner = LearningPathService()
    comp = planner.compare_baselines("test_stu", goal_type="TERM_TEST")
    assert "adaptive_ml" in comp["models_evaluated"]
    assert "baseline_1_fixed_sequence" in comp["models_evaluated"]
    assert "baseline_2_rule_based" in comp["models_evaluated"]
    assert comp["models_evaluated"]["adaptive_ml"]["prerequisite_integrity_pct"] == 100.0


# ==============================================================================
# 2. FASTAPI API ROUTER INTEGRATION TESTS
# ==============================================================================

def test_api_get_curriculum_dag(client):
    response = client.get("/api/v1/learning-path/curriculum/indices-and-logarithms")
    assert response.status_code == 200
    data = response.json()
    assert data["topic_category"] == "Indices and Logarithms"
    assert len(data["concepts"]) == 7


def test_api_get_diagnostic_questions(client):
    response = client.get("/api/v1/learning-path/diagnostic/questions")
    assert response.status_code == 200
    data = response.json()
    assert data["total_questions"] >= 8


def test_api_create_and_fetch_plan(client):
    student_id = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
    create_payload = {
        "student_id": student_id,
        "topic_category": "Indices and Logarithms",
        "goal_type": "TERM_TEST",
        "target_date": "2026-11-20",
        "available_daily_minutes": 35
    }

    # 1. Create plan
    resp = client.post("/api/v1/learning-path/plan", json=create_payload)
    assert resp.status_code == 200
    plan_data = resp.json()
    assert plan_data["goal_type"] == "TERM_TEST"
    assert plan_data["available_daily_minutes"] == 35

    # 2. Retrieve plan
    get_resp = client.get(f"/api/v1/learning-path/plan/{student_id}")
    assert get_resp.status_code == 200
    fetched = get_resp.json()
    assert fetched["plan_id"] == plan_data["plan_id"]


def test_api_submit_diagnostic(client):
    payload = {
        "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
        "topic_category": "Indices and Logarithms",
        "goal_type": "COMPREHENSIVE",
        "responses": [
            {
                "question_id": "q1000000-0000-0000-0000-000000000001",
                "concept_id": "10000000-0000-0000-0000-000000000001",
                "is_correct": True,
                "response_time_ms": 12000
            }
        ]
    }
    resp = client.post("/api/v1/learning-path/diagnostic/submit", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    assert "recommended_next_step" in data
    assert "initial_readiness_vector" in data


def test_api_complete_activity_and_revise(client):
    payload = {
        "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
        "concept_id": "10000000-0000-0000-0000-000000000001",
        "activity_type": "QUIZ",
        "is_successful": True,
        "score": 1.0,
        "duration_seconds": 90
    }
    resp = client.post("/api/v1/learning-path/activity/complete", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    assert data["status"] == "revised"
    assert "next_recommended_activity" in data


def test_api_get_lesson_unit(client):
    concept_id = "10000000-0000-0000-0000-000000000001"
    resp = client.get(f"/api/v1/learning-path/lesson/{concept_id}")
    assert resp.status_code == 200
    lesson = resp.json()
    assert lesson["code"] == "MATH-G11-IND-01"
    assert "theory" in lesson
    assert "formulas" in lesson
    assert "worked_example" in lesson
    assert "guided_practice" in lesson
    assert "quiz" in lesson


def test_api_get_baselines_and_telemetry(client):
    base_resp = client.get("/api/v1/learning-path/baselines/compare")
    assert base_resp.status_code == 200
    assert "models_evaluated" in base_resp.json()

    telem_resp = client.get("/api/v1/learning-path/telemetry")
    assert telem_resp.status_code == 200
    assert "selected_model" in telem_resp.json()


def test_grade_10_curriculum_and_plan_api(client):
    # Test Grade 10 curriculum DAG endpoint
    dag_resp = client.get("/api/v1/learning-path/curriculum/quadratic-equations?grade_level=10")
    assert dag_resp.status_code == 200
    dag_data = dag_resp.json()
    assert dag_data["grade_level"] == 10
    assert dag_data["topic_category"] == "Quadratic Equations"
    assert len(dag_data["concepts"]) == 4

    # Test Grade 10 lesson retrieval
    lesson_resp = client.get("/api/v1/learning-path/lesson/c1111111-1111-1111-1111-111111111111")
    assert lesson_resp.status_code == 200
    lesson = lesson_resp.json()
    assert lesson["grade_level"] == 10
    assert lesson["code"] == "MATH-G10-QUAD-01"
    assert "Zero-Product" in lesson["theory"] or "Quadratic" in lesson["theory"]

    # Test Grade 10 Plan Creation
    plan_payload = {
        "student_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
        "topic_category": "Quadratic Equations",
        "grade_level": 10,
        "goal_type": "TERM_TEST",
        "available_daily_minutes": 30
    }
    plan_resp = client.post("/api/v1/learning-path/plan", json=plan_payload)
    assert plan_resp.status_code == 200
    plan_data = plan_resp.json()
    assert plan_data["grade_level"] == 10
    assert plan_data["topic_category"] == "Quadratic Equations"
    assert len(plan_data["pathway_nodes"]) == 4
    assert plan_data["pathway_nodes"][0]["code"] == "MATH-G10-QUAD-01"

