from uuid import UUID, uuid4
from fastapi import APIRouter, HTTPException, status
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse
from app.api.students import _STUDENT_PROFILE_STATE

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Fixed demo student UUID — matches seed data in seed.py
DEMO_STUDENT_ID = "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"


@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest):
    """Development Authentication & Sign In Endpoint"""
    if not request.email or not request.password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email and password are required."
        )

    if request.email == "student@example.lk":
        student_id = DEMO_STUDENT_ID
        full_name = _STUDENT_PROFILE_STATE.get("full_name") or "Aqeel M.I.M"
        grade_level = 11
        preferred_goal = "TERM_TEST"
    elif "10" in request.email.lower() or "quad" in request.email.lower():
        student_id = DEMO_STUDENT_ID
        full_name = "Kasun Perera"
        grade_level = 10
        preferred_goal = "COMPREHENSIVE"
    else:
        student_id = str(_STUDENT_PROFILE_STATE.get("student_id") or uuid4())
        full_name = _STUDENT_PROFILE_STATE.get("full_name") or request.email.split("@")[0].replace(".", " ").title()
        grade_level = _STUDENT_PROFILE_STATE.get("grade_level", 11)
        preferred_goal = _STUDENT_PROFILE_STATE.get("preferred_goal", "TERM_TEST")

    anonymized_code = f"STU_HASH_{student_id[:8].upper()}"

    # Sync profile state so all other APIs return matched data
    _STUDENT_PROFILE_STATE["student_id"] = UUID(student_id)
    _STUDENT_PROFILE_STATE["anonymized_code"] = anonymized_code
    _STUDENT_PROFILE_STATE["full_name"] = full_name
    _STUDENT_PROFILE_STATE["email"] = request.email
    _STUDENT_PROFILE_STATE["grade_level"] = grade_level
    _STUDENT_PROFILE_STATE["preferred_goal"] = preferred_goal

    return TokenResponse(
        access_token=f"dev_token_{student_id}",
        token_type="bearer",
        student_id=student_id,
        anonymized_code=anonymized_code,
        full_name=full_name,
        email=request.email,
        grade_level=grade_level,
        preferred_goal=preferred_goal,
        avatar_id=_STUDENT_PROFILE_STATE.get("avatar_id", "fox_math"),
        school=_STUDENT_PROFILE_STATE.get("school", "Central College, Kandy"),
        district=_STUDENT_PROFILE_STATE.get("district", "Central Province")
    )


@router.post("/register", response_model=TokenResponse)
def register(request: RegisterRequest):
    """Student Registration & Account Creation Endpoint"""
    if not request.email or not request.password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email and password are required."
        )

    student_id = str(uuid4())
    anonymized_code = f"STU_HASH_{student_id[:8].upper()}"

    # Save to profile state
    _STUDENT_PROFILE_STATE["student_id"] = UUID(student_id)
    _STUDENT_PROFILE_STATE["anonymized_code"] = anonymized_code
    _STUDENT_PROFILE_STATE["full_name"] = request.full_name
    _STUDENT_PROFILE_STATE["email"] = request.email
    _STUDENT_PROFILE_STATE["grade_level"] = request.grade_level
    _STUDENT_PROFILE_STATE["school"] = request.school
    _STUDENT_PROFILE_STATE["district"] = request.district
    _STUDENT_PROFILE_STATE["avatar_id"] = request.avatar_id
    _STUDENT_PROFILE_STATE["preferred_goal"] = request.preferred_goal

    return TokenResponse(
        access_token=f"dev_token_{student_id}",
        token_type="bearer",
        student_id=student_id,
        anonymized_code=anonymized_code,
        full_name=request.full_name,
        email=request.email,
        grade_level=request.grade_level,
        preferred_goal=request.preferred_goal,
        avatar_id=request.avatar_id,
        school=request.school,
        district=request.district
    )
