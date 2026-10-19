from uuid import UUID
from fastapi import APIRouter
from app.schemas.engagement import EngagementDashboardResponse, VirtualPetStatus
from app.services.engagement.engagement_stub import EngagementStub

router = APIRouter(prefix="/engagement", tags=["Engagement (Component 3)"])


@router.get("/dashboard/{student_id}", response_model=EngagementDashboardResponse)
def get_engagement_dashboard(student_id: UUID):
    """Get engagement, streak, and virtual pet status from Component 3 development stub"""
    data = EngagementStub.get_dashboard_data(student_id)
    return EngagementDashboardResponse(
        student_id=student_id,
        current_streak_days=data["current_streak_days"],
        total_points=data["total_points"],
        virtual_pet=VirtualPetStatus(
            level=data["virtual_pet"]["level"],
            health=data["virtual_pet"]["health"],
            pet_name=data["virtual_pet"]["pet_name"]
        )
    )
