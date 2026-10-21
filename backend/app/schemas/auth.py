from typing import Optional
from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    grade_level: int = 11
    school: str = "Central College, Kandy"
    district: str = "Central Province"
    preferred_goal: str = "TERM_TEST"
    avatar_id: str = "fox_math"


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    student_id: str
    anonymized_code: str
    full_name: Optional[str] = None
    email: Optional[str] = None
    grade_level: Optional[int] = 11
    preferred_goal: Optional[str] = "TERM_TEST"
    avatar_id: Optional[str] = "fox_math"
    school: Optional[str] = None
    district: Optional[str] = None
