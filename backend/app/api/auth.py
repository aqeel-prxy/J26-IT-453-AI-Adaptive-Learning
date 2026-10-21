import uuid
from typing import Generator
import bcrypt
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.student import Student
from app.schemas.auth import GoogleAuthRequest, LoginRequest, RegisterRequest, TokenResponse
from app.api.students import _STUDENT_PROFILE_STATE

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Fixed demo student UUID — matches seed data in seed.py
DEMO_STUDENT_ID = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"


def _sync_profile_state(student: Student):
    """Synchronize backend in-memory profile state with student database record."""
    _STUDENT_PROFILE_STATE["student_id"] = student.id
    _STUDENT_PROFILE_STATE["anonymized_code"] = student.anonymized_student_code
    if student.full_name and student.full_name != "Student":
        _STUDENT_PROFILE_STATE["full_name"] = student.full_name
    elif student.email == "student@example.lk":
        _STUDENT_PROFILE_STATE["full_name"] = "Kavindu Dharmasena"
    _STUDENT_PROFILE_STATE["email"] = student.email
    _STUDENT_PROFILE_STATE["grade_level"] = student.grade_level
    _STUDENT_PROFILE_STATE["school"] = student.school or "Central College, Kandy"
    _STUDENT_PROFILE_STATE["district"] = student.district or "Central Province"
    _STUDENT_PROFILE_STATE["avatar_id"] = student.avatar_id or "fox_math"
    _STUDENT_PROFILE_STATE["preferred_goal"] = student.preferred_goal or "TERM_TEST"


@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    """Database-backed Student Sign In Endpoint"""
    if not request.email or not request.password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email and password are required."
        )

    # 1. Look up student in SQLite database by email
    student = db.query(Student).filter(Student.email == request.email).first()

    if student:
        # Check password with bcrypt (or allow dev standard 'password123')
        valid_password = False
        try:
            valid_password = bcrypt.checkpw(request.password.encode("utf-8"), student.hashed_password.encode("utf-8"))
        except Exception:
            valid_password = (student.hashed_password == request.password)

        if not valid_password and request.password != "password123":
            # In development test environments, allow password123 or valid bcrypt hash
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password."
            )
    else:
        # Auto-provision or seed demo accounts in DB if not found
        is_g10 = "10" in request.email.lower() or "quad" in request.email.lower()
        if request.email == "student@example.lk":
            new_id = uuid.UUID(DEMO_STUDENT_ID)
            full_name = _STUDENT_PROFILE_STATE.get("full_name") or "Aqeel M.I.M"
            grade_level = 11
            preferred_goal = "TERM_TEST"
            avatar_id = "fox_math"
        elif is_g10:
            new_id = uuid.uuid4()
            full_name = "Kasun Perera"
            grade_level = 10
            preferred_goal = "COMPREHENSIVE"
            avatar_id = "owl_scholar"
        else:
            new_id = uuid.uuid4()
            full_name = request.email.split("@")[0].replace(".", " ").title()
            grade_level = 11
            preferred_goal = "TERM_TEST"
            avatar_id = "fox_math"

        anonymized_code = f"STU_HASH_{str(new_id)[:8].upper()}"
        hashed_pwd = bcrypt.hashpw(request.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

        student = Student(
            id=new_id,
            anonymized_student_code=anonymized_code,
            email=request.email,
            hashed_password=hashed_pwd,
            grade_level=grade_level,
            full_name=full_name,
            school="Central College, Kandy",
            district="Central Province",
            avatar_id=avatar_id,
            preferred_goal=preferred_goal,
            auth_provider="email"
        )
        db.add(student)
        db.commit()
        db.refresh(student)

    # 2. Synchronize in-memory profile state for Component 3 compatibility
    _sync_profile_state(student)

    return TokenResponse(
        access_token=f"token_{student.id}",
        token_type="bearer",
        student_id=str(student.id),
        anonymized_code=student.anonymized_student_code,
        full_name=student.full_name,
        email=student.email,
        grade_level=student.grade_level,
        preferred_goal=student.preferred_goal,
        avatar_id=student.avatar_id,
        school=student.school,
        district=student.district,
        auth_provider=student.auth_provider or "email"
    )


@router.post("/register", response_model=TokenResponse)
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    """Database-backed Student Registration & Account Creation Endpoint"""
    if not request.email or not request.password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email and password are required."
        )

    # 1. Check if student already exists in database
    student = db.query(Student).filter(Student.email == request.email).first()

    hashed_pwd = bcrypt.hashpw(request.password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    if student:
        # Update existing student's profile & password
        student.full_name = request.full_name
        student.hashed_password = hashed_pwd
        student.grade_level = request.grade_level
        student.school = request.school
        student.district = request.district
        student.avatar_id = request.avatar_id
        student.preferred_goal = request.preferred_goal
        student.auth_provider = "email"
        db.commit()
        db.refresh(student)
    else:
        # Create new student in SQLite database
        new_id = uuid.uuid4()
        anonymized_code = f"STU_HASH_{str(new_id)[:8].upper()}"

        student = Student(
            id=new_id,
            anonymized_student_code=anonymized_code,
            email=request.email,
            hashed_password=hashed_pwd,
            grade_level=request.grade_level,
            full_name=request.full_name,
            school=request.school,
            district=request.district,
            avatar_id=request.avatar_id,
            preferred_goal=request.preferred_goal,
            auth_provider="email"
        )
        db.add(student)
        db.commit()
        db.refresh(student)

    # 2. Synchronize in-memory profile state for Component 3 compatibility
    _sync_profile_state(student)

    return TokenResponse(
        access_token=f"token_{student.id}",
        token_type="bearer",
        student_id=str(student.id),
        anonymized_code=student.anonymized_student_code,
        full_name=student.full_name,
        email=student.email,
        grade_level=student.grade_level,
        preferred_goal=student.preferred_goal,
        avatar_id=student.avatar_id,
        school=student.school,
        district=student.district,
        auth_provider="email"
    )


@router.post("/google", response_model=TokenResponse)
def google_auth(request: GoogleAuthRequest, db: Session = Depends(get_db)):
    """Google OAuth Sign In / Sign Up Endpoint"""
    if not request.email or not request.google_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Google ID and email are required."
        )

    # 1. Search database by email or google_id
    student = db.query(Student).filter(
        or_(Student.email == request.email, Student.google_id == request.google_id)
    ).first()

    if student:
        # Link google_id if not present
        student.google_id = request.google_id
        student.auth_provider = "google"
        if request.full_name and (not student.full_name or student.full_name == "Student"):
            student.full_name = request.full_name
        db.commit()
        db.refresh(student)
    else:
        # Create new Student provisioned via Google
        new_id = uuid.uuid4()
        anonymized_code = f"STU_HASH_{str(new_id)[:8].upper()}"

        student = Student(
            id=new_id,
            anonymized_student_code=anonymized_code,
            email=request.email,
            hashed_password="GOOGLE_OAUTH_SSO_USER",
            grade_level=request.grade_level or 11,
            full_name=request.full_name,
            school=request.school or "Central College, Kandy",
            district=request.district or "Central Province",
            avatar_id=request.avatar_id or "fox_math",
            preferred_goal=request.preferred_goal or "TERM_TEST",
            auth_provider="google",
            google_id=request.google_id
        )
        db.add(student)
        db.commit()
        db.refresh(student)

    # 2. Synchronize in-memory profile state
    _sync_profile_state(student)

    return TokenResponse(
        access_token=f"google_token_{student.id}",
        token_type="bearer",
        student_id=str(student.id),
        anonymized_code=student.anonymized_student_code,
        full_name=student.full_name,
        email=student.email,
        grade_level=student.grade_level,
        preferred_goal=student.preferred_goal,
        avatar_id=student.avatar_id,
        school=student.school,
        district=student.district,
        auth_provider="google"
    )
