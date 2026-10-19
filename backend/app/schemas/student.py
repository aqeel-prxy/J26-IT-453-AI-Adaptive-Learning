from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, EmailStr, ConfigDict


class StudentResponse(BaseModel):
    student_id: UUID
    anonymized_code: str
    email: EmailStr
    grade_level: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
