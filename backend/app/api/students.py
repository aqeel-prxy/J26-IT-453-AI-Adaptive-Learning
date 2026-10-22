from datetime import datetime, timezone
from uuid import UUID, uuid4
from fastapi import APIRouter
from app.schemas.student import (
    StudentResponse,
    StudentProfileResponse,
    StudentProfileUpdateRequest,
)

router = APIRouter(prefix="/students", tags=["Students"])

# In-memory student profile state for development/testing
_STUDENT_PROFILE_STATE = {
    "student_id": UUID("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"),
    "anonymized_code": "STU_HASH_9A4F21",
    "full_name": "Kavindu Dharmasena",
    "email": "kavindu.dharmasena@example.lk",
    "grade_level": 10,
    "school": "Central College, Kandy",
    "district": "Central Province",
    "avatar_id": "fox_math",
    "custom_avatar_url": None,
    "motivational_archetype": "Achiever",
    "preferred_goal": "TERM_TEST",
    "created_at": datetime.now(timezone.utc),
}


@router.get("/me", response_model=StudentResponse)
def get_current_student():
    """Get current student profile stub"""
    return StudentResponse(
        student_id=_STUDENT_PROFILE_STATE["student_id"],
        anonymized_code=_STUDENT_PROFILE_STATE["anonymized_code"],
        email=_STUDENT_PROFILE_STATE["email"],
        grade_level=_STUDENT_PROFILE_STATE["grade_level"],
        created_at=_STUDENT_PROFILE_STATE["created_at"],
    )


@router.get("/profile", response_model=StudentProfileResponse)
@router.get("/profile/{student_id}", response_model=StudentProfileResponse)
def get_student_profile(student_id: UUID = None):
    """Get rich student profile with editable details and motivational archetype"""
    return StudentProfileResponse(**_STUDENT_PROFILE_STATE)


@router.post("/profile", response_model=StudentProfileResponse)
@router.put("/profile", response_model=StudentProfileResponse)
def update_student_profile(payload: StudentProfileUpdateRequest):
    """Update student profile details and avatar"""
    if payload.full_name is not None:
        _STUDENT_PROFILE_STATE["full_name"] = payload.full_name
    if payload.email is not None:
        _STUDENT_PROFILE_STATE["email"] = payload.email
    if payload.grade_level is not None:
        _STUDENT_PROFILE_STATE["grade_level"] = payload.grade_level
    if payload.school is not None:
        _STUDENT_PROFILE_STATE["school"] = payload.school
    if payload.district is not None:
        _STUDENT_PROFILE_STATE["district"] = payload.district
    if payload.avatar_id is not None:
        _STUDENT_PROFILE_STATE["avatar_id"] = payload.avatar_id
    if payload.custom_avatar_url is not None:
        _STUDENT_PROFILE_STATE["custom_avatar_url"] = payload.custom_avatar_url
    if payload.motivational_archetype is not None:
        _STUDENT_PROFILE_STATE["motivational_archetype"] = payload.motivational_archetype
    if payload.preferred_goal is not None:
        _STUDENT_PROFILE_STATE["preferred_goal"] = payload.preferred_goal

    return StudentProfileResponse(**_STUDENT_PROFILE_STATE)
