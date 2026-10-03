from datetime import datetime, timezone
from uuid import uuid4
from fastapi import APIRouter
from app.schemas.student import StudentResponse

router = APIRouter(prefix="/students", tags=["Students"])


@router.get("/me", response_model=StudentResponse)
def get_current_student():
    """Get current student profile stub"""
    student_id = uuid4()
    return StudentResponse(
        student_id=student_id,
        anonymized_code=f"STU_HASH_{str(student_id)[:8].upper()}",
        email="student@example.lk",
        grade_level=10,
        created_at=datetime.now(timezone.utc)
    )
