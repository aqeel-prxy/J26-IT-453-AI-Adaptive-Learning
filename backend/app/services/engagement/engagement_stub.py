"""
============================================================
Component 3: AI-Assisted Engagement, Gamification & Feedback Adaptation
Owner: Dharmasena K.C.D (IT23320628)
============================================================
Backward-compatibility wrapper pointing to the trained ML EngagementService.
"""
from app.services.engagement.engagement_service import EngagementService

# Aliased for backward compatibility across existing endpoints and tests
EngagementStub = EngagementService
