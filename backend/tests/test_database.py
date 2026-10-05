import sys
import os
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.database.base import Base
from app.models import (
    Student, Concept, Question, Attempt, LearnerProfile, ErrorDiagnosis,
    Representation, RepresentationOutcome, StudentEngagement, GameSession
)
from app.database.seed import seed_database

# Use in-memory SQLite for test database isolation
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)


def test_create_tables_and_seed_data(db_session):
    seed_database(db_session)
    
    # Verify concepts seeded
    concepts = db_session.query(Concept).all()
    assert len(concepts) == 3
    quad_concept = db_session.query(Concept).filter_by(code="MATH-G10-QUAD-01").first()
    assert quad_concept is not None
    assert quad_concept.topic_category == "Quadratic Equations"

    # Verify questions seeded
    questions = db_session.query(Question).filter_by(concept_id=quad_concept.id).all()
    assert len(questions) == 1
    assert "x^2 + 5x + 6 = 0" in questions[0].question_text

    # Verify representations seeded
    reps = db_session.query(Representation).filter_by(concept_id=quad_concept.id).all()
    assert len(reps) == 2

    # Verify demo student seeded
    student = db_session.query(Student).filter_by(email="student@example.lk").first()
    assert student is not None
    assert student.grade_level == 10

    # Verify learner profile seeded
    profile = db_session.query(LearnerProfile).filter_by(student_id=student.id).first()
    assert profile is not None
    assert profile.mastery_probability == 0.42

    # Verify engagement seeded
    engagement = db_session.query(StudentEngagement).filter_by(student_id=student.id).first()
    assert engagement is not None
    assert engagement.current_streak_days == 4


def test_attempt_and_error_diagnosis_creation(db_session):
    seed_database(db_session)
    
    student = db_session.query(Student).first()
    question = db_session.query(Question).first()
    
    # Create attempt
    attempt = Attempt(
        student_id=student.id,
        question_id=question.id,
        is_correct=False,
        student_solution="x^2 + 5x + 6 = 0\nx = 2",
        response_time_ms=10000,
        attempt_number=1
    )
    db_session.add(attempt)
    db_session.commit()
    
    # Create error diagnosis
    diag = ErrorDiagnosis(
        attempt_id=attempt.id,
        student_id=student.id,
        question_id=question.id,
        failed_step_index=2,
        error_category="Sign Error",
        explanation_text="Incorrect sign during factorization solving",
        corrected_step="x = -2 or x = -3"
    )
    db_session.add(diag)
    db_session.commit()
    
    saved_diag = db_session.query(ErrorDiagnosis).filter_by(attempt_id=attempt.id).first()
    assert saved_diag is not None
    assert saved_diag.error_category == "Sign Error"
