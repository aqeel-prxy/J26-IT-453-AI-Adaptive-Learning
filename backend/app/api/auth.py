from uuid import uuid4
from fastapi import APIRouter, HTTPException, status
from app.schemas.auth import LoginRequest, TokenResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest):
    """Development Authentication Endpoint"""
    if not request.email or not request.password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email and password are required."
        )
    
    # Development authentication stub
    student_id = str(uuid4())
    anonymized_code = f"STU_HASH_{student_id[:8].upper()}"
    
    return TokenResponse(
        access_token=f"dev_token_{student_id}",
        token_type="bearer",
        student_id=student_id,
        anonymized_code=anonymized_code
    )
