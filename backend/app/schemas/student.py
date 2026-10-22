from datetime import datetime, timezone
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, EmailStr, ConfigDict


class StudentResponse(BaseModel):
    student_id: UUID
    anonymized_code: str
    email: EmailStr
    grade_level: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class StudentProfileUpdateRequest(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    grade_level: Optional[int] = None
    school: Optional[str] = None
    district: Optional[str] = None
    avatar_id: Optional[str] = None
    custom_avatar_url: Optional[str] = None
    motivational_archetype: Optional[str] = None
    preferred_goal: Optional[str] = None


class StudentProfileResponse(BaseModel):
    student_id: UUID
    anonymized_code: str
    full_name: str
    email: str
    grade_level: int
    school: str
    district: str
    avatar_id: str
    custom_avatar_url: Optional[str] = None
    motivational_archetype: str
    preferred_goal: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
