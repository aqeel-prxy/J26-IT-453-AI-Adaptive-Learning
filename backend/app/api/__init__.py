from fastapi import APIRouter
from app.api.auth import router as auth_router
from app.api.students import router as students_router
from app.api.mathematics import router as mathematics_router
from app.api.learner import router as learner_router
from app.api.representation import router as representation_router
from app.api.errors import router as errors_router
from app.api.engagement import router as engagement_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(students_router)
api_router.include_router(mathematics_router)
api_router.include_router(learner_router)
api_router.include_router(representation_router)
api_router.include_router(errors_router)
api_router.include_router(engagement_router)
