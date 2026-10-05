import uuid
import bcrypt
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from app.database.session import SessionLocal, engine
from app.database.base import Base
from app.models import (
    Student, Concept, Question, Representation, LearnerProfile, StudentEngagement
)


def seed_database(db: Session):
    """Populates Grade 10-11 Sri Lankan National Curriculum Math seed data."""
    # Check if seed data already exists
    if db.query(Concept).first() is not None:
        return

    # 1. Create Grade 10-11 Math Concepts
    quad_concept = Concept(
        id=uuid.UUID("c1111111-1111-1111-1111-111111111111"),
        topic_category="Quadratic Equations",
        code="MATH-G10-QUAD-01",
        title="Solving Quadratic Equations by Factorization",
        prerequisite_concept_ids=[],
        grade_level=10
    )
    
    perim_concept = Concept(
        id=uuid.UUID("c2222222-2222-2222-2222-222222222222"),
        topic_category="Perimeter and Area of Plane Figures",
        code="MATH-G10-PERIM-01",
        title="Calculating Area and Perimeter of Composite Shapes",
        prerequisite_concept_ids=[],
        grade_level=10
    )
    
    indices_concept = Concept(
        id=uuid.UUID("c3333333-3333-3333-3333-333333333333"),
        topic_category="Indices and Logarithms",
        code="MATH-G11-IND-01",
        title="Laws of Indices and Exponential Functions",
        prerequisite_concept_ids=[],
        grade_level=11
    )
    
    db.add_all([quad_concept, perim_concept, indices_concept])
    db.commit()

    # 2. Create Canonical Math Question
    quad_question = Question(
        id=uuid.UUID("22222222-2222-2222-2222-222222222222"),
        concept_id=quad_concept.id,
        difficulty_level=0.5,
        question_text="Solve for x: x^2 + 5x + 6 = 0",
        reference_solution={
            "steps": [
                "1. Identify a=1, b=5, c=6",
                "2. Find two numbers that multiply to 6 and add to 5: (2 and 3)",
                "3. Factor expression: (x + 2)(x + 3) = 0",
                "4. Solve linear factors: x + 2 = 0 => x = -2; x + 3 = 0 => x = -3"
            ],
            "final_answer": "x = -2 or x = -3"
        }
    )
    db.add(quad_question)
    db.commit()

    # 3. Create Multi-Modal Representations (Component 1)
    rep_step = Representation(
        id=uuid.UUID("44444444-4444-4444-4444-444444444444"),
        concept_id=quad_concept.id,
        format_type="STEP_BY_STEP",
        content_payload={
            "title": "Solving Quadratic Equations by Factorization",
            "steps": [
                "Step 1: Set equation to standard form ax^2 + bx + c = 0",
                "Step 2: Factorize quadratic into (x - p)(x - q) = 0",
                "Step 3: Equate each factor to zero to find roots"
            ]
        },
        complexity_level=0.4
    )
    
    rep_diagram = Representation(
        id=uuid.UUID("55555555-5555-5555-5555-555555555555"),
        concept_id=quad_concept.id,
        format_type="DIAGRAM",
        content_payload={
            "title": "Geometric Parabola Intersect Diagram",
            "diagram_type": "PARABOLA_ROOTS",
            "x_intercepts": [-2, -3]
        },
        complexity_level=0.6
    )
    db.add_all([rep_step, rep_diagram])
    db.commit()

    # 4. Create Demo Student Account
    hashed_pwd = bcrypt.hashpw(b"password123", bcrypt.gensalt()).decode("utf-8")
    demo_student = Student(
        id=uuid.UUID("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"),
        anonymized_student_code="STU_HASH_DEMO_01",
        email="student@example.lk",
        hashed_password=hashed_pwd,
        grade_level=10
    )
    db.add(demo_student)
    db.commit()

    # 5. Create Learner Profile (Component 2) & Engagement (Component 3)
    profile = LearnerProfile(
        student_id=demo_student.id,
        concept_id=quad_concept.id,
        mastery_probability=0.42,
        forgetting_factor=0.95
    )
    
    engagement = StudentEngagement(
        student_id=demo_student.id,
        current_streak_days=4,
        total_points=240,
        virtual_pet_health=95,
        virtual_pet_level=2
    )
    db.add_all([profile, engagement])
    db.commit()


if __name__ == "__main__":
    Base.metadata.create_all(bind=engine)
    session = SessionLocal()
    try:
        seed_database(session)
        print("Database seed completed successfully.")
    finally:
        session.close()
