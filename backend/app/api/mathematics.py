from typing import List, Optional
from uuid import UUID, uuid4
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.session import get_db
from app.models import Attempt, ErrorDiagnosis, LearnerProfile, StudentEngagement, Question
from app.schemas.mathematics import (
    ConceptResponse, TopicCategoryResponse, AttemptSubmitRequest, AdaptiveAttemptResponse
)
from app.services.error_diagnosis.math_solver import MathSolver
from app.services.error_diagnosis.question_generator import SimilarQuestionService
from app.services.learner.learner_stub import LearnerProfilingStub
from app.services.representation.representation_stub import RepresentationStub
from app.services.engagement.engagement_stub import EngagementStub

router = APIRouter(prefix="/mathematics", tags=["Mathematics"])


@router.get("/topics", response_model=List[TopicCategoryResponse])
def list_topics():
    """Get Grade 10-11 Math Topic Categories"""
    return [
        TopicCategoryResponse(
            topic_category="Quadratic Equations",
            grade_level=10,
            concept_count=4
        ),
        TopicCategoryResponse(
            topic_category="Perimeter and Area of Plane Figures",
            grade_level=10,
            concept_count=3
        ),
        TopicCategoryResponse(
            topic_category="Indices and Logarithms",
            grade_level=11,
            concept_count=5
        )
    ]


@router.get("/concepts/{concept_id}", response_model=ConceptResponse)
def get_concept(concept_id: UUID):
    """Get Concept details by ID"""
    return ConceptResponse(
        concept_id=concept_id,
        topic_category="Quadratic Equations",
        code="MATH-G10-QUAD-01",
        title="Solving Quadratic Equations by Factorization",
        prerequisites=[]
    )


@router.post("/attempts/submit", response_model=AdaptiveAttemptResponse)
def submit_attempt(request: AttemptSubmitRequest, db: Session = Depends(get_db)):
    """
    Submits a student answer attempt.
    Coordinates between component real implementations / stubs and persists attempt state:
    - Component 4 Error Diagnosis (Real MathSolver symbolic engine)
    - Component 2 Learner Profiling
    - Component 1 Representation Selection
    - Component 3 Engagement & Feedback
    """
    attempt_id = uuid4()
    
    # 1. Error Diagnosis (Component 4) - Real Symbolic MathSolver & Step Verification
    question_text = None
    try:
        db_question = db.query(Question).filter(Question.id == request.question_id).first()
        if db_question:
            question_text = db_question.question_text
    except Exception:
        db_question = None

    if not question_text:
        # Check in-memory question bank by question_id
        for topic_questions in SimilarQuestionService.QUESTION_BANK.values():
            for q_item in topic_questions:
                if q_item.get("question_id") == str(request.question_id):
                    question_text = q_item.get("question")
                    break
            if question_text:
                break

    # If question text still not resolved, inspect if first line of student solution is an equation
    if not question_text and request.student_solution:
        lines = [line.strip() for line in request.student_solution.split("\n") if line.strip()]
        if lines and "=" in lines[0]:
            question_text = lines[0]

    # Clean question text (strip 'Solve for x: ', etc.)
    if question_text:
        question_text = MathSolver.clean_math_text(question_text)
    else:
        question_text = "x^2 + 5x + 6 = 0"

    diag = MathSolver.check_student_working(question_text, request.student_solution)
    # Ensure backward compatibility field for legacy callers
    diag["corrected_solution_step"] = diag.get("corrected_step")
    is_correct = diag.get("is_correct", False)
    
    # 2. Learner Profiling Stub (Component 2)
    profile = LearnerProfilingStub.update_learner_state(
        request.student_id, request.question_id, is_correct, request.response_time_ms
    )
    
    # 3. Representation Selection Stub (Component 1)
    rep = RepresentationStub.select_representation(request.student_id, UUID("c1111111-1111-1111-1111-111111111111"))
    
    # 4. Engagement & Feedback Stub (Component 3)
    eng = EngagementStub.process_activity_outcome(request.student_id, is_correct)
    
    # Attempt Persistence in Database
    try:
        new_attempt = Attempt(
            id=attempt_id,
            student_id=request.student_id,
            question_id=request.question_id,
            is_correct=is_correct,
            student_solution=request.student_solution,
            response_time_ms=request.response_time_ms,
            attempt_number=1
        )
        db.add(new_attempt)
        
        # Persist error diagnosis if present
        if not is_correct:
            err_diag = ErrorDiagnosis(
                attempt_id=attempt_id,
                student_id=request.student_id,
                question_id=request.question_id,
                failed_step_index=diag.get("failed_step_index"),
                error_category=diag.get("error_category", "Unclassified"),
                explanation_text=diag.get("explanation_text", ""),
                corrected_step=diag.get("corrected_solution_step") or diag.get("corrected_step")
            )
            db.add(err_diag)
            
        db.commit()
    except Exception:
        db.rollback()
        # Fallback cleanly if database environment is unavailable
    
    return AdaptiveAttemptResponse(
        attempt_id=attempt_id,
        is_correct=is_correct,
        error_diagnosis=diag,
        learner_profile=profile,
        recommended_representation=rep,
        engagement=eng
    )
