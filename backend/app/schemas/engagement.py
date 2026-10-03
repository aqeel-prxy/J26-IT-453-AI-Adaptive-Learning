from uuid import UUID
from pydantic import BaseModel


class VirtualPetStatus(BaseModel):
    level: int = 1
    health: int = 100
    pet_name: str = "MathPaws"


class EngagementDashboardResponse(BaseModel):
    student_id: UUID
    current_streak_days: int
    total_points: int
    virtual_pet: VirtualPetStatus
